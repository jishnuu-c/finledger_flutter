import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rounded_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company & System Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage company profile, UAE VAT tax registration, fiscal periods, and user roles',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save Changes'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Company Profile Card
          RoundedCard(
            title: 'Company Profile & Legal Entity',
            subtitle: 'Primary trading entity for invoice headers and official tax documentation',
            child: Column(
              children: [
                _buildSettingRow('Company Legal Name', 'BSB Trading LLC'),
                const Divider(height: 20),
                _buildSettingRow('Tax Registration Number (TRN)', '100234891000003 (FTA Registered)'),
                const Divider(height: 20),
                _buildSettingRow('Registered Address', 'Building 4, Al Quoz Industrial Area 3, Dubai, UAE'),
                const Divider(height: 20),
                _buildSettingRow('Functional Base Currency', 'AED - United Arab Emirates Dirham'),
                const Divider(height: 20),
                _buildSettingRow('Current Fiscal Year', '01-Jan-2026 to 31-Dec-2026 (Period 10 Active)'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tax Rates Configuration
          RoundedCard(
            title: 'VAT & Tax Rates',
            subtitle: 'UAE Federal Tax Authority (FTA) configuration',
            child: Column(
              children: [
                _buildSettingRow('Standard Rate (5%)', 'Default for all commercial goods & services'),
                const Divider(height: 20),
                _buildSettingRow('Zero Rated (0%)', 'Applies to qualifying exports and designated medical supplies'),
                const Divider(height: 20),
                _buildSettingRow('Exempt Supplies', 'Residential real estate leases & financial services'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Users & Permissions
          RoundedCard(
            title: 'Active Users & Roles',
            subtitle: 'Role-based access control with granular permission directives',
            child: Column(
              children: [
                _buildUserRow('Ahmed Jaber Al Hamri', 'ahmed.alhamri@bsbtrading.ae', 'Financial Controller', 'Super Admin'),
                const Divider(height: 16),
                _buildUserRow('Sara Khalil', 'sara.khalil@bsbtrading.ae', 'Senior Accountant', 'Accounting, Banking, Invoices'),
                const Divider(height: 16),
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
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
        final isNarrow = constraints.maxWidth < 450;
        return Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primarySurface,
              child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(email, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (isNarrow) ...[
                    const SizedBox(height: 4),
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
                  Text(role, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
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
