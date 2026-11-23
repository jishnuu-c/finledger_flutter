import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../data/models/sales_models.dart';
import '../data/services/sales_service.dart';
import 'widgets/invoice_pdf_preview_dialog.dart';
import 'widgets/invoice_status_chip.dart';

class SalesInvoicesListScreen extends StatefulWidget {
  final SalesService? salesService;

  const SalesInvoicesListScreen({
    super.key,
    this.salesService,
  });

  @override
  State<SalesInvoicesListScreen> createState() => _SalesInvoicesListScreenState();
}

class _SalesInvoicesListScreenState extends State<SalesInvoicesListScreen> {
  late final SalesService _salesService;
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatus = 'All Status';
  String _dateRangeText = '01-Oct-2026 → 31-Oct-2026';
  List<Invoice> _invoices = [];
  InvoiceKpis? _kpis;
  bool _isLoading = true;
  int _currentPage = 1;
  final int _totalPages = 6;
  final int _totalItems = 42;

  @override
  void initState() {
    super.initState();
    if (widget.salesService != null) {
      _salesService = widget.salesService!;
    } else {
      DioClient? dio;
      try {
        dio = context.read<DioClient>();
      } catch (_) {}
      _salesService = SalesService(dioClient: dio);
    }
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final kpis = await _salesService.getInvoiceKpis();
    final list = await _salesService.getInvoices(
      status: _selectedStatus,
      search: _searchController.text,
    );

    if (mounted) {
      setState(() {
        _kpis = kpis;
        _invoices = list;
        _isLoading = false;
      });
    }
  }

