import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../data/models/sales_models.dart';
import 'widgets/invoice_pdf_preview_dialog.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _selectedStatusFilter = 'All';

  final List<Map<String, dynamic>> _invoices = [
    {
      'number': 'INV-2026-0895',
      'customer': 'Al Futtaim Engineering LLC',
      'trn': '100029384700003',
      'date': '30-Oct-2026',
      'dueDate': '29-Nov-2026',
      'subtotal': 'AED 40,000.00',
      'vat': 'AED 2,000.00',
      'total': 'AED 42,000.00',
      'balance': 'AED 42,000.00',
      'status': 'Sent',
    },
    {
      'number': 'INV-2026-0894',
      'customer': 'Danube Building Materials',
      'trn': '100492817200003',
      'date': '28-Oct-2026',
      'dueDate': '27-Nov-2026',
      'subtotal': 'AED 18,500.00',
      'vat': 'AED 925.00',
      'total': 'AED 19,425.00',
      'balance': 'AED 9,425.00',
      'status': 'Partial',
    },
    {
      'number': 'INV-2026-0893',
      'customer': 'Sobha Developers Ltd',
      'trn': '100182736400003',
      'date': '24-Oct-2026',
      'dueDate': '23-Nov-2026',
      'subtotal': 'AED 110,000.00',
      'vat': 'AED 5,500.00',
      'total': 'AED 115,500.00',
      'balance': 'AED 0.00',
      'status': 'Paid',
    },
    {
      'number': 'INV-2026-0892',
      'customer': 'Arabtec Construction LLC',
      'trn': '100918273600003',
      'date': '15-Sep-2026',
      'dueDate': '15-Oct-2026',
      'subtotal': 'AED 54,000.00',
      'vat': 'AED 2,700.00',
      'total': 'AED 56,700.00',
      'balance': 'AED 56,700.00',
      'status': 'Overdue',
    },
    {
      'number': 'INV-2026-0891',
      'customer': 'Emirates Post Group',
      'trn': '100374829100003',
      'date': '30-Oct-2026',
      'dueDate': '30-Nov-2026',
      'subtotal': 'AED 8,000.00',
      'vat': 'AED 400.00',
      'total': 'AED 8,400.00',
      'balance': 'AED 8,400.00',
      'status': 'Draft',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs & Header
          _buildHeader(context, isMobile),
          const SizedBox(height: 20),

          // Status Summary Cards (Draft, Sent, Partial, Paid, Overdue)
          _buildStatusSummaryCards(),
          const SizedBox(height: 20),

          // Filters & Invoices Table
          _buildInvoiceListCard(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final breadcrumbs = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => context.go('/dashboard'),
          child: Text(context.l10n.home, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
        const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(context.l10n.sales, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        breadcrumbs,
        const SizedBox(height: 6),
        Text(
          context.l10n.salesInvoicesTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.salesInvoicesSubtitle,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
      ],
    );

    final actionButtons = Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go('/sales/receipts/new'),
          icon: const Icon(Icons.receipt_outlined, size: 16, color: AppColors.textSecondary),
          label: Text(context.l10n.customerReceipts, style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            minimumSize: const Size(0, 40),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/sales/invoices/new'),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: Text(context.l10n.createTaxInvoice, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            minimumSize: const Size(0, 40),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleColumn,
          const SizedBox(height: 14),
          actionButtons,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleColumn),
        const SizedBox(width: 16),
        actionButtons,
      ],
    );
  }

  Widget _buildStatusSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 1000
            ? 5
            : (constraints.maxWidth > 650 ? 3 : (constraints.maxWidth > 420 ? 2 : 1));
        final ratio = count >= 5 ? 2.1 : (count >= 2 ? 2.4 : 3.0);

        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: ratio,
          children: [
            _buildStatusCard(context.l10n.statusDraft.toUpperCase(), '2 ${context.l10n.invoices}', 'AED 18,400', AppColors.draft, AppColors.draftBg),
            _buildStatusCard(context.l10n.statusSent.toUpperCase(), '8 ${context.l10n.invoices}', 'AED 164,200', AppColors.sent, AppColors.sentBg),
            _buildStatusCard(context.l10n.statusPartiallyPaid.toUpperCase(), '4 ${context.l10n.invoices}', 'AED 48,500', AppColors.partial, AppColors.partialBg),
            _buildStatusCard(context.l10n.statusPaid.toUpperCase(), '42 ${context.l10n.invoices}', 'AED 840,000', AppColors.paid, AppColors.paidBg),
            _buildStatusCard(context.l10n.statusOverdue.toUpperCase(), '5 ${context.l10n.invoices}', 'AED 56,700', AppColors.overdue, AppColors.overdueBg),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(String title, String count, String total, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              total,
              maxLines: 1,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
          Text(
            count,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceListCard() {
    return RoundedCard(
      title: 'Tax Invoices',
      subtitle: 'Sorted by invoice issue date (descending)',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter Chips
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatusFilter,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                items: ['All', 'Draft', 'Sent', 'Partial', 'Paid', 'Overdue']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12.5))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatusFilter = val);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoices exported to CSV successfully.'),
                  backgroundColor: AppColors.paid,
                ),
              );
            },
            tooltip: 'Export CSV',
            icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.textSecondary),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 42,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 52,
          headingRowColor: const WidgetStatePropertyAll(Color(0xFFF8FAFC)),
          columns: [
            DataColumn(label: Text(context.l10n.invoiceNumber.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            DataColumn(label: Text(context.l10n.customer.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            DataColumn(label: Text(context.l10n.issueDate.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            DataColumn(label: Text(context.l10n.dueDate.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            DataColumn(label: Text(context.l10n.totalAmount.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            DataColumn(label: Text(context.l10n.balanceDue.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            DataColumn(label: Text(context.l10n.status.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            DataColumn(label: Text(context.l10n.actions.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
          ],
          rows: _invoices.map((inv) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    inv['number'],
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2563EB), fontSize: 13),
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(inv['customer'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('TRN: ${inv['trn']}', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                DataCell(Text(inv['date'], style: const TextStyle(fontSize: 12))),
                DataCell(Text(inv['dueDate'], style: const TextStyle(fontSize: 12))),
                DataCell(Text(inv['total'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                DataCell(
                  Text(
                    inv['balance'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: inv['balance'] == 'AED 0.00' ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                ),
                DataCell(StatusChip.fromStatusString(inv['status'])),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          final invObj = Invoice(
                            id: 1,
                            invoiceNo: inv['number'] ?? 'INV-2026-001',
                            customerId: 1,
                            customerName: inv['customer'] ?? 'Customer',
                            customerTrn: inv['trn'] ?? '100234891000003',
                            customerAddress: 'Building 4, Al Quoz, Dubai, UAE',
                            invoiceDate: inv['date'] ?? '28-Oct-2026',
                            dueDate: inv['dueDate'] ?? '27-Nov-2026',
                            paymentTerms: 'Net 30',
                            currencyCode: 'AED',
                            subtotal: 10000.0,
                            taxTotal: 500.0,
                            total: 10500.0,
                            amountPaid: 0.0,
                            balanceDue: 10500.0,
                            status: inv['status'] ?? 'SENT',
                            lines: const [],
                          );
                          showDialog(
                            context: context,
                            builder: (ctx) => InvoicePdfPreviewDialog(invoice: invObj),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFF2563EB)),
                        tooltip: 'Download Tax PDF',
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tax Invoice ${inv['number']} sent to ${inv['customer']} successfully.'),
                              backgroundColor: AppColors.paid,
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_outlined, size: 16, color: AppColors.textSecondary),
                        tooltip: 'Send to Customer',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
