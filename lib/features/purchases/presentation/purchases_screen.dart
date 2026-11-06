import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/status_chip.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bills = [
      {'num': 'BIL-2026-0344', 'vendor': 'Gulf Petrochem Distribution', 'date': '28-Oct-2026', 'dueDate': '27-Nov-2026', 'amount': 'AED 78,120.00', 'status': 'Partial'},
      {'num': 'BIL-2026-0343', 'vendor': 'Schneider Electric UAE', 'date': '20-Oct-2026', 'dueDate': '19-Nov-2026', 'amount': 'AED 44,500.00', 'status': 'Paid'},
      {'num': 'BIL-2026-0342', 'vendor': 'Al Habtoor Motors Spares', 'date': '14-Oct-2026', 'dueDate': '13-Nov-2026', 'amount': 'AED 29,800.00', 'status': 'Paid'},
      {'num': 'BIL-2026-0341', 'vendor': 'Canon Middle East FZ', 'date': '02-Oct-2026', 'dueDate': '01-Nov-2026', 'amount': 'AED 12,350.00', 'status': 'Draft'},
    ];

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Purchases & Vendor Bills',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Procure-to-pay cycle: Vendor purchase bills, debit notes, and payment orders',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ Enter Vendor Bill'),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchases & Vendor Bills',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Procure-to-pay cycle: Vendor purchase bills, debit notes, and payment orders',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ Enter Vendor Bill'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          RoundedCard(
            title: 'Vendor Bills & Payables (AP)',
            subtitle: 'AED 195,400 total active payables',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 720),
                child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                columns: const [
                  DataColumn(label: Text('BILL #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('VENDOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('BILL DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('DUE DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('AMOUNT (AED)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ],
                rows: bills.map((b) {
                  return DataRow(
                    cells: [
                      DataCell(Text(b['num']!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13))),
                      DataCell(Text(b['vendor']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      DataCell(Text(b['date']!, style: const TextStyle(fontSize: 12))),
                      DataCell(Text(b['dueDate']!, style: const TextStyle(fontSize: 12))),
                      DataCell(Text(b['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataCell(StatusChip.fromStatusString(b['status']!)),
                      DataCell(
                        TextButton(
                          onPressed: () {},
                          child: const Text('Record Payment', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }
}
