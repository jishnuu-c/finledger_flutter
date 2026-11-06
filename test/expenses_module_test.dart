import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finledger/features/expenses/data/models/expense_models.dart';
import 'package:finledger/features/expenses/data/services/expense_service.dart';
import 'package:finledger/features/expenses/presentation/expenses_list_screen.dart';
import 'package:finledger/features/expenses/presentation/new_expense_claim_screen.dart';
import 'package:finledger/features/expenses/presentation/widgets/expense_status_chip.dart';
import 'package:finledger/features/expenses/presentation/widgets/receipt_badge.dart';

void main() {
  group('Expenses Models & Service Tests', () {
    test('Default expenses and KPIs match Figure 11 (Page 20)', () async {
      final service = ExpenseService();
      final kpis = await service.getExpenseKpis();
      final expenses = await service.getExpenses(tab: 'all');

      // Check KPIs
      expect(kpis.thisMonthPosted, 46320.0);
      expect(kpis.vsPreviousMonthPct, 4.2);
      expect(kpis.awaitingApproval, 14860.0);
      expect(kpis.awaitingClaimsCount, 9);
      expect(kpis.toReimburse, 6215.0);
      expect(kpis.toReimburseClaimsCount, 4);
      expect(kpis.topCategory, 'Travel & Fuel');
      expect(kpis.topCategoryAmount, 12480.0);

      // Verify Row 1: EXP-2026-0233
      final exp1 = expenses.firstWhere((e) => e.expenseNo == 'EXP-2026-0233');
      expect(exp1.employeeName, 'Sara Mathew');
      expect(exp1.categorySummary, 'Travel & Fuel');
      expect(exp1.paidByDisplay, 'Employee');
      expect(exp1.subtotal, 1240.0);
      expect(exp1.taxTotal, 62.0);
      expect(exp1.total, 1302.0);
      expect(exp1.attachmentCount, 2);
      expect(exp1.status, 'SUBMITTED');

      // Verify Row 3: EXP-2026-0231 (DEWA)
      final exp3 = expenses.firstWhere((e) => e.expenseNo == 'EXP-2026-0231');
      expect(exp3.employeeName, 'DEWA');
      expect(exp3.paidByDisplay, 'Company - ENBD');
      expect(exp3.total, 7140.0);
      expect(exp3.status, 'POSTED');

      // Verify Row 6: EXP-2026-0225 (Rejected with missing receipt)
      final exp6 = expenses.firstWhere((e) => e.expenseNo == 'EXP-2026-0225');
      expect(exp6.hasMissingReceipt, isTrue);
      expect(exp6.status, 'REJECTED');
    });

    test('Tabs filter expenses by status and employee correctly', () async {
      final service = ExpenseService();

      // 'my' tab
      final myExpenses = await service.getExpenses(tab: 'my');
      expect(myExpenses.every((e) => e.employeeName == 'Sara Mathew'), isTrue);

      // 'approvals' tab
      final approvalExpenses = await service.getExpenses(tab: 'approvals');
      expect(approvalExpenses.every((e) => e.status == 'SUBMITTED'), isTrue);

      // 'reimburse' tab
      final reimburseExpenses = await service.getExpenses(tab: 'reimburse');
      expect(reimburseExpenses.every((e) => e.status == 'APPROVED' && e.paidBy == 'EMPLOYEE'), isTrue);
    });

    test('Approve, reject, and reimburse workflows update expense statuses', () async {
      final service = ExpenseService();

      // Approve Submitted claim
      final approved = await service.approveExpense(1);
      expect(approved.status, 'APPROVED');

      // Reject Submitted claim
      final rejected = await service.rejectExpense(2, reason: 'Missing tax invoice');
      expect(rejected.status, 'REJECTED');
      expect(rejected.rejectionReason, 'Missing tax invoice');

      // Reimburse Approved claim
      final reimbursed = await service.reimburseExpense(5);
      expect(reimbursed.status, 'REIMBURSED');
    });

    test('Bulk approve and bulk reimburse process multiple claims', () async {
      final service = ExpenseService();

      final approvedCount = await service.bulkApprove([1, 2]);
      expect(approvedCount, 2);

      final reimbursedCount = await service.bulkReimburse([5]);
      expect(reimbursedCount, 1);
    });

    test('Creating expense claim calculates totals and sets status (Figure 12)', () async {
      final service = ExpenseService();

      final lines = [
        const ExpenseLine(
          lineNo: 1,
          categoryId: 1,
          categoryName: 'Travel & Fuel',
          description: 'Fuel DXB ↔ AUH',
          costCenter: 'Sales',
          amount: 280.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 14.00,
          totalAmount: 294.00,
          receiptCount: 1,
        ),
        const ExpenseLine(
          lineNo: 2,
          categoryId: 3,
          categoryName: 'Tolls & Parking',
          description: 'Salik + parking',
          costCenter: 'Sales',
          amount: 96.00,
          taxRateName: 'Exempt',
          taxRatePct: 0.0,
          taxAmount: 0.00,
          totalAmount: 96.00,
          receiptCount: 1,
        ),
        const ExpenseLine(
          lineNo: 3,
          categoryId: 2,
          categoryName: 'Client Meals',
          description: 'Lunch - Al Noor team',
          costCenter: 'Sales',
          amount: 420.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 21.00,
          totalAmount: 441.00,
          receiptCount: 0,
          isReceiptMissing: true,
        ),
      ];

      final net = lines.fold<double>(0.0, (sum, l) => sum + l.amount);
      final vat = lines.fold<double>(0.0, (sum, l) => sum + l.taxAmount);
      final total = lines.fold<double>(0.0, (sum, l) => sum + l.totalAmount);

      expect(net, 796.00);
      expect(vat, 35.00);
      expect(total, 831.00);

      final created = await service.createExpenseClaim(
        Expense(
          id: 0,
          expenseNo: 'EXP-2026-0234',
          expenseDate: '30-Oct-2026',
          paidBy: 'EMPLOYEE',
          paidByDisplay: 'Employee',
          employeeName: 'Sara Mathew',
          purpose: 'Abu Dhabi client visits - Al Noor & Gulf Hospitality',
          categorySummary: 'Travel & Fuel',
          subtotal: net,
          taxTotal: vat,
          total: total,
          lines: lines,
        ),
        submitForApproval: true,
      );

      expect(created.status, 'SUBMITTED');
      expect(created.hasMissingReceipt, isTrue);
    });
  });

  group('Expenses Widget Integration Tests', () {
    testWidgets('ExpensesListScreen renders 4 KPI cards, tabs, and table with chips (Figure 11)', (tester) async {
      final service = ExpenseService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesListScreen(expenseService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Check Breadcrumbs & Title
      expect(find.text('Expenses'), findsWidgets);
      expect(find.text('All Expenses'), findsOneWidget);

      // Check 4 KPI Cards
      expect(find.text('This month (posted)'), findsOneWidget);
      expect(find.text('AED 46,320'), findsOneWidget);
      expect(find.text('Awaiting approval'), findsOneWidget);
      expect(find.text('AED 14,860'), findsOneWidget);
      expect(find.text('To reimburse employees'), findsOneWidget);
      expect(find.text('AED 6,215'), findsOneWidget);
      expect(find.text('Top category'), findsOneWidget);

      // Check Tab Bar
      expect(find.text('All'), findsOneWidget);
      expect(find.text('My expenses'), findsOneWidget);
      expect(find.text('Awaiting my approval'), findsOneWidget);
      expect(find.text('To reimburse'), findsOneWidget);
      expect(find.text('9'), findsWidgets); // Badge in tab

      // Check Toolbar
      expect(find.text('01-Oct-2026 → 31-Oct-2026'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('+ New Expense'), findsOneWidget);

      // Check Table headers & Rows
      expect(find.text('EXP-2026-0233'), findsOneWidget);
      expect(find.text('EXP-2026-0232'), findsOneWidget);
      expect(find.text('EXP-2026-0231'), findsOneWidget);
      expect(find.text('EXP-2026-0229'), findsOneWidget);

      // Check Status Chips
      expect(find.byType(ExpenseStatusChip), findsWidgets);
      expect(find.text('Submitted'), findsWidgets);
      expect(find.text('Posted'), findsWidgets);
      expect(find.text('Approved'), findsWidgets);
      expect(find.text('Rejected'), findsWidgets);

      // Check Receipt Badges
      expect(find.byType(ReceiptBadge), findsWidgets);

      // Check Action buttons
      expect(find.text('Approve'), findsWidgets);
      expect(find.text('Reject'), findsWidgets);
      expect(find.text('Reimburse'), findsWidgets);

      // Check Footer & Bulk Actions
      expect(find.textContaining('Showing 1-8 of 57'), findsOneWidget);
      expect(find.text('Approve selected'), findsOneWidget);
      expect(find.text('Reimburse selected'), findsOneWidget);
    });

    testWidgets('NewExpenseClaimScreen renders Paid by toggle, policy warning, right panel (Figure 12)', (tester) async {
      final service = ExpenseService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: NewExpenseClaimScreen(expenseService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Check Breadcrumbs & Title
      expect(find.text('New Expense Claim'), findsOneWidget);

      // Check Paid by toggle
      expect(find.text('Company'), findsOneWidget);
      expect(find.textContaining('Employee'), findsWidgets);

      // Check Header Inputs
      expect(find.text('Sara Mathew'), findsWidgets);
      expect(find.text('EXP-2026-0234 (auto)'), findsOneWidget);
      expect(find.text('AED'), findsWidgets);
      expect(find.textContaining('Abu Dhabi client visits'), findsOneWidget);

      // Check Line Items
      expect(find.text('Fuel DXB ↔ AUH'), findsOneWidget);
      expect(find.text('Salik + parking'), findsOneWidget);
      expect(find.text('Lunch - Al Noor team'), findsOneWidget);

      // Check Policy Check Warning
      expect(find.textContaining('Client Meals requires a receipt'), findsOneWidget);

      // Check Totals
      expect(find.text('796.00'), findsWidgets);
      expect(find.text('35.00'), findsWidgets);
      expect(find.text('831.00'), findsWidgets);

      // Check Right Panel: Receipts area
      expect(find.text('Receipts'), findsOneWidget);
      expect(find.text('fuel_2910.jpg'), findsOneWidget);
      expect(find.text('salik_oct.pdf'), findsOneWidget);

      // Check Right Panel: Approval Flow Stepper
      expect(find.text('Approval flow'), findsOneWidget);
      expect(find.text('Submitted by Sara Mathew'), findsOneWidget);
      expect(find.text('Line manager — Raj'), findsOneWidget);
      expect(find.text('Finance review (> AED 2,000 only)'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);

      // Check Right Panel: Journal Preview Box
      expect(find.text('On approval posts:'), findsOneWidget);
      expect(find.textContaining('Dr Expense accounts'), findsOneWidget);
      expect(find.textContaining('Cr 2150 Employee Reimbursements'), findsOneWidget);

      // Check Action Buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Draft'), findsOneWidget);
      expect(find.text('Submit for Approval'), findsOneWidget);
    });
  });
}
