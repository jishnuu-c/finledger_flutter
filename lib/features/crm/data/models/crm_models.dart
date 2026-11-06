import 'package:flutter/material.dart';

enum TaskUrgency {
  critical, // Due today or near (rose/red badge)
  warning, // Due in 2-3 days (amber badge)
  normal, // Due later (slate badge)
}

class Opportunity {
  final int id;
  final String opportunityNo; // e.g. OPP-2026-0142
  final String title; // Deal name e.g. Hospital ward units
  final String customerName; // e.g. Riyadh Medical Centre
  final int? customerId;
  final int? contactId;
  final int? leadId;
  final String stage; // New, Qualified, Proposal, Negotiation, Won, Lost
  final int stageId;
  final double expectedValue;
  final String currencyCode; // AED, SAR, etc.
  final int probabilityPct;
  final String expectedCloseDate; // e.g. Close 12-Nov or 12-Nov-2026
  final String ownerName;
  final int? ownerUserId;
  final String source; // e.g. Exhibition (Arab Health)
  final String? lostReason;
  final String? closedAt;

  const Opportunity({
    required this.id,
    required this.opportunityNo,
    required this.title,
    required this.customerName,
    this.customerId,
    this.contactId,
    this.leadId,
    required this.stage,
    required this.stageId,
    required this.expectedValue,
    this.currencyCode = 'AED',
    required this.probabilityPct,
    required this.expectedCloseDate,
    required this.ownerName,
    this.ownerUserId,
    this.source = 'Website',
    this.lostReason,
    this.closedAt,
  });

  String get ownerInitial {
    if (ownerName.isEmpty) return 'U';
    return ownerName.trim()[0].toUpperCase();
  }

  Color get ownerBadgeColor {
    switch (ownerInitial) {
      case 'R':
        return const Color(0xFF2563EB); // Royal Blue
      case 'S':
        return const Color(0xFF0D9488); // Teal
      case 'A':
        return const Color(0xFF7C3AED); // Purple
      case 'M':
        return const Color(0xFFD97706); // Amber
      default:
        return const Color(0xFF475569); // Slate
    }
  }

  Opportunity copyWith({
    int? id,
    String? opportunityNo,
    String? title,
    String? customerName,
    int? customerId,
    int? contactId,
    int? leadId,
    String? stage,
    int? stageId,
    double? expectedValue,
    String? currencyCode,
    int? probabilityPct,
    String? expectedCloseDate,
    String? ownerName,
    int? ownerUserId,
    String? source,
    String? lostReason,
    String? closedAt,
  }) {
    return Opportunity(
      id: id ?? this.id,
      opportunityNo: opportunityNo ?? this.opportunityNo,
      title: title ?? this.title,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      contactId: contactId ?? this.contactId,
      leadId: leadId ?? this.leadId,
      stage: stage ?? this.stage,
      stageId: stageId ?? this.stageId,
      expectedValue: expectedValue ?? this.expectedValue,
      currencyCode: currencyCode ?? this.currencyCode,
      probabilityPct: probabilityPct ?? this.probabilityPct,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      ownerName: ownerName ?? this.ownerName,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      source: source ?? this.source,
      lostReason: lostReason ?? this.lostReason,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opportunity_no': opportunityNo,
      'title': title,
      'customer_name': customerName,
      'customer_id': customerId,
      'contact_id': contactId,
      'lead_id': leadId,
      'stage': stage,
      'stage_id': stageId,
      'expected_value': expectedValue,
      'currency_code': currencyCode,
      'probability_pct': probabilityPct,
      'expected_close_date': expectedCloseDate,
      'owner_name': ownerName,
      'owner_user_id': ownerUserId,
      'source': source,
      'lost_reason': lostReason,
      'closed_at': closedAt,
    };
  }

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] as int? ?? 0,
      opportunityNo: json['opportunity_no'] as String? ?? json['opportunityNo'] as String? ?? '',
      title: json['title'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? json['customerName'] as String? ?? '',
      customerId: json['customer_id'] as int? ?? json['customerId'] as int?,
      contactId: json['contact_id'] as int? ?? json['contactId'] as int?,
      leadId: json['lead_id'] as int? ?? json['leadId'] as int?,
      stage: json['stage'] as String? ?? 'New',
      stageId: json['stage_id'] as int? ?? json['stageId'] as int? ?? 1,
      expectedValue: (json['expected_value'] as num? ?? json['expectedValue'] as num? ?? 0.0).toDouble(),
      currencyCode: json['currency_code'] as String? ?? json['currencyCode'] as String? ?? 'AED',
      probabilityPct: json['probability_pct'] as int? ?? json['probabilityPct'] as int? ?? 0,
      expectedCloseDate: json['expected_close_date'] as String? ?? json['expectedCloseDate'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? json['ownerName'] as String? ?? 'Admin',
      ownerUserId: json['owner_user_id'] as int? ?? json['ownerUserId'] as int?,
      source: json['source'] as String? ?? 'Direct',
      lostReason: json['lost_reason'] as String? ?? json['lostReason'] as String?,
      closedAt: json['closed_at'] as String? ?? json['closedAt'] as String?,
    );
  }
}

