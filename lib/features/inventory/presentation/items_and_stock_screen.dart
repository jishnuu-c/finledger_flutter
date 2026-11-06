import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/inventory_models.dart';
import '../data/services/inventory_service.dart';
import 'widgets/stock_ledger_modal.dart';
import 'widgets/stock_status_chip.dart';

class ItemsAndStockScreen extends StatefulWidget {
  final InventoryService? inventoryService;

  const ItemsAndStockScreen({super.key, this.inventoryService});

  @override
  State<ItemsAndStockScreen> createState() => _ItemsAndStockScreenState();
}

class _ItemsAndStockScreenState extends State<ItemsAndStockScreen> {
  late final InventoryService _inventoryService;

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All categories';
  String _selectedWarehouse = 'All warehouses';
  String _selectedStatus = 'Stock status';

  late Future<StockKpis> _kpisFuture;
  late Future<List<StockSummaryItem>> _itemsFuture;
  late Future<List<ItemCategory>> _categoriesFuture;
  late Future<List<Warehouse>> _warehousesFuture;

  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');
  final NumberFormat _compactCurrency = NumberFormat('#,##0', 'en_US');

  @override
  void initState() {
    super.initState();
    _inventoryService = widget.inventoryService ?? InventoryService();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _kpisFuture = _inventoryService.getStockKpis();
      _categoriesFuture = _inventoryService.getCategories();
      _warehousesFuture = _inventoryService.getWarehouses();
      _filterItems();
    });
  }

  void _filterItems() {
    setState(() {
      _itemsFuture = _inventoryService.getStockSummary(
        search: _searchController.text,
        category: _selectedCategory,
        warehouseCode: _selectedWarehouse == 'Dubai WH'
            ? 'DXB-WH'
            : (_selectedWarehouse == 'Riyadh WH' ? 'RUH-WH' : null),
        status: _selectedStatus == 'Stock status' ? null : _selectedStatus,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStockLedger(StockSummaryItem item) {
    StockLedgerModal.show(
      context,
      item: item,
      inventoryService: _inventoryService,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs and Page Title (Figure 9)
            _buildBreadcrumbsAndTitle(),
            const SizedBox(height: 20),

            // 4 KPI Cards (Total stock value, Active SKUs, Below reorder level, Out of stock)
            _buildKpiCards(),
            const SizedBox(height: 20),

            // Filter Toolbar (Search, categories, warehouses, status, buttons)
            _buildFilterToolbar(),
            const SizedBox(height: 16),

            // Stock Table (Figure 9)
            _buildStockTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbsAndTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              onTap: () => context.go('/inventory/items'),
              child: const Text('Inventory', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('Items & Stock', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Items & Stock',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCards() {
    return FutureBuilder<StockKpis>(
      future: _kpisFuture,
      builder: (context, snapshot) {
        final kpis = snapshot.data ??
            const StockKpis(
              totalStockValue: 612500.0,
              activeSkus: 148,
              totalWarehouses: 2,
              belowReorderCount: 7,
              suggestedPoValue: 84200.0,
              outOfStockCount: 2,
              openQuotationsCount: 1,
            );

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 950;
            final isTablet = constraints.maxWidth >= 550;
            final cardWidth = isDesktop
                ? (constraints.maxWidth - 42) / 4
                : (isTablet ? (constraints.maxWidth - 14) / 2 : constraints.maxWidth);

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _buildSingleKpiCard(
                  title: 'Total stock value',
                  value: 'AED ${_compactCurrency.format(kpis.totalStockValue)}',
                  subtitle: 'Weighted average cost',
                  valueColor: AppColors.textPrimary,
                  width: cardWidth,
                ),
                _buildSingleKpiCard(
                  title: 'Active SKUs',
                  value: '${kpis.activeSkus}',
                  subtitle: '${kpis.totalWarehouses} warehouses',
                  valueColor: AppColors.textPrimary,
                  width: cardWidth,
                ),
                _buildSingleKpiCard(
                  title: 'Below reorder level',
                  value: '${kpis.belowReorderCount}',
                  subtitle: 'Suggested PO value AED ${_compactCurrency.format(kpis.suggestedPoValue)}',
                  valueColor: const Color(0xFFDC2626), // red accent in Figure 9
                  width: cardWidth,
                ),
                _buildSingleKpiCard(
                  title: 'Out of stock',
                  value: '${kpis.outOfStockCount}',
                  subtitle: '${kpis.openQuotationsCount} with open quotations',
                  valueColor: const Color(0xFFDC2626), // red accent in Figure 9
                  width: cardWidth,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSingleKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color valueColor,
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: valueColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar() {
    return FutureBuilder(
      future: Future.wait([_categoriesFuture, _warehousesFuture]),
      builder: (context, snapshot) {
        final categories = (snapshot.data?[0] as List<ItemCategory>?) ?? [];
        final warehouses = (snapshot.data?[1] as List<Warehouse>?) ?? [];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;

            final searchAndFilters = [
              // Search input
              SizedBox(
                width: isWide ? 220 : double.infinity,
                height: 38,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _filterItems(),
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'Search SKU / name / barcode...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8, height: 8),

              // Categories dropdown
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem(value: 'All categories', child: Text('All categories')),
                      ...categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                        _filterItems();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8, height: 8),

              // Warehouses dropdown
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedWarehouse,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem(value: 'All warehouses', child: Text('All warehouses')),
                      ...warehouses.map((w) => DropdownMenuItem(
                            value: w.code == 'DXB-WH' ? 'Dubai WH' : 'Riyadh WH',
                            child: Text(w.code == 'DXB-WH' ? 'Dubai WH' : 'Riyadh WH'),
                          )),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedWarehouse = val);
                        _filterItems();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8, height: 8),

              // Stock status dropdown
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'Stock status', child: Text('Stock status')),
                      DropdownMenuItem(value: 'In stock', child: Text('In stock')),
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                      DropdownMenuItem(value: 'Out of stock', child: Text('Out of stock')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedStatus = val);
                        _filterItems();
                      }
                    },
                  ),
                ),
              ),
            ];

            final actionButtons = [
              // Stock Ledger Button (Figure 9)
              OutlinedButton.icon(
                onPressed: () {
                  // Open first item or global ledger
                  _itemsFuture.then((items) {
                    if (items.isNotEmpty && context.mounted) {
                      _openStockLedger(items.first);
                    }
                  });
                },
                icon: const Icon(Icons.menu_book_outlined, size: 14, color: AppColors.textSecondary),
                label: const Text('Stock Ledger', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 8),

              // Export Button (Figure 9)
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exporting stock summary to Excel/CSV...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Export', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
              ),
              const SizedBox(width: 8),

              // + New Item Button (Figure 9)
              ElevatedButton.icon(
                onPressed: () => _showNewItemDialog(),
                icon: const Icon(Icons.add, size: 15, color: Colors.white),
                label: const Text('+ New Item', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Blue from mockup
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ];

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(spacing: 8, runSpacing: 8, children: searchAndFilters),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: actionButtons),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: searchAndFilters,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(children: actionButtons),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStockTable() {
    return FutureBuilder<List<StockSummaryItem>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final items = snapshot.data ?? [];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final effectiveWidth = constraints.maxWidth < 950 ? 950.0 : constraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: effectiveWidth,
                      child: Column(
                          children: [
                            // Table Header (Figure 9)
                            Container(
                              color: const Color(0xFFF8FAFC),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: const Row(
                                children: [
                                  Expanded(flex: 3, child: Text('SKU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 5, child: Text('Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 3, child: Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 2, child: Text('Dubai WH', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 2, child: Text('Riyadh WH', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 2, child: Text('On hand', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 2, child: Text('Reorder lvl', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 2, child: Text('Avg cost', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 3, child: Text('Value (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                  Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.borderSubtle),

                            // Rows (Figure 9)
                            if (items.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                  child: Text('No inventory items found matching filters.', style: TextStyle(color: AppColors.textSecondary)),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                separatorBuilder: (context, _) => const Divider(height: 1, color: AppColors.borderSubtle),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return InkWell(
                                    onTap: () => _openStockLedger(item),
                                    hoverColor: const Color(0xFFF8FAFC),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                                      child: Row(
                                        children: [
                                          // SKU (blue clickable link)
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              item.sku,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                          ),
                                          // Item Description
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                                            ),
                                          ),
                                          // Category
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              item.category,
                                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                            ),
                                          ),
                                          // Dubai WH
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${item.getStockForWarehouse('DXB-WH')}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                                            ),
                                          ),
                                          // Riyadh WH
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${item.getStockForWarehouse('RUH-WH')}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                                            ),
                                          ),
                                          // On hand (Bold)
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${item.onHand}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                            ),
                                          ),
                                          // Reorder lvl
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${item.reorderLevel}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                            ),
                                          ),
                                          // Avg cost
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _currencyFormat.format(item.avgCost),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                            ),
                                          ),
                                          // Value (AED)
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              _currencyFormat.format(item.stockValue),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                            ),
                                          ),
                                          // Status Chip
                                          Expanded(
                                            flex: 3,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: StockStatusChip(status: item.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const Divider(height: 1, color: AppColors.borderSubtle),

              // Table Footer matching Figure 9
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Showing 1-8 of 148 · services and non-inventory items hidden',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPaginationButton('<', isEnabled: false),
                        _buildPaginationNumber('1', isActive: true),
                        _buildPaginationNumber('2', isActive: false),
                        _buildPaginationNumber('3', isActive: false),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ),
                        _buildPaginationNumber('19', isActive: false),
                        _buildPaginationButton('>', isEnabled: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationNumber(String num, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? const Color(0xFFBFDBFE) : Colors.transparent,
        ),
      ),
      child: Center(
        child: Text(
          num,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF2563EB) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String symbol, {required bool isEnabled}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 26,
      height: 26,
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isEnabled ? AppColors.textSecondary : AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  void _showNewItemDialog() {
    final skuController = TextEditingController();
    final nameController = TextEditingController();
    final costController = TextEditingController(text: '0.00');
    final reorderController = TextEditingController(text: '10');

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('New Inventory SKU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: skuController,
                    decoration: const InputDecoration(labelText: 'SKU *', hintText: 'e.g. BSB-GEN-01'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item Name *', hintText: 'e.g. Industrial Sensor'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: costController,
                    decoration: const InputDecoration(labelText: 'Standard / Avg Cost (AED) *'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reorderController,
                    decoration: const InputDecoration(labelText: 'Reorder Level *'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (skuController.text.isNotEmpty && nameController.text.isNotEmpty) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Item SKU "${skuController.text}" registered successfully.'),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: const Text('Save SKU'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
