import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/report_models.dart';
import '../data/services/report_service.dart';
import 'widgets/gl_drilldown_modal.dart';

class ReportsViewerScreen extends StatefulWidget {
  final ReportService? reportService;
  final String initialReportType;

  const ReportsViewerScreen({
    super.key,
    this.reportService,
    this.initialReportType = 'pnl',
  });

  @override
  State<ReportsViewerScreen> createState() => _ReportsViewerScreenState();
}

class _ReportsViewerScreenState extends State<ReportsViewerScreen> {
  late ReportService _service;
  late String _currentReportCode;
  FinancialReportData? _reportData;
  bool _isLoading = true;

  String _dateRangeText = '01-Jan-2026 → 31-Oct-2026';
  String _compareOption = 'Prior Year';
  String _costCenter = 'All Cost Centers';

  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _service = widget.reportService ?? ReportService();
    _currentReportCode = widget.initialReportType;
    _runReport();
  }

  Future<void> _runReport() async {
    setState(() => _isLoading = true);
    final data = await _service.getFinancialReport(
      reportCode: _currentReportCode,
      fromDate: '01-Jan-2026',
      toDate: '31-Oct-2026',
      compareOption: _compareOption,
      costCenter: _costCenter,
    );
    setState(() {
      _reportData = data;
      _isLoading = false;
    });
  }

  void _onReportTypeChanged(String newCode) {
    setState(() {
      _currentReportCode = newCode;
    });
    _runReport();
  }

  void _openGlDrilldown(ReportRow row) {
    if (!row.isDrillable) return;
    showDialog(
      context: context,
      builder: (ctx) => GlDrilldownModal(
        accountCode: row.accountCode!,
        accountName: row.accountName,
        reportService: _service,
      ),
    );
  }

  Future<void> _handleExport(String format) async {
    final fileName = await _service.exportReport(
      reportCode: _currentReportCode,
      format: format,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report exported: $fileName'),
          backgroundColor: const Color(0xFF16A34A),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentConfig = ReportService.availableReports.firstWhere(
      (r) => r.code == _currentReportCode,
      orElse: () => ReportService.availableReports.first,
    );

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs & Title
          _buildHeader(currentConfig),
          const SizedBox(height: 16),

          // Controls Toolbar Bar
          _buildControlsBar(),
          const SizedBox(height: 16),

          // Main Report Paper Sheet
          _isLoading
              ? const ContainerLoadingPlaceholder()
              : _buildReportPaperSheet(),
        ],
      ),
    );
  }

  Widget _buildHeader(ReportTypeConfig config) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Reports', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                const Text('/', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(width: 4),
                Text(config.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                const Text('/', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(width: 4),
                Text(config.title, style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              config.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        // Switcher dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currentReportCode,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                items: ReportService.availableReports.map((r) {
                  return DropdownMenuItem<String>(
                    value: r.code,
                    child: Text(r.title),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) _onReportTypeChanged(val);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 950;
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildPeriodButton(),
                    _buildCompareDropdown(),
                    _buildCostCenterDropdown(),
                    _buildRunButton(),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildExportButtons(),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPeriodButton(),
                      const SizedBox(width: 10),
                      _buildCompareDropdown(),
                      const SizedBox(width: 10),
                      _buildCostCenterDropdown(),
                      const SizedBox(width: 12),
                      _buildRunButton(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildExportButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodButton() {
    return InkWell(
      onTap: () {
        // Quick period switch dialog
        showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: const Text('Select Period', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  setState(() => _dateRangeText = '01-Jan-2026 → 31-Oct-2026');
                  Navigator.pop(ctx);
                  _runReport();
                },
                child: const Text('Year to Date (01-Jan to 31-Oct 2026)'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() => _dateRangeText = '01-Oct-2026 → 31-Oct-2026');
                  Navigator.pop(ctx);
                  _runReport();
                },
                child: const Text('This Month (October 2026)'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() => _dateRangeText = '01-Jul-2026 → 30-Sep-2026');
                  Navigator.pop(ctx);
                  _runReport();
                },
                child: const Text('Q3 2026 (01-Jul to 30-Sep 2026)'),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                _dateRangeText,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompareDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _compareOption,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            items: const [
              DropdownMenuItem(value: 'Prior Year', child: Text('Compare: Prior Year')),
              DropdownMenuItem(value: 'Prior Period', child: Text('Compare: Prior Period')),
              DropdownMenuItem(value: 'Budget', child: Text('Compare: Budget')),
              DropdownMenuItem(value: 'None', child: Text('Compare: None')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _compareOption = val);
                _runReport();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCostCenterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _costCenter,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            items: const [
              DropdownMenuItem(value: 'All Cost Centers', child: Text('All Cost Centers')),
              DropdownMenuItem(value: 'Sales', child: Text('Sales')),
              DropdownMenuItem(value: 'Operations', child: Text('Operations')),
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _costCenter = val);
                _runReport();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRunButton() {
    return ElevatedButton(
      onPressed: _runReport,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: const Text('Run', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildExportButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildExportButton(
          label: 'PDF',
          icon: Icons.picture_as_pdf_outlined,
          onTap: () => _handleExport('pdf'),
        ),
        _buildExportButton(
          label: 'Excel',
          icon: Icons.table_chart_outlined,
          onTap: () => _handleExport('xlsx'),
        ),
        _buildExportButton(
          label: 'Print',
          icon: Icons.print_outlined,
          onTap: () => _handleExport('print'),
        ),
      ],
    );
  }

  Widget _buildExportButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildReportPaperSheet() {
    final data = _reportData!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1050),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            const BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          children: [
            // Centered Header from Figure 16
            Text(
              data.companyName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              data.reportTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              data.periodDescription,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Formatted Table
            _buildStatementTable(data),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementTable(FinancialReportData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = constraints.maxWidth > 850 ? constraints.maxWidth : 850.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            child: Column(
              children: [
                // Column Headers
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.5)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 4,
                        child: Text('Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(data.currentColumnHeader, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(data.comparativeColumnHeader, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Text('Change %', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),

                // Sections
                for (final section in data.sections) ...[
                  if (section.title.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          section.title,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                  for (final row in section.rows) _buildStatementRow(row),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatementRow(ReportRow row) {
    final hasCompare = row.comparativeAmount != null;
    final change = row.changePercentage;

    // Highlight row style (e.g. Net Profit in Figure 16)
    if (row.isHighlight) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // Light blue banner from Figure 16
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                row.accountName,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _currencyFormat.format(row.currentAmount),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                hasCompare ? _currencyFormat.format(row.comparativeAmount!) : '—',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                change != null ? '${change.toStringAsFixed(1)}%' : '—',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
              ),
            ),
          ],
        ),
      );
    }

    // Total row style
    if (row.isTotal) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0)),
            bottom: BorderSide(color: Color(0xFFCBD5E1)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                row.accountName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _currencyFormat.format(row.currentAmount),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                hasCompare ? _currencyFormat.format(row.comparativeAmount!) : '—',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                change != null ? '${change.toStringAsFixed(1)}%' : '—',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: (change ?? 0) >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Standard account row with drilldown click
    return InkWell(
      onTap: row.isDrillable ? () => _openGlDrilldown(row) : null,
      hoverColor: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(left: row.indentLevel * 16.0),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        row.accountName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: row.isDrillable ? const Color(0xFF1E293B) : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (row.isDrillable) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new, size: 12, color: Color(0xFF94A3B8)),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _currencyFormat.format(row.currentAmount),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                hasCompare ? _currencyFormat.format(row.comparativeAmount!) : '—',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                change != null ? '${change.toStringAsFixed(1)}%' : '—',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: (change ?? 0) >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerLoadingPlaceholder extends StatelessWidget {
  const ContainerLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
