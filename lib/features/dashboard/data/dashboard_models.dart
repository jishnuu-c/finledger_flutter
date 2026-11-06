class FinancialKpis {
  final double revenueYtd;
  final double revenueGrowth;
  final double expensesYtd;
  final double expensesGrowth;
  final double receivables;
  final int openInvoicesCount;
  final double cashAndBank;
  final int bankAccountsCount;

  const FinancialKpis({
    required this.revenueYtd,
    required this.revenueGrowth,
    required this.expensesYtd,
    required this.expensesGrowth,
    required this.receivables,
    required this.openInvoicesCount,
    required this.cashAndBank,
    required this.bankAccountsCount,
  });

  factory FinancialKpis.fromJson(Map<String, dynamic> json) {
    return FinancialKpis(
      revenueYtd: (json['revenueYtd'] as num?)?.toDouble() ?? 2485300.00,
      revenueGrowth: (json['revenueGrowth'] as num?)?.toDouble() ?? 12.4,
      expensesYtd: (json['expensesYtd'] as num?)?.toDouble() ?? 1692140.00,
      expensesGrowth: (json['expensesGrowth'] as num?)?.toDouble() ?? 8.1,
      receivables: (json['receivables'] as num?)?.toDouble() ?? 384920.00,
      openInvoicesCount: (json['openInvoicesCount'] as num?)?.toInt() ?? 42,
      cashAndBank: (json['cashAndBank'] as num?)?.toDouble() ?? 918450.00,
      bankAccountsCount: (json['bankAccountsCount'] as num?)?.toInt() ?? 3,
    );
  }
}

class OperationalKpis {
  final double openPipelineCrm;
  final int opportunitiesCount;
  final int weightedProbability;
  final double inventoryValue;
  final int lowStockCount;
  final double expensesAwaitingApproval;
  final int pendingClaimsCount;
  final double accountsPayable;
  final int openBillsCount;

  const OperationalKpis({
    required this.openPipelineCrm,
    required this.opportunitiesCount,
    required this.weightedProbability,
    required this.inventoryValue,
    required this.lowStockCount,
    required this.expensesAwaitingApproval,
    required this.pendingClaimsCount,
    required this.accountsPayable,
    required this.openBillsCount,
  });

  factory OperationalKpis.fromJson(Map<String, dynamic> json) {
    return OperationalKpis(
      openPipelineCrm: (json['openPipelineCrm'] as num?)?.toDouble() ?? 1264000.00,
      opportunitiesCount: (json['opportunitiesCount'] as num?)?.toInt() ?? 31,
      weightedProbability: (json['weightedProbability'] as num?)?.toInt() ?? 38,
      inventoryValue: (json['inventoryValue'] as num?)?.toDouble() ?? 612500.00,
      lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 7,
      expensesAwaitingApproval: (json['expensesAwaitingApproval'] as num?)?.toDouble() ?? 14860.00,
      pendingClaimsCount: (json['pendingClaimsCount'] as num?)?.toInt() ?? 9,
      accountsPayable: (json['accountsPayable'] as num?)?.toDouble() ?? 213640.00,
      openBillsCount: (json['openBillsCount'] as num?)?.toInt() ?? 18,
    );
  }
}

class MonthlyComparison {
  final String month;
  final double revenue;
  final double expenses;

  const MonthlyComparison({
    required this.month,
    required this.revenue,
    required this.expenses,
  });

