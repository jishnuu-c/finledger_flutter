import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:finledger/l10n/app_localizations.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/shared/widgets/top_bar.dart';
import 'package:finledger/shared/widgets/app_shell.dart';
import 'package:finledger/features/dashboard/presentation/dashboard_screen.dart';
import 'package:finledger/core/api/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({required Widget child, required Locale locale}) {
    final tokenService = TokenService();
    final loadingService = LoadingService();
    final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
      ],
    );

    return ProviderScope(
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider<TokenService>.value(value: tokenService),
          legacy_provider.ChangeNotifierProvider<LoadingService>.value(value: loadingService),
          legacy_provider.Provider<DioClient>.value(value: dioClient),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('ar'),
          ],
        ),
      ),
    );
  }

  group('TopBar Responsive Layout Tests (Zero Overflow Guarantee)', () {
    final widths = [
      320.0, // Smallest phones (e.g. older Android / iPhone SE 1st gen)
      360.0, // Standard Android compact
      375.0, // iPhone standard
      390.0, // Modern iPhone / Xiaomi standard
      412.0, // Google Pixel / Samsung Galaxy
      460.0, // User\'s tested device resolution
      480.0, // Phablet compact
      500.0, // Critical breakpoint boundary
      520.0, // Smallest width display setting
      600.0, // 7-inch tablet boundary
      768.0, // Tablet portrait
      1024.0, // Desktop breakpoint
      1440.0, // Desktop widescreen
    ];

    final locales = [
      const Locale('en'),
      const Locale('hi'),
      const Locale('ar'),
    ];

    for (final locale in locales) {
      for (final width in widths) {
        testWidgets('TopBar in AppShell at ${width}px [${locale.languageCode}] renders without overflow', (tester) async {
          final size = Size(width, 800);
          await tester.binding.setSurfaceSize(size);
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            createTestWidget(
              locale: locale,
              child: const AppShell(
                child: DashboardScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Zero exceptions must occur
          expect(tester.takeException(), isNull);

          // TopBar must be present
          expect(find.byType(TopBar), findsOneWidget);
        });
      }
    }
  });
}