class BoardKpis {
  final double openPipeline;
  final double weightedForecast;
  final double wonThisQuarter;
  final double winRatePct;

  const BoardKpis({
    required this.openPipeline,
    required this.weightedForecast,
    required this.wonThisQuarter,
    required this.winRatePct,
  });

  factory BoardKpis.fromJson(Map<String, dynamic> json) {
    return BoardKpis(
      openPipeline: (json['open_pipeline'] as num? ?? 0.0).toDouble(),
      weightedForecast: (json['weighted_forecast'] as num? ?? 0.0).toDouble(),
      wonThisQuarter: (json['won_this_quarter'] as num? ?? 0.0).toDouble(),
      winRatePct: (json['win_rate_pct'] as num? ?? 0.0).toDouble(),
    );
  }
}

class OpportunityBoardData {
  final BoardKpis kpis;
  final List<String> stages;
  final Map<String, List<Opportunity>> stageOpportunities;

  const OpportunityBoardData({
    required this.kpis,
    required this.stages,
    required this.stageOpportunities,
  });

  double totalForStage(String stage) {
    final list = stageOpportunities[stage] ?? [];
    return list.fold(0.0, (sum, opp) => sum + opp.expectedValue);
  }

  int countForStage(String stage) {
    return (stageOpportunities[stage] ?? []).length;
  }
}

class CrmContact {
  final int id;
  final String fullName;
  final String? jobTitle;
  final String? email;
  final String? phone;
  final String? location;
  final bool isPrimary;

  const CrmContact({
    required this.id,
    required this.fullName,
    this.jobTitle,
    this.email,
    this.phone,
    this.location,
    this.isPrimary = true,
  });