  factory MonthlyComparison.fromJson(Map<String, dynamic> json) {
    return MonthlyComparison(
      month: json['month'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReceivablesAgeingData {
  final double current;
  final double days1To30;
  final double days31To60;
  final double days61To90;
  final double daysOver90;

  const ReceivablesAgeingData({
    required this.current,
    required this.days1To30,
    required this.days31To60,
    required this.days61To90,
    required this.daysOver90,
  });

  double get total => current + days1To30 + days31To60 + days61To90 + daysOver90;

  factory ReceivablesAgeingData.fromJson(Map<String, dynamic> json) {
    return ReceivablesAgeingData(
      current: (json['current'] as num?)?.toDouble() ?? 184200.00,
      days1To30: (json['days1To30'] as num?)?.toDouble() ?? 98400.00,
      days31To60: (json['days31To60'] as num?)?.toDouble() ?? 62100.00,
      days61To90: (json['days61To90'] as num?)?.toDouble() ?? 28620.00,
      daysOver90: (json['daysOver90'] as num?)?.toDouble() ?? 11600.00,
    );
  }
}

class RecentTransactionItem {
  final String date;
  final String reference;
  final String description;
  final String type; // Invoice, Receipt, Bill
  final double amount;

  const RecentTransactionItem({
    required this.date,
    required this.reference,
    required this.description,
    required this.type,
    required this.amount,
  });

  factory RecentTransactionItem.fromJson(Map<String, dynamic> json) {
    return RecentTransactionItem(
      date: json['date'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'Invoice',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardSummary {
  final FinancialKpis financial;
  final OperationalKpis operational;
  final List<MonthlyComparison> monthlyData;
  final ReceivablesAgeingData ageing;
  final List<RecentTransactionItem> recentTransactions;

  const DashboardSummary({
    required this.financial,
    required this.operational,
    required this.monthlyData,
    required this.ageing,
    required this.recentTransactions,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final financialJson = json['financial'] is Map<String, dynamic>
        ? json['financial'] as Map<String, dynamic>
        : <String, dynamic>{};
    final operationalJson = json['operational'] is Map<String, dynamic>
        ? json['operational'] as Map<String, dynamic>
        : <String, dynamic>{};
    final ageingJson = json['ageing'] is Map<String, dynamic>
        ? json['ageing'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawMonthly = json['monthlyComparison'] as List? ?? [];
    final rawRecent = json['recentTransactions'] as List? ?? [];

    return DashboardSummary(
      financial: FinancialKpis.fromJson(financialJson),
      operational: OperationalKpis.fromJson(operationalJson),
      monthlyData: rawMonthly.map((e) => MonthlyComparison.fromJson(e as Map<String, dynamic>)).toList(),
      ageing: ReceivablesAgeingData.fromJson(ageingJson),
      recentTransactions: rawRecent.map((e) => RecentTransactionItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Default mock matching Figure 3: Dashboard with exact amounts
  static DashboardSummary defaultMock() {
    return const DashboardSummary(
      financial: FinancialKpis(
        revenueYtd: 2485300.00,
        revenueGrowth: 12.4,
        expensesYtd: 1692140.00,
        expensesGrowth: 8.1,
        receivables: 384920.00,
        openInvoicesCount: 42,
        cashAndBank: 918450.00,
        bankAccountsCount: 3,
      ),
      operational: OperationalKpis(
        openPipelineCrm: 1264000.00,
        opportunitiesCount: 31,
        weightedProbability: 38,
        inventoryValue: 612500.00,
        lowStockCount: 7,
        expensesAwaitingApproval: 14860.00,
        pendingClaimsCount: 9,
        accountsPayable: 213640.00,
        openBillsCount: 18,
      ),
      monthlyData: [
        MonthlyComparison(month: 'May', revenue: 210000, expenses: 140000),
        MonthlyComparison(month: 'Jun', revenue: 260000, expenses: 175000),
        MonthlyComparison(month: 'Jul', revenue: 240000, expenses: 160000),
        MonthlyComparison(month: 'Aug', revenue: 310000, expenses: 190000),
        MonthlyComparison(month: 'Sep', revenue: 290000, expenses: 185000),
        MonthlyComparison(month: 'Oct', revenue: 360000, expenses: 220000),
      ],
      ageing: ReceivablesAgeingData(
        current: 184200.00,
        days1To30: 98400.00,
        days31To60: 62100.00,
        days61To90: 28620.00,
        daysOver90: 11600.00,
      ),
      recentTransactions: [
        RecentTransactionItem(
          date: '29-Oct-2026',
          reference: 'INV-2026-0412',
          description: 'Al Noor Facilities – Air purifiers',
          type: 'Invoice',
          amount: 42525.00,
        ),
        RecentTransactionItem(
          date: '28-Oct-2026',
          reference: 'RCT-2026-0219',
          description: 'Receipt from Gulf Hospitality',
          type: 'Receipt',
          amount: 18900.00,
        ),
        RecentTransactionItem(
          date: '27-Oct-2026',
          reference: 'BILL-2026-0158',
          description: 'Emirates Logistics – Freight',
          type: 'Bill',
          amount: 6300.00,
        ),
      ],
    );
  }
}
