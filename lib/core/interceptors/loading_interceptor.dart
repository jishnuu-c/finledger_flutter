import 'package:dio/dio.dart';
import '../services/loading_service.dart';

class LoadingInterceptor extends Interceptor {
  final LoadingService loadingService;

  LoadingInterceptor({required this.loadingService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if caller wants to suppress global loading indicator
    final silent = options.extra['silent'] == true;
    if (!silent) {
      loadingService.startLoading();
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final silent = response.requestOptions.extra['silent'] == true;
    if (!silent) {
      loadingService.stopLoading();
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final silent = err.requestOptions.extra['silent'] == true;
    if (!silent) {
      loadingService.stopLoading();
    }
    return handler.next(err);
  }
}
