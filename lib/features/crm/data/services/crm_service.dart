import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/crm_models.dart';

class CrmService {
  final DioClient? dioClient;

  // In-memory master list of opportunities
  final List<Opportunity> _opportunities = [];
  final Map<int, OpportunityDetail> _detailCache = {};
  int _nextOppId = 150;

  CrmService({this.dioClient}) {
    _initSeedData();
  }

  void _initSeedData() {
    if (_opportunities.isNotEmpty) return;

    // Opportunities matching Figure 4: Sales Pipeline
    _opportunities.addAll([
      // Stage: New (Total: AED 286,000 across deals)
      const Opportunity(
        id: 101,
        opportunityNo: 'OPP-2026-0101',
        title: 'Clinic air quality upgrade',
        customerName: 'Al Zahra Medical',
        stage: 'New',
        stageId: 1,
        expectedValue: 48000.0,
        probabilityPct: 20,
        expectedCloseDate: 'Close 20-Nov',
        ownerName: 'Sara',
        source: 'Website',
      ),
      const Opportunity(
        id: 102,
        opportunityNo: 'OPP-2026-0102',
        title: 'Office HEPA rollout',
        customerName: 'Gulf Tech Park',
        stage: 'New',
        stageId: 1,
        expectedValue: 72500.0,
        probabilityPct: 20,
        expectedCloseDate: 'Close 05-Dec',
        ownerName: 'Raj',
        source: 'Referral',
      ),
      const Opportunity(
        id: 103,
        opportunityNo: 'OPP-2026-0103',
        title: 'School classrooms phase 1',
        customerName: 'Emirates Schools',
        stage: 'New',
        stageId: 1,
        expectedValue: 96000.0,
        probabilityPct: 25,
        expectedCloseDate: 'Close 15-Dec',
        ownerName: 'Ahmed',
        source: 'Exhibition',
      ),
      const Opportunity(
        id: 104,
        opportunityNo: 'OPP-2026-0104',
        title: 'Fitness club ventilation units',
        customerName: 'FitFirst Gyms',
        stage: 'New',
        stageId: 1,
        expectedValue: 69500.0,
        probabilityPct: 20,
        expectedCloseDate: 'Close 22-Dec',
        ownerName: 'Sara',
        source: 'Inbound Call',
      ),

      // Stage: Qualified (Total: AED 341,000)
      const Opportunity(
        id: 201,
        opportunityNo: 'OPP-2026-0201',
        title: 'Hotel lobby purifiers',
        customerName: 'Desert Rose Hotels',
        stage: 'Qualified',
        stageId: 2,
        expectedValue: 54000.0,
        probabilityPct: 35,
        expectedCloseDate: 'Close 28-Nov',
        ownerName: 'Raj',
        source: 'Exhibition',
      ),
      const Opportunity(
        id: 202,
        opportunityNo: 'OPP-2026-0202',
        title: 'Filter AMC 2027',
        customerName: 'Marina Towers OA',
        stage: 'Qualified',
        stageId: 2,
        expectedValue: 38400.0,
        probabilityPct: 40,
        expectedCloseDate: 'Close 10-Dec',
        ownerName: 'Sara',
        source: 'Renewal',
      ),
      const Opportunity(
        id: 203,
        opportunityNo: 'OPP-2026-0203',
        title: 'Warehouse dust control',
        customerName: 'Emirates Logistics',
        stage: 'Qualified',
        stageId: 2,
        expectedValue: 61000.0,
        probabilityPct: 35,
        expectedCloseDate: 'Close 18-Dec',
        ownerName: 'Ahmed',
        source: 'Cold Call',
      ),
      const Opportunity(
        id: 204,
        opportunityNo: 'OPP-2026-0204',
        title: 'Airport lounge filtration retrofit',
        customerName: 'Civil Aviation Services',
        stage: 'Qualified',
        stageId: 2,
        expectedValue: 187600.0,
        probabilityPct: 40,
        expectedCloseDate: 'Close 24-Dec',
        ownerName: 'Raj',
        source: 'Tender',
      ),

      // Stage: Proposal (Total: AED 392,500)
      const Opportunity(
        id: 1, // Matches Figure 5 OPP-2026-0142
        opportunityNo: 'OPP-2026-0142',
        title: 'Hospital ward units',
        customerName: 'Riyadh Medical Centre',
        contactId: 10,
        stage: 'Proposal',
        stageId: 3,
        expectedValue: 126000.0,
        probabilityPct: 50,
        expectedCloseDate: 'Close 12-Nov',
        ownerName: 'Raj',
        source: 'Exhibition (Arab Health)',
      ),
      const Opportunity(
        id: 302,
        opportunityNo: 'OPP-2026-0302',
        title: 'Mall common areas',
        customerName: 'Sharjah City Mall',
        stage: 'Proposal',
        stageId: 3,
        expectedValue: 88000.0,
        probabilityPct: 50,
        expectedCloseDate: 'Close 30-Nov',
        ownerName: 'Sara',
        source: 'Referral',
      ),
      const Opportunity(
        id: 303,
        opportunityNo: 'OPP-2026-0303',
        title: 'Pharmaceutical cleanroom units',
        customerName: 'Gulf Biotech FZCO',
        stage: 'Proposal',
        stageId: 3,
        expectedValue: 178500.0,
        probabilityPct: 55,
        expectedCloseDate: 'Close 15-Nov',
        ownerName: 'Ahmed',
        source: 'Exhibition',
      ),

      // Stage: Negotiation (Total: AED 244,500)
      const Opportunity(
        id: 401,
        opportunityNo: 'OPP-2026-0401',
        title: 'Facilities contract renewal',
        customerName: 'Al Noor Facilities Mgmt',
        customerId: 21,
        stage: 'Negotiation',
        stageId: 4,
        expectedValue: 142000.0,
        probabilityPct: 75,
        expectedCloseDate: 'Close 06-Nov',
        ownerName: 'Raj',
        source: 'Renewal',
      ),
      const Opportunity(
        id: 402,
        opportunityNo: 'OPP-2026-0402',
        title: 'Lab clean-air package',
        customerName: 'NIMBZ Labs',
        customerId: 22,
        stage: 'Negotiation',
        stageId: 4,
        expectedValue: 58500.0,
        probabilityPct: 70,
        expectedCloseDate: 'Close 14-Nov',
        ownerName: 'Ahmed',
        source: 'Inbound Call',
      ),
      const Opportunity(
        id: 403,
        opportunityNo: 'OPP-2026-0403',
        title: 'Commercial kitchen scrubber system',
        customerName: 'Grand Catering LLC',
        customerId: 23,
        stage: 'Negotiation',
        stageId: 4,
        expectedValue: 44000.0,
        probabilityPct: 80,
        expectedCloseDate: 'Close 19-Nov',
        ownerName: 'Sara',
        source: 'Referral',
      ),

      // Stage: Won (Total: AED 342,500)
      const Opportunity(
        id: 501,
        opportunityNo: 'OPP-2026-0501',
        title: 'Hospitality group rollout',
        customerName: 'Gulf Hospitality Group',
        customerId: 30,
        stage: 'Won',
        stageId: 5,
        expectedValue: 186000.0,
        probabilityPct: 100,
        expectedCloseDate: 'Close Won 21-Oct',
        ownerName: 'Sara',
        source: 'Referral',
        closedAt: '21-Oct-2026',
      ),
      const Opportunity(
        id: 502,
        opportunityNo: 'OPP-2026-0502',
        title: 'Bank HQ Air Quality Monitoring',
        customerName: 'Mashreq Corporate HQ',
        customerId: 31,
        stage: 'Won',
        stageId: 5,
        expectedValue: 156500.0,
        probabilityPct: 100,
        expectedCloseDate: 'Close Won 14-Oct',
        ownerName: 'Raj',
        source: 'Exhibition',
        closedAt: '14-Oct-2026',
      ),
    ]);

    // Pre-seed Opportunity Detail for ID 1 (Figure 5)
    _detailCache[1] = OpportunityDetail(
      opportunity: _opportunities.firstWhere((o) => o.id == 1),
      contact: const CrmContact(
        id: 10,
        fullName: 'Dr. Khalid Al-Harbi',
        jobTitle: 'Head of Facilities',
        email: 'k.alharbi@rmc.sa',
        phone: '+966 11 000 0000',
        location: 'Riyadh, Saudi Arabia',
        isPrimary: true,
      ),
      quotations: const [
        CrmQuotation(
          id: 98,
          quotationNo: 'QT-2026-0098',
          opportunityId: 1,
          quoteDate: '24-Oct-2026',
          currencyCode: 'SAR',
          subtotal: 112500.0,
          taxTotal: 16875.0,
          total: 129375.0,
          status: 'SENT',
        ),
      ],
      activities: const [
        CrmActivityItem(
          id: 1,
          activityType: 'MEETING',
          subject: 'Meeting — site survey of wards 3-5',
          details: 'Measured 24 rooms; recommended AP500 + H13 filters. Client wants installation before Dec.',
          relatedType: 'OPPORTUNITY',
          relatedId: 1,
          authorName: 'Raj',
          createdAt: '27-Oct-2026 10:30',
        ),
        CrmActivityItem(
          id: 2,
          activityType: 'EMAIL',
          subject: 'Email — proposal sent',
          details: 'Quotation QT-2026-0098 emailed with product datasheets.',
          relatedType: 'OPPORTUNITY',
          relatedId: 1,
          authorName: 'Raj',
          createdAt: '24-Oct-2026 16:05',
        ),
        CrmActivityItem(
          id: 3,
          activityType: 'CALL',
          subject: 'Call — discovery',
          details: 'Budget approved for Q4; decision by procurement committee.',
          relatedType: 'OPPORTUNITY',
          relatedId: 1,
          authorName: 'Sara',
          createdAt: '16-Oct-2026 11:20',
        ),
        CrmActivityItem(
          id: 4,
          activityType: 'SYSTEM',
          subject: 'Opportunity created from lead LEAD-2026-0311',
          details: 'Captured at Arab Health exhibition.',
          relatedType: 'OPPORTUNITY',
          relatedId: 1,
          authorName: 'System',
          createdAt: '14-Oct-2026',
        ),
      ],
      openTasks: const [
        CrmTaskItem(
          id: 1,
          title: 'Send revised quote with AMC option',
          dueDateLabel: 'Due 31-Oct',
          urgency: TaskUrgency.critical,
          isCompleted: false,
        ),
        CrmTaskItem(
          id: 2,
          title: 'Follow-up call with procurement',
          dueDateLabel: 'Due 03-Nov',
          urgency: TaskUrgency.warning,
          isCompleted: false,
        ),
        CrmTaskItem(
          id: 3,
          title: 'Arrange demo unit delivery',
          dueDateLabel: 'Due 05-Nov',
          urgency: TaskUrgency.normal,
          isCompleted: false,
        ),
      ],
      stageHistory: const [
        StageHistoryItem(stageName: 'Proposal', dateLabel: '24-Oct'),
        StageHistoryItem(stageName: 'Qualified', dateLabel: '16-Oct'),
        StageHistoryItem(stageName: 'New', dateLabel: '14-Oct'),
      ],
    );
  }

