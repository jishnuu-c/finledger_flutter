import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/core/api/dio_client.dart';
import 'package:finledger/features/dashboard/presentation/dashboard_screen.dart';
import 'package:finledger/features/crm/presentation/pipeline_board_screen.dart';
import 'package:finledger/features/crm/presentation/opportunity_detail_screen.dart';
import 'package:finledger/features/sales/presentation/sales_invoices_list_screen.dart';
import 'package:finledger/features/sales/presentation/create_tax_invoice_screen.dart';
import 'package:finledger/features/sales/presentation/record_customer_receipt_screen.dart';
import 'package:finledger/features/inventory/presentation/items_and_stock_screen.dart';
import 'package:finledger/features/inventory/presentation/stock_adjustment_transfer_screen.dart';
import 'package:finledger/features/expenses/presentation/expenses_list_screen.dart';
import 'package:finledger/features/expenses/presentation/new_expense_claim_screen.dart';
import 'package:finledger/features/accounting/presentation/chart_of_accounts_screen.dart';
import 'package:finledger/features/accounting/presentation/new_journal_entry_screen.dart';
import 'package:finledger/features/banking/presentation/bank_reconciliation_screen.dart';
import 'package:finledger/features/reports/presentation/reports_viewer_screen.dart';
import 'package:finledger/features/settings/presentation/company_settings_screen.dart';
import 'package:finledger/features/settings/presentation/settings_screen.dart';
import 'package:finledger/features/reports/presentation/widgets/gl_drilldown_modal.dart';
import 'package:finledger/features/reports/data/services/report_service.dart';
import 'package:finledger/features/inventory/presentation/widgets/stock_ledger_modal.dart';
import 'package:finledger/features/inventory/presentation/widgets/barcode_scanner_modal.dart';
import 'package:finledger/features/inventory/data/services/inventory_service.dart';
import 'package:finledger/features/banking/presentation/widgets/import_statement_modal.dart';
import 'package:finledger/features/banking/presentation/widgets/create_bank_entry_modal.dart';
import 'package:finledger/features/banking/data/models/banking_models.dart';
import 'package:finledger/features/sales/presentation/widgets/invoice_pdf_preview_dialog.dart';
import 'package:finledger/features/sales/data/services/sales_service.dart';
import 'package:finledger/features/expenses/data/services/expense_service.dart';
import 'package:finledger/features/accounting/presentation/widgets/new_account_dialog.dart';
import 'package:finledger/features/crm/presentation/widgets/convert_customer_dialog.dart';
import 'package:finledger/features/crm/presentation/widgets/new_opportunity_dialog.dart';
import 'package:finledger/features/crm/presentation/widgets/lost_reason_dialog.dart';
import 'package:finledger/features/expenses/presentation/widgets/mobile_camera_modal.dart';
import 'package:finledger/features/purchases/presentation/purchases_screen.dart';
import 'package:finledger/features/sales/presentation/sales_screen.dart';
import 'package:finledger/features/reports/presentation/reports_screen.dart';
import 'package:finledger/features/inventory/presentation/inventory_screen.dart';
import 'package:finledger/features/expenses/presentation/expenses_screen.dart';
import 'package:finledger/features/banking/presentation/banking_screen.dart';
import 'package:finledger/features/crm/presentation/crm_screen.dart';
import 'package:finledger/features/accounting/presentation/accounting_screen.dart';
import 'package:finledger/features/accounting/presentation/journal_entries_list_screen.dart';
import 'package:finledger/features/auth/presentation/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp(Widget child) {
    final tokenService = TokenService();
    final loadingService = LoadingService();
    final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TokenService>.value(value: tokenService),
        ChangeNotifierProvider<LoadingService>.value(value: loadingService),
        Provider<DioClient>.value(value: dioClient),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  final viewports = [
    const Size(360, 640),   // Compact mobile portrait (standard Android)
    const Size(375, 812),   // Mobile portrait
    const Size(768, 1024),  // Tablet portrait
    const Size(1024, 768),  // Tablet landscape
    const Size(1440, 900),  // Desktop
  ];

  for (final size in viewports) {
    group('Responsive Viewport ${size.width}x${size.height}', () {
      Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
        await tester.binding.setSurfaceSize(size);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        await tester.pumpWidget(buildTestApp(screen));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      testWidgets('DashboardScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const DashboardScreen());
      });

      testWidgets('PipelineBoardScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const PipelineBoardScreen());
      });

      testWidgets('OpportunityDetailScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const OpportunityDetailScreen(opportunityId: 1));
      });

      testWidgets('CrmScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const CrmScreen());
      });

      testWidgets('SalesInvoicesListScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const SalesInvoicesListScreen());
      });

      testWidgets('SalesScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const SalesScreen());
      });

      testWidgets('CreateTaxInvoiceScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const CreateTaxInvoiceScreen());
      });

      testWidgets('RecordCustomerReceiptScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const RecordCustomerReceiptScreen());
      });

      testWidgets('PurchasesScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const PurchasesScreen());
      });

      testWidgets('ItemsAndStockScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const ItemsAndStockScreen());
      });

      testWidgets('InventoryScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const InventoryScreen());
      });

      testWidgets('StockAdjustmentTransferScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const StockAdjustmentTransferScreen());
      });

      testWidgets('ExpensesListScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const ExpensesListScreen());
      });

      testWidgets('ExpensesScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const ExpensesScreen());
      });

      testWidgets('NewExpenseClaimScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const NewExpenseClaimScreen());
      });

      testWidgets('ChartOfAccountsScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const ChartOfAccountsScreen());
      });

      testWidgets('AccountingScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const AccountingScreen());
      });

      testWidgets('JournalEntriesListScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const JournalEntriesListScreen());
      });

      testWidgets('NewJournalEntryScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const NewJournalEntryScreen());
      });

      testWidgets('BankReconciliationScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const BankReconciliationScreen());
      });

      testWidgets('BankingScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const BankingScreen());
      });

      testWidgets('ReportsViewerScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const ReportsViewerScreen());
      });

      testWidgets('ReportsScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const ReportsScreen());
      });

      testWidgets('CompanySettingsScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const CompanySettingsScreen());
      });

      testWidgets('SettingsScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const SettingsScreen());
      });

      testWidgets('LoginScreen renders without overflow', (tester) async {
        await pumpScreen(tester, const LoginScreen());
      });
    });
  }

  group('Responsive Modals on Mobile Viewport (360x640)', () {
    const mobileSize = Size(360, 640);

    testWidgets('GlDrilldownModal renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final reportService = ReportService();
      await tester.pumpWidget(buildTestApp(
        GlDrilldownModal(
          accountCode: '1110',
          accountName: '1110 Emirates NBD Current',
          reportService: reportService,
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('General Ledger Drill-Down'), findsOneWidget);
    });

    testWidgets('StockLedgerModal renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final invService = InventoryService();
      final summary = await invService.getStockSummary();
      await tester.pumpWidget(buildTestApp(
        StockLedgerModal(
          item: summary.first,
          inventoryService: invService,
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining(summary.first.sku), findsOneWidget);
    });

    testWidgets('ImportStatementModal renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(buildTestApp(
        ImportStatementModal(
          onImport: (_) {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Import Bank Statement'), findsOneWidget);
    });

    testWidgets('CreateBankEntryModal renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final line = BankStatementLine(
        id: 'L-1',
        date: '28-Oct-2026',
        description: 'MONTHLY ACCOUNT MAINTENANCE FEE & SMS ALERT SERVICE CHARGES',
        amount: -250.00,
      );
      await tester.pumpWidget(buildTestApp(
        CreateBankEntryModal(
          line: line,
          onPost: ({required accountCode, required accountName, required amount, required narration, required reference}) {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Create Bank Charge Entry'), findsOneWidget);
    });

    testWidgets('InvoicePdfPreviewDialog renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final salesService = SalesService();
      final invoices = await salesService.getInvoices();
      await tester.pumpWidget(buildTestApp(
        InvoicePdfPreviewDialog(invoice: invoices.first),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Tax Invoice PDF Preview'), findsOneWidget);
    });

    testWidgets('NewAccountDialog renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(buildTestApp(
        NewAccountDialog(
          groupAccounts: const [],
          onSave: (_) async {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('New General Ledger Account'), findsOneWidget);
    });

    testWidgets('ConvertCustomerDialog renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(buildTestApp(
        const ConvertCustomerDialog(
          initialCustomerName: 'Industrial Sensor System',
          initialContactName: 'Ali Hassan',
          initialEmail: 'ali@company.ae',
          initialPhone: '+971 4 123 4567',
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Convert to Customer Account'), findsOneWidget);
    });

    testWidgets('NewOpportunityDialog renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(buildTestApp(
        const NewOpportunityDialog(stages: ['New', 'Lead', 'Qualified', 'Proposal', 'Won']),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Create New Opportunity'), findsOneWidget);
    });

    testWidgets('LostReasonDialog renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(buildTestApp(
        const LostReasonDialog(opportunityTitle: 'HVAC Contract'),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Mark Opportunity as Lost'), findsOneWidget);
    });

    testWidgets('BarcodeScannerModal renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final invService = InventoryService();
      await tester.pumpWidget(buildTestApp(
        BarcodeScannerModal(
          inventoryService: invService,
          onItemScanned: (_) {},
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Scan Item Barcode'), findsOneWidget);
    });

    testWidgets('MobileCameraModal renders without overflow on mobile', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      tester.view.physicalSize = mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final expenseService = ExpenseService();
      await tester.pumpWidget(buildTestApp(
        MobileCameraModal(
          expenseService: expenseService,
          onReceiptCaptured: (_) {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Mobile Receipt Camera'), findsOneWidget);
    });
  });
}
