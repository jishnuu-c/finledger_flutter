import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/token_service.dart';
import 'app_routes.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/crm/presentation/crm_screen.dart';
import '../../features/crm/presentation/pipeline_board_screen.dart';
import '../../features/crm/presentation/opportunity_detail_screen.dart';
import '../../features/sales/presentation/sales_screen.dart';
import '../../features/sales/presentation/sales_invoices_list_screen.dart';
import '../../features/sales/presentation/create_tax_invoice_screen.dart';
import '../../features/sales/presentation/record_customer_receipt_screen.dart';
import '../../features/purchases/presentation/purchases_screen.dart';
import '../../features/inventory/presentation/items_and_stock_screen.dart';
import '../../features/inventory/presentation/stock_adjustment_transfer_screen.dart';
import '../../features/expenses/presentation/expenses_list_screen.dart';
import '../../features/expenses/presentation/new_expense_claim_screen.dart';
import '../../features/accounting/presentation/chart_of_accounts_screen.dart';
import '../../features/accounting/presentation/journal_entries_list_screen.dart';
import '../../features/accounting/presentation/new_journal_entry_screen.dart';
import '../../features/banking/presentation/banking_screen.dart';
import '../../features/banking/presentation/bank_reconciliation_screen.dart';
import '../../features/reports/presentation/reports_viewer_screen.dart';
import '../../features/settings/presentation/company_settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

GoRouter createAppRouter(TokenService tokenService) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: tokenService,
    redirect: (context, state) {
      final isAuth = tokenService.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // If not authenticated and not on login page, redirect to login
      if (!isAuth && !isLoggingIn) {
        return AppRoutes.login;
      }

      // If already authenticated and trying to access login, redirect to dashboard
      if (isAuth && isLoggingIn) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // Public Auth Route (Outside Shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Protected Shell Routes (Inside FinLedger Application Shell)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.crm,
            redirect: (context, state) => AppRoutes.crmPipeline,
          ),
          GoRoute(
            path: AppRoutes.crmPipeline,
            name: 'crmPipeline',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PipelineBoardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.crmLeads,
            name: 'crmLeads',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CrmScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.crmQuotations,
            name: 'crmQuotations',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CrmScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.crmOpportunityDetail,
            name: 'crmOpportunityDetail',
            pageBuilder: (context, state) {
              final idStr = state.pathParameters['id'] ?? '1';
              final id = int.tryParse(idStr) ?? 1;
              return NoTransitionPage(
                child: OpportunityDetailScreen(opportunityId: id),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.sales,
            redirect: (context, state) => AppRoutes.salesInvoices,
          ),
          GoRoute(
            path: AppRoutes.salesCustomers,
            name: 'salesCustomers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SalesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.salesInvoices,
            name: 'salesInvoices',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SalesInvoicesListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.salesInvoicesNew,
            name: 'createTaxInvoice',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CreateTaxInvoiceScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.salesReceiptsNew,
            name: 'recordCustomerReceipt',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecordCustomerReceiptScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.purchases,
            name: 'purchases',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PurchasesScreen(initialTab: 'bills'),
            ),
          ),
          GoRoute(
            path: AppRoutes.purchasesBills,
            name: 'purchasesBills',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PurchasesScreen(initialTab: 'bills'),
            ),
          ),
          GoRoute(
            path: AppRoutes.purchasesVendors,
            name: 'purchasesVendors',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PurchasesScreen(initialTab: 'vendors'),
            ),
          ),
          GoRoute(
            path: AppRoutes.purchasesPaymentsNew,
            name: 'purchasesPayments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PurchasesScreen(initialTab: 'payments'),
            ),
          ),
          GoRoute(
            path: AppRoutes.inventory,
            redirect: (context, state) => AppRoutes.inventoryItems,
          ),
          GoRoute(
            path: AppRoutes.inventoryItems,
            name: 'inventoryItems',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ItemsAndStockScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.inventoryAdjustmentsNew,
            name: 'newStockAdjustment',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StockAdjustmentTransferScreen(initialTab: StockActionTab.adjustment),
            ),
          ),
          GoRoute(
            path: AppRoutes.inventoryTransfersNew,
            name: 'newStockTransfer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StockAdjustmentTransferScreen(initialTab: StockActionTab.transfer),
            ),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            name: 'expenses',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExpensesListScreen(initialTab: 'all'),
            ),
          ),
          GoRoute(
            path: AppRoutes.expensesApprovals,
            name: 'expensesApprovals',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExpensesListScreen(initialTab: 'approvals'),
            ),
          ),
          GoRoute(
            path: AppRoutes.expensesNew,
            name: 'newExpenseClaim',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NewExpenseClaimScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.accounting,
            redirect: (context, state) => AppRoutes.accountingAccounts,
          ),
          GoRoute(
            path: AppRoutes.accountingAccounts,
            name: 'chartOfAccounts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChartOfAccountsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.accountingJournals,
            name: 'journalEntries',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JournalEntriesListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.accountingJournalsNew,
            name: 'newJournalEntry',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NewJournalEntryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.banking,
            name: 'banking',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BankingScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.bankingAccounts,
            name: 'bankingAccounts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BankingScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.bankingReconciliation,
            name: 'bankReconciliation',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BankReconciliationScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsViewerScreen(initialReportType: 'pnl'),
            ),
          ),
          GoRoute(
            path: AppRoutes.reportsType,
            name: 'reportsViewer',
            pageBuilder: (context, state) {
              final type = state.pathParameters['type'] ?? 'pnl';
              return NoTransitionPage(
                child: ReportsViewerScreen(initialReportType: type),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CompanySettingsScreen(initialTab: 'profile'),
            ),
          ),
          GoRoute(
            path: AppRoutes.settingsTab,
            name: 'settingsTab',
            pageBuilder: (context, state) {
              final tab = state.pathParameters['tab'] ?? 'profile';
              return NoTransitionPage(
                child: CompanySettingsScreen(initialTab: tab),
              );
            },
          ),
        ],
      ),
    ],
  );
}
