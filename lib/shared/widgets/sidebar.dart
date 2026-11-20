import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/locale_provider.dart';
import 'language_switcher.dart';

class NavSection {
  final String? title; // If null, renders as standalone top item (e.g. Dashboard)
  final List<NavSubItem> items;

  const NavSection({this.title, required this.items});

  String? getLocalizedTitle(BuildContext context) {
    if (title == null) return null;
    final l = context.l10n;
    switch (title) {
      case 'CRM':
        return l.crm;
      case 'SALES':
        return l.sales;
      case 'PURCHASES':
        return l.purchases;
      case 'INVENTORY':
        return l.inventory;
      case 'EXPENSES':
        return l.expensesSection;
      case 'ACCOUNTING':
        return l.accounting;
      case 'BANKING':
        return l.banking;
      default:
        return title;
    }
  }
}

class NavSubItem {
  final String id;
  final String label;
  final String route;
  final IconData? icon;

  const NavSubItem({
    required this.id,
    required this.label,
    required this.route,
    this.icon,
  });

  String getLocalizedLabel(BuildContext context) {
    final l = context.l10n;
    switch (id) {
      case 'dashboard':
        return l.dashboard;
      case 'crm_leads':
        return l.leads;
      case 'crm_pipeline':
        return l.pipeline;
      case 'crm_quotations':
        return l.quotations;
      case 'sales_customers':
        return l.customers;
      case 'sales_invoices':
        return l.invoices;
      case 'sales_receipts':
        return l.receipts;
      case 'purchases_vendors':
        return l.vendors;
      case 'purchases_bills':
        return l.bills;
      case 'purchases_payments':
        return l.payments;
      case 'inventory_items':
        return l.itemsAndStock;
      case 'inventory_adjustments':
        return l.adjustments;
      case 'inventory_transfers':
        return l.transfers;
      case 'expenses_list':
        return l.expenses;
      case 'expenses_approvals':
        return l.approvals;
      case 'accounting_coa':
        return l.chartOfAccounts;
      case 'accounting_journals':
        return l.journalEntries;
      case 'banking_accounts':
        return l.bankAccounts;
      case 'banking_reconciliation':
        return l.reconciliation;
      case 'reports':
        return l.reports;
      case 'settings':
        return l.settings;
      default:
        return label;
    }
  }
}

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  static const List<NavSection> sections = [
    NavSection(
      title: null,
      items: [
        NavSubItem(
          id: 'dashboard',
          label: 'Dashboard',
          route: '/dashboard',
          icon: Icons.dashboard_outlined,
        ),
      ],
    ),
    NavSection(
      title: 'CRM',
      items: [
        NavSubItem(id: 'crm_leads', label: 'Leads', route: '/crm/leads'),
        NavSubItem(id: 'crm_pipeline', label: 'Pipeline', route: '/crm/pipeline'),
        NavSubItem(id: 'crm_quotations', label: 'Quotations', route: '/crm/quotations'),
      ],
    ),
    NavSection(
      title: 'SALES',
      items: [
        NavSubItem(id: 'sales_customers', label: 'Customers', route: '/sales/customers'),
        NavSubItem(id: 'sales_invoices', label: 'Invoices', route: '/sales/invoices'),
        NavSubItem(id: 'sales_receipts', label: 'Receipts', route: '/sales/receipts/new'),
      ],
    ),
    NavSection(
      title: 'PURCHASES',
      items: [
        NavSubItem(id: 'purchases_vendors', label: 'Vendors', route: '/purchases/vendors'),
        NavSubItem(id: 'purchases_bills', label: 'Bills', route: '/purchases/bills'),
        NavSubItem(id: 'purchases_payments', label: 'Payments', route: '/purchases/payments/new'),
      ],
    ),
    NavSection(
      title: 'INVENTORY',
      items: [
        NavSubItem(id: 'inventory_items', label: 'Items & Stock', route: '/inventory/items'),
        NavSubItem(id: 'inventory_adjustments', label: 'Adjustments', route: '/inventory/adjustments/new'),
        NavSubItem(id: 'inventory_transfers', label: 'Transfers', route: '/inventory/transfers/new'),
      ],
    ),
    NavSection(
      title: 'EXPENSES',
      items: [
        NavSubItem(id: 'expenses_list', label: 'Expenses', route: '/expenses'),
        NavSubItem(id: 'expenses_approvals', label: 'Approvals', route: '/expenses/approvals'),
      ],
    ),
    NavSection(
      title: 'ACCOUNTING',
      items: [
        NavSubItem(id: 'accounting_coa', label: 'Chart of Accounts', route: '/accounting/accounts'),
        NavSubItem(id: 'accounting_journals', label: 'Journal Entries', route: '/accounting/journals'),
      ],
    ),
    NavSection(
      title: 'BANKING',
      items: [
        NavSubItem(id: 'banking_accounts', label: 'Bank Accounts', route: '/banking'),
        NavSubItem(id: 'banking_reconciliation', label: 'Reconciliation', route: '/banking/reconciliation'),
      ],
    ),
    NavSection(
      title: null,
      items: [
        NavSubItem(
          id: 'reports',
          label: 'Reports',
          route: '/reports',
          icon: Icons.bar_chart_outlined,
        ),
        NavSubItem(
          id: 'settings',
          label: 'Settings',
          route: '/settings',
          icon: Icons.settings_outlined,
        ),
      ],
    ),
  ];

  bool _isItemActive(NavSubItem item, String currentRoute) {
    switch (item.id) {
      case 'dashboard':
        return currentRoute == '/dashboard' || currentRoute == '/';
      case 'crm_leads':
        return currentRoute == '/crm/leads';
      case 'crm_pipeline':
        return currentRoute == '/crm/pipeline' || currentRoute.startsWith('/crm/opportunities');
      case 'crm_quotations':
        return currentRoute == '/crm/quotations';
      case 'sales_customers':
        return currentRoute == '/sales/customers';
      case 'sales_invoices':
        return currentRoute == '/sales/invoices' || currentRoute == '/sales/invoices/new';
      case 'sales_receipts':
        return currentRoute.startsWith('/sales/receipts');
      case 'purchases_vendors':
        return currentRoute == '/purchases/vendors';
      case 'purchases_bills':
        return currentRoute == '/purchases' || currentRoute == '/purchases/bills';
      case 'purchases_payments':
        return currentRoute.startsWith('/purchases/payments');
      case 'inventory_items':
        return currentRoute == '/inventory' || currentRoute == '/inventory/items';
      case 'inventory_adjustments':
        return currentRoute.startsWith('/inventory/adjustments');
      case 'inventory_transfers':
        return currentRoute.startsWith('/inventory/transfers');
      case 'expenses_list':
        return currentRoute == '/expenses' || currentRoute == '/expenses/new';
      case 'expenses_approvals':
        return currentRoute == '/expenses/approvals';
      case 'accounting_coa':
        return currentRoute == '/accounting' || currentRoute == '/accounting/accounts';
      case 'accounting_journals':
        return currentRoute.startsWith('/accounting/journals');
      case 'banking_accounts':
        return currentRoute == '/banking' || currentRoute == '/banking/accounts';
      case 'banking_reconciliation':
        return currentRoute.startsWith('/banking/reconciliation');
      case 'reports':
        return currentRoute.startsWith('/reports');
      case 'settings':
        return currentRoute.startsWith('/settings');
      default:
        return currentRoute == item.route;
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = '/';
    try {
      currentRoute = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      currentRoute = '/';
    }
    final width = isCollapsed ? 72.0 : 224.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.fastOutSlowIn,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: BorderDirectional(
          end: BorderSide(color: AppColors.sidebarDivider, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo & Collapse header
          _buildHeader(context),

          // Scrollable Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              children: [
                for (final section in sections) ...[
                  if (section.title != null && !isCollapsed)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 5),
                      child: Text(
                        section.getLocalizedTitle(context) ?? section.title!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sidebarGroupLabel,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ),
                  for (final item in section.items)
                    _buildNavItem(context, item, currentRoute, section.title != null),
                ],
              ],
            ),
          ),

          // Bottom Collapse Toggle & Language Selector
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: isCollapsed ? 12 : 14,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.sidebarDivider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (!isCollapsed) ...[
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        'F',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const Flexible(
                    child: Text(
                      'FinLedger',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38BDF8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggleCollapse,
              tooltip: context.l10n.collapseSidebar,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(
                Icons.menu_open_rounded,
                color: AppColors.sidebarText,
                size: 19,
              ),
            ),
          ] else ...[
            InkWell(
              onTap: onToggleCollapse,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'F',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavSubItem item, String currentRoute, bool isSubItem) {
    final isSelected = _isItemActive(item, currentRoute);
    final displayLabel = item.getLocalizedLabel(context);
    final isDashboard = item.id == 'dashboard';

    return Container(
      margin: EdgeInsetsDirectional.symmetric(
        horizontal: isCollapsed ? 8 : (isDashboard ? 10 : 12),
        vertical: 1.5,
      ),
      child: Tooltip(
        message: isCollapsed ? displayLabel : '',
        waitDuration: const Duration(milliseconds: 300),
        child: InkWell(
          onTap: () {
            // Dismiss drawer on mobile if open
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
            if (currentRoute != item.route) {
              context.go(item.route);
            }
          },
          hoverColor: AppColors.sidebarHover,
          splashColor: AppColors.sidebarActive,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: isCollapsed ? 0 : 12,
              vertical: isSubItem ? 6.5 : 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.sidebarText,
                  ),
                  if (!isCollapsed) const SizedBox(width: 10),
                ],
                if (!isCollapsed)
                  Expanded(
                    child: Text(
                      displayLabel,
                      style: TextStyle(
                        fontSize: isSubItem ? 12 : 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : AppColors.sidebarText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
        child: IconButton(
          onPressed: onToggleCollapse,
          tooltip: context.l10n.expandSidebar,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            color: AppColors.sidebarText,
            size: 20,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.sidebarDivider, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segmented language switcher inside navigation drawer
          LanguageSwitcher.drawerToggle(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'FinLedger v2.0',
                  style: TextStyle(fontSize: 10, color: AppColors.sidebarGroupLabel),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onToggleCollapse,
                tooltip: context.l10n.collapseSidebar,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                  color: AppColors.sidebarText,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
