class BankAccount {
  final int id;
  final String code;
  final String name;
  final String iban;
  final String currency;
  final double currentBalance;
  final int glAccountId;

  const BankAccount({
    required this.id,
    required this.code,
    required this.name,
    required this.iban,
    this.currency = 'AED',
    required this.currentBalance,
    required this.glAccountId,
  });

  String get displayName => '$name ($code)';

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as int? ?? 1,
      code: json['code'] as String? ?? '1110',
      name: json['name'] as String? ?? 'Emirates NBD - Current',
      iban: json['iban'] as String? ?? '',
      currency: json['currency'] as String? ?? 'AED',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      glAccountId: json['glAccountId'] as int? ?? 1110,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'iban': iban,
    'currency': currency,
    'currentBalance': currentBalance,
    'glAccountId': glAccountId,
  };
}

class BankStatementLine {
  final String id;
  final String date;
  final String description;
  final double amount;
  bool isChecked;
  String? matchRef;
  bool isSuggested;
  bool requiresCreateEntry;

  BankStatementLine({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    this.isChecked = false,
    this.matchRef,
    this.isSuggested = false,
    this.requiresCreateEntry = false,
  });

  factory BankStatementLine.fromJson(Map<String, dynamic> json) {
    return BankStatementLine(
      id: json['id']?.toString() ?? '',
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isChecked: json['isChecked'] as bool? ?? false,
      matchRef: json['matchRef'] as String?,
      isSuggested: json['isSuggested'] as bool? ?? false,
      requiresCreateEntry: json['requiresCreateEntry'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'description': description,
    'amount': amount,
    'isChecked': isChecked,
    'matchRef': matchRef,
    'isSuggested': isSuggested,
    'requiresCreateEntry': requiresCreateEntry,
  };
}

class BookTransaction {
  final String id;
  final String date;
  final String reference;
  final double amount;
  bool isChecked;
  bool isCleared;
  String? matchedStatementLineId;

  BookTransaction({
    required this.id,
    required this.date,
    required this.reference,
    required this.amount,
    this.isChecked = false,
    this.isCleared = false,
    this.matchedStatementLineId,
  });

  factory BookTransaction.fromJson(Map<String, dynamic> json) {
    return BookTransaction(
      id: json['id']?.toString() ?? '',
      date: json['date'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isChecked: json['isChecked'] as bool? ?? false,
      isCleared: json['isCleared'] as bool? ?? false,
      matchedStatementLineId: json['matchedStatementLineId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'reference': reference,
    'amount': amount,
    'isChecked': isChecked,
    'isCleared': isCleared,
    'matchedStatementLineId': matchedStatementLineId,
  };
}

class BankReconciliationSession {
  final int bankAccountId;
  final String bankAccountName;
  final String statementDate;
  double statementEndingBalance;
  double baseClearedBalance;
  List<BankStatementLine> statementLines;
  List<BookTransaction> bookTransactions;
  bool isFinished;

  BankReconciliationSession({
    required this.bankAccountId,
    required this.bankAccountName,
    required this.statementDate,
    required this.statementEndingBalance,
    required this.baseClearedBalance,
    required this.statementLines,
    required this.bookTransactions,
    this.isFinished = false,
  });

  /// Dynamic cleared book balance calculated from base cleared balance + checked book transactions
  double get clearedBookBalance {
    // In double-entry accounting reconciliation:
    // Base book balance + checked cleared transactions
    // For Figure 15:
    // Base starting balance is 689,700.00
    // Checked transactions: RCT-2026-0219 (+18,900) + PAY-2026-0144 (-6,300) = +12,600
    // 689,700 + 12,600 = 702,300.00
    double sum = baseClearedBalance;
    for (final tx in bookTransactions) {
      if (tx.isChecked) {
        sum += tx.amount;
      }
    }
    return sum;
  }

  /// Difference = statementEndingBalance - clearedBookBalance
  double get difference {
    final diff = statementEndingBalance - clearedBookBalance;
    // Round to 2 decimal places to avoid IEEE 754 precision issues
    return (diff * 100).roundToDouble() / 100;
  }

  /// Finish button is ONLY enabled when difference == 0.00
  bool get canFinishReconciliation => difference.abs() < 0.001;
}
