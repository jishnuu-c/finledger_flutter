import 'package:dio/dio.dart';
import 'endpoints.dart';
import '../services/token_service.dart';
import '../services/loading_service.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/refresh_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/loading_interceptor.dart';

class DioClient {
  late final Dio dio;
  final TokenService tokenService;
  final LoadingService loadingService;
  final String baseUrl;
  final void Function()? onLogoutRequired;
  final OnApiErrorCallback? onApiError;

  DioClient({
    required this.tokenService,
    required this.loadingService,
    this.baseUrl = Endpoints.defaultBaseUrl,
    this.onLogoutRequired,
    this.onApiError,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    dio = Dio(baseOptions);

    // 1. Loading Interceptor (Outermost for network tracking)
    dio.interceptors.add(LoadingInterceptor(loadingService: loadingService));

    // 2. Auth Interceptor (Injects Bearer token)
    dio.interceptors.add(AuthInterceptor(tokenService: tokenService));

    // 3. Refresh Interceptor (Handles 401 unauthorized & queue replay)
    dio.interceptors.add(
      RefreshInterceptor(
        dio: dio,
        tokenService: tokenService,
        onLogoutRequired: onLogoutRequired,
      ),
    );

    // 4. Error Interceptor (Parses ApiError response JSON {timestamp, status, code, message, fieldErrors})
    dio.interceptors.add(ErrorInterceptor(onApiError: onApiError));
  }
}
