import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/stat_kpi_card.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'code': 'SKU-GEN-500', 'name': 'Diesel Generator 500kVA', 'category': 'Heavy Equipment', 'stock': '6 units', 'reorder': '2 units', 'avgCost': 'AED 42,500.00', 'status': 'Optimal'},
      {'code': 'SKU-INV-102', 'name': 'Solar Inverter 50kW Dual MPPT', 'category': 'Electrical & Solar', 'stock': '14 units', 'reorder': '5 units', 'avgCost': 'AED 8,900.00', 'status': 'Optimal'},
      {'code': 'SKU-FLT-200', 'name': 'HVAC Pleated Air Filter 24x24', 'category': 'Consumables', 'stock': '18 units', 'reorder': '50 units', 'avgCost': 'AED 45.00', 'status': 'Low Stock'},
      {'code': 'SKU-LUB-040', 'name': 'Synthetic Turbine Lubricant 200L', 'category': 'Chemicals', 'stock': '4 drums', 'reorder': '10 drums', 'avgCost': 'AED 1,650.00', 'status': 'Low Stock'},
      {'code': 'SKU-RCK-900', 'name': 'Heavy Duty Industrial Pallet Racks', 'category': 'Logistics & Storage', 'stock': '82 sections', 'reorder': '20 sections', 'avgCost': 'AED 620.00', 'status': 'Optimal'},
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                context.l10n.home,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(
                context.l10n.inventory,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Header & Actions
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.inventoryTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.inventorySubtitle,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/inventory/transfers/new'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.sync_alt_rounded, size: 16),
                      label: Text(context.l10n.stockTransfer, style: const TextStyle(fontSize: 12.5)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/inventory/items'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(context.l10n.newItem, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
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
                        context.l10n.inventoryTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.inventorySubtitle,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/inventory/transfers/new'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.sync_alt_rounded, size: 16),
                      label: Text(context.l10n.stockTransfer, style: const TextStyle(fontSize: 12.5)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/inventory/items'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(context.l10n.newItem, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Inventory KPIs
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 550 ? 2 : 1);
              final itemWidth = (constraints.maxWidth - (cols - 1) * 16) / cols;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: const StatKpiCard(
                      title: 'Total Stock Valuation',
                      value: 'AED 512,000',
                      subtitle: 'Calculated on receipt',
                      icon: Icons.inventory_2_outlined,
                      iconColor: Color(0xFFEA580C),
                      iconBgColor: Color(0xFFFFEDD5),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: const StatKpiCard(
                      title: 'Active Warehouses',
                      value: '2 Locations',
                      subtitle: 'Al Quoz Central & JAFZA Depot',
                      icon: Icons.warehouse_outlined,
                      iconColor: Color(0xFF2563EB),
                      iconBgColor: Color(0xFFEFF6FF),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: const StatKpiCard(
                      title: 'Low Stock Alerts',
                      value: '4 SKUs',
                      badgeText: 'Action Required',
                      badgeColor: AppColors.overdueBg,
                      badgeTextColor: AppColors.overdue,
                      icon: Icons.warning_amber_rounded,
                      iconColor: Color(0xFFDC2626),
                      iconBgColor: Color(0xFFFEE2E2),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Stock Overview Table
          RoundedCard(
            title: 'Stock Summary & Movement Log',
            subtitle: 'Al Quoz Central Warehouse (Main Trading)',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 750),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  headingRowHeight: 40,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 48,
                  horizontalMargin: 16,
                  columnSpacing: 20,
                  columns: [
                    DataColumn(label: Text(context.l10n.sku, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                    DataColumn(label: Text(context.l10n.itemName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                    DataColumn(label: Text(context.l10n.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                    DataColumn(label: Text(context.l10n.onHand, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                    DataColumn(label: Text(context.l10n.reorderLevel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                    DataColumn(label: Text(context.l10n.weightedAvgCost, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                    DataColumn(label: Text(context.l10n.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  ],
                  rows: items.map((it) {
                    final isLow = it['status'] == 'Low Stock';
                    return DataRow(
                      cells: [
                        DataCell(Text(it['code']!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13))),
                        DataCell(Text(it['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(Text(it['category']!, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                        DataCell(Text(it['stock']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary))),
                        DataCell(Text(it['reorder']!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                        DataCell(Text(it['avgCost']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary))),
                        DataCell(
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isLow ? AppColors.overdueBg : AppColors.paidBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isLow ? const Color(0xFFFECACA) : const Color(0xFFDCFCE7),
                              ),
                            ),
                            child: Text(
                              it['status']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isLow ? AppColors.overdue : AppColors.paid,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
