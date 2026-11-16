import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/services/token_service.dart';
import '../../../../shared/models/user_profile.dart';
import '../../data/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;
  final bool isLockedOut;
  final int? remainingLockoutSeconds;
  final String? savedEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLockedOut = false,
    this.remainingLockoutSeconds,
    this.savedEmail,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorMessage,
    bool? isLockedOut,
    int? remainingLockoutSeconds,
    String? savedEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLockedOut: isLockedOut ?? this.isLockedOut,
      remainingLockoutSeconds: remainingLockoutSeconds ?? this.remainingLockoutSeconds,
      savedEmail: savedEmail ?? this.savedEmail,
    );
  }
}

// Low-level dependencies provided via ProviderScope overrides in main.dart
final tokenServiceProvider = Provider<TokenService>((ref) {
  throw UnimplementedError('tokenServiceProvider must be overridden in ProviderScope');
});

final dioClientProvider = Provider<DioClient>((ref) {
  throw UnimplementedError('dioClientProvider must be overridden in ProviderScope');
});

final authRepositoryProvider = Provider<AuthService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  return AuthService(dioClient: dioClient, tokenService: tokenService);
});

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;
  late final TokenService _tokenService;

  @override
  AuthState build() {
    _authService = ref.watch(authRepositoryProvider);
    _tokenService = ref.watch(tokenServiceProvider);

    _initSession();

    return AuthState(
      status: _tokenService.isAuthenticated
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      user: _tokenService.currentUser,
    );
  }

  Future<void> _initSession() async {
    final remainingLockout = await _authService.getRemainingLockoutSeconds();
    final savedEmail = await _authService.getRememberedEmail();

    if (!ref.mounted) return;

    if (remainingLockout != null && remainingLockout > 0) {
      final minutes = (remainingLockout / 60).ceil();
      state = state.copyWith(
        isLockedOut: true,
        remainingLockoutSeconds: remainingLockout,
        savedEmail: savedEmail,
        errorMessage:
            'Account temporarily locked after 5 failed attempts. Please wait $minutes minute${minutes == 1 ? '' : 's'}.',
      );
    } else {
      state = state.copyWith(
        isLockedOut: false,
        remainingLockoutSeconds: null,
        savedEmail: savedEmail,
      );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    if (state.isLockedOut) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    debugPrint('[AuthNotifier] Attempting real API login for $email...');

    try {
      final result = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (!ref.mounted) return result.success;

      if (result.success) {
        debugPrint('[AuthNotifier] Login successful for $email');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: _tokenService.currentUser,
          errorMessage: null,
          isLockedOut: false,
          remainingLockoutSeconds: null,
        );
        return true;
      } else {
        debugPrint('[AuthNotifier] Login failed: ${result.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message ?? 'Authentication failed.',
          isLockedOut: result.isLockedOut,
          remainingLockoutSeconds: result.remainingLockoutSeconds,
        );
        return false;
      }
    } catch (e, stack) {
      debugPrint('[AuthNotifier] Unexpected error during login: $e\n$stack');
      if (!ref.mounted) return false;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred: $e',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
