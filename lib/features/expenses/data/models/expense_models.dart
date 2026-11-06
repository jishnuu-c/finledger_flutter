import 'package:flutter/material.dart';

/// Expense Category with Policy Rules (Table 45, Page 70)
@immutable
class ExpenseCategory {
  final int id;
  final String name;
  final int accountId;
  final String accountCode;
  final String accountName;
  final double defaultTaxRatePct;
  final String defaultTaxRateName;
  final double? limitPerClaim;
  final bool receiptRequired;
  final bool isActive;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    this.defaultTaxRatePct = 5.0,
    this.defaultTaxRateName = 'VAT 5%',
    this.limitPerClaim,
    this.receiptRequired = true,
    this.isActive = true,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      accountId: json['account_id'] as int? ?? (json['accountId'] as int? ?? 0),
      accountCode: json['accountCode'] as String? ?? '6100',
      accountName: json['accountName'] as String? ?? 'Operating Expense',
      defaultTaxRatePct: (json['defaultTaxRatePct'] as num?)?.toDouble() ?? 5.0,
      defaultTaxRateName: json['defaultTaxRateName'] as String? ?? 'VAT 5%',
      limitPerClaim: (json['limit_per_claim'] as num?)?.toDouble() ?? (json['limitPerClaim'] as num?)?.toDouble(),
      receiptRequired: json['receipt_required'] as bool? ?? (json['receiptRequired'] as bool? ?? true),
      isActive: json['is_active'] as bool? ?? (json['isActive'] as bool? ?? true),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'account_id': accountId,
    'accountCode': accountCode,
    'accountName': accountName,
    'defaultTaxRatePct': defaultTaxRatePct,
    'defaultTaxRateName': defaultTaxRateName,
    'limit_per_claim': ?limitPerClaim,
    'receipt_required': receiptRequired,
    'is_active': isActive,
  };
}

/// Expense Attachment (Table 48, Page 72)
@immutable
class ExpenseAttachment {
  final int id;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String storageKey;
  final String? localPath;
  final String uploadedAt;

  const ExpenseAttachment({
    required this.id,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.storageKey,
    this.localPath,
    required this.uploadedAt,
  });

  bool get isPdf => fileName.toLowerCase().endsWith('.pdf') || contentType.contains('pdf');
  bool get isImage => !isPdf;

