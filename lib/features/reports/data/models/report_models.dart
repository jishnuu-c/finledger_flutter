class ReportTypeConfig {
  final String code;
  final String title;
  final String category;
  final String description;

  const ReportTypeConfig({
    required this.code,
    required this.title,
    required this.category,
    required this.description,
  });
}

class ReportRow {
  final String? accountCode;
  final String accountName;
  final double currentAmount;
  final double? comparativeAmount;
  final double? changePercentage;
  final bool isSectionHeader;
  final bool isTotal;
  final bool isHighlight; // E.g. Net Profit light blue row in Figure 16
  final int indentLevel;

  const ReportRow({
    this.accountCode,
    required this.accountName,
    required this.currentAmount,
    this.comparativeAmount,
    this.changePercentage,
    this.isSectionHeader = false,
    this.isTotal = false,
    this.isHighlight = false,
    this.indentLevel = 0,
  });

  bool get isDrillable => accountCode != null && accountCode!.isNotEmpty;
}

class ReportSection {
  final String title;
  final List<ReportRow> rows;

  const ReportSection({
    required this.title,
    required this.rows,
  });
}

class FinancialReportData {
  final String reportCode;
  final String companyName;
  final String reportTitle;
  final String periodDescription;
  final String currentColumnHeader;
  final String comparativeColumnHeader;
  final List<ReportSection> sections;

  const FinancialReportData({
    required this.reportCode,
    this.companyName = 'BSB Trading LLC',
    required this.reportTitle,
    required this.periodDescription,
    this.currentColumnHeader = '2026',
    this.comparativeColumnHeader = '2025',
    required this.sections,
  });
}

class GlTransaction {
  final String date;
  final String entryNo;
  final String reference;
  final String narration;
  final double debit;
  final double credit;
  final double runningBalance;

  const GlTransaction({
    required this.date,
    required this.entryNo,
    required this.reference,
    required this.narration,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });
}
