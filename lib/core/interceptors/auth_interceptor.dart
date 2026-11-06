import 'package:dio/dio.dart';
import '../services/token_service.dart';
import '../api/endpoints.dart';

class AuthInterceptor extends Interceptor {
  final TokenService tokenService;

  AuthInterceptor({required this.tokenService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Exclude public authentication endpoints from Bearer token
    final path = options.path;
    final isAuthEndpoint = path.contains(Endpoints.login) || path.contains(Endpoints.refresh);

    if (!isAuthEndpoint) {
      final token = tokenService.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Default request headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }
}
