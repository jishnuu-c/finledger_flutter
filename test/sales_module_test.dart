import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finledger/features/sales/data/models/sales_models.dart';
import 'package:finledger/features/sales/data/services/sales_service.dart';
import 'package:finledger/features/sales/presentation/sales_invoices_list_screen.dart';
import 'package:finledger/features/sales/presentation/create_tax_invoice_screen.dart';
import 'package:finledger/features/sales/presentation/record_customer_receipt_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Sales Service & Invoices Tests', () {
    test('Default invoices match Figure 6 (Page 15)', () async {
      final service = SalesService();
      final invoices = await service.getInvoices();
      final kpis = await service.getInvoiceKpis();

      // Check 4 KPI summary cards
      expect(kpis.draftCount, 6);
      expect(kpis.unpaidAmount, 271320.00);
      expect(kpis.overdueAmount, 113600.00);
      expect(kpis.paidThisMonthAmount, 196450.00);

      // Check invoices matching Figure 6
      expect(invoices.length, 7);
      expect(invoices[0].invoiceNo, 'INV-2026-0412');
      expect(invoices[0].customerName, 'Al Noor Facilities Mgmt');
      expect(invoices[0].total, 42525.00);
      expect(invoices[0].balanceDue, 42525.00);
      expect(invoices[0].status, 'SENT');

      expect(invoices[1].invoiceNo, 'INV-2026-0411');
      expect(invoices[1].customerName, 'Gulf Hospitality Group');
      expect(invoices[1].status, 'PAID');
      expect(invoices[1].balanceDue, 0.0);

      expect(invoices[2].invoiceNo, 'INV-2026-0410');
      expect(invoices[2].customerName, 'Riyadh Medical Centre');
      expect(invoices[2].status, 'PARTIAL');
      expect(invoices[2].balanceDue, 30000.00);

      expect(invoices[3].invoiceNo, 'INV-2026-0405');
      expect(invoices[3].customerName, 'Sharjah Schools Co.');
      expect(invoices[3].status, 'OVERDUE');

      expect(invoices[5].invoiceNo, 'INV-2026-0413');
      expect(invoices[5].customerName, 'Desert Rose Hotels');
      expect(invoices[5].status, 'DRAFT');
    });

    test('Filtering invoices by status and search works properly', () async {
      final service = SalesService();

      // Search by invoice #
      final searchResult = await service.getInvoices(search: 'INV-2026-0410');
      expect(searchResult.length, 1);
      expect(searchResult.first.customerName, 'Riyadh Medical Centre');

      // Filter by status Paid
      final paidInvoices = await service.getInvoices(status: 'Paid');
      expect(paidInvoices.length, 2);
      for (final inv in paidInvoices) {
        expect(inv.status, 'PAID');
      }

      // Filter by status Overdue
      final overdueInvoices = await service.getInvoices(status: 'Overdue');
      expect(overdueInvoices.length, 2);
      for (final inv in overdueInvoices) {
        expect(inv.status, 'OVERDUE');
      }
    });

    test('Create Tax Invoice validates lines and calculates totals', () async {
      final service = SalesService();

      // Creating invoice with no lines throws
      expect(
        () async => await service.createInvoice(
          invoice: const Invoice(
            id: 0,
            invoiceNo: 'INV-TEST',
            customerId: 1,
            customerName: 'Test',
            invoiceDate: '30-Oct-2026',
            dueDate: '29-Nov-2026',
            subtotal: 0,
            taxTotal: 0,
            total: 0,
            balanceDue: 0,
            status: 'DRAFT',
            lines: [],
          ),
        ),
        throwsA(isA<Exception>()),
      );

      // Create invoice matching Figure 7
      final created = await service.createInvoice(
        invoice: const Invoice(
          id: 0,
          invoiceNo: 'INV-2026-0414',
          customerId: 1,
          customerName: 'Al Noor Facilities Mgmt',
          invoiceDate: '30-Oct-2026',
          dueDate: '29-Nov-2026',
          subtotal: 0,
          taxTotal: 0,
          total: 0,
          balanceDue: 0,
          status: 'DRAFT',
          lines: [
            InvoiceLine(
              itemCode: 'BSB-AP500',
              description: 'HEPA Air Purifier 500',
              quantity: 10,
              unitPrice: 3200.0,
              discountPct: 5,
              taxRatePct: 5,
              taxAmount: 0,
              lineTotal: 0,
            ),
            InvoiceLine(
              itemCode: 'BSB-FLT-H13',
              description: 'H13 Replacement Filter',
              quantity: 20,
              unitPrice: 450.0,
              discountPct: 0,
              taxRatePct: 5,
              taxAmount: 0,
              lineTotal: 0,
            ),
            InvoiceLine(
              itemCode: 'SRV-INST',
              description: 'Installation service',
              quantity: 1,
              unitPrice: 1100.0,
              discountPct: 0,
              taxRatePct: 5,
              taxAmount: 0,
              lineTotal: 0,
            ),
          ],
        ),
        send: true,
      );

      // Verify recalculated totals matching Figure 7
      expect(created.status, 'SENT');
      expect(created.subtotal, 40500.00); // 30400 + 9000 + 1100
      expect(created.taxTotal, 2025.00); // 5% on 40500
      expect(created.total, 42525.00);
      expect(created.balanceDue, 42525.00);
    });
  });

  group('Customer Receipts & Auto-Allocation Tests', () {
    test('Auto-allocation oldest-first allocates correctly (Figure 8)', () async {
      final service = SalesService();
      final openInvoices = await service.getCustomerOpenInvoices(3); // Riyadh Medical Centre

      expect(openInvoices.length, 3);
      expect(openInvoices[0].invoiceNo, 'INV-2026-0410');
      expect(openInvoices[0].outstanding, 30000.00);
      expect(openInvoices[1].invoiceNo, 'INV-2026-0388');
      expect(openInvoices[1].outstanding, 3000.00);
      expect(openInvoices[2].invoiceNo, 'INV-2026-0415');
      expect(openInvoices[2].outstanding, 8400.00);

      // Allocate 33,000.00 received
      final allocated = service.autoAllocateOldestFirst(
        openInvoices: openInvoices,
        amountReceived: 33000.00,
      );

      expect(allocated[0].appliedPayment, 30000.00);
      expect(allocated[0].isSelected, true);
      expect(allocated[1].appliedPayment, 3000.00);
      expect(allocated[1].isSelected, true);
      expect(allocated[2].appliedPayment, 0.00);
      expect(allocated[2].isSelected, false);
    });

    test('Creating receipt validates amounts and updates invoice balances', () async {
      final service = SalesService();

      // Allocating more than received throws error
      expect(
        () async => await service.createReceipt(
          customerId: 3,
          customerName: 'Riyadh Medical Centre',
          receiptDate: '30-Oct-2026',
          depositToAccountId: 3,
          depositToAccountName: '1110 – Emirates NBD Current',
          paymentMethod: 'Bank Transfer',
          amount: 20000.00,
          allocatedInvoices: const [
            CustomerOpenInvoice(
              invoiceId: 410,
              invoiceNo: 'INV-2026-0410',
              invoiceDate: '25-Oct-2026',
              total: 63000.00,
              outstanding: 30000.00,
              appliedPayment: 30000.00, // 30,000 > 20,000
            ),
          ],
        ),
        throwsA(isA<Exception>()),
      );

      // Create valid receipt matching Figure 8
      final receipt = await service.createReceipt(
        customerId: 3,
        customerName: 'Riyadh Medical Centre',
        receiptDate: '30-Oct-2026',
        depositToAccountId: 3,
        depositToAccountName: '1110 – Emirates NBD Current',
        paymentMethod: 'Bank Transfer',
        reference: 'TT-889123',
        amount: 33000.00,
        allocatedInvoices: const [
          CustomerOpenInvoice(
            invoiceId: 410,
            invoiceNo: 'INV-2026-0410',
            invoiceDate: '25-Oct-2026',
            total: 63000.00,
            outstanding: 30000.00,
            appliedPayment: 30000.00,
          ),
          CustomerOpenInvoice(
            invoiceId: 388,
            invoiceNo: 'INV-2026-0388',
            invoiceDate: '18-Aug-2026',
            total: 12600.00,
            outstanding: 3000.00,
            appliedPayment: 3000.00,
          ),
        ],
      );

      expect(receipt.receiptNo.startsWith('RCT-2026-'), true);
      expect(receipt.amount, 33000.00);
      expect(receipt.appliedAmount, 33000.00);
      expect(receipt.unappliedAmount, 0.00);

      // Verify invoice 410 was updated to PAID
      final invoices = await service.getInvoices();
      final inv410 = invoices.firstWhere((i) => i.id == 410);
      expect(inv410.balanceDue, 0.00);
      expect(inv410.status, 'PAID');
    });
  });

  group('Sales Widget Integration Tests', () {
    testWidgets('SalesInvoicesListScreen renders KPI cards, table and chips (Figure 6)', (tester) async {
      final service = SalesService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: SalesInvoicesListScreen(salesService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Check Breadcrumbs & Title
      expect(find.text('Sales Invoices'), findsOneWidget);
      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('Invoices'), findsWidgets);

      // Check 4 KPI summary cards
      expect(find.text('Draft'), findsWidgets);
      expect(find.text('Unpaid'), findsOneWidget);
      expect(find.text('Overdue'), findsWidgets);
      expect(find.text('Paid (this month)'), findsOneWidget);
      expect(find.text('AED 271,320'), findsOneWidget);
      expect(find.text('AED 113,600'), findsOneWidget);
      expect(find.text('AED 196,450'), findsOneWidget);

      // Check filter bar
      expect(find.text('Search invoice / customer...'), findsOneWidget);
      expect(find.text('All Status'), findsOneWidget);
      expect(find.text('01-Oct-2026 → 31-Oct-2026'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('+ New Invoice'), findsOneWidget);

      // Check Table columns & rows
      expect(find.text('Invoice #'), findsOneWidget);
      expect(find.text('INV-2026-0412'), findsOneWidget);
      expect(find.text('INV-2026-0411'), findsOneWidget);
      expect(find.text('INV-2026-0410'), findsOneWidget);
      expect(find.text('Al Noor Facilities Mgmt'), findsWidgets);

      // Check status chips
      expect(find.text('Sent'), findsWidgets);
      expect(find.text('Paid'), findsWidgets);
      expect(find.text('Partial'), findsWidgets);

      // Check Pagination footer
      expect(find.textContaining('Showing 1-7 of 42'), findsOneWidget);
    });

    testWidgets('CreateTaxInvoiceScreen renders customer picker, lines grid and totals (Figure 7)', (tester) async {
      final service = SalesService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: CreateTaxInvoiceScreen(salesService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Check Title
      expect(find.text('New Tax Invoice'), findsOneWidget);

      // Check Customer picker & TRN subtext
      expect(find.text('Customer *'), findsOneWidget);
      expect(find.text('Al Noor Facilities Mgmt'), findsOneWidget);
      expect(find.textContaining('TRN: 100234567800003'), findsOneWidget);

      // Check Invoice No & Terms
      expect(find.text('Invoice No.'), findsOneWidget);
      expect(find.text('INV-2026-0414'), findsOneWidget);
      expect(find.text('Net 30'), findsOneWidget);

      // Check Line items
      expect(find.text('BSB-AP500'), findsOneWidget);
      expect(find.text('BSB-FLT-H13'), findsOneWidget);
      expect(find.text('SRV-INST'), findsOneWidget);

      // Check Totals
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('40,500.00'), findsOneWidget);
      expect(find.text('VAT (5%)'), findsOneWidget);
      expect(find.text('2,025.00'), findsOneWidget);
      expect(find.text('Total (AED)'), findsOneWidget);
      expect(find.text('42,525.00'), findsOneWidget);

      // Check Action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Draft'), findsOneWidget);
      expect(find.text('Preview PDF'), findsOneWidget);
      expect(find.text('Save & Send'), findsOneWidget);
    });

    testWidgets('RecordCustomerReceiptScreen renders auto-allocation and auto journal (Figure 8)', (tester) async {
      final service = SalesService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: RecordCustomerReceiptScreen(salesService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Check Title
      expect(find.text('Record Customer Receipt'), findsOneWidget);

      // Check Form inputs
      expect(find.text('Customer *'), findsOneWidget);
      expect(find.text('Riyadh Medical Centre'), findsOneWidget);
      expect(find.text('Deposit To *'), findsOneWidget);
      expect(find.text('1110 – Emirates NBD Current'), findsOneWidget);
      expect(find.text('Bank Transfer'), findsOneWidget);
      expect(find.text('33,000.00'), findsWidgets);
      expect(find.text('TT-889123'), findsOneWidget);

      // Check Apply to Outstanding Invoices table
      expect(find.text('Apply to Outstanding Invoices'), findsOneWidget);
      expect(find.text('INV-2026-0410'), findsOneWidget);
      expect(find.text('INV-2026-0388'), findsOneWidget);
      expect(find.text('INV-2026-0415'), findsOneWidget);

      // Check Summary Card
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Amount received'), findsOneWidget);
      expect(find.text('Applied to invoices'), findsOneWidget);
      expect(find.text('Unapplied (advance)'), findsOneWidget);

      // Check Live Auto journal preview
      expect(find.text('Auto journal:'), findsOneWidget);
      expect(find.textContaining('Dr 1110 Emirates NBD'), findsOneWidget);
      expect(find.textContaining('Cr 1200 Accounts Receivable'), findsOneWidget);

      // Check Save Receipt Button
      expect(find.text('Save Receipt'), findsOneWidget);
    });
  });
}