  void _showPdfPreview(Invoice invoice) {
    showDialog(
      context: context,
      builder: (ctx) => InvoicePdfPreviewDialog(invoice: invoice),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2028),
      initialDateRange: DateTimeRange(
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 31),
      ),
    );

    if (picked != null) {
      final formatter = DateFormat('dd-MMM-yyyy');
      setState(() {
        _dateRangeText = '${formatter.format(picked.start)} → ${formatter.format(picked.end)}';
      });
      _loadData();
    }
  }

  void _exportInvoices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting 42 invoices to CSV... Download started.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 28,
          vertical: isMobile ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Title
            _buildBreadcrumbsAndTitle(),
            const SizedBox(height: 18),

            // 4 KPI Summary Cards (Figure 6)
            _buildKpiCards(),
            const SizedBox(height: 20),

            // Filter Toolbar (Figure 6)
            _buildFilterToolbar(),
            const SizedBox(height: 16),

            // Invoices Table & Pagination (Figure 6)
            _buildInvoicesTable(),
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
              onTap: () => context.go('/dashboard'),
              child: Text(context.l10n.home, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            InkWell(
              onTap: () => context.go('/sales/invoices'),
              child: Text(context.l10n.sales, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(context.l10n.invoices, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.salesInvoicesTitle,
          style: const TextStyle(
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
    final currencyFormatter = NumberFormat('#,##0', 'en_US');
    final kpis = _kpis;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 950;
        final isTablet = constraints.maxWidth >= 550;
        final cardWidth = isDesktop
            ? (constraints.maxWidth - 36) / 4
            : (isTablet ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth);

        final cards = [
          _buildSummaryCard(
            title: context.l10n.statusDraft,
            value: '${kpis?.draftCount ?? 6}',
            valueColor: AppColors.textPrimary,
            icon: Icons.edit_note_rounded,
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: context.l10n.statusUnpaid,
            value: 'AED ${currencyFormatter.format(kpis?.unpaidAmount ?? 271320)}',
            valueColor: AppColors.textPrimary,
            icon: Icons.schedule_rounded,
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: context.l10n.statusOverdue,
            value: 'AED ${currencyFormatter.format(kpis?.overdueAmount ?? 113600)}',
            valueColor: const Color(0xFFDC2626), // Red from Figure 6
            icon: Icons.warning_amber_rounded,
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: context.l10n.paidThisMonth,
            value: 'AED ${currencyFormatter.format(kpis?.paidThisMonthAmount ?? 196450)}',
            valueColor: const Color(0xFF16A34A), // Green from Figure 6
            icon: Icons.check_circle_outline_rounded,
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

  Widget _buildFilterToolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        // Search Input
        final searchInput = SizedBox(
          width: isWide ? 200 : double.infinity,
          height: 40,
          child: TextField(
            controller: _searchController,
            onSubmitted: (_) => _loadData(),
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              hintText: context.l10n.searchInvoiceCustomer,
              hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: 17, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        );

        // Status Filter Dropdown
        final statusDropdown = Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              items: [
                DropdownMenuItem(value: 'All Status', child: Text(context.l10n.allStatus)),
                DropdownMenuItem(value: 'Draft', child: Text(context.l10n.statusDraft)),
                DropdownMenuItem(value: 'Sent', child: Text(context.l10n.statusSent)),
                DropdownMenuItem(value: 'Partial', child: Text(context.l10n.statusPartial)),
                DropdownMenuItem(value: 'Paid', child: Text(context.l10n.statusPaid)),
                DropdownMenuItem(value: 'Overdue', child: Text(context.l10n.statusOverdue)),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedStatus = val);
                  _loadData();
                }
              },
            ),
          ),
        );

        // Date Range Picker Button
        final datePickerButton = InkWell(
          onTap: _pickDateRange,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    _dateRangeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );

        // Export Button
        final exportBtn = OutlinedButton.icon(
          onPressed: _exportInvoices,
          icon: const Icon(Icons.download_rounded, size: 15, color: AppColors.textSecondary),
          label: Text(context.l10n.export, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            minimumSize: const Size(0, 40),
          ),
        );

        // New Invoice Button
        final newInvoiceBtn = ElevatedButton.icon(
          onPressed: () => context.go('/sales/invoices/new'),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: Text('+ ${context.l10n.newInvoice}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            minimumSize: const Size(0, 40),
            elevation: 0,
          ),
        );

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchInput,
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  statusDropdown,
                  datePickerButton,
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  exportBtn,
                  newInvoiceBtn,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    searchInput,
                    const SizedBox(width: 8),
                    statusDropdown,
                    const SizedBox(width: 8),
                    datePickerButton,
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            exportBtn,
            const SizedBox(width: 8),
            newInvoiceBtn,
          ],
        );
      },
    );
  }

  Widget _buildInvoicesTable() {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth = constraints.maxWidth < 850 ? 850.0 : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: effectiveWidth,
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          color: const Color(0xFFF8FAFC),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: Text('Invoice #', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                              Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                              Expanded(flex: 3, child: Text('Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                              Expanded(flex: 2, child: Text('Due Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                              Expanded(flex: 2, child: Text('Total (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                              Expanded(flex: 2, child: Text('Balance (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                              SizedBox(width: 16),
                              SizedBox(width: 80, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.borderSubtle),

                        // Rows or Loading
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_invoices.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Text(context.l10n.noInvoicesFound, style: const TextStyle(color: AppColors.textMuted)),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _invoices.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderSubtle),
                            itemBuilder: (context, index) {
                              final inv = _invoices[index];
                              return InkWell(
                                onTap: () => _showPdfPreview(inv),
                                hoverColor: const Color(0xFFF8FAFC),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  child: Row(
                                    children: [
                                      // Invoice # (blue link)
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          inv.invoiceNo,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),
                                      // Date
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          inv.invoiceDate,
                                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      // Customer
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          inv.customerName,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Due Date
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          inv.dueDate,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: inv.dueDate == '—' ? AppColors.textMuted : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      // Total (AED)
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          currencyFormatter.format(inv.total),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      // Balance (AED)
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          currencyFormatter.format(inv.balanceDue),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Status chip
                                      SizedBox(
                                        width: 80,
                                        child: Center(child: InvoiceStatusChip(status: inv.status)),
                                      ),
                                    ],
                                  ),
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

            // Pagination footer (Figure 6)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Showing 1-${_invoices.length} of $_totalItems',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                          icon: const Icon(Icons.chevron_left, size: 18),
                          splashRadius: 16,
                          visualDensity: VisualDensity.compact,
                        ),
                        for (int p = 1; p <= _totalPages; p++)
                          InkWell(
                            onTap: () => setState(() => _currentPage = p),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: _currentPage == p ? const Color(0xFFEFF6FF) : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _currentPage == p ? const Color(0xFFBFDBFE) : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                '$p',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _currentPage == p ? FontWeight.bold : FontWeight.normal,
                                  color: _currentPage == p ? const Color(0xFF2563EB) : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: _currentPage < _totalPages ? () => setState(() => _currentPage++) : null,
                          icon: const Icon(Icons.chevron_right, size: 18),
                          splashRadius: 16,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
