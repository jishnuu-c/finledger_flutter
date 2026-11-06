import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/api/dio_client.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
              'Home',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(width: 4),
            const Text(
              '>',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(width: 4),
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
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
        final ratio = cols == 4 ? 2.3 : (cols == 2 ? 2.6 : 3.2);
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
              title: 'Total Revenue (YTD)',
              value: _formatCurrency(f.revenueYtd),
              trendBadge: '▲ ${f.revenueGrowth.toStringAsFixed(1)}% vs last year',
              trendIsPositive: true,
            ),

            // Total Expenses (YTD)
            _buildKpiCard(
              title: 'Total Expenses (YTD)',
              value: _formatCurrency(f.expensesYtd),
              trendBadge: '▲ ${f.expensesGrowth.toStringAsFixed(1)}% vs last year',
              trendIsPositive: false, // In accounting/Figure 3, expense increase is red
            ),

            // Accounts Receivable
            _buildKpiCard(
              title: 'Accounts Receivable',
              value: _formatCurrency(f.receivables),
              subtitle: '${f.openInvoicesCount} open invoices',
            ),

            // Cash & Bank
            _buildKpiCard(
              title: 'Cash & Bank',
              value: _formatCurrency(f.cashAndBank),
              subtitle: '${f.bankAccountsCount} bank accounts',
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
        final ratio = cols == 4 ? 2.3 : (cols == 2 ? 2.6 : 3.2);
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
              title: 'Open Pipeline (CRM)',
              value: _formatCurrency(o.openPipelineCrm),
              subtitle: '${o.opportunitiesCount} opportunities • ${o.weightedProbability}% weighted',
            ),

            // Inventory Value with Low Stock in RED
            _buildKpiCard(
              title: 'Inventory Value',
              value: _formatCurrency(o.inventoryValue),
              subtitle: '${o.lowStockCount} items below reorder level',
              subtitleColor: const Color(0xFFDC2626), // Red per Figure 3
            ),

            // Expenses Awaiting Approval
            _buildKpiCard(
              title: 'Expenses Awaiting Approval',
              value: _formatCurrency(o.expensesAwaitingApproval),
              subtitle: '${o.pendingClaimsCount} claims',
            ),

            // Accounts Payable
            _buildKpiCard(
              title: 'Accounts Payable',
              value: _formatCurrency(o.accountsPayable),
              subtitle: '${o.openBillsCount} open bills',
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
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
              color: Color(0xFF64748B),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
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
                          ? const Color(0xFF16A34A) // Green
                          : const Color(0xFFDC2626), // Red
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
                color: subtitleColor ?? const Color(0xFF94A3B8),
                fontWeight: subtitleColor != null ? FontWeight.w600 : FontWeight.w400,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  // Row 3 Left: Revenue vs Expenses (last 6 months)
  Widget _buildRevenueExpensesChartCard(List<MonthlyComparison> data) {
    const double maxChartValue = 400000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue vs Expenses (last 6 months)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
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
                                    color: Color(0xFF1D4ED8), // Royal Blue
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // Light blue bar for Expenses
                                Container(
                                  width: 14,
                                  height: expHeight,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF93C5FD), // Light Sky Blue
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
                                color: Color(0xFF64748B),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(width: 10, height: 10, color: const Color(0xFF1D4ED8)),
              const SizedBox(width: 6),
              const Text('Revenue', style: TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
              const SizedBox(width: 20),
              Container(width: 10, height: 10, color: const Color(0xFF93C5FD)),
              const SizedBox(width: 6),
              const Text('Expenses', style: TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
            ],
          ),
        ],
      ),
    );
  }

  // Row 3 Right: Receivables Ageing progress bars
  Widget _buildReceivablesAgeingCard(ReceivablesAgeingData ageing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receivables Ageing',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 18),

          // Current (Green bar)
          _buildAgeingItem('Current', ageing.current, const Color(0xFF10B981), 0.95),
          const SizedBox(height: 12),

          // 1-30 days (Cyan/Blue bar)
          _buildAgeingItem('1-30 days', ageing.days1To30, const Color(0xFF0284C7), 0.52),
          const SizedBox(height: 12),

          // 31-60 days (Amber bar)
          _buildAgeingItem('31-60 days', ageing.days31To60, const Color(0xFFF59E0B), 0.34),
          const SizedBox(height: 12),

          // 61-90 days (Orange bar)
          _buildAgeingItem('61-90 days', ageing.days61To90, const Color(0xFFEA580C), 0.16),
          const SizedBox(height: 12),

          // 90+ days (Red bar)
          _buildAgeingItem('90+ days', ageing.daysOver90, const Color(0xFFDC2626), 0.08),
        ],
      ),
    );
  }

  Widget _buildAgeingItem(String label, double amount, Color barColor, double fillRatio) {
    final formatter = NumberFormat('#,##0', 'en_US');

    return Row(
      children: [
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
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
            alignment: Alignment.centerRight,
            child: Text(
              'AED ${formatter.format(amount)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 800),
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 46,
                dataRowMaxHeight: 46,
                horizontalMargin: 20,
                columnSpacing: 32,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Date',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Reference',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Description',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Type',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Text(
                      'Amount (AED)',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
                rows: items.map((tx) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          tx.date,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                        ),
                      ),
                      DataCell(
                        Text(
                          tx.reference,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                        ),
                      ),
                      DataCell(
                        Text(
                          tx.description,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                        ),
                      ),
                      DataCell(_buildTypeChip(tx.type)),
                      DataCell(
                        Text(
                          currencyFormatter.format(tx.amount),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
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

    switch (type.toLowerCase()) {
      case 'invoice':
        bg = const Color(0xFFEFF6FF); // Light blue
        text = const Color(0xFF2563EB); // Blue
        break;
      case 'receipt':
        bg = const Color(0xFFDCFCE7); // Light green
        text = const Color(0xFF16A34A); // Green
        break;
      case 'bill':
        bg = const Color(0xFFFEF3C7); // Light amber
        text = const Color(0xFFD97706); // Amber
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