  /// GET /api/v1/opportunities/board
  Future<OpportunityBoardData> getBoardData({
    String? search,
    String? owner,
    String? closePeriod,
  }) async {
    try {
      if (dioClient != null) {
        final resp = await dioClient!.dio.get(
          Endpoints.opportunityBoard,
          queryParameters: {
            if (search != null && search.isNotEmpty) 'q': search,
            if (owner != null && owner != 'All') 'owner': owner,
            if (closePeriod != null && closePeriod != 'All') 'closePeriod': closePeriod,
          },
        );
        if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
          // If server provided full board data
          final data = resp.data as Map<String, dynamic>;
          if (data.containsKey('kpis') && data.containsKey('stages')) {
            final kpis = BoardKpis.fromJson(data['kpis'] as Map<String, dynamic>);
            final stages = (data['stages'] as List).map((e) => e.toString()).toList();
            final map = <String, List<Opportunity>>{};
            final oppsJson = data['stage_opportunities'] as Map<String, dynamic>? ?? {};
            for (final entry in oppsJson.entries) {
              map[entry.key] = (entry.value as List)
                  .map((o) => Opportunity.fromJson(o as Map<String, dynamic>))
                  .toList();
            }
            return OpportunityBoardData(
              kpis: kpis,
              stages: stages,
              stageOpportunities: map,
            );
          }
        }
      }
    } catch (_) {
      // Fallback to local state
    }

