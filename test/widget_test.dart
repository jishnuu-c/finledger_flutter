import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:finledger/main.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/core/api/dio_client.dart';
import 'package:finledger/shared/widgets/sidebar.dart';

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

      return MaterialApp.router(
        routerConfig: router,
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

    testWidgets('Only Pipeline is selected when location is /crm/pipeline', (tester) async {
      await pumpSidebar(tester, '/crm/pipeline');
      final selected = getSelectedLabels();
      expect(selected, ['Pipeline']);
    });

    testWidgets('Only Invoices is selected when location is /sales/invoices', (tester) async {
      await pumpSidebar(tester, '/sales/invoices');
      final selected = getSelectedLabels();
      expect(selected, ['Invoices']);
    });

    testWidgets('Only Bills is selected when location is /purchases/bills', (tester) async {
      await pumpSidebar(tester, '/purchases/bills');
      final selected = getSelectedLabels();
      expect(selected, ['Bills']);
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
}
