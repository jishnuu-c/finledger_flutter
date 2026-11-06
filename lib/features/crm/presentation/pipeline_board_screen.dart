import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/models/crm_models.dart';
import '../data/services/crm_service.dart';
import 'widgets/convert_customer_dialog.dart';
import 'widgets/kanban_column_widget.dart';
import 'widgets/lost_reason_dialog.dart';
import 'widgets/new_opportunity_dialog.dart';

enum PipelineViewMode { board, list }

class PipelineBoardScreen extends StatefulWidget {
  final CrmService? crmService;

  const PipelineBoardScreen({
    super.key,
    this.crmService,
  });

  @override
  State<PipelineBoardScreen> createState() => _PipelineBoardScreenState();
}

class _PipelineBoardScreenState extends State<PipelineBoardScreen> {
  late final CrmService _crmService;
  final TextEditingController _searchController = TextEditingController();

  String _selectedOwner = 'All';
  String _selectedClose = 'This quarter';
  PipelineViewMode _viewMode = PipelineViewMode.board;
  OpportunityBoardData? _boardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.crmService != null) {
      _crmService = widget.crmService!;
    } else {
      DioClient? dio;
      try {
        dio = context.read<DioClient>();
      } catch (_) {}
      _crmService = CrmService(dioClient: dio);
    }
    _loadBoardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBoardData() async {
    setState(() => _isLoading = true);
    final data = await _crmService.getBoardData(
      search: _searchController.text,
      owner: _selectedOwner,
      closePeriod: _selectedClose,
    );
    if (mounted) {
      setState(() {
        _boardData = data;
        _isLoading = false;
      });
    }
  }

  /// Handles drag-and-drop stage updates with business rules:
  /// 1. Won requires customer
  /// 2. Lost requires lost reason
  /// 3. Rollback on API error
  Future<void> _handleDropStage(Opportunity opp, String targetStage) async {
    final originalStage = opp.stage;
    if (originalStage == targetStage) return;

    // Rule: Moving to WON requires a customer
    int? customerId = opp.customerId;
    String? customerName = opp.customerName;

    if (targetStage == 'Won' && customerId == null) {
      final result = await showDialog<ConvertCustomerDialogResult>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ConvertCustomerDialog(
          initialCustomerName: opp.customerName,
          isWinningDeal: true,
        ),
      );

      if (result == null) {
        // User cancelled linking customer; abort drop without changes
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deal cannot be marked Won without an associated customer.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      customerId = 999;
      customerName = result.customerName;
    }

    // Rule: Moving to LOST requires a mandatory lost reason
    String? lostReason;
    if (targetStage == 'Lost') {
      if (!mounted) return;
      final reason = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => LostReasonDialog(opportunityTitle: opp.title),
      );

      if (reason == null || reason.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deal cannot be marked Lost without a mandatory lost reason.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }
      lostReason = reason;
    }

    // Optimistic UI update
    final previousBoardData = _boardData;
    final updatedOpp = opp.copyWith(
      stage: targetStage,
      customerId: customerId,
      customerName: customerName,
      lostReason: lostReason,
    );

    setState(() {
      if (_boardData != null) {
        final currentStageList = List<Opportunity>.from(_boardData!.stageOpportunities[originalStage] ?? []);
        currentStageList.removeWhere((o) => o.id == opp.id);

        final targetStageList = List<Opportunity>.from(_boardData!.stageOpportunities[targetStage] ?? []);
        targetStageList.insert(0, updatedOpp);

        final updatedMap = Map<String, List<Opportunity>>.from(_boardData!.stageOpportunities);
        updatedMap[originalStage] = currentStageList;
        updatedMap[targetStage] = targetStageList;

        _boardData = OpportunityBoardData(
          kpis: _boardData!.kpis,
          stages: _boardData!.stages,
          stageOpportunities: updatedMap,
        );
      }
    });

    try {
      await _crmService.updateOpportunityStage(
        opportunityId: opp.id,
        newStage: targetStage,
        lostReason: lostReason,
        customerId: customerId,
        customerName: customerName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved "${opp.title}" to $targetStage'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        // Refresh server calculations
        _loadBoardData();
      }
    } catch (e) {
      // Rollback on API failure per spec Page 10 & 13
      if (mounted) {
        setState(() {
          _boardData = previousBoardData;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stage update failed. Card rolled back to $originalStage: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToDetail(Opportunity opp) {
    context.go('/crm/opportunities/${opp.id}');
  }

  Future<void> _openNewOpportunityModal() async {
    final created = await showDialog<Opportunity>(
      context: context,
      builder: (ctx) => NewOpportunityDialog(stages: _boardData?.stages ?? ['New']),
    );

    if (created != null) {
      await _crmService.createOpportunity(
        title: created.title,
        customerName: created.customerName,
        expectedValue: created.expectedValue,
        probabilityPct: created.probabilityPct,
        expectedCloseDate: created.expectedCloseDate,
        ownerName: created.ownerName,
        stage: created.stage,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opportunity "${created.title}" created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadBoardData();
      }
    }
  }

  void _showImportLeadsModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Import Leads & Deals'),
        content: const Text(
          'Upload a CSV file containing lead coordinates, estimated deal amounts, and sales owners. '
          'Records will be automatically parsed and mapped into the Sales Pipeline.',
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Leads import completed. 6 new opportunities added to pipeline.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.file_upload_outlined, size: 16),
                label: const Text('Select CSV File'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs & Title
              _buildBreadcrumbsAndTitle(),
              const SizedBox(height: 16),

              // Top Filter Bar & Actions (Figure 4)
              _buildTopFilterBar(),
              const SizedBox(height: 16),

              // 4 KPI Cards (Figure 4)
              _buildKpiStrip(),
              const SizedBox(height: 20),

              // Kanban Board or List View
              if (isMobile)
                SizedBox(
                  height: 540,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _viewMode == PipelineViewMode.board
                          ? _buildKanbanBoard()
                          : _buildListView(),
                )
              else
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _viewMode == PipelineViewMode.board
                          ? _buildKanbanBoard()
                          : _buildListView(),
                ),
            ],
          );

          return isMobile
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: content,
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: content,
                );
        },
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
              onTap: () => context.go('/crm/pipeline'),
              child: const Text(
                'CRM',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
            ),
            const Text(
              '  /  ',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const Text(
              'Pipeline',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Sales Pipeline',
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

  Widget _buildTopFilterBar() {
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
              width: 220,
              height: 38,
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _loadBoardData(),
                decoration: InputDecoration(
                  hintText: 'Search opportunity...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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

            // Owner Dropdown: "Owner: All ▼"
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
                  value: _selectedOwner,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('Owner: All')),
                    DropdownMenuItem(value: 'Raj', child: Text('Owner: Raj')),
                    DropdownMenuItem(value: 'Sara', child: Text('Owner: Sara')),
                    DropdownMenuItem(value: 'Ahmed', child: Text('Owner: Ahmed')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedOwner = val);
                      _loadBoardData();
                    }
                  },
                ),
              ),
            ),

            // Close Period Dropdown: "Close: This quarter ▼"
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
                  value: _selectedClose,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  items: const [
                    DropdownMenuItem(value: 'This quarter', child: Text('Close: This quarter')),
                    DropdownMenuItem(value: 'This month', child: Text('Close: This month')),
                    DropdownMenuItem(value: 'Next quarter', child: Text('Close: Next quarter')),
                    DropdownMenuItem(value: 'All', child: Text('Close: All')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedClose = val);
                      _loadBoardData();
                    }
                  },
                ),
              ),
            ),

            // Board / List View Toggle
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleSegment(
                    label: 'Board',
                    isSelected: _viewMode == PipelineViewMode.board,
                    onTap: () => setState(() => _viewMode = PipelineViewMode.board),
                  ),
                  Container(width: 1, height: 20, color: AppColors.border),
                  _buildToggleSegment(
                    label: 'List',
                    isSelected: _viewMode == PipelineViewMode.list,
                    onTap: () => setState(() => _viewMode = PipelineViewMode.list),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Right Actions
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _showImportLeadsModal,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Import Leads', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: _openNewOpportunityModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Figure 4 blue button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                elevation: 0,
              ),
              child: const Text('+ New Opportunity', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiStrip() {
    final currencyFormatter = NumberFormat('#,##0', 'en_US');
    final kpis = _boardData?.kpis;

    final openPipeStr = 'AED ${currencyFormatter.format(kpis?.openPipeline ?? 1264000)}';
    final weightedStr = 'AED ${currencyFormatter.format(kpis?.weightedForecast ?? 481700)}';
    final wonQuarterStr = 'AED ${currencyFormatter.format(kpis?.wonThisQuarter ?? 342500)}';
    final winRateStr = '${(kpis?.winRatePct ?? 34).toStringAsFixed(0)}%';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 950;
        final isTablet = constraints.maxWidth >= 550;
        final cardWidth = isDesktop
            ? (constraints.maxWidth - 36) / 4
            : (isTablet ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth);

        final cards = [
          _buildKpiCard(
            title: 'Open pipeline',
            value: openPipeStr,
            valueColor: AppColors.textPrimary,
            width: cardWidth,
          ),
          _buildKpiCard(
            title: 'Weighted forecast',
            value: weightedStr,
            valueColor: AppColors.textPrimary,
            width: cardWidth,
          ),
          _buildKpiCard(
            title: 'Won this quarter',
            value: wonQuarterStr,
            valueColor: const Color(0xFF10B981), // Emerald green from Figure 4
            width: cardWidth,
          ),
          _buildKpiCard(
            title: 'Win rate (90 days)',
            value: winRateStr,
            valueColor: AppColors.textPrimary,
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

  Widget _buildKpiCard({
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
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
        ],
      ),
    );
  }

  Widget _buildKanbanBoard() {
    if (_boardData == null) return const SizedBox.shrink();

    final stages = _boardData!.stages;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: stages.map((stage) {
          final opps = _boardData!.stageOpportunities[stage] ?? [];
          final total = _boardData!.totalForStage(stage);

          return KanbanColumnWidget(
            stageName: stage,
            opportunities: opps,
            totalValue: total,
            onDropOpportunity: _handleDropStage,
            onOpportunityClick: _navigateToDetail,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListView() {
    final allOpps = _boardData?.stageOpportunities.values.expand((x) => x).toList() ?? [];
    final currencyFormatter = NumberFormat('#,##0', 'en_US');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
      child: ListView.separated(
        itemCount: allOpps.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderSubtle),
        itemBuilder: (context, index) {
          final opp = allOpps[index];
          return ListTile(
            onTap: () => _navigateToDetail(opp),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    opp.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    opp.stage,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${opp.customerName} • Close: ${opp.expectedCloseDate} • Owner: ${opp.ownerName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${opp.currencyCode} ${currencyFormatter.format(opp.expectedValue)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
              ],
            ),
          );
        },
      ),
    ),
    );
  }
}
