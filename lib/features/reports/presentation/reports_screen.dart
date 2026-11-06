import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rounded_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {'title': 'Profit & Loss Statement (P&L)', 'category': 'Financial Statements', 'desc': 'Trading revenue, cost of goods sold (COGS), operating expenses, and net profit margins', 'icon': Icons.trending_up},
      {'title': 'Balance Sheet', 'category': 'Financial Statements', 'desc': 'Assets, liabilities, and retained earnings equity summary', 'icon': Icons.balance_outlined},
      {'title': 'Trial Balance', 'category': 'General Ledger', 'desc': 'Complete listing of all debit and credit account balances verifying ledger equilibrium', 'icon': Icons.account_tree_outlined},
      {'title': 'UAE FTA VAT 201 Return', 'category': 'Tax & Compliance', 'desc': 'Box-by-box breakdown of 5% standard rated sales, zero rated supplies, and recoverable input VAT', 'icon': Icons.receipt_long_outlined},
      {'title': 'Aged Receivables (AR Summary)', 'category': 'Cash Flow & Credit', 'desc': 'Customer balances aged by current, 30, 60, 90+ days overdue', 'icon': Icons.calendar_month_outlined},
      {'title': 'Inventory Valuation & Movement', 'category': 'Operations', 'desc': 'Weighted average cost stock valuations per warehouse and movement log', 'icon': Icons.inventory_2_outlined},
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
                  'Financial Reports & Compliance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Certified double-entry reports, UAE VAT 201 statements, and management intelligence',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('Export Board Pack PDF'),
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
                        'Financial Reports & Compliance',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Certified double-entry reports, UAE VAT 201 statements, and management intelligence',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('Export Board Pack PDF'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 900 ? 2 : 1;
              final isNarrow = constraints.maxWidth < 500;
              final ratio = count == 2 ? 2.8 : (isNarrow ? 1.85 : 2.5);
              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: ratio,
                children: reports.map((r) {
                  return RoundedCard(
                    padding: EdgeInsets.all(isNarrow ? 12 : 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(r['icon'] as IconData, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (r['category'] as String).toUpperCase(),
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.8),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                r['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r['desc'] as String,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                          tooltip: 'Run Report',
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
