import 'package:dio/dio.dart';
import '../../shared/models/api_error.dart';

typedef OnApiErrorCallback = void Function(ApiError error);

class ErrorInterceptor extends Interceptor {
  final OnApiErrorCallback? onApiError;

  ErrorInterceptor({this.onApiError});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiError apiError;

    if (err.response != null && err.response?.data != null) {
      final dynamic data = err.response!.data;
      if (data is Map<String, dynamic>) {
        apiError = ApiError.fromJson(data, fallbackStatus: err.response?.statusCode);
      } else {
        apiError = ApiError(
          status: err.response?.statusCode ?? 500,
          code: 'HTTP_ERROR',
          message: data?.toString() ?? err.message ?? 'Server error',
          path: err.requestOptions.path,
        );
      }
    } else {
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          apiError = ApiError(
            status: 408,
            code: 'TIMEOUT',
            message: 'Connection timed out. Please verify your network.',
            path: err.requestOptions.path,
          );
          break;
        case DioExceptionType.connectionError:
          apiError = ApiError(
            status: 503,
            code: 'NETWORK_ERROR',
            message: 'Unable to reach the FinLedger server. Check your connection.',
            path: err.requestOptions.path,
          );
          break;
        case DioExceptionType.cancel:
          apiError = ApiError(
            status: 499,
            code: 'REQUEST_CANCELLED',
            message: 'Request was cancelled.',
            path: err.requestOptions.path,
          );
          break;
        default:
          apiError = ApiError(
            status: 500,
            code: 'UNKNOWN_ERROR',
            message: err.message ?? 'An unexpected error occurred.',
            path: err.requestOptions.path,
          );
      }
    }

    onApiError?.call(apiError);

    // Propagate DioException with custom ApiError as error payload
    final customException = err.copyWith(
      error: apiError,
      message: apiError.displayMessage,
    );

    return handler.next(customException);
  }
}
