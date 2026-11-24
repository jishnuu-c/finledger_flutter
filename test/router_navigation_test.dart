import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finledger/l10n/app_localizations.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/core/api/dio_client.dart';
import 'package:finledger/core/router/app_router.dart';
import 'package:finledger/features/auth/presentation/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'jwt_token': 'dummy_mock_jwt_token_for_tests',
      'user_role': 'Admin',
      'user_email': 'admin@finledger.ae',
    });
  });

  final testRoutes = [
    '/dashboard',
    '/crm',
    '/crm/pipeline',
    '/crm/leads',
    '/crm/quotations',
    '/crm/opportunities/1',
    '/sales',
    '/sales/customers',
    '/sales/invoices',
    '/sales/invoices/new',
    '/sales/receipts/new',
    '/purchases',
    '/purchases/bills',
    '/purchases/vendors',
    '/purchases/payments/new',
    '/inventory',
    '/inventory/items',
    '/inventory/adjustments/new',
    '/inventory/transfers/new',
    '/expenses',
    '/expenses/approvals',
    '/expenses/new',
    '/accounting',
    '/accounting/accounts',
    '/accounting/journals',
    '/accounting/journals/new',
    '/banking',
    '/banking/accounts',
    '/banking/reconciliation',
    '/reports',
    '/reports/pnl',
    '/reports/balance_sheet',
    '/reports/vat',
    '/settings',
    '/settings/profile',
    '/settings/fiscal_years',
    '/settings/tax_rates',
    '/settings/currencies',
    '/settings/number_series',
    '/settings/users_roles',
    '/settings/audit_log',
  ];

  testWidgets('Unauthenticated router redirects to /login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final tokenService = TokenService();
    final loadingService = LoadingService();
    final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
    final router = createAppRouter(tokenService);

    await tester.pumpWidget(
      legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider<TokenService>.value(value: tokenService),
          legacy_provider.ChangeNotifierProvider<LoadingService>.value(value: loadingService),
          legacy_provider.Provider<DioClient>.value(value: dioClient),
        ],
        child: ProviderScope(
          overrides: [
            tokenServiceProvider.overrideWithValue(tokenService),
            dioClientProvider.overrideWithValue(dioClient),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, equals('/login'));
    expect(tester.takeException(), isNull);
  });

  group('Authenticated Route Navigation Tests', () {
    for (final route in testRoutes) {
      testWidgets('Navigates cleanly to $route', (tester) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', 'mock_jwt_token_for_tests');
        await prefs.setString('user_role', 'Admin');

        final tokenService = TokenService();
        final loadingService = LoadingService();
        final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
        final router = createAppRouter(tokenService);

        await tester.pumpWidget(
          legacy_provider.MultiProvider(
            providers: [
              legacy_provider.ChangeNotifierProvider<TokenService>.value(value: tokenService),
              legacy_provider.ChangeNotifierProvider<LoadingService>.value(value: loadingService),
              legacy_provider.Provider<DioClient>.value(value: dioClient),
            ],
            child: ProviderScope(
              overrides: [
                tokenServiceProvider.overrideWithValue(tokenService),
                dioClientProvider.overrideWithValue(dioClient),
              ],
              child: MaterialApp.router(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: router,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        router.go(route);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
