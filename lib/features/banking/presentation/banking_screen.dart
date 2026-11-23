import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../shared/widgets/rounded_card.dart';
import 'widgets/import_statement_modal.dart';

class BankingScreen extends StatelessWidget {
  const BankingScreen({super.key});

  void _openImportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ImportStatementModal(
        onImport: (csvData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.importStatementCsv),
              backgroundColor: AppColors.paid,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb & Page Header
          _buildHeader(context, isMobile),
          const SizedBox(height: 20),

          // Bank Accounts Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 920
                  ? 3
                  : constraints.maxWidth > 580
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: count == 3 ? 2.3 : (count == 2 ? 2.1 : 2.4),
                children: [
                  _buildBankAccountCard(
                    title: 'Emirates NBD - Main Operating',
                    iban: 'IBAN: AE12 0330 0000 0012 3456 789',
                    balance: 'AED 540,250.00',
                    status: 'Statement matched 100%',
                    statusColor: AppColors.paid,
                    accountType: 'Current Account',
                  ),
                  _buildBankAccountCard(
                    title: 'Mashreq Bank - Payroll Account',
                    iban: 'IBAN: AE44 0310 0000 0098 7654 321',
                    balance: 'AED 240,000.00',
                    status: 'All salaries cleared',
                    statusColor: AppColors.paid,
                    accountType: 'Payroll Account',
                  ),
                  _buildBankAccountCard(
                    title: 'First Abu Dhabi Bank (FAB) - USD',
                    iban: 'IBAN: AE89 0280 0000 0055 4433 221',
                    balance: 'USD 45,200.00 (~AED 166,000)',
                    status: '2 pending matches',
                    statusColor: AppColors.partial,
                    accountType: 'Forex Account',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Bank Statement Matcher (Reconciliation Assistant)
          RoundedCard(
            title: 'Bank Statement Matcher',
            subtitle: 'Comparing imported bank transactions against FinLedger General Ledger receipts and payments',
            trailing: OutlinedButton.icon(
              onPressed: () => context.go('/banking/reconciliation'),
              icon: const Icon(Icons.open_in_new_rounded, size: 14),
              label: Text(context.l10n.reconciliation),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
            child: Column(
              children: [
                _buildMatchingRow(
                  context: context,
                  date: '30-Oct-2026',
                  desc: 'Customer Transfer: Al Futtaim Engineering',
                  amount: 'AED 42,000.00',
                  matchInfo: 'Matched to INV-2026-0895',
                  isMatched: true,
                ),
                const Divider(height: 18, color: AppColors.border),
                _buildMatchingRow(
                  context: context,
                  date: '29-Oct-2026',
                  desc: 'Cheque Clearance: Gulf Petrochem Distribution',
                  amount: '-AED 39,060.00',
                  matchInfo: 'Matched to BIL-2026-0344 (Partial 50%)',
                  isMatched: true,
                ),
                const Divider(height: 18, color: AppColors.border),
                _buildMatchingRow(
                  context: context,
                  date: '28-Oct-2026',
                  desc: 'FAB Merchant POS Terminal Settlement',
                  amount: 'AED 14,820.00',
                  matchInfo: 'Auto-matched via Daily POS Summary',
                  isMatched: true,
                ),
                const Divider(height: 18, color: AppColors.border),
                _buildMatchingRow(
                  context: context,
                  date: '27-Oct-2026',
                  desc: 'Bank Service Maintenance Charge & VAT',
                  amount: '-AED 157.50',
                  matchInfo: 'Suggest GL Account: 6150 (Bank Charges)',
                  isMatched: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb
        Row(
          children: [
            Text(
              context.l10n.home,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 6),
              child: Text('›', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            ),
            Text(
              context.l10n.bankingTitle,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Title and actions
        if (isMobile) ...[
          Text(
            context.l10n.bankingTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.bankingSubtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/banking/reconciliation'),
                icon: const Icon(Icons.sync_alt_rounded, size: 16),
                label: Text(context.l10n.reconciliation),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openImportModal(context),
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: Text(context.l10n.importBankStatement),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 8),
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
                      context.l10n.bankingTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.bankingSubtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.go('/banking/reconciliation'),
                    icon: const Icon(Icons.sync_alt_rounded, size: 16),
                    label: Text(context.l10n.bankReconciliation),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openImportModal(context),
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: Text(context.l10n.importBankStatement),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBankAccountCard({
    required String title,
    required String iban,
    required String balance,
    required String status,
    required Color statusColor,
    required String accountType,
  }) {
    return Container(
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      accountType,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            iban,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    balance,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingRow({
    required BuildContext context,
    required String date,
    required String desc,
    required String amount,
    required String matchInfo,
    required bool isMatched,
  }) {
    final isNegative = amount.startsWith('-');
    final amountColor = isNegative ? AppColors.overdue : AppColors.paid;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isMatched
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isMatched
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Text(
                        matchInfo,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isMatched ? const Color(0xFF166534) : const Color(0xFFB45309),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.go('/banking/reconciliation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMatched ? AppColors.paid : AppColors.primary,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      isMatched ? 'Reconciled' : 'Reconcile',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: 85,
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isMatched
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isMatched
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Text(
                      matchInfo,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isMatched ? const Color(0xFF166534) : const Color(0xFFB45309),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 14),
            ElevatedButton(
              onPressed: () => context.go('/banking/reconciliation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isMatched ? AppColors.paid : AppColors.primary,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                isMatched ? 'Reconciled' : 'Reconcile',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
