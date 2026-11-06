import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../services/token_service.dart';
import '../api/endpoints.dart';

class RefreshInterceptor extends QueuedInterceptor {
  final Dio dio;
  final TokenService tokenService;
  final VoidCallback? onLogoutRequired;

  Completer<String?>? _refreshCompleter;

  RefreshInterceptor({
    required this.dio,
    required this.tokenService,
    this.onLogoutRequired,
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final statusCode = response?.statusCode;
    final requestOptions = err.requestOptions;

    // Check if this error is an unauthenticated 401
    final is401 = statusCode == 401;
    final isAuthEndpoint = requestOptions.path.contains(Endpoints.login) ||
        requestOptions.path.contains(Endpoints.refresh);

    if (is401 && !isAuthEndpoint) {
      final currentRefreshToken = tokenService.refreshToken;
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        await _handleLogout();
        return handler.next(err);
      }

      // Synchronize concurrent refresh attempts
      if (_refreshCompleter != null) {
        try {
          final newAccessToken = await _refreshCompleter!.future;
          if (newAccessToken != null) {
            final retryResponse = await _retryRequest(requestOptions, newAccessToken);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          return handler.next(err);
        }
      }

      _refreshCompleter = Completer<String?>();

      try {
        // Execute token refresh using a clean independent dio call
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: dio.options.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        );

        final refreshResponse = await refreshDio.post(
          Endpoints.refresh,
          data: {'refreshToken': currentRefreshToken},
        );

        if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
          final data = refreshResponse.data as Map<String, dynamic>;
          final newAccessToken = data['accessToken'] as String?;
          final newRefreshToken = data['refreshToken'] as String? ?? currentRefreshToken;

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            await tokenService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            _refreshCompleter!.complete(newAccessToken);
            _refreshCompleter = null;

            // Retry the original failed request
            final retryResponse = await _retryRequest(requestOptions, newAccessToken);
            return handler.resolve(retryResponse);
          }
        }

        throw Exception('Invalid refresh token response');
      } catch (refreshErr) {
        _refreshCompleter?.complete(null);
        _refreshCompleter = null;
        await _handleLogout();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions, String newAccessToken) {
    final options = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers)
        ..['Authorization'] = 'Bearer $newAccessToken',
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _handleLogout() async {
    await tokenService.clearTokens();
    onLogoutRequired?.call();
  }
}
