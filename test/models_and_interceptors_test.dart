import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:finledger/shared/models/api_error.dart';
import 'package:finledger/shared/models/page_response.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/core/interceptors/auth_interceptor.dart';
import 'package:finledger/core/interceptors/loading_interceptor.dart';
import 'package:finledger/core/interceptors/error_interceptor.dart';

class TestErrorHandler extends ErrorInterceptorHandler {
  DioException? capturedException;

  @override
  void next(DioException err) {
    capturedException = err;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiError & FieldError Tests', () {
    test('parses complete ApiError JSON with fieldErrors', () {
      final json = {
        'timestamp': '2026-10-30T10:15:30.000Z',
        'status': 400,
        'code': 'VALIDATION_FAILED',
        'message': 'Invoice validation failed',
        'path': '/api/v1/invoices',
        'fieldErrors': [
          {'field': 'customerId', 'message': 'Customer is required'},
          {'field': 'lines', 'message': 'At least one invoice line item must be provided'},
        ],
      };

      final error = ApiError.fromJson(json);

      expect(error.status, 400);
      expect(error.code, 'VALIDATION_FAILED');
      expect(error.message, 'Invoice validation failed');
      expect(error.path, '/api/v1/invoices');
      expect(error.fieldErrors.length, 2);
      expect(error.fieldErrors[0].field, 'customerId');
      expect(error.fieldErrors[0].message, 'Customer is required');
      expect(error.displayMessage, contains('Customer is required'));
    });
  });

  group('PageResponse<T> Tests', () {
    test('parses paged JSON format', () {
      final json = {
        'content': [
          {'id': 1, 'name': 'Item A'},
          {'id': 2, 'name': 'Item B'},
        ],
        'page': 0,
        'size': 20,
        'totalElements': 42,
        'totalPages': 3,
        'first': true,
        'last': false,
      };

      final response = PageResponse<String>.fromJson(
        json,
        (raw) => (raw as Map<String, dynamic>)['name'] as String,
      );

      expect(response.content, ['Item A', 'Item B']);
      expect(response.page, 0);
      expect(response.size, 20);
      expect(response.totalElements, 42);
      expect(response.totalPages, 3);
      expect(response.isFirst, true);
      expect(response.isLast, false);
      expect(response.hasNext, true);
      expect(response.hasPrevious, false);
    });
  });

  group('Interceptor Unit Tests', () {
    test('AuthInterceptor adds Bearer token to normal requests', () async {
      final tokenService = TokenService();
      await tokenService.saveTokens(
        accessToken: 'test_token_12345',
        refreshToken: 'refresh_token_abc',
      );

      final interceptor = AuthInterceptor(tokenService: tokenService);
      final options = RequestOptions(path: '/invoices');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer test_token_12345');
    });

    test('AuthInterceptor does NOT add Bearer token to /auth/login or /auth/refresh', () async {
      final tokenService = TokenService();
      await tokenService.saveTokens(
        accessToken: 'test_token_12345',
        refreshToken: 'refresh_token_abc',
      );

      final interceptor = AuthInterceptor(tokenService: tokenService);

      final loginOptions = RequestOptions(path: '/auth/login');
      final loginHandler = RequestInterceptorHandler();
      interceptor.onRequest(loginOptions, loginHandler);
      expect(loginOptions.headers['Authorization'], isNull);

      final refreshOptions = RequestOptions(path: '/auth/refresh');
      final refreshHandler = RequestInterceptorHandler();
      interceptor.onRequest(refreshOptions, refreshHandler);
      expect(refreshOptions.headers['Authorization'], isNull);
    });

    test('LoadingInterceptor tracks request count', () {
      final loadingService = LoadingService();
      final interceptor = LoadingInterceptor(loadingService: loadingService);
      final options = RequestOptions(path: '/items');
      final reqHandler = RequestInterceptorHandler();
      final respHandler = ResponseInterceptorHandler();

      expect(loadingService.isLoading, false);

      interceptor.onRequest(options, reqHandler);
      expect(loadingService.isLoading, true);
      expect(loadingService.activeRequests, 1);

      final response = Response(requestOptions: options, statusCode: 200);
      interceptor.onResponse(response, respHandler);
      expect(loadingService.isLoading, false);
      expect(loadingService.activeRequests, 0);
    });

    test('ErrorInterceptor extracts ApiError from badResponse via callback', () {
      ApiError? interceptedError;
      final interceptor = ErrorInterceptor(
        onApiError: (err) => interceptedError = err,
      );

      final requestOptions = RequestOptions(path: '/invoices');
      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 422,
          data: {
            'timestamp': '2026-10-30T12:00:00Z',
            'status': 422,
            'code': 'UNBALANCED_JOURNAL',
            'message': 'Total debits must equal total credits',
            'fieldErrors': [],
          },
        ),
      );

      final testHandler = TestErrorHandler();
      interceptor.onError(dioException, testHandler);

      expect(interceptedError, isNotNull);
      expect(interceptedError!.status, 422);
      expect(interceptedError!.code, 'UNBALANCED_JOURNAL');
      expect(interceptedError!.message, 'Total debits must equal total credits');
      expect(testHandler.capturedException, isNotNull);
      expect(testHandler.capturedException!.error, isA<ApiError>());
      expect((testHandler.capturedException!.error as ApiError).code, 'UNBALANCED_JOURNAL');
    });
  });
}
