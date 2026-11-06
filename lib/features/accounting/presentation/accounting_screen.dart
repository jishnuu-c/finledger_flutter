import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/status_chip.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'General Ledger & Accounting',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Double-entry chart of accounts, manual journals, and balance sheet integrity',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ New Journal Entry'),
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
                        'General Ledger & Accounting',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Double-entry chart of accounts, manual journals, and balance sheet integrity',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ New Journal Entry'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Chart of Accounts'),
              Tab(text: 'Journal Entries'),
              Tab(text: 'General Ledger Trail'),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartOfAccounts(isMobile),
                _buildJournalEntries(),
                _buildGeneralLedgerTrail(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartOfAccounts(bool isMobile) {
    final accounts = [
      {
        'code': '1010',
        'name': 'Emirates NBD - Operating Current A/C',
        'type': 'Asset (Bank)',
        'balance': 'AED 540,250.00',
      },
      {
        'code': '1020',
        'name': 'Mashreq Bank - AED Payroll A/C',
        'type': 'Asset (Bank)',
        'balance': 'AED 240,000.00',
      },
      {
        'code': '1100',
        'name': 'Accounts Receivable (Trade Debtors)',
        'type': 'Asset (AR)',
        'balance': 'AED 324,800.00',
      },
      {
        'code': '1200',
        'name': 'Merchandise Inventory (Trading Stock)',
        'type': 'Asset (Inventory)',
        'balance': 'AED 512,000.00',
      },
      {
        'code': '2000',
        'name': 'Accounts Payable (Trade Creditors)',
        'type': 'Liability (AP)',
        'balance': 'AED 195,400.00',
      },
      {
        'code': '2150',
        'name': 'FTA VAT Output Payable (5%)',
        'type': 'Liability (Tax)',
        'balance': 'AED 42,150.00',
      },
      {
        'code': '3000',
        'name': 'Owner / Paid-up Share Capital',
        'type': 'Equity',
        'balance': 'AED 500,000.00',
      },
      {
        'code': '4000',
        'name': 'Commercial Trading Sales Revenue',
        'type': 'Revenue',
        'balance': 'AED 1,420,500.00',
      },
      {
        'code': '5000',
        'name': 'Cost of Goods Sold (COGS)',
        'type': 'Expense',
        'balance': 'AED 610,000.00',
      },
    ];

    return SingleChildScrollView(
      child: RoundedCard(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        title: 'Chart of Accounts Hierarchy',
        subtitle:
            'Standardized accounting structure with live account balances',
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: accounts.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final a = accounts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      a['code']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          a['type']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    a['balance']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJournalEntries() {
    final journals = [
      {
        'id': 'JRN-2026-0412',
        'date': '29-Oct-2026',
        'narration':
            'Monthly asset depreciation for office IT and vehicle fleet',
        'debit': 'AED 12,400.00',
        'credit': 'AED 12,400.00',
        'status': 'Posted',
      },
      {
        'id': 'JRN-2026-0411',
        'date': '28-Oct-2026',
        'narration': 'End-of-month foreign exchange revaluation',
        'debit': 'AED 4,820.00',
        'credit': 'AED 4,820.00',
        'status': 'Posted',
      },
      {
        'id': 'JRN-2026-0410',
        'date': '25-Oct-2026',
        'narration': 'Prepaid rent amortization for Al Quoz warehouse',
        'debit': 'AED 15,000.00',
        'credit': 'AED 15,000.00',
        'status': 'Posted',
      },
      {
        'id': 'JRN-2026-0409',
        'date': '22-Oct-2026',
        'narration': 'Accrued staff gratuity provision',
        'debit': 'AED 8,600.00',
        'credit': 'AED 8,600.00',
        'status': 'Draft',
      },
    ];

    return SingleChildScrollView(
      child: RoundedCard(
        title: 'Manual Journal Entries',
        subtitle:
            'Enforces balanced lines validator: Sum(Debits) == Sum(Credits)',
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 600),
            child: Column(
              children: [
                for (int i = 0; i < journals.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          journals[i]['id']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 260,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journals[i]['narration']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                journals[i]['date']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'DR: ${journals[i]['debit']!}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'CR: ${journals[i]['credit']!}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        StatusChip.fromStatusString(journals[i]['status']!),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralLedgerTrail() {
    return const SingleChildScrollView(
      child: RoundedCard(
        title: 'Audit Trail & General Ledger Export',
        subtitle:
            'Every ledger movement traces directly back to source documents',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 48,
                  color: AppColors.primaryLight,
                ),
                SizedBox(height: 12),
                Text(
                  'Complete General Ledger Active',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  'All transaction debits and credits are balanced with zero discrepancies across 142 posted transactions.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
