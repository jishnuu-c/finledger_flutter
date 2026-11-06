import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.contentBackground,
      // Drawer on tablet / mobile devices
      drawer: isDesktop
          ? null
          : Drawer(
              width: 260,
              backgroundColor: AppColors.sidebarBackground,
              child: SafeArea(
                child: Sidebar(
                  isCollapsed: false,
                  onToggleCollapse: () => Navigator.of(context).pop(),
                ),
              ),
            ),
      body: Row(
        children: [
          // Fixed sidebar on desktop
          if (isDesktop)
            Sidebar(
              isCollapsed: _isSidebarCollapsed,
              onToggleCollapse: _toggleSidebar,
            ),

          // Main Content View
          Expanded(
            child: Column(
              children: [
                TopBar(
                  showMobileMenu: !isDesktop,
                  onMobileMenuToggle: () =>
                      _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: Container(
                    color: AppColors.contentBackground, // #F8FAFC
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
