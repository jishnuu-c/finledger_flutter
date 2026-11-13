class JournalLine {
  final int? id;
  final int lineNo;
  final int accountId;
  final String accountCode;
  final String accountName;
  final String description;
  final String costCenter;
  final double debit;
  final double credit;

  const JournalLine({
    this.id,
    required this.lineNo,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.description,
    this.costCenter = '',
    required this.debit,
    required this.credit,
  });

  factory JournalLine.fromJson(Map<String, dynamic> json) {
    return JournalLine(
      id: json['id'] as int?,
      lineNo: ((json['lineNo'] ?? json['line_no']) as num?)?.toInt() ?? 1,
      accountId: ((json['accountId'] ?? json['account_id']) as num?)?.toInt() ?? 0,
      accountCode: (json['accountCode'] ?? json['account_code']) as String? ?? '',
      accountName: (json['accountName'] ?? json['account_name']) as String? ?? '',
      description: json['description'] as String? ?? '',
      costCenter: (json['costCenter'] ?? json['cost_center']) as String? ?? '',
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lineNo': lineNo,
    'accountId': accountId,
    'accountCode': accountCode,
    'accountName': accountName,
    'description': description,
    'costCenter': costCenter,
    'debit': debit,
    'credit': credit,
  };

  JournalLine copyWith({
    int? id,
    int? lineNo,
    int? accountId,
    String? accountCode,
    String? accountName,
    String? description,
    String? costCenter,
    double? debit,
    double? credit,
  }) {
    return JournalLine(
      id: id ?? this.id,
      lineNo: lineNo ?? this.lineNo,
      accountId: accountId ?? this.accountId,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      description: description ?? this.description,
      costCenter: costCenter ?? this.costCenter,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
    );
  }
}

class JournalEntry {
  final int id;
  final String entryNo;
  final String entryDate;
  final String reference;
  final String narration;
  final String currencyCode;
  final double exchangeRate;
  final double totalDebit;
  final double totalCredit;
  final String status; // 'DRAFT', 'POSTED', 'VOID'
  final List<JournalLine> lines;

  const JournalEntry({
    required this.id,
    required this.entryNo,
    required this.entryDate,
    required this.reference,
    required this.narration,
    this.currencyCode = 'AED',
    this.exchangeRate = 1.0,
    required this.totalDebit,
    required this.totalCredit,
    required this.status,
    required this.lines,
  });

  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.001 && totalDebit > 0;
  double get difference => (totalDebit - totalCredit).abs();

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List? ?? [];
    return JournalEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      entryNo: (json['entryNo'] ?? json['entry_no']) as String? ?? '',
      entryDate: (json['entryDate'] ?? json['entry_date']) as String? ?? '',
      reference: json['reference'] as String? ?? '',
      narration: json['narration'] as String? ?? '',
      currencyCode: (json['currencyCode'] ?? json['currency_code']) as String? ?? 'AED',
      exchangeRate: ((json['exchangeRate'] ?? json['exchange_rate']) as num?)?.toDouble() ?? 1.0,
      totalDebit: ((json['totalDebit'] ?? json['total_debit']) as num?)?.toDouble() ?? 0.0,
      totalCredit: ((json['totalCredit'] ?? json['total_credit']) as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'DRAFT',
      lines: rawLines.map((l) => JournalLine.fromJson(l as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'entryNo': entryNo,
    'entryDate': entryDate,
    'reference': reference,
    'narration': narration,
    'currencyCode': currencyCode,
    'exchangeRate': exchangeRate,
    'totalDebit': totalDebit,
    'totalCredit': totalCredit,
    'status': status,
    'lines': lines.map((l) => l.toJson()).toList(),
  };
}
