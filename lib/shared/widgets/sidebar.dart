import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class NavSection {
  final String? title; // If null, renders as standalone top item (e.g. Dashboard)
  final List<NavSubItem> items;

  const NavSection({this.title, required this.items});
}

class NavSubItem {
  final String label;
  final String route;
  final IconData? icon;

  const NavSubItem({
    required this.label,
    required this.route,
    this.icon,
  });
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
          label: 'Dashboard',
          route: '/dashboard',
          icon: Icons.dashboard_outlined,
        ),
      ],
    ),
    NavSection(
      title: 'CRM',
      items: [
        NavSubItem(label: 'Leads', route: '/crm/leads'),
        NavSubItem(label: 'Pipeline', route: '/crm/pipeline'),
        NavSubItem(label: 'Quotations', route: '/crm/quotations'),
      ],
    ),
    NavSection(
      title: 'SALES',
      items: [
        NavSubItem(label: 'Customers', route: '/sales/customers'),
        NavSubItem(label: 'Invoices', route: '/sales/invoices'),
        NavSubItem(label: 'Receipts', route: '/sales/receipts/new'),
      ],
    ),
    NavSection(
      title: 'PURCHASES',
      items: [
        NavSubItem(label: 'Vendors', route: '/purchases/vendors'),
        NavSubItem(label: 'Bills', route: '/purchases/bills'),
        NavSubItem(label: 'Payments', route: '/purchases/payments/new'),
      ],
    ),
    NavSection(
      title: 'INVENTORY',
      items: [
        NavSubItem(label: 'Items & Stock', route: '/inventory/items'),
        NavSubItem(label: 'Adjustments', route: '/inventory/adjustments/new'),
        NavSubItem(label: 'Transfers', route: '/inventory/transfers/new'),
      ],
    ),
    NavSection(
      title: 'EXPENSES',
      items: [
        NavSubItem(label: 'Expenses', route: '/expenses'),
        NavSubItem(label: 'Approvals', route: '/expenses/approvals'),
      ],
    ),
    NavSection(
      title: 'ACCOUNTING',
      items: [
        NavSubItem(label: 'Chart of Accounts', route: '/accounting/accounts'),
        NavSubItem(label: 'Journal Entries', route: '/accounting/journals'),
      ],
    ),
    NavSection(
      title: 'BANKING',
      items: [
        NavSubItem(label: 'Bank Accounts', route: '/banking'),
        NavSubItem(label: 'Reconciliation', route: '/banking/reconciliation'),
      ],
    ),
    NavSection(
      title: null,
      items: [
        NavSubItem(
          label: 'Reports',
          route: '/reports',
          icon: Icons.bar_chart_outlined,
        ),
        NavSubItem(
          label: 'Settings',
          route: '/settings',
          icon: Icons.settings_outlined,
        ),
      ],
    ),
  ];

  bool _isItemActive(NavSubItem item, String currentRoute) {
    switch (item.label) {
      case 'Dashboard':
        return currentRoute == '/dashboard' || currentRoute == '/';
      case 'Leads':
        return currentRoute == '/crm/leads';
      case 'Pipeline':
        return currentRoute == '/crm/pipeline' || currentRoute.startsWith('/crm/opportunities');
      case 'Quotations':
        return currentRoute == '/crm/quotations';
      case 'Customers':
        return currentRoute == '/sales/customers';
      case 'Invoices':
        return currentRoute == '/sales/invoices' || currentRoute == '/sales/invoices/new';
      case 'Receipts':
        return currentRoute.startsWith('/sales/receipts');
      case 'Vendors':
        return currentRoute == '/purchases/vendors';
      case 'Bills':
        return currentRoute == '/purchases' || currentRoute == '/purchases/bills';
      case 'Payments':
        return currentRoute.startsWith('/purchases/payments');
      case 'Items & Stock':
        return currentRoute == '/inventory' || currentRoute == '/inventory/items';
      case 'Adjustments':
        return currentRoute.startsWith('/inventory/adjustments');
      case 'Transfers':
        return currentRoute.startsWith('/inventory/transfers');
      case 'Expenses':
        return currentRoute == '/expenses' || currentRoute == '/expenses/new';
      case 'Approvals':
        return currentRoute == '/expenses/approvals';
      case 'Chart of Accounts':
        return currentRoute == '/accounting' || currentRoute == '/accounting/accounts';
      case 'Journal Entries':
        return currentRoute.startsWith('/accounting/journals');
      case 'Bank Accounts':
        return currentRoute == '/banking' || currentRoute == '/banking/accounts';
      case 'Reconciliation':
        return currentRoute.startsWith('/banking/reconciliation');
      case 'Reports':
        return currentRoute.startsWith('/reports');
      case 'Settings':
        return currentRoute.startsWith('/settings');
      default:
        return currentRoute == item.route;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final width = isCollapsed ? 76.0 : 220.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground, // #0F1B33 from spec & Figure 3
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo & Collapse header
          _buildHeader(context),

          // Scrollable Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final section in sections) ...[
                  if (section.title != null && !isCollapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        section.title!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  for (final item in section.items)
                    _buildNavItem(context, item, currentRoute, section.title != null),
                ],
              ],
            ),
          ),

          // Bottom Collapse Toggle
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 58,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 10 : 14),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (!isCollapsed) ...[
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Flexible(
                    child: Text(
                      'FinLedger',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
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
              tooltip: 'Collapse sidebar',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(
                Icons.menu_open_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
            ),
          ] else ...[
            InkWell(
              onTap: onToggleCollapse,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'F',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
    final isDashboard = item.label == 'Dashboard';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 10 : (isDashboard ? 10 : 12),
        vertical: 1.5,
      ),
      child: Tooltip(
        message: isCollapsed ? item.label : '',
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
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 12,
              vertical: isSubItem ? 6.5 : 8,
            ),
            decoration: BoxDecoration(
              // Active highlight matching Figures 3, 13, and 14 (vivid blue #2563EB)
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : Colors.transparent,
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
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  ),
                  if (!isCollapsed) const SizedBox(width: 10),
                ],
                if (!isCollapsed)
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: isSubItem ? 12 : 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
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
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: IconButton(
          onPressed: onToggleCollapse,
          tooltip: 'Expand sidebar',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Text(
              'FinLedger v2.0',
              style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onToggleCollapse,
            tooltip: 'Collapse sidebar',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