  String get initials {
    final parts = fullName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    // e.g. Dr. Khalid Al-Harbi -> KA or KH
    if (parts[0].toLowerCase().startsWith('dr')) {
      if (parts.length >= 3) {
        return '${parts[1][0]}${parts[2][0]}'.toUpperCase();
      }
      return parts[1][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory CrmContact.fromJson(Map<String, dynamic> json) {
    return CrmContact(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? json['jobTitle'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      isPrimary: json['is_primary'] as bool? ?? json['isPrimary'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'job_title': jobTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'is_primary': isPrimary,
    };
  }
}

class CrmQuotation {
  final int id;
  final String quotationNo; // e.g. QT-2026-0098
  final int? opportunityId;
  final String quoteDate;
  final String currencyCode;
  final double subtotal;
  final double taxTotal;
  final double total; // e.g. 129375.0
  final String status; // DRAFT, SENT, ACCEPTED, REJECTED, INVOICED

  const CrmQuotation({
    required this.id,
    required this.quotationNo,
    this.opportunityId,
    required this.quoteDate,
    required this.currencyCode,
    required this.subtotal,
    required this.taxTotal,
    required this.total,
    required this.status,
  });

  factory CrmQuotation.fromJson(Map<String, dynamic> json) {
    return CrmQuotation(
      id: json['id'] as int? ?? 0,
      quotationNo: json['quotation_no'] as String? ?? json['quotationNo'] as String? ?? '',
      opportunityId: json['opportunity_id'] as int? ?? json['opportunityId'] as int?,
      quoteDate: json['quote_date'] as String? ?? json['quoteDate'] as String? ?? '',
      currencyCode: json['currency_code'] as String? ?? json['currencyCode'] as String? ?? 'SAR',
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
      taxTotal: (json['tax_total'] as num? ?? 0.0).toDouble(),
      total: (json['total'] as num? ?? 0.0).toDouble(),
      status: json['status'] as String? ?? 'DRAFT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_no': quotationNo,
      'opportunity_id': opportunityId,
      'quote_date': quoteDate,
      'currency_code': currencyCode,
      'subtotal': subtotal,
      'tax_total': taxTotal,
      'total': total,
      'status': status,
    };
  }
}

class CrmActivityItem {
  final int id;
  final String activityType; // CALL, MEETING, EMAIL, WHATSAPP, NOTE, TASK, SYSTEM
  final String subject;
  final String? details;
  final String relatedType;
  final int relatedId;
  final String authorName;
  final String createdAt;
  final String? dueAt;
  final String? completedAt;

  const CrmActivityItem({
    required this.id,
    required this.activityType,
    required this.subject,
    this.details,
    this.relatedType = 'OPPORTUNITY',
    required this.relatedId,
    required this.authorName,
    required this.createdAt,
    this.dueAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  factory CrmActivityItem.fromJson(Map<String, dynamic> json) {
    return CrmActivityItem(
      id: json['id'] as int? ?? 0,
      activityType: json['activity_type'] as String? ?? json['activityType'] as String? ?? 'NOTE',
      subject: json['subject'] as String? ?? '',
      details: json['details'] as String?,
      relatedType: json['related_type'] as String? ?? 'OPPORTUNITY',
      relatedId: json['related_id'] as int? ?? json['relatedId'] as int? ?? 0,
      authorName: json['author_name'] as String? ?? json['authorName'] as String? ?? 'User',
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      dueAt: json['due_at'] as String? ?? json['dueAt'] as String?,
      completedAt: json['completed_at'] as String? ?? json['completedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType,
      'subject': subject,
      'details': details,
      'related_type': relatedType,
      'related_id': relatedId,
      'author_name': authorName,
      'created_at': createdAt,
      'due_at': dueAt,
      'completed_at': completedAt,
    };
  }
}

class CrmTaskItem {
  final int id;
  final String title;
  final String dueDateLabel; // e.g. Due 31-Oct
  final TaskUrgency urgency;
  final bool isCompleted;
  final int? activityId;

  const CrmTaskItem({
    required this.id,
    required this.title,
    required this.dueDateLabel,
    this.urgency = TaskUrgency.normal,
    this.isCompleted = false,
    this.activityId,
  });

  CrmTaskItem copyWith({
    int? id,
    String? title,
    String? dueDateLabel,
    TaskUrgency? urgency,
    bool? isCompleted,
    int? activityId,
  }) {
    return CrmTaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDateLabel: dueDateLabel ?? this.dueDateLabel,
      urgency: urgency ?? this.urgency,
      isCompleted: isCompleted ?? this.isCompleted,
      activityId: activityId ?? this.activityId,
    );
  }

  factory CrmTaskItem.fromJson(Map<String, dynamic> json) {
    final urgencyStr = json['urgency'] as String? ?? 'normal';
    final urgency = urgencyStr == 'critical'
        ? TaskUrgency.critical
        : urgencyStr == 'warning'
            ? TaskUrgency.warning
            : TaskUrgency.normal;

    return CrmTaskItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      dueDateLabel: json['due_date_label'] as String? ?? '',
      urgency: urgency,
      isCompleted: json['is_completed'] as bool? ?? false,
      activityId: json['activity_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'due_date_label': dueDateLabel,
      'urgency': urgency.name,
      'is_completed': isCompleted,
      'activity_id': activityId,
    };
  }
}

class StageHistoryItem {
  final String stageName;
  final String dateLabel; // e.g. 24-Oct

  const StageHistoryItem({
    required this.stageName,
    required this.dateLabel,
  });

  factory StageHistoryItem.fromJson(Map<String, dynamic> json) {
    return StageHistoryItem(
      stageName: json['stage_name'] as String? ?? '',
      dateLabel: json['date_label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage_name': stageName,
      'date_label': dateLabel,
    };
  }
}

class OpportunityDetail {
  final Opportunity opportunity;
  final CrmContact? contact;
  final List<CrmQuotation> quotations;
  final List<CrmActivityItem> activities;
  final List<CrmTaskItem> openTasks;
  final List<StageHistoryItem> stageHistory;

  const OpportunityDetail({
    required this.opportunity,
    this.contact,
    required this.quotations,
    required this.activities,
    required this.openTasks,
    required this.stageHistory,
  });

  OpportunityDetail copyWith({
    Opportunity? opportunity,
    CrmContact? contact,
    List<CrmQuotation>? quotations,
    List<CrmActivityItem>? activities,
    List<CrmTaskItem>? openTasks,
    List<StageHistoryItem>? stageHistory,
  }) {
    return OpportunityDetail(
      opportunity: opportunity ?? this.opportunity,
      contact: contact ?? this.contact,
      quotations: quotations ?? this.quotations,
      activities: activities ?? this.activities,
      openTasks: openTasks ?? this.openTasks,
      stageHistory: stageHistory ?? this.stageHistory,
    );
  }
}
