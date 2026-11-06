import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/status_chip.dart';

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
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Invoices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage UAE VAT compliant tax invoices, credit notes, and customer receipts',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_outlined, size: 16),
                label: const Text('+ Customer Receipt'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ Create Tax Invoice'),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales Invoices',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage UAE VAT compliant tax invoices, credit notes, and customer receipts',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.receipt_outlined, size: 16),
              label: const Text('+ Customer Receipt'),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+ Create Tax Invoice'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 1000 ? 5 : (constraints.maxWidth > 600 ? 3 : (constraints.maxWidth > 400 ? 2 : 1));
        final ratio = count >= 5 ? 2.2 : (count >= 2 ? 2.5 : 3.2);
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: ratio,
          children: [
            _buildStatusCard('DRAFT', '2 Invoices', 'AED 18,400', AppColors.draft, AppColors.draftBg),
            _buildStatusCard('SENT', '8 Invoices', 'AED 164,200', AppColors.sent, AppColors.sentBg),
            _buildStatusCard('PARTIAL', '4 Invoices', 'AED 48,500', AppColors.partial, AppColors.partialBg),
            _buildStatusCard('PAID', '42 Invoices', 'AED 840,000', AppColors.paid, AppColors.paidBg),
            _buildStatusCard('OVERDUE', '5 Invoices', 'AED 56,700', AppColors.overdue, AppColors.overdueBg),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(String title, String count, String total, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
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
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
              ),
              Container(
                width: 8,
                height: 8,
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
          DropdownButton<String>(
            value: _selectedStatusFilter,
            underline: const SizedBox(),
            items: ['All', 'Draft', 'Sent', 'Partial', 'Paid', 'Overdue']
                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedStatusFilter = val);
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            tooltip: 'Export CSV',
            icon: const Icon(Icons.download_rounded, size: 18),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 42,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 52,
          columns: const [
            DataColumn(label: Text('INVOICE #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('CUSTOMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ISSUE DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('DUE DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('TOTAL (AED)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('BALANCE (AED)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          ],
          rows: _invoices.map((inv) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    inv['number'],
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13),
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
                        onPressed: () {},
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.primary),
                        tooltip: 'Download Tax PDF',
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send_outlined, size: 16, color: AppColors.textSecondary),
                        tooltip: 'Send to Customer',
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
