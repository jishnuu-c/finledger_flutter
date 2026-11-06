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
        NavSubItem(label: 'Leads', route: '/crm/pipeline'),
        NavSubItem(label: 'Pipeline', route: '/crm/pipeline'),
        NavSubItem(label: 'Quotations', route: '/crm/pipeline'),
      ],
    ),
    NavSection(
      title: 'SALES',
      items: [
        NavSubItem(label: 'Customers', route: '/sales/invoices'),
        NavSubItem(label: 'Invoices', route: '/sales/invoices'),
        NavSubItem(label: 'Receipts', route: '/sales/receipts/new'),
      ],
    ),
    NavSection(
      title: 'PURCHASES',
      items: [
        NavSubItem(label: 'Vendors', route: '/purchases'),
        NavSubItem(label: 'Bills', route: '/purchases'),
        NavSubItem(label: 'Payments', route: '/purchases'),
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
        NavSubItem(label: 'Approvals', route: '/expenses'),
      ],
    ),
    NavSection(
      title: 'ACCOUNTING',
      items: [
        NavSubItem(label: 'Chart of Accounts', route: '/accounting'),
        NavSubItem(label: 'Journal Entries', route: '/accounting'),
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
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 18),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (!isCollapsed) ...[
            Row(
              children: [
                const Text(
                  'FinLedger',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
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
            IconButton(
              onPressed: onToggleCollapse,
              tooltip: 'Collapse sidebar',
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
    final isSelected = (currentRoute == item.route) ||
        (item.route != '/dashboard' && currentRoute.startsWith('${item.route}/')) ||
        (item.label == 'Pipeline' && currentRoute.startsWith('/crm/opportunities')) ||
        (item.label == 'Invoices' && currentRoute.startsWith('/sales/invoices')) ||
        (item.label == 'Receipts' && currentRoute.startsWith('/sales/receipts')) ||
        (item.label == 'Items & Stock' && currentRoute.startsWith('/inventory/items')) ||
        (item.label == 'Adjustments' && currentRoute.startsWith('/inventory/adjustments')) ||
        (item.label == 'Transfers' && currentRoute.startsWith('/inventory/transfers')) ||
        (item.label == 'Expenses' && (currentRoute == '/expenses' || currentRoute.startsWith('/expenses/'))) ||
        (item.label == 'Reconciliation' && currentRoute.startsWith('/banking')) ||
        (item.label == 'Reports' && (currentRoute == '/reports' || currentRoute.startsWith('/reports/'))) ||
        (item.label == 'Settings' && (currentRoute == '/settings' || currentRoute.startsWith('/settings/')));

    // Special treatment for Dashboard or Top-level items matching Figure 3
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
          const Text(
            'FinLedger v2.0',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          IconButton(
            onPressed: onToggleCollapse,
            tooltip: 'Collapse sidebar',
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
