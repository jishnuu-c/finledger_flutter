import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/expense_models.dart';
import '../data/services/expense_service.dart';
import 'widgets/expense_status_chip.dart';
import 'widgets/receipt_badge.dart';

class ExpensesListScreen extends StatefulWidget {
  final ExpenseService? expenseService;

  const ExpensesListScreen({super.key, this.expenseService});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  late final ExpenseService _expenseService;

  String _activeTab = 'all'; // 'all', 'my', 'approvals', 'reimburse'
  final Set<int> _selectedIds = {};

  late Future<ExpenseKpis> _kpisFuture;
  late Future<List<Expense>> _expensesFuture;

  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');
  final NumberFormat _compactFormat = NumberFormat('#,##0', 'en_US');

  @override
  void initState() {
    super.initState();
    _expenseService = widget.expenseService ?? ExpenseService();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _kpisFuture = _expenseService.getExpenseKpis();
      _loadExpenses();
    });
  }

  void _loadExpenses() {
    setState(() {
      _expensesFuture = _expenseService.getExpenses(tab: _activeTab);
    });
  }

  Future<void> _handleApprove(int id) async {
    try {
      await _expenseService.approveExpense(id);
      _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense claim approved.'), backgroundColor: Color(0xFF16A34A)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving expense: $e'), backgroundColor: const Color(0xFFDC2626)),
      );
    }
  }

  Future<void> _handleReject(int id) async {
    final reasonController = TextEditingController(text: 'Mandatory tax invoice receipt missing as per policy.');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Expense Claim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter rejection reason for the employee:', style: TextStyle(fontSize: 12.5)),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                child: const Text('Reject Claim'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _expenseService.rejectExpense(id, reason: reasonController.text);
      _loadData();
    }
  }

  Future<void> _handleReimburse(int id) async {
    await _expenseService.reimburseExpense(id);
    _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense reimbursed via payroll / bank transfer.'), backgroundColor: Color(0xFF059669)),
    );
  }

  Future<void> _handleBulkApprove() async {
    if (_selectedIds.isEmpty) return;
    final count = await _expenseService.bulkApprove(_selectedIds.toList());
    _selectedIds.clear();
    _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk approved $count claim(s).'), backgroundColor: const Color(0xFF16A34A)),
    );
  }

  Future<void> _handleBulkReimburse() async {
    if (_selectedIds.isEmpty) return;
    final count = await _expenseService.bulkReimburse(_selectedIds.toList());
    _selectedIds.clear();
    _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk reimbursed $count claim(s).'), backgroundColor: const Color(0xFF059669)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs and Title (Figure 11)
            _buildBreadcrumbsAndTitle(),
            const SizedBox(height: 20),

            // 4 KPI Cards (This month, Awaiting approval, To reimburse, Top category)
            _buildKpiCards(),
            const SizedBox(height: 20),

            // Tab bar and Toolbar (Figure 11)
            _buildTabBarAndToolbar(),
            const SizedBox(height: 16),

            // Expenses Table
            _buildExpensesTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbsAndTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              onTap: () => context.go('/expenses'),
              child: const Text('Expenses', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('All Expenses', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Expenses',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCards() {
    return FutureBuilder<ExpenseKpis>(
      future: _kpisFuture,
      builder: (context, snapshot) {
        final kpis = snapshot.data ??
            const ExpenseKpis(
              thisMonthPosted: 46320.0,
              vsPreviousMonthPct: 4.2,
              awaitingApproval: 14860.0,
              awaitingClaimsCount: 9,
              toReimburse: 6215.0,
              toReimburseClaimsCount: 4,
              topCategory: 'Travel & Fuel',
              topCategoryAmount: 12480.0,
            );

        return LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 950 ? 4 : (constraints.maxWidth >= 550 ? 2 : 1);
            final itemWidth = (constraints.maxWidth - (cols - 1) * 14) / cols;

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _buildSingleKpi(
                  title: 'This month (posted)',
                  value: 'AED ${_compactFormat.format(kpis.thisMonthPosted)}',
                  subtitleWidget: const Text(
                    '▲ 4.2% vs September',
                    style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  valueColor: AppColors.textPrimary,
                  width: itemWidth,
                ),
                _buildSingleKpi(
                  title: 'Awaiting approval',
                  value: 'AED ${_compactFormat.format(kpis.awaitingApproval)}',
                  subtitleWidget: Text(
                    '${kpis.awaitingClaimsCount} claims',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  valueColor: const Color(0xFFD97706), // Amber
                  width: itemWidth,
                ),
                _buildSingleKpi(
                  title: 'To reimburse employees',
                  value: 'AED ${_compactFormat.format(kpis.toReimburse)}',
                  subtitleWidget: Text(
                    '${kpis.toReimburseClaimsCount} approved claims',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  valueColor: AppColors.textPrimary,
                  width: itemWidth,
                ),
                _buildSingleKpi(
                  title: 'Top category',
                  value: kpis.topCategory,
                  subtitleWidget: Text(
                    'AED ${_compactFormat.format(kpis.topCategoryAmount)} this month',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  valueColor: AppColors.textPrimary,
                  width: itemWidth,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSingleKpi({
    required String title,
    required String value,
    required Widget subtitleWidget,
    required Color valueColor,
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: valueColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: subtitleWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarAndToolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        final tabs = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabItem('All', 'all'),
            const SizedBox(width: 20),
            _buildTabItem('My expenses', 'my'),
            const SizedBox(width: 20),
            _buildTabItem('Awaiting my approval', 'approvals', badgeCount: 9),
            const SizedBox(width: 20),
            _buildTabItem('To reimburse', 'reimburse'),
          ],
        );

        final toolbarActions = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Date range button (Figure 11: 01-Oct-2026 -> 31-Oct-2026)
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('01-Oct-2026 → 31-Oct-2026', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ),

            // Export Button
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting expenses to Excel...')),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Export', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
            ),

            // + New Expense Button (Figure 11)
            ElevatedButton(
              onPressed: () => context.go('/expenses/new'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Text('+ New Expense', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            ),
          ],
        );

        if (!isDesktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: tabs),
              const SizedBox(height: 12),
              toolbarActions,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: tabs,
              ),
            ),
            const SizedBox(width: 12),
            toolbarActions,
          ],
        );
      },
    );
  }

  Widget _buildTabItem(String label, String tabKey, {int? badgeCount}) {
    final isActive = _activeTab == tabKey;

    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tabKey;
          _loadExpenses();
        });
      },
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? const Color(0xFF2563EB) : AppColors.textSecondary,
                ),
              ),
              if (badgeCount != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 24,
            color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTable() {
    return FutureBuilder<List<Expense>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final expenses = snapshot.data ?? [];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  const minTableWidth = 1050.0;
                  final effectiveWidth = constraints.maxWidth < minTableWidth ? minTableWidth : constraints.maxWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: effectiveWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Table Header (Figure 11)
                          Container(
                            color: const Color(0xFFF8FAFC),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  child: Checkbox(
                                    value: _selectedIds.length == expenses.length && expenses.isNotEmpty,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedIds.addAll(expenses.map((e) => e.id));
                                        } else {
                                          _selectedIds.clear();
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(flex: 3, child: Text('Expense #', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                const Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                const Expanded(flex: 3, child: Text('Employee / Payee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                const Expanded(flex: 3, child: Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                const Expanded(flex: 3, child: Text('Paid by', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                const Expanded(flex: 2, child: Text('Net', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                const Expanded(flex: 2, child: Text('VAT', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                const Expanded(flex: 3, child: Text('Total (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                const SizedBox(width: 44, child: Center(child: Icon(Icons.attach_file, size: 14, color: AppColors.textSecondary))),
                                const Expanded(flex: 2, child: Center(child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                                const SizedBox(width: 145, child: Align(alignment: Alignment.centerRight, child: Text('Action', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.borderSubtle),

                          // Rows
                          if (expenses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                child: Text('No expenses found for this tab.', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: expenses.length,
                              separatorBuilder: (context, _) => const Divider(height: 1, color: AppColors.borderSubtle),
                              itemBuilder: (context, index) {
                                final exp = expenses[index];
                                final isChecked = _selectedIds.contains(exp.id);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      // Checkbox
                                      SizedBox(
                                        width: 24,
                                        child: Checkbox(
                                          value: isChecked,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                _selectedIds.add(exp.id);
                                              } else {
                                                _selectedIds.remove(exp.id);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Expense # (Blue link)
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          exp.expenseNo,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),

                                      // Date
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          exp.expenseDate,
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                        ),
                                      ),

                                      // Employee / Payee
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          exp.employeeName,
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                        ),
                                      ),

                                      // Category
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          exp.categorySummary,
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                        ),
                                      ),

                                      // Paid by
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          exp.paidByDisplay,
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                        ),
                                      ),

                                      // Net
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _currencyFormat.format(exp.subtotal),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                        ),
                                      ),

                                      // VAT
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _currencyFormat.format(exp.taxTotal),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                        ),
                                      ),

                                      // Total (AED)
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          _currencyFormat.format(exp.total),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                      ),

                                      // Receipts paperclip icon
                                      SizedBox(
                                        width: 44,
                                        child: Center(
                                          child: ReceiptBadge(
                                            count: exp.attachmentCount,
                                            isMissing: exp.hasMissingReceipt,
                                          ),
                                        ),
                                      ),

                                      // Status Chip
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: ExpenseStatusChip(status: exp.status),
                                        ),
                                      ),

                                      // Actions (Figure 11: Approve / Reject or Reimburse or View)
                                      SizedBox(
                                        width: 145,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: _buildActionButtons(exp),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),

              // Bottom footer matching Figure 11:
              // "Showing 1-8 of 57 · Bulk: Approve selected · Reimburse selected" and "< 1 2 3 ... 8 >"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Showing 1-8 of 57  ·  Bulk: ',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        InkWell(
                          onTap: _selectedIds.isNotEmpty ? _handleBulkApprove : null,
                          child: Text(
                            'Approve selected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedIds.isNotEmpty ? const Color(0xFF2563EB) : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const Text('  ·  ', style: TextStyle(color: AppColors.textMuted)),
                        InkWell(
                          onTap: _selectedIds.isNotEmpty ? _handleBulkReimburse : null,
                          child: Text(
                            'Reimburse selected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedIds.isNotEmpty ? const Color(0xFF059669) : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPaginationButton('<', isEnabled: false),
                          _buildPaginationNumber('1', isActive: true),
                          _buildPaginationNumber('2', isActive: false),
                          _buildPaginationNumber('3', isActive: false),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ),
                          _buildPaginationNumber('8', isActive: false),
                          _buildPaginationButton('>', isEnabled: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(Expense exp) {
    if (exp.status == 'SUBMITTED') {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _handleApprove(exp.id),
              child: const Row(
                children: [
                  Icon(Icons.check, size: 14, color: Color(0xFF2563EB)),
                  SizedBox(width: 2),
                  Text('Approve', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _handleReject(exp.id),
              child: const Row(
                children: [
                  Icon(Icons.close, size: 14, color: Color(0xFF2563EB)),
                  SizedBox(width: 2),
                  Text('Reject', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (exp.status == 'APPROVED' && exp.paidBy == 'EMPLOYEE') {
      return InkWell(
        onTap: () => _handleReimburse(exp.id),
        child: const Text(
          'Reimburse',
          style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
        ),
      );
    }

    return const Text(
      'View',
      style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
    );
  }

  Widget _buildPaginationNumber(String num, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isActive ? const Color(0xFFBFDBFE) : Colors.transparent),
      ),
      child: Center(
        child: Text(
          num,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF2563EB) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String symbol, {required bool isEnabled}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 26,
      height: 26,
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isEnabled ? AppColors.textSecondary : AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
