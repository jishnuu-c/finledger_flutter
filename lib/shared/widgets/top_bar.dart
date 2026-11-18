import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/loading_service.dart';
import '../../core/services/token_service.dart';
import '../../core/localization/locale_provider.dart';
import 'language_switcher.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMobileMenuToggle;
  final bool showMobileMenu;

  const TopBar({
    super.key,
    this.onMobileMenuToggle,
    this.showMobileMenu = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  String _getPageTitle(BuildContext context, String route) {
    final l = context.l10n;
    if (route.startsWith('/crm/leads')) return '${l.crm} / ${l.leads}';
    if (route.startsWith('/crm/quotations')) return '${l.crm} / ${l.quotations}';
    if (route.startsWith('/crm/opportunities')) return '${l.crm} / ${l.opportunities}';
    if (route.startsWith('/crm')) return l.crmPipeline;
    if (route.startsWith('/sales/customers')) return '${l.sales} / ${l.customers}';
    if (route.startsWith('/sales/invoices/new')) return '${l.sales} / ${l.newInvoice}';
    if (route.startsWith('/sales/invoices')) return l.invoices;
    if (route.startsWith('/sales/receipts')) return l.customerReceipts;
    if (route.startsWith('/sales')) return l.sales;
    if (route.startsWith('/purchases/vendors')) return '${l.purchases} / ${l.vendors}';
    if (route.startsWith('/purchases/bills')) return l.vendorBills;
    if (route.startsWith('/purchases/payments')) return '${l.purchases} / ${l.payments}';
    if (route.startsWith('/purchases')) return l.purchases;
    if (route.startsWith('/inventory/items')) return l.itemsAndStock;
    if (route.startsWith('/inventory/adjustments')) return l.adjustments;
    if (route.startsWith('/inventory/transfers')) return l.transfers;
    if (route.startsWith('/inventory')) return l.inventory;
    if (route.startsWith('/expenses/approvals')) return l.approvals;
    if (route.startsWith('/expenses/new')) return l.newExpenseClaim;
    if (route.startsWith('/expenses')) return l.expenses;
    if (route.startsWith('/accounting/accounts')) return l.chartOfAccounts;
    if (route.startsWith('/accounting/journals/new')) return '${l.journalEntries} / ${l.create}';
    if (route.startsWith('/accounting/journals')) return l.journalEntries;
    if (route.startsWith('/accounting')) return l.accounting;
    if (route.startsWith('/banking/reconciliation')) return l.bankReconciliation;
    if (route.startsWith('/banking')) return l.bankAccounts;
    if (route.startsWith('/reports')) return l.financialReports;
    if (route.startsWith('/settings')) return l.companySettings;
    return l.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    final tokenService = context.watch<TokenService>();
    final loadingService = context.watch<LoadingService>();
    final user = tokenService.currentUser;
    final company = user?.company;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final pageTitle = _getPageTitle(context, currentRoute);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          left: false,
          right: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 680;
              final isMobile = constraints.maxWidth < 500;

              return Container(
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 16,
                      ),
                      child: Row(
                        children: [
                          // Mobile hamburger if on narrow screen
                          if (showMobileMenu) ...[
                            IconButton(
                              onPressed: onMobileMenuToggle,
                              icon: const Icon(
                                Icons.menu,
                                color: Color(0xFF334155),
                                size: 20,
                              ),
                              tooltip: 'Menu',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                            const SizedBox(width: 4),
                          ],

                          // Title / Breadcrumb: Never overflows on mobile
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: isMobile
                                  ? Text(
                                      pageTitle,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          context.l10n.home,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          '>',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            pageTitle,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF475569),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(width: 4),

                          // Search box: Search... (Figure 3) - Adaptive on wider screens
                          if (!isNarrow) ...[
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth >= 900
                                    ? 220
                                    : 140,
                                maxHeight: 34,
                              ),
                              child: TextField(
                                style: const TextStyle(fontSize: 12.5),
                                decoration: InputDecoration(
                                  hintText: context.l10n.searchPlaceholder,
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                  fillColor: const Color(0xFFF8FAFC),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Company Switcher: BSB Trading LLC ▾ (Figure 3)
                          PopupMenuButton<String>(
                            tooltip: context.l10n.switchCompany,
                            offset: const Offset(0, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'BSB Trading LLC',
                                child: Row(
                                  children: [
                                    Text(
                                      'BSB Trading LLC',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'BSB Gulf Logistics FZE',
                                child: Text(
                                  'BSB Gulf Logistics FZE',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isMobile ? 65 : (constraints.maxWidth >= 900 ? 150 : 110),
                                  ),
                                  child: Text(
                                    company?.name ?? 'BSB Trading LLC',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 15,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: isMobile ? 4 : 8),

                          // Global Language Switcher: Visible on TopBar
                          const LanguageSwitcher(),

                          SizedBox(width: isMobile ? 4 : 10),

                          // User Avatar: Blue circular avatar with 'R' (Figure 3)
                          PopupMenuButton<String>(
                            offset: const Offset(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            onSelected: (val) async {
                              if (val == 'logout') {
                                await tokenService.clearTokens();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                enabled: false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.fullName ?? 'Ahmed Al Hamri',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      user?.role ?? 'Financial Controller',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem<String>(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.logout,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.l10n.signOut,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              width: isMobile ? 28 : 32,
                              height: isMobile ? 28 : 32,
                              decoration: const BoxDecoration(
                                color: Color(
                                  0xFF2563EB,
                                ), // Blue circle matching Figure 3
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  'R',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isMobile ? 12.5 : 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loading progress indicator on bottom border
                    if (loadingService.isLoading)
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SizedBox(
                          height: 2,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
