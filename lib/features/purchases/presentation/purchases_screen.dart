import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/status_chip.dart';

class PurchasesScreen extends StatefulWidget {
  final String initialTab;

  const PurchasesScreen({super.key, this.initialTab = 'bills'});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  void didUpdateWidget(PurchasesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _activeTab = widget.initialTab;
      });
    }
  }

  void _showNewBillDialog() {
    final billNoController = TextEditingController(text: 'BILL-2026-004');
    final vendorController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final isMobile = screenWidth < 550;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 28,
            vertical: 24,
          ),
          child: Container(
            width: isMobile ? screenWidth - 32 : 480,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.enterVendorBill,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                      splashRadius: 18,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 16),

                // Form Fields
                Text(
                  context.l10n.billNumber,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: billNoController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.tag_rounded, size: 16, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  context.l10n.vendor,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: vendorController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Al-Futtaim Logistics',
                      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.store_outlined, size: 16, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  '${context.l10n.totalAmount} (${context.l10n.currencyAed})',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.payments_outlined, size: 16, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Dialog Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        minimumSize: const Size(0, 38),
                      ),
                      child: Text(
                        context.l10n.cancel,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.vendorBillRecorded),
                            backgroundColor: AppColors.paid,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        minimumSize: const Size(0, 38),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.saveBill,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bills = [
      {'num': 'BIL-2026-0344', 'vendor': 'Gulf Petrochem Distribution', 'date': '28-Oct-2026', 'dueDate': '27-Nov-2026', 'amount': 'AED 78,120.00', 'status': 'Partial'},
      {'num': 'BIL-2026-0343', 'vendor': 'Schneider Electric UAE', 'date': '20-Oct-2026', 'dueDate': '19-Nov-2026', 'amount': 'AED 44,500.00', 'status': 'Paid'},
      {'num': 'BIL-2026-0342', 'vendor': 'Al Habtoor Motors Spares', 'date': '14-Oct-2026', 'dueDate': '13-Nov-2026', 'amount': 'AED 29,800.00', 'status': 'Paid'},
      {'num': 'BIL-2026-0341', 'vendor': 'Canon Middle East FZ', 'date': '02-Oct-2026', 'dueDate': '01-Nov-2026', 'amount': 'AED 12,350.00', 'status': 'Draft'},
    ];

    final vendors = [
      {'code': 'VND-001', 'name': 'Gulf Petrochem Distribution', 'trn': '100928374600003', 'terms': 'Net 30', 'openPayables': 'AED 78,120.00', 'status': 'Active'},
      {'code': 'VND-002', 'name': 'Schneider Electric UAE', 'trn': '100192837400003', 'terms': 'Net 30', 'openPayables': 'AED 0.00', 'status': 'Active'},
      {'code': 'VND-003', 'name': 'Al Habtoor Motors Spares', 'trn': '100384726100003', 'terms': 'Net 30', 'openPayables': 'AED 0.00', 'status': 'Active'},
      {'code': 'VND-004', 'name': 'Canon Middle East FZ', 'trn': '100582910200003', 'terms': 'Net 30', 'openPayables': 'AED 12,350.00', 'status': 'Active'},
    ];

    final payments = [
      {'num': 'PAY-2026-0188', 'vendor': 'Schneider Electric UAE', 'bill': 'BIL-2026-0343', 'date': '22-Oct-2026', 'amount': 'AED 44,500.00', 'method': 'Bank Transfer', 'status': 'Cleared'},
      {'num': 'PAY-2026-0187', 'vendor': 'Al Habtoor Motors Spares', 'bill': 'BIL-2026-0342', 'date': '16-Oct-2026', 'amount': 'AED 29,800.00', 'method': 'Cheque #4001', 'status': 'Cleared'},
      {'num': 'PAY-2026-0186', 'vendor': 'Gulf Petrochem Distribution', 'bill': 'BIL-2026-0344', 'date': '30-Oct-2026', 'amount': 'AED 39,060.00', 'method': 'Bank Transfer', 'status': 'Cleared'},
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
          // Breadcrumbs & Header
          _buildBreadcrumbsAndHeader(isMobile),
          const SizedBox(height: 18),

          // KPI Summary Cards
          _buildKpiCards(),
          const SizedBox(height: 18),

          // Sub-navigation tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton('bills', '${context.l10n.bills} (4)', Icons.receipt_long_outlined),
                const SizedBox(width: 8),
                _buildTabButton('vendors', '${context.l10n.vendors} (4)', Icons.store_mall_directory_outlined),
                const SizedBox(width: 8),
                _buildTabButton('payments', '${context.l10n.payments} (3)', Icons.payments_outlined),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active Tab Content
          if (_activeTab == 'vendors') ...[
            _buildVendorsTable(vendors),
          ] else if (_activeTab == 'payments') ...[
            _buildPaymentsTable(payments),
          ] else ...[
            _buildBillsTable(bills),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbsAndHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              onTap: () => context.go('/dashboard'),
              child: Text(context.l10n.home, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(context.l10n.purchases, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        if (isMobile) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.purchasesTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.purchasesSubtitle,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _showNewBillDialog,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: Text('+ ${context.l10n.enterVendorBill}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: const Size(0, 40),
                  elevation: 0,
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
                      context.l10n.purchasesTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.purchasesSubtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showNewBillDialog,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: Text('+ ${context.l10n.enterVendorBill}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: const Size(0, 40),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildKpiCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 950;
        final isTablet = constraints.maxWidth >= 550;
        final cardWidth = isDesktop
            ? (constraints.maxWidth - 36) / 4
            : (isTablet ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth);

        final cards = [
          _buildSummaryCard(
            title: 'Total Payables',
            value: 'AED 195,400',
            valueColor: AppColors.textPrimary,
            icon: Icons.receipt_long_rounded,
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: 'Due in 30 Days',
            value: 'AED 78,120',
            valueColor: const Color(0xFFDC2626),
            icon: Icons.schedule_rounded,
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: 'Disbursed This Month',
            value: 'AED 113,360',
            valueColor: const Color(0xFF16A34A),
            icon: Icons.check_circle_outline_rounded,
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: 'Approved Suppliers',
            value: '4 Active',
            valueColor: AppColors.textPrimary,
            icon: Icons.store_mall_directory_rounded,
            width: cardWidth,
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards,
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: valueColor == const Color(0xFFDC2626)
                      ? AppColors.overdueBg
                      : (valueColor == const Color(0xFF16A34A) ? AppColors.paidBg : AppColors.primarySurface),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: valueColor == const Color(0xFFDC2626)
                      ? const Color(0xFFDC2626)
                      : (valueColor == const Color(0xFF16A34A) ? const Color(0xFF16A34A) : AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsTable(List<Map<String, String>> bills) {
    return RoundedCard(
      title: 'Vendor Bills & Payables (AP)',
      subtitle: 'AED 195,400 total active payables',
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 42,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 52,
                headingRowColor: const WidgetStatePropertyAll(Color(0xFFF8FAFC)),
                dividerThickness: 1,
                horizontalMargin: 20,
                columnSpacing: 18,
                columns: [
                  DataColumn(label: Text(context.l10n.colBillNo, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.vendor, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.colBillDate, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.colDueDate, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text('${context.l10n.amount} (${context.l10n.currencyAed})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.status, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.colActions, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                ],
                rows: bills.map((b) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          b['num']!,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB), fontSize: 13),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Text(
                            b['vendor']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      DataCell(Text(b['date']!, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                      DataCell(Text(b['dueDate']!, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                      DataCell(
                        Text(
                          b['amount']!,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      DataCell(StatusChip.fromStatusString(b['status']!)),
                      DataCell(
                        OutlinedButton(
                          onPressed: () {
                            setState(() => _activeTab = 'payments');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Switched to Payments tab for ${b['num']} (${b['vendor']})'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF93C5FD)),
                            foregroundColor: const Color(0xFF2563EB),
                            backgroundColor: const Color(0xFFEFF6FF),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            minimumSize: const Size(0, 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text('Record Payment', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorsTable(List<Map<String, String>> vendors) {
    return RoundedCard(
      title: 'Vendor Accounts Directory (AP)',
      subtitle: '4 active approved suppliers',
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 42,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 52,
                headingRowColor: const WidgetStatePropertyAll(Color(0xFFF8FAFC)),
                dividerThickness: 1,
                horizontalMargin: 20,
                columnSpacing: 18,
                columns: [
                  DataColumn(label: Text(context.l10n.colCode, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.colVendorName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.colTrn, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.colPaymentTerms, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.colOpenPayables, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.status, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                ],
                rows: vendors.map((v) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          v['code']!,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB), fontSize: 13),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text(
                            v['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      DataCell(Text(v['trn']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace'))),
                      DataCell(Text(v['terms']!, style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary))),
                      DataCell(
                        Text(
                          v['openPayables']!,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      DataCell(StatusChip.fromStatusString(v['status']!)),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsTable(List<Map<String, String>> payments) {
    return RoundedCard(
      title: 'Vendor Payments & Vouchers',
      subtitle: 'AED 113,360 total disbursements',
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 42,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 52,
                headingRowColor: const WidgetStatePropertyAll(Color(0xFFF8FAFC)),
                dividerThickness: 1,
                horizontalMargin: 20,
                columnSpacing: 18,
                columns: [
                  DataColumn(label: Text(context.l10n.colPaymentNo, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.vendor, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.againstBill, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.date, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.amount, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.colMethod, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  DataColumn(label: Text(context.l10n.status, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                ],
                rows: payments.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          p['num']!,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB), fontSize: 13),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Text(
                            p['vendor']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      DataCell(Text(p['bill']!, style: const TextStyle(fontSize: 12.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w500))),
                      DataCell(Text(p['date']!, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                      DataCell(
                        Text(
                          p['amount']!,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      DataCell(Text(p['method']!, style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary))),
                      DataCell(StatusChip.fromStatusString(p['status']!)),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String tabKey, String label, IconData icon) {
    final isSelected = _activeTab == tabKey;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tabKey;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