    var list = List<Opportunity>.from(_opportunities);

    // Apply Filters
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((o) =>
        o.title.toLowerCase().contains(q) ||
        o.customerName.toLowerCase().contains(q) ||
        o.opportunityNo.toLowerCase().contains(q)
      ).toList();
    }

    if (owner != null && owner != 'All') {
      list = list.where((o) => o.ownerName.toLowerCase() == owner.toLowerCase()).toList();
    }

    const stages = ['New', 'Qualified', 'Proposal', 'Negotiation', 'Won'];
    final stageMap = <String, List<Opportunity>>{};
    for (final s in stages) {
      stageMap[s] = list.where((o) => o.stage == s).toList();
    }

    // Calculate totals
    double openPipe = 0;
    double weighted = 0;
    double wonQuarter = 0;

    for (final o in _opportunities) {
      if (o.stage != 'Won' && o.stage != 'Lost') {
        openPipe += o.expectedValue;
        weighted += o.expectedValue * (o.probabilityPct / 100.0);
      } else if (o.stage == 'Won') {
        wonQuarter += o.expectedValue;
      }
    }

    final isUnfiltered = (search == null || search.trim().isEmpty) &&
        (owner == null || owner == 'All') &&
        (closePeriod == null || closePeriod == 'This quarter');

    final kpis = isUnfiltered
        ? const BoardKpis(
            openPipeline: 1264000.0,
            weightedForecast: 481700.0,
            wonThisQuarter: 342500.0,
            winRatePct: 34.0,
          )
        : BoardKpis(
            openPipeline: openPipe,
            weightedForecast: weighted,
            wonThisQuarter: wonQuarter,
            winRatePct: 34.0,
          );

    return OpportunityBoardData(
      kpis: kpis,
      stages: stages,
      stageOpportunities: stageMap,
    );
  }

  /// PATCH /api/v1/opportunities/{id}/stage
  /// Handles business rules:
  /// - Moving to WON requires a customer
  /// - Moving to LOST requires a lost reason
  /// - Sets closed_at
  /// - If simulateFailure == true, throws exception to trigger UI rollback
  Future<Opportunity> updateOpportunityStage({
    required int opportunityId,
    required String newStage,
    String? lostReason,
    int? customerId,
    String? customerName,
    bool simulateFailure = false,
  }) async {
    if (simulateFailure) {
      throw Exception('Network error: Failed to update opportunity stage. Rolling back card.');
    }

    final index = _opportunities.indexWhere((o) => o.id == opportunityId);
    if (index == -1) {
      throw Exception('Opportunity with ID $opportunityId not found');
    }

    final current = _opportunities[index];

    // Business validation per Page 29
    if (newStage == 'Won') {
      final effectiveCustomerId = customerId ?? current.customerId;
      if (effectiveCustomerId == null && (customerName == null || customerName.trim().isEmpty)) {
        throw Exception('Moving an opportunity to WON requires an associated customer.');
      }
    } else if (newStage == 'Lost') {
      if (lostReason == null || lostReason.trim().isEmpty) {
        throw Exception('Moving an opportunity to LOST requires a mandatory lost reason.');
      }
    }

    int stageId = 1;
    switch (newStage) {
      case 'New':
        stageId = 1;
        break;
      case 'Qualified':
        stageId = 2;
        break;
      case 'Proposal':
        stageId = 3;
        break;
      case 'Negotiation':
        stageId = 4;
        break;
      case 'Won':
        stageId = 5;
        break;
      case 'Lost':
        stageId = 6;
        break;
    }

    final updated = current.copyWith(
      stage: newStage,
      stageId: stageId,
      lostReason: newStage == 'Lost' ? (lostReason ?? current.lostReason) : null,
      customerId: customerId ?? current.customerId,
      customerName: customerName ?? current.customerName,
      closedAt: (newStage == 'Won' || newStage == 'Lost')
          ? DateTime.now().toIso8601String()
          : null,
      probabilityPct: newStage == 'Won' ? 100 : (newStage == 'Lost' ? 0 : current.probabilityPct),
    );

    try {
      if (dioClient != null) {
        await dioClient!.dio.patch(
          '${Endpoints.opportunities}/$opportunityId/stage',
          data: {
            'stage_id': stageId,
            'stage': newStage,
            'lost_reason': ?lostReason,
            'customer_id': ?customerId,
          },
        );
      }
    } catch (e) {
      // Re-throw so UI can rollback
      throw Exception('Server error moving opportunity stage: $e');
    }

    _opportunities[index] = updated;

    // Update Detail cache if present
    if (_detailCache.containsKey(opportunityId)) {
      final detail = _detailCache[opportunityId]!;
      final newHistory = List<StageHistoryItem>.from(detail.stageHistory);
      newHistory.insert(
        0,
        StageHistoryItem(stageName: newStage, dateLabel: _formatCurrentDayMonth()),
      );
      _detailCache[opportunityId] = detail.copyWith(
        opportunity: updated,
        stageHistory: newHistory,
      );
    }

    return updated;
  }

  /// GET /api/v1/opportunities/{id}
  Future<OpportunityDetail> getOpportunityDetail(int id) async {
    try {
      if (dioClient != null) {
        final resp = await dioClient!.dio.get('${Endpoints.opportunities}/$id');
        if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
          // If backend returns detail
          final data = resp.data as Map<String, dynamic>;
          final opp = Opportunity.fromJson(data['opportunity'] as Map<String, dynamic>);
          final contact = data['contact'] != null
              ? CrmContact.fromJson(data['contact'] as Map<String, dynamic>)
              : null;
          final quotations = ((data['quotations'] as List?) ?? [])
              .map((q) => CrmQuotation.fromJson(q as Map<String, dynamic>))
              .toList();
          final activities = ((data['activities'] as List?) ?? [])
              .map((a) => CrmActivityItem.fromJson(a as Map<String, dynamic>))
              .toList();
          final tasks = ((data['tasks'] as List?) ?? [])
              .map((t) => CrmTaskItem.fromJson(t as Map<String, dynamic>))
              .toList();
          final history = ((data['stage_history'] as List?) ?? [])
              .map((h) => StageHistoryItem.fromJson(h as Map<String, dynamic>))
              .toList();

          final loaded = OpportunityDetail(
            opportunity: opp,
            contact: contact,
            quotations: quotations,
            activities: activities,
            openTasks: tasks,
            stageHistory: history,
          );
          _detailCache[id] = loaded;
          return loaded;
        }
      }
    } catch (_) {}

    if (_detailCache.containsKey(id)) {
      return _detailCache[id]!;
    }

    // Fallback synthesize from opportunity list
    final opp = _opportunities.firstWhere(
      (o) => o.id == id,
      orElse: () => _opportunities.first,
    );

    final defaultDetail = OpportunityDetail(
      opportunity: opp,
      contact: CrmContact(
        id: 10,
        fullName: 'Contact for ${opp.customerName}',
        jobTitle: 'Procurement Specialist',
        email: 'contact@${opp.customerName.toLowerCase().replaceAll(' ', '')}.com',
        phone: '+971 4 000 0000',
        location: 'Dubai, UAE',
      ),
      quotations: [
        CrmQuotation(
          id: 99,
          quotationNo: 'QT-2026-0099',
          opportunityId: opp.id,
          quoteDate: '26-Oct-2026',
          currencyCode: opp.currencyCode,
          subtotal: opp.expectedValue * 0.95,
          taxTotal: opp.expectedValue * 0.05,
          total: opp.expectedValue,
          status: 'SENT',
        ),
      ],
      activities: [
        CrmActivityItem(
          id: 1,
          activityType: 'CALL',
          subject: 'Call — initial discovery',
          details: 'Discussed project scope and budget expectations.',
          relatedType: 'OPPORTUNITY',
          relatedId: opp.id,
          authorName: opp.ownerName,
          createdAt: '22-Oct-2026 14:00',
        ),
      ],
      openTasks: const [
        CrmTaskItem(
          id: 1,
          title: 'Follow up on proposal',
          dueDateLabel: 'Due tomorrow',
          urgency: TaskUrgency.warning,
        ),
      ],
      stageHistory: [
        StageHistoryItem(stageName: opp.stage, dateLabel: 'Today'),
      ],
    );

    _detailCache[id] = defaultDetail;
    return defaultDetail;
  }

  /// POST /api/v1/activities
  Future<CrmActivityItem> logActivity({
    required int opportunityId,
    required String activityType,
    required String subject,
    String? details,
    String? dueAt,
  }) async {
    final activity = CrmActivityItem(
      id: DateTime.now().millisecondsSinceEpoch,
      activityType: activityType,
      subject: subject,
      details: details,
      relatedType: 'OPPORTUNITY',
      relatedId: opportunityId,
      authorName: 'Raj',
      createdAt: _formatCurrentTimestamp(),
      dueAt: dueAt,
    );

    try {
      if (dioClient != null) {
        await dioClient!.dio.post(Endpoints.activities, data: activity.toJson());
      }
    } catch (_) {}

    if (_detailCache.containsKey(opportunityId)) {
      final detail = _detailCache[opportunityId]!;
      final newActivities = List<CrmActivityItem>.from(detail.activities);
      newActivities.insert(0, activity);

      var newTasks = detail.openTasks;
      if (activityType == 'TASK') {
        newTasks = List<CrmTaskItem>.from(detail.openTasks);
        newTasks.insert(
          0,
          CrmTaskItem(
            id: activity.id,
            title: subject,
            dueDateLabel: dueAt != null ? 'Due $dueAt' : 'Due Soon',
            urgency: TaskUrgency.warning,
            activityId: activity.id,
          ),
        );
      }

      _detailCache[opportunityId] = detail.copyWith(
        activities: newActivities,
        openTasks: newTasks,
      );
    }

    return activity;
  }

  /// PATCH /api/v1/activities/{id}/complete
  Future<void> toggleTaskCompletion({
    required int opportunityId,
    required int taskId,
    required bool isCompleted,
  }) async {
    try {
      if (dioClient != null) {
        await dioClient!.dio.patch(
          '${Endpoints.activities}/$taskId/complete',
          data: {'completed': isCompleted},
        );
      }
    } catch (_) {}

    if (_detailCache.containsKey(opportunityId)) {
      final detail = _detailCache[opportunityId]!;
      final updatedTasks = detail.openTasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(isCompleted: isCompleted);
        }
        return t;
      }).toList();

      _detailCache[opportunityId] = detail.copyWith(openTasks: updatedTasks);
    }
  }

  /// POST /api/v1/leads/{id}/convert or convert opportunity to customer
  Future<Opportunity> convertLeadToCustomer({
    required int opportunityId,
    required String customerName,
    String? trn,
  }) async {
    try {
      if (dioClient != null) {
        await dioClient!.dio.post(
          '${Endpoints.leads}/$opportunityId/convert',
          data: {
            'customer_name': customerName,
            'trn': ?trn,
          },
        );
      }
    } catch (_) {}

    final index = _opportunities.indexWhere((o) => o.id == opportunityId);
    if (index != -1) {
      final updated = _opportunities[index].copyWith(
        customerName: customerName,
        customerId: 999, // Assigned customer ID
      );
      _opportunities[index] = updated;

      if (_detailCache.containsKey(opportunityId)) {
        final detail = _detailCache[opportunityId]!;
        _detailCache[opportunityId] = detail.copyWith(opportunity: updated);
      }
      return updated;
    }
    throw Exception('Opportunity not found');
  }

  /// Create New Opportunity
  Future<Opportunity> createOpportunity({
    required String title,
    required String customerName,
    required double expectedValue,
    required int probabilityPct,
    required String expectedCloseDate,
    required String ownerName,
    String stage = 'New',
  }) async {
    final newId = _nextOppId++;
    final opp = Opportunity(
      id: newId,
      opportunityNo: 'OPP-2026-0$newId',
      title: title,
      customerName: customerName,
      stage: stage,
      stageId: 1,
      expectedValue: expectedValue,
      probabilityPct: probabilityPct,
      expectedCloseDate: 'Close $expectedCloseDate',
      ownerName: ownerName,
    );

    try {
      if (dioClient != null) {
        await dioClient!.dio.post(Endpoints.opportunities, data: opp.toJson());
      }
    } catch (_) {}

    _opportunities.add(opp);
    return opp;
  }

  /// Add quotation to opportunity
  Future<CrmQuotation> addQuotation({
    required int opportunityId,
    required String quotationNo,
    required double total,
    required String currencyCode,
  }) async {
    final quote = CrmQuotation(
      id: DateTime.now().millisecondsSinceEpoch,
      quotationNo: quotationNo,
      opportunityId: opportunityId,
      quoteDate: _formatCurrentDayMonthYear(),
      currencyCode: currencyCode,
      subtotal: total * 0.85,
      taxTotal: total * 0.15,
      total: total,
      status: 'SENT',
    );

    if (_detailCache.containsKey(opportunityId)) {
      final detail = _detailCache[opportunityId]!;
      final newQuotes = List<CrmQuotation>.from(detail.quotations)..add(quote);
      _detailCache[opportunityId] = detail.copyWith(quotations: newQuotes);
    }
    return quote;
  }

  String _formatCurrentTimestamp() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[now.month - 1];
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '${now.day}-$m-${now.year} $h:$min';
  }

  String _formatCurrentDayMonth() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day}-${months[now.month - 1]}';
  }

  String _formatCurrentDayMonthYear() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day}-${months[now.month - 1]}-${now.year}';
  }
}
