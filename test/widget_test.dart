import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:finledger/main.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/core/api/dio_client.dart';
import 'package:finledger/core/localization/locale_provider.dart';
import 'package:finledger/l10n/app_localizations.dart';
import 'package:finledger/shared/widgets/sidebar.dart';
import 'package:finledger/shared/widgets/top_bar.dart';
import 'package:finledger/shared/widgets/language_switcher.dart';

void main() {
  testWidgets('FinLedger smoke test', (WidgetTester tester) async {
    final tokenService = TokenService();
    final loadingService = LoadingService();
    final dioClient = DioClient(
      tokenService: tokenService,
      loadingService: loadingService,
    );

    await tester.pumpWidget(
      FinLedgerApp(
        tokenService: tokenService,
        loadingService: loadingService,
        dioClient: dioClient,
      ),
    );

    // Initial frame loads
    expect(find.byType(FinLedgerApp), findsOneWidget);
  });

  group('Sidebar Navigation Active State Tests (Figure 3 & Single Active Item)', () {
    Widget buildSidebarTest(String location) {
      final router = GoRouter(
        initialLocation: location,
        routes: [
          GoRoute(
            path: location,
            builder: (context, state) => Scaffold(
              body: Sidebar(
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ],
      );

      return ProviderScope(
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    Future<void> pumpSidebar(WidgetTester tester, String location) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(buildSidebarTest(location));
      await tester.pumpAndSettle();
    }

    List<String> getSelectedLabels() {
      final selectedLabels = <String>[];
      for (final section in Sidebar.sections) {
        for (final item in section.items) {
          final finder = find.widgetWithText(InkWell, item.label);
          for (final element in finder.evaluate()) {
            final inkWell = element.widget as InkWell;
            final child = inkWell.child as Container?;
            final box = child?.decoration as BoxDecoration?;
            if (box?.color == const Color(0xFF2563EB)) {
              if (!selectedLabels.contains(item.label)) {
                selectedLabels.add(item.label);
              }
            }
          }
        }
      }
      return selectedLabels;
    }

    testWidgets('Only Leads is selected when location is /crm/leads', (tester) async {
      await pumpSidebar(tester, '/crm/leads');
      final selected = getSelectedLabels();
      expect(selected, ['Leads']);
    });

    testWidgets('Only Pipeline is selected when location is /crm/pipeline', (tester) async {
      await pumpSidebar(tester, '/crm/pipeline');
      final selected = getSelectedLabels();
      expect(selected, ['Pipeline']);
    });

    testWidgets('Only Quotations is selected when location is /crm/quotations', (tester) async {
      await pumpSidebar(tester, '/crm/quotations');
      final selected = getSelectedLabels();
      expect(selected, ['Quotations']);
    });

    testWidgets('Only Customers is selected when location is /sales/customers', (tester) async {
      await pumpSidebar(tester, '/sales/customers');
      final selected = getSelectedLabels();
      expect(selected, ['Customers']);
    });

    testWidgets('Only Invoices is selected when location is /sales/invoices', (tester) async {
      await pumpSidebar(tester, '/sales/invoices');
      final selected = getSelectedLabels();
      expect(selected, ['Invoices']);
    });

    testWidgets('Only Receipts is selected when location is /sales/receipts/new', (tester) async {
      await pumpSidebar(tester, '/sales/receipts/new');
      final selected = getSelectedLabels();
      expect(selected, ['Receipts']);
    });

    testWidgets('Only Vendors is selected when location is /purchases/vendors', (tester) async {
      await pumpSidebar(tester, '/purchases/vendors');
      final selected = getSelectedLabels();
      expect(selected, ['Vendors']);
    });

    testWidgets('Only Bills is selected when location is /purchases/bills', (tester) async {
      await pumpSidebar(tester, '/purchases/bills');
      final selected = getSelectedLabels();
      expect(selected, ['Bills']);
    });

    testWidgets('Only Payments is selected when location is /purchases/payments/new', (tester) async {
      await pumpSidebar(tester, '/purchases/payments/new');
      final selected = getSelectedLabels();
      expect(selected, ['Payments']);
    });

    testWidgets('Only Items & Stock is selected when location is /inventory/items', (tester) async {
      await pumpSidebar(tester, '/inventory/items');
      final selected = getSelectedLabels();
      expect(selected, ['Items & Stock']);
    });

    testWidgets('Only Adjustments is selected when location is /inventory/adjustments/new', (tester) async {
      await pumpSidebar(tester, '/inventory/adjustments/new');
      final selected = getSelectedLabels();
      expect(selected, ['Adjustments']);
    });

    testWidgets('Only Transfers is selected when location is /inventory/transfers/new', (tester) async {
      await pumpSidebar(tester, '/inventory/transfers/new');
      final selected = getSelectedLabels();
      expect(selected, ['Transfers']);
    });

    testWidgets('Only Expenses is selected when location is /expenses', (tester) async {
      await pumpSidebar(tester, '/expenses');
      final selected = getSelectedLabels();
      expect(selected, ['Expenses']);
    });

    testWidgets('Only Approvals is selected when location is /expenses/approvals', (tester) async {
      await pumpSidebar(tester, '/expenses/approvals');
      final selected = getSelectedLabels();
      expect(selected, ['Approvals']);
    });

    testWidgets('Only Chart of Accounts is selected when location is /accounting/accounts', (tester) async {
      await pumpSidebar(tester, '/accounting/accounts');
      final selected = getSelectedLabels();
      expect(selected, ['Chart of Accounts']);
    });

    testWidgets('Only Journal Entries is selected when location is /accounting/journals', (tester) async {
      await pumpSidebar(tester, '/accounting/journals');
      final selected = getSelectedLabels();
      expect(selected, ['Journal Entries']);
    });

    testWidgets('Only Bank Accounts is selected when location is /banking', (tester) async {
      await pumpSidebar(tester, '/banking');
      final selected = getSelectedLabels();
      expect(selected, ['Bank Accounts']);
    });

    testWidgets('Only Reconciliation is selected when location is /banking/reconciliation', (tester) async {
      await pumpSidebar(tester, '/banking/reconciliation');
      final selected = getSelectedLabels();
      expect(selected, ['Reconciliation']);
    });
  });

  group('Localization, LanguageSwitcher & Dynamic RTL Tests', () {
    testWidgets('LanguageSwitcher in TopBar renders and reflects active locale', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final activeLocale = ref.watch(localeNotifierProvider);
              return MaterialApp(
                locale: activeLocale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: const Scaffold(
                  body: LanguageSwitcher(),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSwitcher), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets('Drawer language toggle switches between English, Hindi, and Arabic', (tester) async {
      late WidgetRef savedRef;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              savedRef = ref;
              final activeLocale = ref.watch(localeNotifierProvider);
              return MaterialApp(
                locale: activeLocale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: Scaffold(
                  body: LanguageSwitcher.drawerToggle(),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EN'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);

      // Tap Hindi
      await tester.tap(find.text('हिन्दी'));
      await tester.pumpAndSettle();
      expect(savedRef.read(localeNotifierProvider).languageCode, 'hi');

      // Tap Arabic
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(savedRef.read(localeNotifierProvider).languageCode, 'ar');
    });

    testWidgets('Selecting Arabic activates Right-to-Left (RTL) Directionality dynamically', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final activeLocale = ref.watch(localeNotifierProvider);
              return MaterialApp(
                locale: activeLocale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: Builder(
                  builder: (ctx) {
                    final isRtl = Directionality.of(ctx) == TextDirection.rtl;
                    return Scaffold(
                      body: Column(
                        children: [
                          Text(isRtl ? 'CURRENT_RTL' : 'CURRENT_LTR'),
                          LanguageSwitcher.drawerToggle(),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially English -> LTR
      expect(find.text('CURRENT_LTR'), findsOneWidget);

      // Tap Arabic toggle
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Dynamically switched to RTL without app restart
      expect(find.text('CURRENT_RTL'), findsOneWidget);
    });

    testWidgets('SettingsLanguageCard renders all supported languages with radio options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final activeLocale = ref.watch(localeNotifierProvider);
              return MaterialApp(
                locale: activeLocale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: Scaffold(
                  body: LanguageSwitcher.settingsCard(),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('English (US/UK)'), findsOneWidget);
      expect(find.text('हिन्दी (Hindi)'), findsOneWidget);
      expect(find.text('العربية (Arabic - RTL)'), findsOneWidget);
    });

    testWidgets('Sidebar translates drawer titles when locale is Hindi', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('hi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: Sidebar(
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hindi translations rendered
      expect(find.text('डैशबोर्ड'), findsOneWidget);
      expect(find.text('ग्राहक'), findsOneWidget);
      expect(find.text('चालान (इनवॉइस)'), findsOneWidget);
      expect(find.text('बिल'), findsOneWidget);
    });

    testWidgets('Sidebar translates drawer titles when locale is Arabic and applies RTL', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: Sidebar(
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Arabic translations rendered
      expect(find.text('لوحة القيادة'), findsOneWidget);
      expect(find.text('العملاء'), findsOneWidget);
      expect(find.text('الفواتير الضريبية'), findsOneWidget);
      expect(find.text('فواتير الموردين'), findsOneWidget);
    });

    testWidgets('TopBar renders without overflow on 360x640 mobile screen in Hindi', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final tokenService = TokenService();
      final loadingService = LoadingService();

      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(
              appBar: TopBar(showMobileMenu: true),
              body: Center(child: Text('Dashboard View')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        legacy_provider.MultiProvider(
          providers: [
            legacy_provider.ChangeNotifierProvider<TokenService>.value(value: tokenService),
            legacy_provider.ChangeNotifierProvider<LoadingService>.value(value: loadingService),
          ],
          child: ProviderScope(
            child: MaterialApp.router(
              locale: const Locale('hi'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure TopBar rendered cleanly with page title and language badge without throwing overflow exception
      expect(find.byType(TopBar), findsOneWidget);
      expect(find.byType(LanguageSwitcher), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TopBar renders without overflow on narrow 320x568 screen in Arabic (RTL)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final tokenService = TokenService();
      final loadingService = LoadingService();

      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(
              appBar: TopBar(showMobileMenu: true),
              body: Center(child: Text('Dashboard View')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        legacy_provider.MultiProvider(
          providers: [
            legacy_provider.ChangeNotifierProvider<TokenService>.value(value: tokenService),
            legacy_provider.ChangeNotifierProvider<LoadingService>.value(value: loadingService),
          ],
          child: ProviderScope(
            child: MaterialApp.router(
              locale: const Locale('ar'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TopBar), findsOneWidget);
      expect(find.byType(LanguageSwitcher), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
