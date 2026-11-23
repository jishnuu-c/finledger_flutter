import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/locale_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  void _exportBoardPack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.boardPackSuccess),
        backgroundColor: AppColors.paid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = [
      {'code': 'pnl', 'title': 'Profit & Loss Statement (P&L)', 'category': 'Financial Statements', 'desc': 'Trading revenue, cost of goods sold (COGS), operating expenses, and net profit margins', 'icon': Icons.trending_up},
      {'code': 'balance-sheet', 'title': 'Balance Sheet', 'category': 'Financial Statements', 'desc': 'Assets, liabilities, and retained earnings equity summary', 'icon': Icons.balance_outlined},
      {'code': 'trial-balance', 'title': 'Trial Balance', 'category': 'General Ledger', 'desc': 'Complete listing of all debit and credit account balances verifying ledger equilibrium', 'icon': Icons.account_tree_outlined},
      {'code': 'vat-return', 'title': 'UAE FTA VAT 201 Return', 'category': 'Tax & Compliance', 'desc': 'Box-by-box breakdown of 5% standard rated sales, zero rated supplies, and recoverable input VAT', 'icon': Icons.receipt_long_outlined},
      {'code': 'ar-ageing', 'title': 'Aged Receivables (AR Summary)', 'category': 'Cash Flow & Credit', 'desc': 'Customer balances aged by current, 30, 60, 90+ days overdue', 'icon': Icons.calendar_month_outlined},
      {'code': 'stock-valuation', 'title': 'Inventory Valuation & Movement', 'category': 'Operations', 'desc': 'Weighted average cost stock valuations per warehouse and movement log', 'icon': Icons.inventory_2_outlined},
    ];

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                onTap: () => context.go('/dashboard'),
                child: Text(context.l10n.home, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
              const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(context.l10n.reports, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),

          // Header
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.reportsTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.reportsSubtitle,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _exportBoardPack(context),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFF2563EB)),
                  label: Text(context.l10n.exportBoardPackPdf, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.reportsTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.reportsSubtitle,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _exportBoardPack(context),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFF2563EB)),
                  label: Text(context.l10n.exportBoardPackPdf, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),

          // Reports Directory Grid (Wrap-based for zero aspect-ratio overflow)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 840;
              final cardWidth = isDesktop
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: reports.map((r) {
                  final code = r['code'] as String;
                  return SizedBox(
                    width: cardWidth,
                    child: InkWell(
                      onTap: () => context.go('/reports/$code'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(r['icon'] as IconData, color: const Color(0xFF2563EB), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (r['category'] as String).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    r['title'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    r['desc'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
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
