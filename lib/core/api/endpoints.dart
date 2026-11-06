class Endpoints {
  static const String defaultBaseUrl = 'https://api.finledger.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';

  // CRM
  static const String leads = '/leads';
  static const String opportunities = '/opportunities';
  static const String opportunityBoard = '/opportunities/board';
  static const String activities = '/activities';
  static const String quotations = '/quotations';

  // Sales
  static const String customers = '/customers';
  static const String invoices = '/invoices';
  static const String receipts = '/receipts';

  // Purchases
  static const String vendors = '/vendors';
  static const String bills = '/bills';
  static const String payments = '/payments';

  // Inventory
  static const String items = '/items';
  static const String itemStockSummary = '/items/stock-summary';
  static const String warehouses = '/warehouses';
  static const String stockBalances = '/stock-balances';
  static const String stockAdjustments = '/stock-adjustments';
  static const String stockTransfers = '/stock-transfers';

  // Expenses
  static const String expenses = '/expenses';
  static const String expenseApprovals = '/expenses/approvals';
  static const String expenseCategories = '/expense-categories';

  // Accounting
  static const String accounts = '/accounts';
  static const String accountTree = '/accounts/tree';
  static const String journalEntries = '/journal-entries';
  static const String generalLedger = '/reports/general-ledger';

  // Banking
  static const String bankAccounts = '/bank-accounts';
  static const String bankReconciliations = '/bank-reconciliations';
  static const String bankStatements = '/bank-statements';
  static const String bankStatementImport = '/bank-statements/import';
  static const String bankStatementMatch = '/bank-reconciliations/match';
  static const String bankStatementReconcile = '/bank-reconciliations/reconcile';

  // Reports
  static const String reports = '/reports';
  static const String reportProfitLoss = '/reports/profit-loss';
  static const String reportBalanceSheet = '/reports/balance-sheet';
  static const String reportTrialBalance = '/reports/trial-balance';
  static const String reportGeneralLedger = '/reports/general-ledger';
  static const String reportArAgeing = '/reports/ar-ageing';
  static const String reportApAgeing = '/reports/ap-ageing';
  static const String reportVatReturn = '/reports/vat-return';

  // Settings
  static const String companies = '/companies';
  static const String companyProfile = '/companies/profile';
  static const String users = '/users';
  static const String roles = '/roles';
  static const String taxRates = '/tax-rates';
  static const String fiscalYears = '/companies/fiscal-years';
  static const String currencies = '/companies/currencies';
  static const String numberSeries = '/companies/number-series';
  static const String auditLogs = '/companies/audit-log';
}
