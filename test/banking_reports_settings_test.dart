import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finledger/features/banking/data/services/banking_service.dart';
import 'package:finledger/features/banking/presentation/bank_reconciliation_screen.dart';
import 'package:finledger/features/reports/data/services/report_service.dart';
import 'package:finledger/features/reports/presentation/reports_viewer_screen.dart';
import 'package:finledger/features/settings/data/services/settings_service.dart';
import 'package:finledger/features/settings/presentation/company_settings_screen.dart';

void main() {
  group('Bank Reconciliation Logic & Service Tests', () {
    late BankingService service;

    setUp(() {
      service = BankingService();
    });

    test('Initial session matches Figure 15 (Page 24) exact values', () async {
      final session = await service.getReconciliationSession(1);

      expect(session.statementDate, equals('31-Oct-2026'));
      expect(session.statementEndingBalance, equals(705850.00));
      expect(session.clearedBookBalance, equals(702300.00));
      expect(session.difference, equals(3550.00));
      expect(session.canFinishReconciliation, isFalse);

      // Verify statement lines
      expect(session.statementLines.length, equals(4));
      expect(session.statementLines[0].description, equals('TT IN GULF HOSPITALITY'));
      expect(session.statementLines[0].isChecked, isTrue);
      expect(session.statementLines[0].matchRef, equals('RCT-0219'));

      expect(session.statementLines[2].description, equals('BANK CHARGES OCT'));
      expect(session.statementLines[2].requiresCreateEntry, isTrue);

      expect(session.statementLines[3].isSuggested, isTrue);
      expect(session.statementLines[3].matchRef, equals('RCT-0220'));

      // Verify book transactions
      expect(session.bookTransactions.length, equals(4));
      expect(session.bookTransactions[0].reference, equals('RCT-2026-0219'));
      expect(session.bookTransactions[0].isChecked, isTrue);
    });

    test('Cannot finish reconciliation when difference != 0.00', () async {
      final session = await service.getReconciliationSession(1);
      expect(session.difference, equals(3550.00));

      expect(
        () => service.finishReconciliation(session),
        throwsA(isA<Exception>()),
      );
    });

    test('Accepting Suggestion matches statement line and clears book transaction', () async {
      final session = await service.getReconciliationSession(1);
      expect(session.statementLines[3].isChecked, isFalse);

      service.acceptSuggestion(session, 'stmt-4');

      expect(session.statementLines[3].isChecked, isTrue);
      expect(session.statementLines[3].isSuggested, isFalse);

      final bookTx = session.bookTransactions.firstWhere((t) => t.reference == 'RCT-2026-0220');
      expect(bookTx.isChecked, isTrue);
      expect(bookTx.isCleared, isTrue);
    });

    test('Creating entry for Bank Charges updates statement line and adds book transaction', () async {
      final session = await service.getReconciliationSession(1);
      final initialBookCount = session.bookTransactions.length;

      await service.createBankEntry(
        session: session,
        stmtLineId: 'stmt-3',
        accountCode: '6150',
        accountName: 'Bank Charges',
        amount: 150.00,
        reference: 'JE-2026-0188',
        narration: 'Monthly bank service charge',
      );

      expect(session.statementLines[2].requiresCreateEntry, isFalse);
      expect(session.statementLines[2].isChecked, isTrue);
      expect(session.statementLines[2].matchRef, equals('JE-2026-0188'));
      expect(session.bookTransactions.length, equals(initialBookCount + 1));
    });

    test('Reconciliation finishes successfully when Difference is 0.00', () async {
      final session = await service.getReconciliationSession(1);

      // Set statement ending balance equal to cleared book balance (702,300.00)
      session.statementEndingBalance = 702300.00;
      expect(session.difference, equals(0.00));
      expect(session.canFinishReconciliation, isTrue);

      final result = await service.finishReconciliation(session);
      expect(result, isTrue);
      expect(session.isFinished, isTrue);
    });

    test('Importing CSV bank statement parses rows and creates lines', () async {
      final session = await service.getReconciliationSession(1);
      final initialCount = session.statementLines.length;

      const csv = '''Date,Description,Amount,Reference
31-Oct,TEST DEPOSIT,5000.00,REF-123
31-Oct,TEST WITHDRAWAL,-1200.00,''';

      final added = service.importCsvStatement(session, csv);
      expect(added, equals(2));
      expect(session.statementLines.length, equals(initialCount + 2));
    });
  });

  group('Reports Service & Logic Tests', () {
    late ReportService reportService;

    setUp(() {
      reportService = ReportService();
    });

    test('P&L report returns exact figures matching Figure 16 (Page 25)', () async {
      final report = await reportService.getFinancialReport(reportCode: 'pnl');

      expect(report.companyName, equals('BSB Trading LLC'));
      expect(report.reportTitle, equals('Profit & Loss Statement'));
      expect(report.currentColumnHeader, equals('2026'));
      expect(report.comparativeColumnHeader, equals('2025'));

      // Revenue Section
      final revSection = report.sections[0];
      expect(revSection.title, equals('Revenue'));
      expect(revSection.rows[0].accountName, equals('4100 Product Sales'));
      expect(revSection.rows[0].currentAmount, equals(2215800.00));
      expect(revSection.rows[0].comparativeAmount, equals(1968200.00));
      expect(revSection.rows[0].changePercentage, equals(12.6));

      // Total Revenue
      expect(revSection.rows[2].accountName, equals('Total Revenue'));
      expect(revSection.rows[2].currentAmount, equals(2485300.00));
      expect(revSection.rows[2].comparativeAmount, equals(2211200.00));
      expect(revSection.rows[2].changePercentage, equals(12.4));

      // Gross Profit
      final cogsSection = report.sections[1];
      expect(cogsSection.rows[1].accountName, equals('Gross Profit'));
      expect(cogsSection.rows[1].currentAmount, equals(1364500.00));
      expect(cogsSection.rows[1].comparativeAmount, equals(1176700.00));
      expect(cogsSection.rows[1].changePercentage, equals(16.0));

      // Operating Expenses
      final opexSection = report.sections[2];
      expect(opexSection.rows[3].accountName, equals('Total Operating Expenses'));
      expect(opexSection.rows[3].currentAmount, equals(571340.00));
      expect(opexSection.rows[3].comparativeAmount, equals(530600.00));

      // Net Profit
      final netSection = report.sections[3];
      expect(netSection.rows[0].accountName, equals('Net Profit'));
      expect(netSection.rows[0].currentAmount, equals(793160.00));
      expect(netSection.rows[0].comparativeAmount, equals(646100.00));
      expect(netSection.rows[0].changePercentage, equals(22.8));
      expect(netSection.rows[0].isHighlight, isTrue);
    });

    test('GL drilldown returns transactions for account', () async {
      final txs = await reportService.getGlTransactionsForAccount('4100');
      expect(txs.isNotEmpty, isTrue);
      expect(txs[0].reference, equals('INV-2026-0895'));
      expect(txs[0].entryNo, equals('JE-2026-0142'));
    });
  });

  group('Company Settings Service Tests', () {
    late SettingsService settingsService;

    setUp(() {
      settingsService = SettingsService();
    });

    test('Returns default BSB Trading LLC profile', () async {
      final profile = await settingsService.getCompanyProfile();
      expect(profile.companyName, equals('BSB Trading LLC'));
      expect(profile.trn, equals('100234891000003'));
      expect(profile.currency, contains('AED'));
      expect(profile.emirate, equals('Dubai'));
    });

    test('Updates company profile successfully', () async {
      final profile = await settingsService.getCompanyProfile();
      profile.companyName = 'BSB Trading & Technologies LLC';
      final ok = await settingsService.updateCompanyProfile(profile);
      expect(ok, isTrue);

      final reloaded = await settingsService.getCompanyProfile();
      expect(reloaded.companyName, equals('BSB Trading & Technologies LLC'));
    });

    test('Fiscal years and tax rates return required UAE FTA items', () {
      final fy = settingsService.getFiscalYears();
      expect(fy.any((y) => y.year == 2026 && y.isOpen), isTrue);

      final taxes = settingsService.getTaxRates();
      expect(taxes.any((t) => t.ratePercent == 5.0), isTrue);
      expect(taxes.any((t) => t.type == 'Zero-Rated'), isTrue);
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('BankReconciliationScreen renders header, split tables, and summary bar (Figure 15)', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BankReconciliationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Bank Reconciliation'), findsOneWidget);
      expect(find.text('Import Statement (CSV)'), findsOneWidget);

      // Check tables
      expect(find.text('Bank Statement Lines'), findsOneWidget);
      expect(find.text('Book Transactions (unreconciled)'), findsOneWidget);
      expect(find.text('TT IN GULF HOSPITALITY'), findsOneWidget);
      expect(find.text('Create entry'), findsOneWidget);
      expect(find.text('Suggest RCT-0220'), findsOneWidget);

      // Check summary bar
      expect(find.text('Statement balance'), findsOneWidget);
      expect(find.text('Cleared book balance'), findsOneWidget);
      expect(find.text('Difference'), findsOneWidget);
      expect(find.text('3,550.00'), findsOneWidget);
      expect(find.text('Finish Reconciliation'), findsOneWidget);
    });

    testWidgets('ReportsViewerScreen renders toolbar, export buttons, and statement paper (Figure 16)', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportsViewerScreen(initialReportType: 'pnl'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check toolbar
      expect(find.text('Profit & Loss Statement'), findsWidgets);
      expect(find.text('Run'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('Excel'), findsOneWidget);

      // Check statement content
      expect(find.text('BSB Trading LLC'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('4100 Product Sales'), findsOneWidget);
      expect(find.text('2,215,800.00'), findsOneWidget);
      expect(find.text('Gross Profit'), findsOneWidget);
      expect(find.text('Net Profit'), findsOneWidget);
      expect(find.text('793,160.00'), findsOneWidget);
    });

    testWidgets('CompanySettingsScreen renders vertical sub-navigation and profile editing form (Page 26)', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompanySettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check sub-navigation items
      expect(find.text('Company Profile'), findsWidgets);
      expect(find.text('Fiscal Years'), findsOneWidget);
      expect(find.text('Tax Rates'), findsOneWidget);
      expect(find.text('Currencies'), findsOneWidget);
      expect(find.text('Number Series'), findsOneWidget);
      expect(find.text('Users & Roles'), findsOneWidget);
      expect(find.text('Audit Log'), findsOneWidget);

      // Check form fields
      expect(find.text('BSB Trading LLC'), findsOneWidget);
      expect(find.text('FTA Active'), findsOneWidget);
      expect(find.text('Upload New Logo'), findsOneWidget);
      expect(find.text('Save Changes'), findsWidgets);
    });

    testWidgets('CompanySettingsScreen renders Currencies tab on mobile viewport (360x640) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompanySettingsScreen(initialTab: 'currencies'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Currencies & Exchange Rates'), findsOneWidget);
      expect(find.text('Update Rates'), findsOneWidget);
      expect(find.text('UAE Dirham'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('3.6725'), findsOneWidget);
    });

    testWidgets('CompanySettingsScreen renders Users & Roles tab on mobile viewport (360x640) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompanySettingsScreen(initialTab: 'users_roles'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Users & Role-Based Permissions'), findsOneWidget);
      expect(find.text('+ Invite User'), findsOneWidget);
      expect(find.text('Ahmed Jaber Al Hamri'), findsOneWidget);
      expect(find.text('Sara Mathew'), findsOneWidget);
      expect(find.text('Senior Accountant'), findsOneWidget);
    });

    testWidgets('CompanySettingsScreen renders all other tabs on mobile viewport (360x640) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      for (final tab in ['fiscal_years', 'tax_rates', 'number_series', 'audit_log']) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompanySettingsScreen(initialTab: tab),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
