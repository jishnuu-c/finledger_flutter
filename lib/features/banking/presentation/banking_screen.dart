import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rounded_card.dart';

class BankingScreen extends StatelessWidget {
  const BankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
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
                  'Bank Accounts & Treasury',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bank feeds, statement reconciliation, transaction matching & auto-clearing',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/banking/reconciliation'),
                      icon: const Icon(Icons.sync_alt, size: 16),
                      label: const Text('Reconciliation'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file_outlined, size: 16),
                      label: const Text('Import Statement (OFX/CSV)'),
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
                        'Bank Accounts & Treasury',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bank feeds, statement reconciliation, transaction matching & auto-clearing',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                      icon: const Icon(Icons.sync_alt, size: 16),
                      label: const Text('Bank Reconciliation'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file_outlined, size: 16),
                      label: const Text('Import Statement (OFX/CSV)'),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Bank Accounts Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 900
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
                childAspectRatio: count == 3 ? 2.4 : (count == 2 ? 2.0 : 2.4),
                children: [
                  _buildBankAccountCard(
                    'Emirates NBD - Main Operating',
                    'IBAN: AE12 0330 0000 0012 3456 789',
                    'AED 540,250.00',
                    'Statement matched 100%',
                    AppColors.paid,
                  ),
                  _buildBankAccountCard(
                    'Mashreq Bank - Payroll Account',
                    'IBAN: AE44 0310 0000 0098 7654 321',
                    'AED 240,000.00',
                    'All salaries cleared',
                    AppColors.paid,
                  ),
                  _buildBankAccountCard(
                    'First Abu Dhabi Bank (FAB) - USD',
                    'IBAN: AE89 0280 0000 0055 4433 221',
                    'USD 45,200.00 (~AED 166,000)',
                    '2 pending matches',
                    AppColors.partial,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Reconciliation Assistant
          RoundedCard(
            title: 'Bank Statement Matcher',
            subtitle: 'Comparing imported bank transactions against FinLedger General Ledger receipts and payments',
            child: Column(
              children: [
                _buildMatchingRow(
                  '30-Oct-2026',
                  'Customer Transfer: Al Futtaim Engineering',
                  'AED 42,000.00',
                  'Matched to INV-2026-0895',
                  true,
                ),
                const Divider(height: 16),
                _buildMatchingRow(
                  '29-Oct-2026',
                  'Cheque Clearance: Gulf Petrochem Distribution',
                  '-AED 39,060.00',
                  'Matched to BIL-2026-0344 (Partial 50%)',
                  true,
                ),
                const Divider(height: 16),
                _buildMatchingRow(
                  '28-Oct-2026',
                  'FAB Merchant POS Terminal Settlement',
                  'AED 14,820.00',
                  'Auto-matched via Daily POS Summary',
                  true,
                ),
                const Divider(height: 16),
                _buildMatchingRow(
                  '27-Oct-2026',
                  'Bank Service Maintenance Charge & VAT',
                  '-AED 157.50',
                  'Suggest GL Account: 6150 (Bank Charges)',
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(String title, String iban, String balance, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.account_balance, size: 18, color: AppColors.primary),
            ],
          ),
          Text(
            iban,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    balance,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingRow(String date, String desc, String amount, String matchInfo, bool isMatched) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: amount.startsWith('-') ? AppColors.overdue : AppColors.paid,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      matchInfo,
                      style: TextStyle(fontSize: 11, color: isMatched ? AppColors.paid : AppColors.partial),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMatched ? AppColors.paid : AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      isMatched ? 'Reconciled' : 'Reconcile',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return Row(
          children: [
            Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    matchInfo,
                    style: TextStyle(fontSize: 11, color: isMatched ? AppColors.paid : AppColors.partial),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: amount.startsWith('-') ? AppColors.overdue : AppColors.paid,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isMatched ? AppColors.paid : AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
              ),
              child: Text(
                isMatched ? 'Reconciled' : 'Reconcile',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }
}
