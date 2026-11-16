import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/services/token_service.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/api_error.dart';

class AuthResult {
  final bool success;
  final String? message;
  final bool isLockedOut;
  final int? remainingLockoutSeconds;

  const AuthResult({
    required this.success,
    this.message,
    this.isLockedOut = false,
    this.remainingLockoutSeconds,
  });
}

class AuthService {
  final DioClient dioClient;
  final TokenService tokenService;

  static const String _keyFailedAttempts = 'fl_login_failed_attempts';
  static const String _keyLockoutUntil = 'fl_login_lockout_until';
  static const String _keyRememberedEmail = 'fl_remembered_email';
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  AuthService({
    required this.dioClient,
    required this.tokenService,
  });

  /// Check whether the account is currently locked out
  Future<int?> getRemainingLockoutSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutMillis = prefs.getInt(_keyLockoutUntil);
    if (lockoutMillis == null) return null;

    final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutMillis);
    final now = DateTime.now();
    if (now.isBefore(lockoutUntil)) {
      return lockoutUntil.difference(now).inSeconds;
    } else {
      // Lockout expired, reset failed attempts
      await resetFailedAttempts();
      return null;
    }
  }

  /// Get saved email if 'Remember me' was checked
  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRememberedEmail);
  }

  /// Reset failed attempt counters upon successful login
  Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFailedAttempts);
    await prefs.remove(_keyLockoutUntil);
  }

  /// Record a failed login attempt and check for 5-attempt lockout threshold
  Future<AuthResult> recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    int attempts = (prefs.getInt(_keyFailedAttempts) ?? 0) + 1;
    await prefs.setInt(_keyFailedAttempts, attempts);

    if (attempts >= maxFailedAttempts) {
      final lockoutUntil = DateTime.now().add(lockoutDuration);
      await prefs.setInt(_keyLockoutUntil, lockoutUntil.millisecondsSinceEpoch);
      return AuthResult(
        success: false,
        isLockedOut: true,
        remainingLockoutSeconds: lockoutDuration.inSeconds,
        message:
            'Account temporarily locked after $maxFailedAttempts failed attempts. Please contact your administrator or try again in 15 minutes.',
      );
    }

    final remaining = maxFailedAttempts - attempts;
    return AuthResult(
      success: false,
      isLockedOut: false,
      message: 'Invalid email or password. $remaining attempt${remaining == 1 ? '' : 's'} remaining before lockout.',
    );
  }

  /// Execute POST /api/v1/auth/login and enrich with /api/v1/auth/me
  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    // 1. Check if user is locked out
    final remainingLockout = await getRemainingLockoutSeconds();
    if (remainingLockout != null && remainingLockout > 0) {
      final minutes = (remainingLockout / 60).ceil();
      return AuthResult(
        success: false,
        isLockedOut: true,
        remainingLockoutSeconds: remainingLockout,
        message: 'Account temporarily locked. Please try again in $minutes minute${minutes == 1 ? '' : 's'}.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final cleanEmail = email.trim();
    if (rememberMe) {
      await prefs.setString(_keyRememberedEmail, cleanEmail);
    } else {
      await prefs.remove(_keyRememberedEmail);
    }

    try {
      debugPrint('[AuthService] POST ${Endpoints.login} to ${dioClient.dio.options.baseUrl} for $cleanEmail');

      // 2. Call POST /api/v1/auth/login
      final response = await dioClient.dio.post(
        Endpoints.login,
        data: {
          'email': cleanEmail,
          'password': password,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          extra: {'silent': true},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String? ?? '';

        if (accessToken.isEmpty) {
          return const AuthResult(
            success: false,
            message: 'Server response did not contain an access token.',
          );
        }

        // Direct parse from AuthResponse (contains user and permissions)
        UserProfile userProfile;
        try {
          userProfile = UserProfile.fromJson(data);
        } catch (e) {
          debugPrint('[AuthService] Error parsing AuthResponse: $e');
          userProfile = UserProfile.defaultMock();
        }

        // 3. Enrich with GET /api/v1/auth/me to fetch company legal profile
        try {
          final meResponse = await dioClient.dio.get(
            Endpoints.me,
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Accept': 'application/json',
              },
              extra: {'silent': true},
            ),
          );
          if (meResponse.statusCode == 200 && meResponse.data is Map<String, dynamic>) {
            final meProfile = UserProfile.fromJson(meResponse.data as Map<String, dynamic>);
            userProfile = meProfile;
          }
        } catch (meErr) {
          debugPrint('[AuthService] /auth/me call skipped/failed: $meErr');
        }

        await tokenService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: userProfile,
        );

        await resetFailedAttempts();
        return const AuthResult(success: true);
      } else {
        return await recordFailedAttempt();
      }
    } on DioException catch (dioErr) {
      debugPrint('[AuthService] DioException: type=${dioErr.type}, statusCode=${dioErr.response?.statusCode}, message=${dioErr.message}');

      // Connectivity & Timeout Errors (Do NOT count as failed password attempts)
      if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.sendTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout) {
        return const AuthResult(
          success: false,
          message: 'Connection timed out. Unable to reach FinLedger backend at 192.168.1.201:8080.',
        );
      }

      if (dioErr.type == DioExceptionType.connectionError) {
        return const AuthResult(
          success: false,
          message: 'Cannot reach server at 192.168.1.201:8080. Ensure the backend is running and your device is on the same local network.',
        );
      }

      // Backend HTTP response errors
      final res = dioErr.response;
      if (res != null) {
        final dynamic resData = res.data;
        String? backendCode;
        String? backendMessage;

        if (resData is Map<String, dynamic>) {
          backendCode = resData['code']?.toString();
          backendMessage = resData['message']?.toString();
        }

        if (res.statusCode == 422) {
          if (backendCode == 'ACCOUNT_LOCKED') {
            return AuthResult(
              success: false,
              isLockedOut: true,
              remainingLockoutSeconds: lockoutDuration.inSeconds,
              message: backendMessage ?? 'Account is locked due to 5 consecutive failed attempts.',
            );
          } else if (backendCode == 'ACCOUNT_DISABLED') {
            return AuthResult(
              success: false,
              message: backendMessage ?? 'Account is disabled. Please contact your administrator.',
            );
          } else if (backendCode == 'INVALID_CREDENTIALS') {
            return await recordFailedAttempt();
          } else {
            return AuthResult(
              success: false,
              message: backendMessage ?? 'Unprocessable entity.',
            );
          }
        }

        if (res.statusCode == 401) {
          return await recordFailedAttempt();
        }

        if (res.statusCode == 400) {
          return AuthResult(
            success: false,
            message: backendMessage ?? 'Invalid request format.',
          );
        }

        if (backendMessage != null && backendMessage.isNotEmpty) {
          return AuthResult(success: false, message: backendMessage);
        }
      }

      if (dioErr.error is ApiError) {
        final apiError = dioErr.error as ApiError;
        if (apiError.code == 'ACCOUNT_LOCKED') {
          return AuthResult(
            success: false,
            isLockedOut: true,
            remainingLockoutSeconds: lockoutDuration.inSeconds,
            message: apiError.message,
          );
        }
        if (apiError.code == 'INVALID_CREDENTIALS' || apiError.status == 401) {
          return await recordFailedAttempt();
        }
        return AuthResult(success: false, message: apiError.message);
      }

      return AuthResult(
        success: false,
        message: dioErr.message ?? 'An unexpected network error occurred.',
      );
    } catch (e, stack) {
      debugPrint('[AuthService] Unexpected error: $e\n$stack');
      return AuthResult(
        success: false,
        message: 'An unexpected application error occurred: $e',
      );
    }
  }

  /// Call POST /api/v1/auth/logout
  Future<void> logout() async {
    try {
      await dioClient.dio.post(
        Endpoints.logout,
        options: Options(extra: {'silent': true}),
      );
    } catch (_) {}
    await tokenService.clearTokens();
  }
}
