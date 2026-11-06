import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/models/crm_models.dart';
import '../data/services/crm_service.dart';
import 'widgets/convert_customer_dialog.dart';
import 'widgets/lost_reason_dialog.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final int opportunityId;
  final CrmService? crmService;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunityId,
    this.crmService,
  });

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  late final CrmService _crmService;
  final TextEditingController _quickLogController = TextEditingController();

  OpportunityDetail? _detail;
  bool _isLoading = true;
  String _selectedTab = 'Activity'; // Activity, Notes, Emails, Files (3)

  final List<String> _stages = ['New', 'Qualified', 'Proposal', 'Negotiation', 'Won'];

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
    _loadDetail();
  }

  @override
  void dispose() {
    _quickLogController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final detail = await _crmService.getOpportunityDetail(widget.opportunityId);
    if (mounted) {
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStageClick(String targetStage) async {
    if (_detail == null) return;
    final opp = _detail!.opportunity;
    if (opp.stage == targetStage) return;

    int? customerId = opp.customerId;
    String? customerName = opp.customerName;

    // Rule: Won requires a customer
    if (targetStage == 'Won' && customerId == null) {
      final res = await showDialog<ConvertCustomerDialogResult>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ConvertCustomerDialog(
          initialCustomerName: opp.customerName,
          isWinningDeal: true,
        ),
      );
      if (res == null) return;
      customerId = 999;
      customerName = res.customerName;
    }

    try {
      final updated = await _crmService.updateOpportunityStage(
        opportunityId: opp.id,
        newStage: targetStage,
        customerId: customerId,
        customerName: customerName,
      );

      final newHistory = List<StageHistoryItem>.from(_detail!.stageHistory);
      newHistory.insert(
        0,
        StageHistoryItem(stageName: targetStage, dateLabel: _formatToday()),
      );

      setState(() {
        _detail = _detail!.copyWith(
          opportunity: updated,
          stageHistory: newHistory,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stage changed to $targetStage'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stage: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleMarkLost() async {
    if (_detail == null) return;
    final opp = _detail!.opportunity;

    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LostReasonDialog(opportunityTitle: opp.title),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      final updated = await _crmService.updateOpportunityStage(
        opportunityId: opp.id,
        newStage: 'Lost',
        lostReason: reason,
      );

      final newHistory = List<StageHistoryItem>.from(_detail!.stageHistory);
      newHistory.insert(
        0,
        StageHistoryItem(stageName: 'Lost', dateLabel: _formatToday()),
      );

      setState(() {
        _detail = _detail!.copyWith(
          opportunity: updated,
          stageHistory: newHistory,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opportunity marked as Lost'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _handleConvertToCustomer() async {
    if (_detail == null) return;
    final opp = _detail!.opportunity;

    final res = await showDialog<ConvertCustomerDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConvertCustomerDialog(
        initialCustomerName: opp.customerName,
        initialContactName: _detail!.contact?.fullName,
        initialEmail: _detail!.contact?.email,
        initialPhone: _detail!.contact?.phone,
        isWinningDeal: false,
      ),
    );

    if (res == null) return;

    try {
      final updated = await _crmService.convertLeadToCustomer(
        opportunityId: opp.id,
        customerName: res.customerName,
        trn: res.trn,
      );

      setState(() {
        _detail = _detail!.copyWith(opportunity: updated);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Converted "${res.customerName}" into permanent Customer record.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversion failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _handleAddQuotation() async {
    if (_detail == null) return;
    final opp = _detail!.opportunity;

    final quoteNum = 'QT-2026-0${100 + _detail!.quotations.length}';
    final created = await _crmService.addQuotation(
      opportunityId: opp.id,
      quotationNo: quoteNum,
      total: opp.expectedValue,
      currencyCode: opp.currencyCode,
    );

    setState(() {
      final list = List<CrmQuotation>.from(_detail!.quotations)..add(created);
      _detail = _detail!.copyWith(quotations: list);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generated Quotation $quoteNum for ${opp.currencyCode} ${opp.expectedValue.toStringAsFixed(0)}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _logQuickAction(String type) async {
    if (_detail == null) return;
    final text = _quickLogController.text.trim();
    final subject = text.isNotEmpty ? text : '$type with ${_detail!.contact?.fullName ?? _detail!.opportunity.customerName}';

    final logged = await _crmService.logActivity(
      opportunityId: widget.opportunityId,
      activityType: type.toUpperCase(),
      subject: '$type — $subject',
      details: text.isNotEmpty ? text : 'Logged via quick action.',
      dueAt: type == 'Task' ? '08-Nov' : null,
    );

    _quickLogController.clear();

    final activities = List<CrmActivityItem>.from(_detail!.activities)..insert(0, logged);
    var tasks = _detail!.openTasks;
    if (type == 'Task') {
      tasks = List<CrmTaskItem>.from(_detail!.openTasks)..insert(
        0,
        CrmTaskItem(
          id: logged.id,
          title: subject,
          dueDateLabel: 'Due 08-Nov',
          urgency: TaskUrgency.warning,
          activityId: logged.id,
        ),
      );
    }

    setState(() {
      _detail = _detail!.copyWith(activities: activities, openTasks: tasks);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged $type successfully'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleTask(CrmTaskItem task, bool isChecked) async {
    if (_detail == null) return;

    await _crmService.toggleTaskCompletion(
      opportunityId: widget.opportunityId,
      taskId: task.id,
      isCompleted: isChecked,
    );

    final updatedTasks = _detail!.openTasks.map((t) {
      if (t.id == task.id) return t.copyWith(isCompleted: isChecked);
      return t;
    }).toList();

    setState(() {
      _detail = _detail!.copyWith(openTasks: updatedTasks);
    });
  }

  String _formatToday() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day}-${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _detail == null) {
      return const Scaffold(
        backgroundColor: AppColors.contentBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final opp = _detail!.opportunity;

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Title
            _buildBreadcrumb(opp),
            const SizedBox(height: 6),
            Text(
              '${opp.customerName} — ${opp.title}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 18),

            // Top Stage Progress Bar & Actions (Figure 5)
            _buildStageBarAndActions(opp),
            const SizedBox(height: 20),

            // 3-Column Layout: Left (Details, Contact, Quotes), Center (Timeline), Right (Tasks, Stage History)
            _buildThreeColumnLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(Opportunity opp) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => context.go('/crm/pipeline'),
          child: const Text('CRM', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
        const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        InkWell(
          onTap: () => context.go('/crm/pipeline'),
          child: const Text('Opportunities', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
        const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(
          opp.opportunityNo,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStageBarAndActions(Opportunity opp) {
    final currentStageIndex = _stages.indexOf(opp.stage);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Stage progress pills matching Figure 5
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _stages.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final stage = entry.value;
                    final isCurrent = stage == opp.stage;
                    final isPast = currentStageIndex != -1 && idx < currentStageIndex;

                    return InkWell(
                      onTap: () => _handleStageClick(stage),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF2563EB) // Solid Blue from Figure 5
                              : (isPast ? const Color(0xFFE2E8F0) : Colors.transparent),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          stage,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                            color: isCurrent
                                ? Colors.white
                                : (isPast ? const Color(0xFF1E40AF) : AppColors.textMuted),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ),

            // Action Buttons matching Figure 5
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _handleMarkLost,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  ),
                  child: const Text('Mark Lost', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                OutlinedButton(
                  onPressed: _handleAddQuotation,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  ),
                  child: const Text('+ Quotation', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: _handleConvertToCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // Solid blue button
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    elevation: 0,
                  ),
                  child: const Text('Convert to Customer', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildThreeColumnLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 980;

        if (!isDesktop) {
          // Stacked vertically on small viewports
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLeftColumn(),
              const SizedBox(height: 16),
              _buildCenterColumn(),
              const SizedBox(height: 16),
              _buildRightColumn(),
            ],
          );
        }

        // Full 3-Column Desktop Layout (Figure 5)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (Deal details, Contact, Quotes) ~290px
            SizedBox(
              width: 290,
              child: _buildLeftColumn(),
            ),
            const SizedBox(width: 16),

            // Center Column (Activity Feed) Expanded
            Expanded(
              child: _buildCenterColumn(),
            ),
            const SizedBox(width: 16),

            // Right Column (Tasks, Stage History) ~290px
            SizedBox(
              width: 290,
              child: _buildRightColumn(),
            ),
          ],
        );
      },
    );
  }

  // LEFT COLUMN: Deal details, Contact card, linked Quotations
  Widget _buildLeftColumn() {
    final opp = _detail!.opportunity;
    final contact = _detail!.contact;
    final currencyFormatter = NumberFormat('#,##0', 'en_US');

    return Column(
      children: [
        // 1. Deal Details Card
        _buildCardContainer(
          title: 'Deal details',
          child: Column(
            children: [
              _buildDetailRow('Opportunity', opp.opportunityNo),
              _buildDetailRow('Expected value', '${opp.currencyCode} ${currencyFormatter.format(opp.expectedValue)}'),
              _buildDetailRow('Probability', '${opp.probabilityPct}%'),
              _buildDetailRow('Expected close', opp.expectedCloseDate.replaceAll('Close ', '')),
              _buildDetailRow('Owner', opp.ownerName),
              _buildDetailRow('Source', opp.source),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Contact Card
        _buildCardContainer(
          title: 'Contact',
          child: contact == null
              ? const Text('No primary contact linked.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar Circle KA
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D9488), // Teal background
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            contact.initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                              if (contact.jobTitle != null)
                                Text(
                                  contact.jobTitle!,
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (contact.email != null)
                      _buildContactItem(Icons.email_outlined, contact.email!),
                    if (contact.phone != null)
                      _buildContactItem(Icons.phone_outlined, contact.phone!),
                    if (contact.location != null)
                      _buildContactItem(Icons.location_on_outlined, contact.location!),
                  ],
                ),
        ),
        const SizedBox(height: 16),

        // 3. Quotations Card
        _buildCardContainer(
          title: 'Quotations',
          child: _detail!.quotations.isEmpty
              ? const Text('No quotations generated yet.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
              : Column(
                  children: _detail!.quotations.map((q) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                q.quotationNo,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB), // Blue link color
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  q.status == 'SENT' ? 'Sent' : q.status,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${q.currencyCode} ${currencyFormatter.format(q.total)} incl. VAT 15%',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // CENTER COLUMN: Activity timeline, Quick Log bar, Tabs
  Widget _buildCenterColumn() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs: Activity, Notes, Emails, Files (3)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabItem('Activity', isSelected: _selectedTab == 'Activity'),
                const SizedBox(width: 18),
                _buildTabItem('Notes', isSelected: _selectedTab == 'Notes'),
                const SizedBox(width: 18),
                _buildTabItem('Emails', isSelected: _selectedTab == 'Emails'),
                const SizedBox(width: 18),
                _buildTabItem('Files (3)', isSelected: _selectedTab == 'Files (3)'),
              ],
            ),
          ),
          const Divider(height: 24, color: AppColors.borderSubtle),

          // Quick Log Bar matching Figure 5
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: LayoutBuilder(
              builder: (context, qConstraints) {
                if (qConstraints.maxWidth < 450) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _quickLogController,
                        decoration: const InputDecoration(
                          hintText: 'Log a call, meeting or note...',
                          hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildQuickButton(
                            label: 'Call',
                            icon: Icons.phone_outlined,
                            onTap: () => _logQuickAction('Call'),
                          ),
                          _buildQuickButton(
                            label: 'Meeting',
                            icon: Icons.calendar_today_outlined,
                            onTap: () => _logQuickAction('Meeting'),
                          ),
                          _buildQuickButton(
                            label: 'Task',
                            icon: Icons.check_box_outlined,
                            onTap: () => _logQuickAction('Task'),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quickLogController,
                        decoration: const InputDecoration(
                          hintText: 'Log a call, meeting or note...',
                          hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildQuickButton(
                          label: 'Call',
                          icon: Icons.phone_outlined,
                          onTap: () => _logQuickAction('Call'),
                        ),
                        _buildQuickButton(
                          label: 'Meeting',
                          icon: Icons.calendar_today_outlined,
                          onTap: () => _logQuickAction('Meeting'),
                        ),
                        _buildQuickButton(
                          label: 'Task',
                          icon: Icons.check_box_outlined,
                          onTap: () => _logQuickAction('Task'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Activity Timeline Stream
          _buildActivityTimeline(),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, {required bool isSelected}) {
    return InkWell(
      onTap: () => setState(() => _selectedTab = label),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF2563EB) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 40,
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimeline() {
    final activities = _detail!.activities;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final item = activities[index];
        final isLast = index == activities.length - 1;

        Color iconBg = const Color(0xFF64748B);
        IconData icon = Icons.circle;

        switch (item.activityType) {
          case 'MEETING':
            iconBg = const Color(0xFF8B5CF6); // Purple
            icon = Icons.calendar_month_outlined;
            break;
          case 'EMAIL':
            iconBg = const Color(0xFF2563EB); // Royal blue
            icon = Icons.mail_outline_rounded;
            break;
          case 'CALL':
            iconBg = const Color(0xFF0D9488); // Teal
            icon = Icons.phone_outlined;
            break;
          case 'TASK':
            iconBg = const Color(0xFFD97706); // Amber
            icon = Icons.check_circle_outline;
            break;
          default:
            iconBg = const Color(0xFF94A3B8); // Slate grey
            icon = Icons.star_border_rounded;
            break;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon & Vertical Line
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: Colors.white, size: 14),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.subject,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (item.details != null && item.details!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.details!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${item.authorName} · ${item.createdAt}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // RIGHT COLUMN: Open tasks & Stage history
  Widget _buildRightColumn() {
    return Column(
      children: [
        // 1. Open Tasks Card
        _buildCardContainer(
          title: 'Open tasks',
          child: _detail!.openTasks.isEmpty
              ? const Text('All tasks completed! Great job.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
              : Column(
                  children: _detail!.openTasks.map((task) {
                    Color badgeBg = const Color(0xFFF1F5F9);
                    Color badgeText = const Color(0xFF475569);

                    switch (task.urgency) {
                      case TaskUrgency.critical:
                        badgeBg = const Color(0xFFFEE2E2); // Rose
                        badgeText = const Color(0xFFDC2626);
                        break;
                      case TaskUrgency.warning:
                        badgeBg = const Color(0xFFFEF3C7); // Amber
                        badgeText = const Color(0xFFD97706);
                        break;
                      case TaskUrgency.normal:
                        badgeBg = const Color(0xFFF1F5F9); // Slate
                        badgeText = const Color(0xFF475569);
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: task.isCompleted,
                              onChanged: (val) {
                                if (val != null) _toggleTask(task, val);
                              },
                              activeColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task.dueDateLabel,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: badgeText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),

        // 2. Stage History Card
        _buildCardContainer(
          title: 'Stage history',
          child: Column(
            children: _detail!.stageHistory.map((sh) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sh.stageName,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      '· ${sh.dateLabel}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
