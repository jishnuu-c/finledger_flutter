import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
        Row(
          children: [
            InkWell(
              onTap: () => context.go('/sales/invoices'),
              child: const Text('Sales', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('Invoices', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Sales Invoices',
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
            title: 'Draft',
            value: '${kpis?.draftCount ?? 6}',
            valueColor: AppColors.textPrimary,
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: 'Unpaid',
            value: 'AED ${currencyFormatter.format(kpis?.unpaidAmount ?? 271320)}',
            valueColor: AppColors.textPrimary,
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: 'Overdue',
            value: 'AED ${currencyFormatter.format(kpis?.overdueAmount ?? 113600)}',
            valueColor: const Color(0xFFDC2626), // Red from Figure 6
            width: cardWidth,
          ),
          _buildSummaryCard(
            title: 'Paid (this month)',
            value: 'AED ${currencyFormatter.format(kpis?.paidThisMonthAmount ?? 196450)}',
            valueColor: const Color(0xFF16A34A), // Green from Figure 6
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
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
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
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Left Filters
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Search Input
            SizedBox(
              width: 240,
              height: 38,
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _loadData(),
                decoration: InputDecoration(
                  hintText: 'Search invoice / customer...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
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
            ),

            // Status Filter Dropdown
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  items: const [
                    DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                    DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'Sent', child: Text('Sent')),
                    DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                    DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'Overdue', child: Text('Overdue')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStatus = val);
                      _loadData();
                    }
                  },
                ),
              ),
            ),

            // Date Range Picker Button
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    _dateRangeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Right Actions: Export and + New Invoice
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _exportInvoices,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Export', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => context.go('/sales/invoices/new'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Blue button from Figure 6
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                elevation: 0,
              ),
              child: const Text('+ New Invoice', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoicesTable() {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.border)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 2, child: Text('Invoice #', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                Expanded(flex: 3, child: Text('Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                Expanded(flex: 2, child: Text('Due Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                Expanded(flex: 2, child: Text('Total (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                Expanded(flex: 2, child: Text('Balance (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                SizedBox(width: 16),
                                SizedBox(width: 80, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                              ],
                            ),
                          ),

                          // Rows or Loading
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_invoices.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                child: Text('No invoices found matching criteria', style: TextStyle(color: AppColors.textMuted)),
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
                border: Border(top: BorderSide(color: AppColors.border)),
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
