import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/status_chip.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final claims = [
      {'id': 'EXP-2026-0119', 'employee': 'Tariq Mansoor', 'title': 'Abu Dhabi Client Meeting & Fuel', 'category': 'Travel & Fuel', 'date': '28-Oct-2026', 'amount': 'AED 1,450.00', 'receipts': '2 receipts', 'status': 'Pending Approval'},
      {'id': 'EXP-2026-0118', 'employee': 'Sara Khalil', 'title': 'Software Subscription & Cloud API', 'category': 'IT & Subscriptions', 'date': '26-Oct-2026', 'amount': 'AED 3,820.00', 'receipts': '1 receipt', 'status': 'Pending Approval'},
      {'id': 'EXP-2026-0117', 'employee': 'Ahmed Al Hamri', 'title': 'Audit & Legal Compliance Filing', 'category': 'Legal & Professional', 'date': '24-Oct-2026', 'amount': 'AED 12,000.00', 'receipts': '3 receipts', 'status': 'Approved'},
      {'id': 'EXP-2026-0116', 'employee': 'Zaid Rashid', 'title': 'Warehouse Packaging Tools', 'category': 'Office & Warehouse Supplies', 'date': '21-Oct-2026', 'amount': 'AED 840.00', 'receipts': '1 receipt', 'status': 'Reimbursed'},
    ];

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expenses & Employee Claims',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Track corporate spend, receipt attachments, approval workflow & employee reimbursements',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Batch Approve'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('+ New Expense Claim'),
                    ),
                  ],
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
                        'Expenses & Employee Claims',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Track corporate spend, receipt attachments, approval workflow & employee reimbursements',
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
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Batch Approve'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('+ New Expense Claim'),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          RoundedCard(
            title: 'Expense Claims & Approvals',
            subtitle: '6 claims pending controller approval (Total AED 48,500.00)',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 800),
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 48,
                columns: const [
                  DataColumn(label: Text('CLAIM #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('EMPLOYEE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('AMOUNT (AED)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('RECEIPT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ACTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ],
                rows: claims.map((c) {
                  return DataRow(
                    cells: [
                      DataCell(Text(c['id']!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13))),
                      DataCell(Text(c['employee']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      DataCell(Text(c['title']!, style: const TextStyle(fontSize: 12.5))),
                      DataCell(Text(c['category']!, style: const TextStyle(fontSize: 12))),
                      DataCell(Text(c['date']!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                      DataCell(Text(c['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataCell(
                        Row(
                          children: [
                            const Icon(Icons.attach_file, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(c['receipts']!, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      DataCell(StatusChip.fromStatusString(c['status']!)),
                      DataCell(
                        c['status'] == 'Pending Approval'
                            ? Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.check, color: AppColors.paid, size: 18),
                                    tooltip: 'Approve',
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.close, color: AppColors.overdue, size: 18),
                                    tooltip: 'Reject',
                                  ),
                                ],
                              )
                            : const Text('—', style: TextStyle(color: AppColors.textMuted)),
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
