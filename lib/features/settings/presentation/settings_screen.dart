import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/language_switcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                onTap: () => context.go('/dashboard'),
                child: Text(context.l10n.home, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
              const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(context.l10n.settings, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),

          // Header
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.systemSettings,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage company profile, UAE VAT tax registration, fiscal periods, language, and user roles',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.saveChanges),
                        backgroundColor: AppColors.paid,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined, size: 16, color: Colors.white),
                  label: Text(context.l10n.saveChanges, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: const Size(0, 40),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.systemSettings,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manage company profile, UAE VAT tax registration, fiscal periods, language, and user roles',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.saveChanges),
                        backgroundColor: AppColors.paid,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined, size: 16, color: Colors.white),
                  label: Text(context.l10n.saveChanges, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    minimumSize: const Size(0, 40),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),

          // Prominent Language & Localization Switcher Card
          LanguageSwitcher.settingsCard(),
          const SizedBox(height: 20),

          // Company Profile Card
          RoundedCard(
            title: 'Company Profile & Legal Entity',
            subtitle: 'Primary trading entity for invoice headers and official tax documentation',
            child: Column(
              children: [
                _buildSettingRow('Company Legal Name', 'BSB Trading LLC'),
                const Divider(height: 22, color: AppColors.borderSubtle),
                _buildSettingRow('Tax Registration Number (TRN)', '100234891000003 (FTA Registered)'),
                const Divider(height: 22, color: AppColors.borderSubtle),
                _buildSettingRow('Registered Address', 'Building 4, Al Quoz Industrial Area 3, Dubai, UAE'),
                const Divider(height: 22, color: AppColors.borderSubtle),
                _buildSettingRow('Functional Base Currency', 'AED - United Arab Emirates Dirham'),
                const Divider(height: 22, color: AppColors.borderSubtle),
                _buildSettingRow('Current Fiscal Year', '01-Jan-2026 to 31-Dec-2026 (Period 10 Active)'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tax Rates Configuration
          RoundedCard(
            title: 'VAT & Tax Rates',
            subtitle: 'UAE Federal Tax Authority (FTA) configuration',
            child: Column(
              children: [
                _buildSettingRow('Standard Rate (5%)', 'Default for all commercial goods & services'),
                const Divider(height: 22, color: AppColors.borderSubtle),
                _buildSettingRow('Zero Rated (0%)', 'Applies to qualifying exports and designated medical supplies'),
                const Divider(height: 22, color: AppColors.borderSubtle),
                _buildSettingRow('Exempt Supplies', 'Residential real estate leases & financial services'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Users & Permissions
          RoundedCard(
            title: 'Active Users & Roles',
            subtitle: 'Role-based access control with granular permission directives',
            child: Column(
              children: [
                _buildUserRow('Ahmed Jaber Al Hamri', 'ahmed.alhamri@bsbtrading.ae', 'Financial Controller', 'Super Admin'),
                const Divider(height: 20, color: AppColors.borderSubtle),
                _buildUserRow('Sara Khalil', 'sara.khalil@bsbtrading.ae', 'Senior Accountant', 'Accounting, Banking, Invoices'),
                const Divider(height: 20, color: AppColors.borderSubtle),
                _buildUserRow('Tariq Mansoor', 'tariq.m@bsbtrading.ae', 'Sales Manager', 'CRM, Quotations, Sales Orders'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserRow(String name, String email, String role, String perms) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;
        return Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(email, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (isNarrow) ...[
                    const SizedBox(height: 5),
                    Text('$role • $perms', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (!isNarrow) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(role, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5, color: Color(0xFF334155)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 3),
                  Text(perms, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
