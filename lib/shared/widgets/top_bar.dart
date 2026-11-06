import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/loading_service.dart';
import '../../core/services/token_service.dart';

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

  String _getPageTitle(String route) {
    if (route.startsWith('/crm')) {
      return 'CRM';
    }
    if (route.startsWith('/sales')) {
      return 'Sales';
    }
    if (route.startsWith('/purchases')) {
      return 'Purchases';
    }
    if (route.startsWith('/inventory')) {
      return 'Inventory';
    }
    if (route.startsWith('/expenses')) {
      return 'Expenses';
    }
    if (route.startsWith('/accounting/accounts')) {
      return 'Chart of Accounts';
    }
    if (route.startsWith('/accounting/journals/new')) {
      return 'Journal Entries / New';
    }
    if (route.startsWith('/accounting/journals')) {
      return 'Journal Entries';
    }
    if (route.startsWith('/accounting')) {
      return 'Accounting';
    }
    if (route.startsWith('/banking')) {
      return 'Banking';
    }
    if (route.startsWith('/reports')) {
      return 'Reports';
    }
    if (route.startsWith('/settings')) {
      return 'Settings';
    }
    return 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final tokenService = context.watch<TokenService>();
    final loadingService = context.watch<LoadingService>();
    final user = tokenService.currentUser;
    final company = user?.company;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final pageTitle = _getPageTitle(currentRoute);

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
                        horizontal: isMobile ? 12 : 20,
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
                            ),
                            const SizedBox(width: 4),
                          ],

                          // Breadcrumb on left: Home > Dashboard (Figure 3)
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Home',
                                  style: TextStyle(
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

                          const Spacer(),

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
                                  hintText: 'Search...',
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
                            const SizedBox(width: 12),
                          ],

                          // Company Switcher: BSB Trading LLC ▾ (Figure 3)
                          PopupMenuButton<String>(
                            tooltip: 'Switch Company',
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
                                    maxWidth: isMobile ? 95 : 150,
                                  ),
                                  child: Text(
                                    company?.name ?? 'BSB Trading LLC',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: isMobile ? 8 : 16),

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
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Sign Out',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(
                                  0xFF2563EB,
                                ), // Blue circle matching Figure 3
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'R', // Letter 'R' matching Figure 3
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
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