  factory ExpenseAttachment.fromJson(Map<String, dynamic> json) {
    return ExpenseAttachment(
      id: json['id'] as int? ?? 0,
      fileName: json['file_name'] as String? ?? (json['fileName'] as String? ?? ''),
      contentType: json['content_type'] as String? ?? (json['contentType'] as String? ?? 'image/jpeg'),
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? ((json['sizeBytes'] as num?)?.toInt() ?? 0),
      storageKey: json['storage_key'] as String? ?? (json['storageKey'] as String? ?? ''),
      localPath: json['localPath'] as String?,
      uploadedAt: json['uploaded_at'] as String? ?? (json['uploadedAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'file_name': fileName,
    'content_type': contentType,
    'size_bytes': sizeBytes,
    'storage_key': storageKey,
    'localPath': ?localPath,
    'uploaded_at': uploadedAt,
  };
}

/// Individual Expense Line within a claim (Table 47, Page 71)
@immutable
class ExpenseLine {
  final int? id;
  final int? expenseId;
  final int lineNo;
  final int categoryId;
  final String categoryName;
  final String description;
  final String costCenter;
  final String? billableTo;
  final double amount; // Net of VAT
  final String taxRateName;
  final double taxRatePct;
  final double taxAmount;
  final double totalAmount;
  final int receiptCount;
  final bool isReceiptMissing;

  const ExpenseLine({
    this.id,
    this.expenseId,
    this.lineNo = 1,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    this.costCenter = 'Sales',
    this.billableTo,
    required this.amount,
    this.taxRateName = 'VAT 5%',
    this.taxRatePct = 5.0,
    required this.taxAmount,
    required this.totalAmount,
    this.receiptCount = 0,
    this.isReceiptMissing = false,
  });

  ExpenseLine copyWith({
    int? id,
    int? expenseId,
    int? lineNo,
    int? categoryId,
    String? categoryName,
    String? description,
    String? costCenter,
    String? billableTo,
    double? amount,
    String? taxRateName,
    double? taxRatePct,
    double? taxAmount,
    double? totalAmount,
    int? receiptCount,
    bool? isReceiptMissing,
  }) {
    final finalAmount = amount ?? this.amount;
    final finalTaxRate = taxRatePct ?? this.taxRatePct;
    final finalTaxName = taxRateName ?? this.taxRateName;
    final finalTaxAmount = taxAmount ?? (finalAmount * (finalTaxRate / 100));
    final finalTotal = totalAmount ?? (finalAmount + finalTaxAmount);

    return ExpenseLine(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      lineNo: lineNo ?? this.lineNo,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      costCenter: costCenter ?? this.costCenter,
      billableTo: billableTo ?? this.billableTo,
      amount: finalAmount,
      taxRateName: finalTaxName,
      taxRatePct: finalTaxRate,
      taxAmount: finalTaxAmount,
      totalAmount: finalTotal,
      receiptCount: receiptCount ?? this.receiptCount,
      isReceiptMissing: isReceiptMissing ?? this.isReceiptMissing,
    );
  }

  factory ExpenseLine.fromJson(Map<String, dynamic> json) {
    final net = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final tax = (json['tax_amount'] as num?)?.toDouble() ?? ((json['taxAmount'] as num?)?.toDouble() ?? 0.0);
    final total = (json['totalAmount'] as num?)?.toDouble() ?? (net + tax);

    return ExpenseLine(
      id: json['id'] as int?,
      expenseId: json['expense_id'] as int? ?? json['expenseId'] as int?,
      lineNo: (json['line_no'] as num?)?.toInt() ?? ((json['lineNo'] as num?)?.toInt() ?? 1),
      categoryId: json['category_id'] as int? ?? (json['categoryId'] as int? ?? 0),
      categoryName: json['categoryName'] as String? ?? (json['category'] as String? ?? ''),
      description: json['description'] as String? ?? '',
      costCenter: json['cost_center'] as String? ?? (json['costCenter'] as String? ?? 'Sales'),
      billableTo: json['billable_to'] as String? ?? json['billableTo'] as String?,
      amount: net,
      taxRateName: json['taxRateName'] as String? ?? 'VAT 5%',
      taxRatePct: (json['taxRatePct'] as num?)?.toDouble() ?? 5.0,
      taxAmount: tax,
      totalAmount: total,
      receiptCount: (json['receiptCount'] as num?)?.toInt() ?? 0,
      isReceiptMissing: json['isReceiptMissing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': ?id,
    'expense_id': ?expenseId,
    'line_no': lineNo,
    'category_id': categoryId,
    'categoryName': categoryName,
    'description': description,
    'cost_center': costCenter,
    'billable_to': ?billableTo,
    'amount': amount,
    'taxRateName': taxRateName,
    'taxRatePct': taxRatePct,
    'tax_amount': taxAmount,
    'totalAmount': totalAmount,
    'receiptCount': receiptCount,
    'isReceiptMissing': isReceiptMissing,
  };
}

/// Expense Header Document (Table 46, Page 70-71)
@immutable
class Expense {
  final int id;
  final String expenseNo;
  final String expenseDate; // Formatted or short e.g. '29-Oct' / '29-Oct-2026'
  final String paidBy; // 'EMPLOYEE' or 'COMPANY'
  final String paidByDisplay; // 'Employee', 'Company - ENBD', 'Company - Card'
  final String employeeName;
  final String? payeeName;
  final int? bankAccountId;
  final String? bankAccountName;
  final String currencyCode;
  final String purpose;
  final String categorySummary;
  final double subtotal; // Net
  final double taxTotal; // VAT
  final double total;
  final int attachmentCount;
  final bool hasMissingReceipt;
  final String status; // 'SUBMITTED', 'POSTED', 'APPROVED', 'REJECTED', 'REIMBURSED', 'DRAFT'
  final String? submittedAt;
  final String? approvedBy;
  final String? rejectionReason;
  final List<ExpenseLine> lines;
  final List<ExpenseAttachment> attachments;

  const Expense({
    required this.id,
    required this.expenseNo,
    required this.expenseDate,
    required this.paidBy,
    required this.paidByDisplay,
    required this.employeeName,
    this.payeeName,
    this.bankAccountId,
    this.bankAccountName,
    this.currencyCode = 'AED',
    this.purpose = '',
    required this.categorySummary,
    required this.subtotal,
    required this.taxTotal,
    required this.total,
    this.attachmentCount = 0,
    this.hasMissingReceipt = false,
    this.status = 'DRAFT',
    this.submittedAt,
    this.approvedBy,
    this.rejectionReason,
    this.lines = const [],
    this.attachments = const [],
  });

  Expense copyWith({
    int? id,
    String? expenseNo,
    String? expenseDate,
    String? paidBy,
    String? paidByDisplay,
    String? employeeName,
    String? payeeName,
    int? bankAccountId,
    String? bankAccountName,
    String? currencyCode,
    String? purpose,
    String? categorySummary,
    double? subtotal,
    double? taxTotal,
    double? total,
    int? attachmentCount,
    bool? hasMissingReceipt,
    String? status,
    String? submittedAt,
    String? approvedBy,
    String? rejectionReason,
    List<ExpenseLine>? lines,
    List<ExpenseAttachment>? attachments,
  }) {
    return Expense(
      id: id ?? this.id,
      expenseNo: expenseNo ?? this.expenseNo,
      expenseDate: expenseDate ?? this.expenseDate,
      paidBy: paidBy ?? this.paidBy,
      paidByDisplay: paidByDisplay ?? this.paidByDisplay,
      employeeName: employeeName ?? this.employeeName,
      payeeName: payeeName ?? this.payeeName,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      currencyCode: currencyCode ?? this.currencyCode,
      purpose: purpose ?? this.purpose,
      categorySummary: categorySummary ?? this.categorySummary,
      subtotal: subtotal ?? this.subtotal,
      taxTotal: taxTotal ?? this.taxTotal,
      total: total ?? this.total,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      hasMissingReceipt: hasMissingReceipt ?? this.hasMissingReceipt,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      lines: lines ?? this.lines,
      attachments: attachments ?? this.attachments,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int? ?? 0,
      expenseNo: json['expense_no'] as String? ?? (json['expenseNo'] as String? ?? ''),
      expenseDate: json['expense_date'] as String? ?? (json['expenseDate'] as String? ?? ''),
      paidBy: json['paid_by'] as String? ?? (json['paidBy'] as String? ?? 'EMPLOYEE'),
      paidByDisplay: json['paidByDisplay'] as String? ?? 'Employee',
      employeeName: json['employeeName'] as String? ?? (json['payee_name'] as String? ?? ''),
      payeeName: json['payee_name'] as String? ?? json['payeeName'] as String?,
      bankAccountId: json['bank_account_id'] as int? ?? json['bankAccountId'] as int?,
      bankAccountName: json['bankAccountName'] as String?,
      currencyCode: json['currency_code'] as String? ?? (json['currencyCode'] as String? ?? 'AED'),
      purpose: json['purpose'] as String? ?? '',
      categorySummary: json['categorySummary'] as String? ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxTotal: (json['tax_total'] as num?)?.toDouble() ?? ((json['taxTotal'] as num?)?.toDouble() ?? 0.0),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      attachmentCount: (json['attachmentCount'] as num?)?.toInt() ?? 0,
      hasMissingReceipt: json['hasMissingReceipt'] as bool? ?? false,
      status: json['status'] as String? ?? 'DRAFT',
      submittedAt: json['submitted_at'] as String? ?? json['submittedAt'] as String?,
      approvedBy: json['approved_by'] as String? ?? json['approvedBy'] as String?,
      rejectionReason: json['rejection_reason'] as String? ?? json['rejectionReason'] as String?,
      lines: (json['lines'] as List<dynamic>?)
              ?.map((l) => ExpenseLine.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) => ExpenseAttachment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'expense_no': expenseNo,
    'expense_date': expenseDate,
    'paid_by': paidBy,
    'paidByDisplay': paidByDisplay,
    'employeeName': employeeName,
    'payee_name': ?payeeName,
    'bank_account_id': ?bankAccountId,
    'bankAccountName': ?bankAccountName,
    'currency_code': currencyCode,
    'purpose': purpose,
    'categorySummary': categorySummary,
    'subtotal': subtotal,
    'tax_total': taxTotal,
    'total': total,
    'attachmentCount': attachmentCount,
    'hasMissingReceipt': hasMissingReceipt,
    'status': status,
    'submitted_at': ?submittedAt,
    'approved_by': ?approvedBy,
    'rejection_reason': ?rejectionReason,
    'lines': lines.map((l) => l.toJson()).toList(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
  };
}

/// 4 KPI Cards for Expenses (Figure 11, Page 20)
@immutable
class ExpenseKpis {
  final double thisMonthPosted;
  final double vsPreviousMonthPct;
  final double awaitingApproval;
  final int awaitingClaimsCount;
  final double toReimburse;
  final int toReimburseClaimsCount;
  final String topCategory;
  final double topCategoryAmount;

  const ExpenseKpis({
    required this.thisMonthPosted,
    required this.vsPreviousMonthPct,
    required this.awaitingApproval,
    required this.awaitingClaimsCount,
    required this.toReimburse,
    required this.toReimburseClaimsCount,
    required this.topCategory,
    required this.topCategoryAmount,
  });

  factory ExpenseKpis.fromJson(Map<String, dynamic> json) {
    return ExpenseKpis(
      thisMonthPosted: (json['thisMonthPosted'] as num?)?.toDouble() ?? 46320.0,
      vsPreviousMonthPct: (json['vsPreviousMonthPct'] as num?)?.toDouble() ?? 4.2,
      awaitingApproval: (json['awaitingApproval'] as num?)?.toDouble() ?? 14860.0,
      awaitingClaimsCount: (json['awaitingClaimsCount'] as num?)?.toInt() ?? 9,
      toReimburse: (json['toReimburse'] as num?)?.toDouble() ?? 6215.0,
      toReimburseClaimsCount: (json['toReimburseClaimsCount'] as num?)?.toInt() ?? 4,
      topCategory: json['topCategory'] as String? ?? 'Travel & Fuel',
      topCategoryAmount: (json['topCategoryAmount'] as num?)?.toDouble() ?? 12480.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'thisMonthPosted': thisMonthPosted,
    'vsPreviousMonthPct': vsPreviousMonthPct,
    'awaitingApproval': awaitingApproval,
    'awaitingClaimsCount': awaitingClaimsCount,
    'toReimburse': toReimburse,
    'toReimburseClaimsCount': toReimburseClaimsCount,
    'topCategory': topCategory,
    'topCategoryAmount': topCategoryAmount,
  };
}

/// 4-Step Approval Flow Item (Figure 12, Page 21)
@immutable
class ApprovalStep {
  final int stepNumber;
  final String title;
  final String approver;
  final String statusText; // 'Pending', 'Waiting', 'Skipped', '—', 'Approved'
  final Color circleColor;
  final Color statusColor;

  const ApprovalStep({
    required this.stepNumber,
    required this.title,
    required this.approver,
    required this.statusText,
    required this.circleColor,
    required this.statusColor,
  });
}
