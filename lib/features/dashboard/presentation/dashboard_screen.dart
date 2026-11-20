import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/localization/locale_provider.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardService _dashboardService;
  DashboardSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final dioClient = context.read<DioClient>();
    _dashboardService = DashboardService(dioClient: dioClient);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final data = await _dashboardService.getSummary();
    if (mounted) {
      setState(() {
        _summary = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _summary == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final summary = _summary ?? DashboardSummary.defaultMock();

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Title matching Figure 3
            _buildPageHeader(),
            const SizedBox(height: 18),

            // Row 1: Financial KPIs (Total Revenue, Total Expenses, Accounts Receivable, Cash & Bank)
            _buildFinancialKpis(summary.financial),
            const SizedBox(height: 16),

            // Row 2: Operational KPIs (Open Pipeline, Inventory Value, Expenses Awaiting Approval, Accounts Payable)
            _buildOperationalKpis(summary.operational),
            const SizedBox(height: 16),

            // Row 3: Revenue vs Expenses (last 6 months) + Receivables Ageing
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 980) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: _buildRevenueExpensesChartCard(summary.monthlyData),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: _buildReceivablesAgeingCard(summary.ageing),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildRevenueExpensesChartCard(summary.monthlyData),
                      const SizedBox(height: 16),
                      _buildReceivablesAgeingCard(summary.ageing),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Row 4: Recent Transactions Table
            _buildRecentTransactionsCard(summary.recentTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.home,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(width: 4),
            const Text(
              '>',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.dashboard,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.dashboard,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  // Format numbers like "AED 2,485,300"
  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return 'AED ${formatter.format(value)}';
  }

  Widget _buildFinancialKpis(FinancialKpis f) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 1050 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        final ratio = cols == 4
            ? 2.3
            : (cols == 2
                ? 2.6
                : (constraints.maxWidth < 360 ? 2.3 : 2.8));
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: ratio,
          children: [
            // Total Revenue (YTD)
            _buildKpiCard(
              title: context.l10n.totalRevenue,
              value: _formatCurrency(f.revenueYtd),
              trendBadge: '▲ ${f.revenueGrowth.toStringAsFixed(1)}% ${context.l10n.vsLastYear}',
              trendIsPositive: true,
              route: '/sales/invoices',
            ),

            // Total Expenses (YTD)
            _buildKpiCard(
              title: context.l10n.ytdExpenses,
              value: _formatCurrency(f.expensesYtd),
              trendBadge: '▲ ${f.expensesGrowth.toStringAsFixed(1)}% ${context.l10n.vsLastYear}',
              trendIsPositive: false, // In accounting/Figure 3, expense increase is red
              route: '/expenses',
            ),

            // Accounts Receivable
            _buildKpiCard(
              title: context.l10n.receivables,
              value: _formatCurrency(f.receivables),
              subtitle: '${f.openInvoicesCount} ${context.l10n.openInvoices}',
              route: '/sales/invoices',
            ),

            // Cash & Bank
            _buildKpiCard(
              title: context.l10n.cashAndBank,
              value: _formatCurrency(f.cashAndBank),
              subtitle: '${f.bankAccountsCount} ${context.l10n.bankAccountsCount}',
              route: '/banking/accounts',
            ),
          ],
        );
      },
    );
  }

  Widget _buildOperationalKpis(OperationalKpis o) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 1050 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        final ratio = cols == 4
            ? 2.3
            : (cols == 2
                ? 2.6
                : (constraints.maxWidth < 360 ? 2.3 : 2.8));
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: ratio,
          children: [
            // Open Pipeline (CRM)
            _buildKpiCard(
              title: context.l10n.openPipelineCrm,
              value: _formatCurrency(o.openPipelineCrm),
              subtitle: '${o.opportunitiesCount} ${context.l10n.opportunities} • ${o.weightedProbability}% ${context.l10n.weightedProbability}',
              route: '/crm/pipeline',
            ),

            // Inventory Value with Low Stock in RED
            _buildKpiCard(
              title: context.l10n.inventoryValue,
              value: _formatCurrency(o.inventoryValue),
              subtitle: '${o.lowStockCount} ${context.l10n.lowStockAlert}',
              subtitleColor: AppColors.error,
              route: '/inventory/items',
            ),

            // Expenses Awaiting Approval
            _buildKpiCard(
              title: context.l10n.expensesAwaitingApproval,
              value: _formatCurrency(o.expensesAwaitingApproval),
              subtitle: '${o.pendingClaimsCount} ${context.l10n.pendingClaims}',
              route: '/expenses/approvals',
            ),

            // Accounts Payable
            _buildKpiCard(
              title: context.l10n.accountsPayable,
              value: _formatCurrency(o.accountsPayable),
              subtitle: '${o.openBillsCount} ${context.l10n.openBills}',
              route: '/purchases/bills',
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    String? subtitle,
    Color? subtitleColor,
    String? trendBadge,
    bool? trendIsPositive,
    String? route,
  }) {
    final cardContent = Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 5,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          if (trendBadge != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    trendBadge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: trendIsPositive == true
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            )
          else if (subtitle != null)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: subtitleColor ?? AppColors.textMuted,
                fontWeight: subtitleColor != null ? FontWeight.w600 : FontWeight.w400,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );

    if (route != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(10),
          child: cardContent,
        ),
      );
    }
    return cardContent;
  }

  // Row 3 Left: Revenue vs Expenses (last 6 months)
  Widget _buildRevenueExpensesChartCard(List<MonthlyComparison> data) {
    const double maxChartValue = 400000;

    return Container(
      padding: const EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.revenueVsExpenses6Months,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Custom dual-bar chart matching Figure 3
          LayoutBuilder(
            builder: (context, chartConstraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: chartConstraints.maxWidth < 420 ? 420 : chartConstraints.maxWidth,
                  ),
                  child: SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: data.map((d) {
                        final revHeight = (d.revenue / maxChartValue * 150).clamp(10.0, 150.0);
                        final expHeight = (d.expenses / maxChartValue * 150).clamp(10.0, 150.0);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Dark blue bar for Revenue
                                Container(
                                  width: 14,
                                  height: revHeight,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1D4ED8),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // Light blue bar for Expenses
                                Container(
                                  width: 14,
                                  height: expHeight,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF93C5FD),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              d.month,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Legend at bottom matching Figure 3
          Wrap(
            spacing: 20,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, color: const Color(0xFF1D4ED8)),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.revenue,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, color: const Color(0xFF93C5FD)),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.expenses,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Row 3 Right: Receivables Ageing progress bars
  Widget _buildReceivablesAgeingCard(ReceivablesAgeingData ageing) {
    return Container(
      padding: const EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.receivablesAgeing,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),

          // Current (Green bar)
          _buildAgeingItem(context.l10n.ageingCurrent, ageing.current, const Color(0xFF10B981), 0.95),
          const SizedBox(height: 12),

          // 1-30 days (Cyan/Blue bar)
          _buildAgeingItem(context.l10n.ageing1to30Days, ageing.days1To30, const Color(0xFF0284C7), 0.52),
          const SizedBox(height: 12),

          // 31-60 days (Amber bar)
          _buildAgeingItem(context.l10n.ageing31to60Days, ageing.days31To60, const Color(0xFFF59E0B), 0.34),
          const SizedBox(height: 12),

          // 61-90 days (Orange bar)
          _buildAgeingItem(context.l10n.ageing61to90Days, ageing.days61To90, const Color(0xFFEA580C), 0.16),
          const SizedBox(height: 12),

          // 90+ days (Red bar)
          _buildAgeingItem(context.l10n.ageing90PlusDays, ageing.daysOver90, AppColors.error, 0.08),
        ],
      ),
    );
  }

  Widget _buildAgeingItem(String label, double amount, Color barColor, double fillRatio) {
    final formatter = NumberFormat('#,##0', 'en_US');

    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fillRatio.clamp(0.05, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 85),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              'AED ${formatter.format(amount)}',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Row 4: Recent Transactions table
  Widget _buildRecentTransactionsCard(List<RecentTransactionItem> items) {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 12),
            child: Text(
              context.l10n.recentActivity,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 800),
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                horizontalMargin: 20,
                columnSpacing: 32,
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                columns: [
                  DataColumn(
                    label: Text(
                      context.l10n.date,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      context.l10n.reference,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      context.l10n.description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      context.l10n.status,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Text(
                      '${context.l10n.amount} (${context.l10n.currencyAed})',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                rows: items.map((tx) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          tx.date,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                      DataCell(
                        Text(
                          tx.reference,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          tx.description,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                      DataCell(_buildTypeChip(tx.type)),
                      DataCell(
                        Text(
                          currencyFormatter.format(tx.amount),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color bg;
    Color text;
    String displayLabel = type;

    switch (type.toLowerCase()) {
      case 'invoice':
        bg = AppColors.sentBg;
        text = AppColors.sent;
        displayLabel = context.l10n.typeInvoice;
        break;
      case 'receipt':
        bg = AppColors.paidBg;
        text = AppColors.paid;
        displayLabel = context.l10n.typeReceipt;
        break;
      case 'bill':
        bg = AppColors.partialBg;
        text = AppColors.partial;
        displayLabel = context.l10n.typeBill;
        break;
      default:
        bg = AppColors.draftBg;
        text = AppColors.draft;
    }

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: text.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
