import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/inventory_models.dart';
import '../data/services/inventory_service.dart';
import 'widgets/barcode_scanner_modal.dart';

enum StockActionTab { adjustment, transfer }

class StockAdjustmentTransferScreen extends StatefulWidget {
  final StockActionTab initialTab;
  final InventoryService? inventoryService;

  const StockAdjustmentTransferScreen({
    super.key,
    this.initialTab = StockActionTab.adjustment,
    this.inventoryService,
  });

  @override
  State<StockAdjustmentTransferScreen> createState() => _StockAdjustmentTransferScreenState();
}

class _StockAdjustmentTransferScreenState extends State<StockAdjustmentTransferScreen> {
  late final InventoryService _inventoryService;
  late StockActionTab _activeTab;

  // Warehouses & Items lookup
  List<Warehouse> _warehouses = [];
  List<StockSummaryItem> _availableItems = [];
  bool _isLoading = true;

  // Adjustment fields (Figure 10)
  final TextEditingController _adjNoController = TextEditingController(text: 'ADJ-2026-0021 (auto)');
  final TextEditingController _adjDateController = TextEditingController(text: '30-Oct-2026');
  final TextEditingController _adjNotesController = TextEditingController(text: 'Monthly cycle count - October 2026, aisle A-C');
  String _adjWarehouseCode = 'DXB-WH';
  String _adjReason = 'Stock count';
  String _adjAccount = '5150 - Inventory Adjustments';
  final List<StockAdjustmentLine> _adjLines = [];

  // Transfer fields
  final TextEditingController _trfNoController = TextEditingController(text: 'TRF-2026-0009 (auto)');
  final TextEditingController _trfDateController = TextEditingController(text: '30-Oct-2026');
  final TextEditingController _trfNotesController = TextEditingController(text: 'Stock replenishment for Riyadh regional showroom');
  String _trfFromWarehouseCode = 'DXB-WH';
  String _trfToWarehouseCode = 'RUH-WH';
  final List<StockTransferLine> _trfLines = [];

  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _inventoryService = widget.inventoryService ?? InventoryService();
    _initData();
  }

  Future<void> _initData() async {
    final whs = await _inventoryService.getWarehouses();
    final items = await _inventoryService.getStockSummary();

    if (!mounted) return;

    setState(() {
      _warehouses = whs;
      _availableItems = items;
      _isLoading = false;

      // Populate default adjustment lines matching Figure 10:
      // Line 1: BSB-FLT-H13 | H13 Replacement Filter | System: 420 | Counted: 412 | Diff: -8 | Cost: 185.00 | Impact: -1,480.00
      // Line 2: BSB-SNS-01  | Indoor Air Quality Sensor| System: 88  | Counted: 89  | Diff: +1 | Cost: 240.00 | Impact: 240.00
      // Line 3: BSB-AP500   | HEPA Air Purifier 500    | System: 64  | Counted: 63  | Diff: -1 | Cost: 2150.00| Impact: -2,150.00
      // Line 4: BSB-MNT-WL  | Wall-mount Bracket Kit   | System: 150 | Counted: 150 | Diff: 0  | Cost: 38.00  | Impact: 0.00
      _adjLines.clear();
      _adjLines.addAll([
        const StockAdjustmentLine(
          itemId: 3,
          sku: 'BSB-FLT-H13',
          description: 'H13 Replacement Filter',
          systemQty: 420,
          countedQty: 412,
          difference: -8,
          avgCost: 185.00,
          valueImpact: -1480.00,
        ),
        const StockAdjustmentLine(
          itemId: 6,
          sku: 'BSB-SNS-01',
          description: 'Indoor Air Quality Sensor',
          systemQty: 88,
          countedQty: 89,
          difference: 1,
          avgCost: 240.00,
          valueImpact: 240.00,
        ),
        const StockAdjustmentLine(
          itemId: 1,
          sku: 'BSB-AP500',
          description: 'HEPA Air Purifier 500',
          systemQty: 64,
          countedQty: 63,
          difference: -1,
          avgCost: 2150.00,
          valueImpact: -2150.00,
        ),
        const StockAdjustmentLine(
          itemId: 7,
          sku: 'BSB-MNT-WL',
          description: 'Wall-mount Bracket Kit',
          systemQty: 150,
          countedQty: 150,
          difference: 0,
          avgCost: 38.00,
          valueImpact: 0.00,
        ),
      ]);

      // Populate default transfer line
      _trfLines.clear();
      _trfLines.add(
        const StockTransferLine(
          itemId: 1,
          sku: 'BSB-AP500',
          description: 'HEPA Air Purifier 500',
          availableQty: 64,
          transferQty: 10,
          unitCost: 2150.00,
          transferValue: 21500.00,
        ),
      );
    });
  }

  @override
  void dispose() {
    _adjNoController.dispose();
    _adjDateController.dispose();
    _adjNotesController.dispose();
    _trfNoController.dispose();
    _trfDateController.dispose();
    _trfNotesController.dispose();
    super.dispose();
  }

  // Net value impact for adjustment: sum of valueImpact
  double get _adjNetValueImpact {
    return _adjLines.fold<double>(0.0, (sum, line) => sum + line.valueImpact);
  }

  // Total transfer value
  double get _trfTotalValue {
    return _trfLines.fold<double>(0.0, (sum, line) => sum + line.transferValue);
  }

  void _onCountedQtyChanged(int index, String value) {
    final parsed = int.tryParse(value) ?? _adjLines[index].systemQty;
    setState(() {
      _adjLines[index] = _adjLines[index].copyWith(countedQty: parsed);
    });
  }

  void _onTransferQtyChanged(int index, String value) {
    final parsed = int.tryParse(value) ?? 1;
    setState(() {
      _trfLines[index] = _trfLines[index].copyWith(transferQty: parsed);
    });
  }

  void _onAddItemToAdjustment() {
    // Pick the first item not yet in the lines, or default first item
    StockSummaryItem? candidate;
    for (final it in _availableItems) {
      if (!_adjLines.any((l) => l.itemId == it.id)) {
        candidate = it;
        break;
      }
    }
    candidate ??= _availableItems.firstOrNull;

    if (candidate != null) {
      final sysQty = candidate.getStockForWarehouse(_adjWarehouseCode);
      setState(() {
        _adjLines.add(
          StockAdjustmentLine(
            itemId: candidate!.id,
            sku: candidate.sku,
            description: candidate.name,
            systemQty: sysQty,
            countedQty: sysQty,
            difference: 0,
            avgCost: candidate.avgCost,
            valueImpact: 0.0,
          ),
        );
      });
    }
  }

  void _onAddItemToTransfer() {
    StockSummaryItem? candidate;
    for (final it in _availableItems) {
      if (!_trfLines.any((l) => l.itemId == it.id)) {
        candidate = it;
        break;
      }
    }
    candidate ??= _availableItems.firstOrNull;

    if (candidate != null) {
      final avail = candidate.getStockForWarehouse(_trfFromWarehouseCode);
      setState(() {
        _trfLines.add(
          StockTransferLine(
            itemId: candidate!.id,
            sku: candidate.sku,
            description: candidate.name,
            availableQty: avail,
            transferQty: avail > 0 ? 1 : 0,
            unitCost: candidate.avgCost,
            transferValue: (avail > 0 ? 1 : 0) * candidate.avgCost,
          ),
        );
      });
    }
  }

  void _onScanBarcode() {
    BarcodeScannerModal.show(
      context,
      inventoryService: _inventoryService,
      onItemScanned: (item) {
        if (_activeTab == StockActionTab.adjustment) {
          final sysQty = item.getStockForWarehouse(_adjWarehouseCode);
          setState(() {
            _adjLines.add(
              StockAdjustmentLine(
                itemId: item.id,
                sku: item.sku,
                description: item.name,
                systemQty: sysQty,
                countedQty: sysQty,
                difference: 0,
                avgCost: item.avgCost,
                valueImpact: 0.0,
              ),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scanned & added: ${item.sku} - ${item.name}'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        } else {
          final avail = item.getStockForWarehouse(_trfFromWarehouseCode);
          setState(() {
            _trfLines.add(
              StockTransferLine(
                itemId: item.id,
                sku: item.sku,
                description: item.name,
                availableQty: avail,
                transferQty: 1,
                unitCost: item.avgCost,
                transferValue: item.avgCost,
              ),
            );
          });
        }
      },
    );
  }

  void _onLoadAllWarehouseItems() {
    setState(() {
      _adjLines.clear();
      for (final item in _availableItems) {
        final sys = item.getStockForWarehouse(_adjWarehouseCode);
        _adjLines.add(
          StockAdjustmentLine(
            itemId: item.id,
            sku: item.sku,
            description: item.name,
            systemQty: sys,
            countedQty: sys,
            difference: 0,
            avgCost: item.avgCost,
            valueImpact: 0.0,
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded all ${_availableItems.length} items from $_adjWarehouseCode for physical count.'),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  Future<void> _submitAdjustment({required bool post}) async {
    if (_adjLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one line item.'), backgroundColor: Color(0xFFDC2626)),
      );
      return;
    }

    try {
      final adjustment = StockAdjustment(
        id: 0,
        adjustmentNo: 'ADJ-2026-0021',
        adjustmentDate: _adjDateController.text,
        warehouseId: _adjWarehouseCode == 'DXB-WH' ? 1 : 2,
        warehouseCode: _adjWarehouseCode,
        warehouseName: _adjWarehouseCode == 'DXB-WH' ? 'Dubai Warehouse' : 'Riyadh Warehouse',
        reason: _adjReason,
        adjustmentAccount: _adjAccount,
        notes: _adjNotesController.text,
        totalValue: _adjNetValueImpact,
        lines: _adjLines,
      );

      await _inventoryService.createStockAdjustment(adjustment, postImmediately: post);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            post
                ? 'Stock adjustment ADJ-2026-0021 posted and ledger updated.'
                : 'Stock adjustment saved as draft.',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      context.go('/inventory/items');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving adjustment: $e'), backgroundColor: const Color(0xFFDC2626)),
      );
    }
  }

  Future<void> _submitTransfer({required bool dispatch}) async {
    if (_trfLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one line item.'), backgroundColor: Color(0xFFDC2626)),
      );
      return;
    }
    if (_trfFromWarehouseCode == _trfToWarehouseCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From and To warehouse cannot be identical.'), backgroundColor: Color(0xFFDC2626)),
      );
      return;
    }

    try {
      final transfer = StockTransfer(
        id: 0,
        transferNo: 'TRF-2026-0009',
        transferDate: _trfDateController.text,
        fromWarehouseId: _trfFromWarehouseCode == 'DXB-WH' ? 1 : 2,
        fromWarehouseCode: _trfFromWarehouseCode,
        toWarehouseId: _trfToWarehouseCode == 'RUH-WH' ? 2 : 1,
        toWarehouseCode: _trfToWarehouseCode,
        notes: _trfNotesController.text,
        totalValue: _trfTotalValue,
        lines: _trfLines,
      );

      await _inventoryService.createStockTransfer(transfer, dispatchImmediately: dispatch);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dispatch
                ? 'Stock transfer TRF-2026-0009 dispatched in transit.'
                : 'Stock transfer saved as draft.',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      context.go('/inventory/items');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving transfer: $e'), backgroundColor: const Color(0xFFDC2626)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _activeTab == StockActionTab.adjustment ? 'New Stock Adjustment' : 'New Stock Transfer';
    final breadcrumbSub = _activeTab == StockActionTab.adjustment ? 'Adjustments' : 'Transfers';

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs and Title (Figure 10)
                  _buildBreadcrumbsAndTitle(title, breadcrumbSub),
                  const SizedBox(height: 18),

                  // Toggle Tabs (Stock Adjustment / Stock Transfer)
                  _buildActionTabs(),
                  const SizedBox(height: 20),

                  // Header Form Card
                  if (_activeTab == StockActionTab.adjustment)
                    _buildAdjustmentHeaderCard()
                  else
                    _buildTransferHeaderCard(),
                  const SizedBox(height: 20),

                  // Dynamic Line Items Grid
                  if (_activeTab == StockActionTab.adjustment)
                    _buildAdjustmentLinesCard()
                  else
                    _buildTransferLinesCard(),
                  const SizedBox(height: 22),

                  // Bottom Split Cards: Journal Preview & Stock Effect
                  if (_activeTab == StockActionTab.adjustment)
                    _buildAdjustmentBottomCards()
                  else
                    _buildTransferBottomCards(),
                ],
              ),
            ),
    );
  }

  Widget _buildBreadcrumbsAndTitle(String title, String breadcrumbSub) {
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
            Text(breadcrumbSub, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('New', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTabs() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Stock Adjustment Tab
        InkWell(
          onTap: () {
            setState(() => _activeTab = StockActionTab.adjustment);
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _activeTab == StockActionTab.adjustment ? const Color(0xFF2563EB) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _activeTab == StockActionTab.adjustment ? const Color(0xFF2563EB) : AppColors.border,
              ),
            ),
            child: Text(
              'Stock Adjustment',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _activeTab == StockActionTab.adjustment ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),

        // Stock Transfer Tab
        InkWell(
          onTap: () {
            setState(() => _activeTab = StockActionTab.transfer);
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _activeTab == StockActionTab.transfer ? const Color(0xFF2563EB) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _activeTab == StockActionTab.transfer ? const Color(0xFF2563EB) : AppColors.border,
              ),
            ),
            child: Text(
              'Stock Transfer',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _activeTab == StockActionTab.transfer ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Stock Adjustment Form Elements ---

  Widget _buildAdjustmentHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 550) {
                return Column(
                  children: [
                    _buildAdjNoField(),
                    const SizedBox(height: 12),
                    _buildAdjDateField(),
                    const SizedBox(height: 12),
                    _buildAdjWarehouseField(),
                    const SizedBox(height: 12),
                    _buildAdjReasonField(),
                    const SizedBox(height: 12),
                    _buildAdjAccountField(),
                  ],
                );
              }
              if (constraints.maxWidth < 950) {
                final halfWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: halfWidth, child: _buildAdjNoField()),
                    SizedBox(width: halfWidth, child: _buildAdjDateField()),
                    SizedBox(width: halfWidth, child: _buildAdjWarehouseField()),
                    SizedBox(width: halfWidth, child: _buildAdjReasonField()),
                    SizedBox(width: constraints.maxWidth, child: _buildAdjAccountField()),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: _buildAdjNoField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _buildAdjDateField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: _buildAdjWarehouseField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _buildAdjReasonField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 5, child: _buildAdjAccountField()),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Notes Row
          const Text('Notes', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          SizedBox(
            height: 38,
            child: TextField(
              controller: _adjNotesController,
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjNoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adjustment No.', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          height: 38,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            _adjNoController.text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        SizedBox(
          height: 38,
          child: TextField(
            controller: _adjDateController,
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjWarehouseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Warehouse *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
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
              value: _adjWarehouseCode,
              isExpanded: true,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              items: _warehouses.map((w) {
                return DropdownMenuItem(value: w.code, child: Text('${w.code} - ${w.name}'));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _adjWarehouseCode = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reason *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
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
              value: _adjReason,
              isExpanded: true,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              items: const [
                DropdownMenuItem(value: 'Stock count', child: Text('Stock count')),
                DropdownMenuItem(value: 'Damaged goods', child: Text('Damaged goods')),
                DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                DropdownMenuItem(value: 'Theft / Loss', child: Text('Theft / Loss')),
                DropdownMenuItem(value: 'Opening balance', child: Text('Opening balance')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _adjReason = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adjustment Account *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
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
              value: _adjAccount,
              isExpanded: true,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              items: const [
                DropdownMenuItem(value: '5150 - Inventory Adjustments', child: Text('5150 - Inventory Adjustments')),
                DropdownMenuItem(value: '5160 - Damaged Goods Write-off', child: Text('5160 - Damaged Goods Write-off')),
                DropdownMenuItem(value: '5170 - Inventory Shrinkage', child: Text('5170 - Inventory Shrinkage')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _adjAccount = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentLinesCard() {
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
              const minTableWidth = 850.0;
              final effectiveWidth = constraints.maxWidth < minTableWidth ? minTableWidth : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Column(
                    children: [
                      // Header Row (Figure 10)
                      Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text('Item *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 6, child: Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('System qty', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Counted qty', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Difference', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Avg cost', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 3, child: Text('Value impact (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            SizedBox(width: 32),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),

                      // Dynamic Line Rows
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _adjLines.length,
                        separatorBuilder: (context, _) => const Divider(height: 1, color: AppColors.borderSubtle),
                        itemBuilder: (context, index) {
                          final line = _adjLines[index];
                          final diff = line.difference;
                          final diffColor = diff < 0
                              ? const Color(0xFFDC2626) // Red
                              : (diff > 0 ? const Color(0xFF16A34A) : AppColors.textSecondary); // Green or neutral

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                // Item picker dropdown / display
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: line.sku,
                                        isExpanded: true,
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        items: _availableItems.map((it) {
                                          return DropdownMenuItem(value: it.sku, child: Text(it.sku));
                                        }).toList(),
                                        onChanged: (sku) {
                                          if (sku != null) {
                                            final sel = _availableItems.firstWhere((it) => it.sku == sku);
                                            final sys = sel.getStockForWarehouse(_adjWarehouseCode);
                                            setState(() {
                                              _adjLines[index] = StockAdjustmentLine(
                                                itemId: sel.id,
                                                sku: sel.sku,
                                                description: sel.name,
                                                systemQty: sys,
                                                countedQty: sys,
                                                difference: 0,
                                                avgCost: sel.avgCost,
                                                valueImpact: 0.0,
                                              );
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Description
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    line.description,
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                                  ),
                                ),

                                // System Qty (Live)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${line.systemQty}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                  ),
                                ),

                                // Counted Qty Input
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: 72,
                                      height: 34,
                                      child: TextFormField(
                                        initialValue: '${line.countedQty}',
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            borderSide: const BorderSide(color: AppColors.border),
                                          ),
                                        ),
                                        onChanged: (val) => _onCountedQtyChanged(index, val),
                                      ),
                                    ),
                                  ),
                                ),

                                // Difference (Auto-calculated, -red, +green)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${diff > 0 ? '+' : ''}$diff',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: diffColor),
                                  ),
                                ),

                                // Avg Cost
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _currencyFormat.format(line.avgCost),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                  ),
                                ),

                                // Value Impact (AED)
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    _currencyFormat.format(line.valueImpact),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: line.valueImpact < 0
                                          ? const Color(0xFFDC2626)
                                          : (line.valueImpact > 0 ? const Color(0xFF16A34A) : AppColors.textPrimary),
                                    ),
                                  ),
                                ),

                                // Delete Row Button
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Color(0xFFDC2626)),
                                    onPressed: () {
                                      setState(() => _adjLines.removeAt(index));
                                    },
                                    tooltip: 'Remove line',
                                  ),
                                ),
                              ],
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

          // Action links & Net value impact row (Figure 10)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: _onAddItemToAdjustment,
                      child: const Text(
                        '+ Add item',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ),
                    const Text('·', style: TextStyle(color: AppColors.textMuted)),
                    InkWell(
                      onTap: _onScanBarcode,
                      child: const Text(
                        'Scan barcode',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ),
                    const Text('·', style: TextStyle(color: AppColors.textMuted)),
                    InkWell(
                      onTap: _onLoadAllWarehouseItems,
                      child: const Text(
                        'Load all items in warehouse',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ),
                  ],
                ),

                // Net value impact (Figure 10: Net value impact -3,390.00)
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Net value impact', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(
                      _currencyFormat.format(_adjNetValueImpact),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _adjNetValueImpact < 0
                            ? const Color(0xFFDC2626)
                            : (_adjNetValueImpact > 0 ? const Color(0xFF16A34A) : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentBottomCards() {
    final netImpact = _adjNetValueImpact;
    final absImpact = netImpact.abs();
    final itemsChangedCount = _adjLines.where((l) => l.difference != 0).length;
    final unitsOut = _adjLines.where((l) => l.difference < 0).fold<int>(0, (sum, l) => sum + l.difference.abs());
    final unitsIn = _adjLines.where((l) => l.difference > 0).fold<int>(0, (sum, l) => sum + l.difference);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        final journalCard = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Journal preview (on post)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderSubtle),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: const Row(
                        children: [
                          Expanded(flex: 5, child: Text('Account', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                          Expanded(flex: 3, child: Text('Debit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                          Expanded(flex: 3, child: Text('Credit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),

                    // Rows matching Figure 10:
                    // If net loss (netImpact < 0): Dr 5150 Inventory Adjustments, Cr 1300 Inventory
                    // If net surplus: Dr 1300 Inventory, Cr 5150 Inventory Adjustments
                    if (netImpact <= 0) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Expanded(flex: 5, child: Text('5150 Inventory Adjustments', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary))),
                            Expanded(flex: 3, child: Text(_currencyFormat.format(absImpact), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                            const Expanded(flex: 3, child: Text('', textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Expanded(flex: 5, child: Text('1300 Inventory', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary))),
                            const Expanded(flex: 3, child: Text('', textAlign: TextAlign.right)),
                            Expanded(flex: 3, child: Text(_currencyFormat.format(absImpact), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Expanded(flex: 5, child: Text('1300 Inventory', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary))),
                            Expanded(flex: 3, child: Text(_currencyFormat.format(absImpact), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                            const Expanded(flex: 3, child: Text('', textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Expanded(flex: 5, child: Text('5150 Inventory Adjustments', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary))),
                            const Expanded(flex: 3, child: Text('', textAlign: TextAlign.right)),
                            Expanded(flex: 3, child: Text(_currencyFormat.format(absImpact), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );

        final effectCard = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stock effect', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(
                '${_adjLines.length} lines · $itemsChangedCount items changed',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Units out: $unitsOut · Units in: $unitsIn',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Creates $itemsChangedCount rows in the stock ledger (ADJUSTMENT_IN / OUT)',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Action buttons (Figure 10: Save Draft, Post Adjustment)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: () => _submitAdjustment(post: false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Save Draft', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
                  ),
                  ElevatedButton(
                    onPressed: () => _submitAdjustment(post: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                    child: const Text('Post Adjustment', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );

        if (!isDesktop) {
          return Column(
            children: [
              journalCard,
              const SizedBox(height: 16),
              effectCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: journalCard),
            const SizedBox(width: 18),
            Expanded(flex: 4, child: effectCard),
          ],
        );
      },
    );
  }

  // --- Stock Transfer Form Elements ---

  Widget _buildTransferHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 550) {
                return Column(
                  children: [
                    _buildTrfNoField(),
                    const SizedBox(height: 12),
                    _buildTrfDateField(),
                    const SizedBox(height: 12),
                    _buildTrfFromField(),
                    const SizedBox(height: 12),
                    _buildTrfToField(),
                  ],
                );
              }
              if (constraints.maxWidth < 950) {
                final halfWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: halfWidth, child: _buildTrfNoField()),
                    SizedBox(width: halfWidth, child: _buildTrfDateField()),
                    SizedBox(width: halfWidth, child: _buildTrfFromField()),
                    SizedBox(width: halfWidth, child: _buildTrfToField()),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: _buildTrfNoField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _buildTrfDateField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: _buildTrfFromField()),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: _buildTrfToField()),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Notes
          const Text('Notes', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          SizedBox(
            height: 38,
            child: TextField(
              controller: _trfNotesController,
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrfNoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transfer No.', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          height: 38,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(_trfNoController.text, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        ),
      ],
    );
  }

  Widget _buildTrfDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        SizedBox(
          height: 38,
          child: TextField(
            controller: _trfDateController,
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrfFromField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('From Warehouse *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
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
              value: _trfFromWarehouseCode,
              isExpanded: true,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              items: _warehouses.map((w) {
                return DropdownMenuItem(value: w.code, child: Text('${w.code} - ${w.name}'));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _trfFromWarehouseCode = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrfToField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('To Warehouse *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
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
              value: _trfToWarehouseCode,
              isExpanded: true,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              items: _warehouses.map((w) {
                return DropdownMenuItem(value: w.code, child: Text('${w.code} - ${w.name}'));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _trfToWarehouseCode = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferLinesCard() {
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
              const minTableWidth = 800.0;
              final effectiveWidth = constraints.maxWidth < minTableWidth ? minTableWidth : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text('Item *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 6, child: Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Available Qty', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Transfer Qty', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Unit Cost', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 3, child: Text('Transfer Value (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            SizedBox(width: 32),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),

                      // Dynamic Lines
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _trfLines.length,
                        separatorBuilder: (context, _) => const Divider(height: 1, color: AppColors.borderSubtle),
                        itemBuilder: (context, index) {
                          final line = _trfLines[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                // SKU
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: line.sku,
                                        isExpanded: true,
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        items: _availableItems.map((it) {
                                          return DropdownMenuItem(value: it.sku, child: Text(it.sku));
                                        }).toList(),
                                        onChanged: (sku) {
                                          if (sku != null) {
                                            final sel = _availableItems.firstWhere((it) => it.sku == sku);
                                            final avail = sel.getStockForWarehouse(_trfFromWarehouseCode);
                                            setState(() {
                                              _trfLines[index] = StockTransferLine(
                                                itemId: sel.id,
                                                sku: sel.sku,
                                                description: sel.name,
                                                availableQty: avail,
                                                transferQty: 1,
                                                unitCost: sel.avgCost,
                                                transferValue: sel.avgCost,
                                              );
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Description
                                Expanded(
                                  flex: 6,
                                  child: Text(line.description, style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
                                ),

                                // Available Qty at source
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${line.availableQty}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                  ),
                                ),

                                // Transfer Qty input
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: 72,
                                      height: 34,
                                      child: TextFormField(
                                        initialValue: '${line.transferQty}',
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            borderSide: const BorderSide(color: AppColors.border),
                                          ),
                                        ),
                                        onChanged: (val) => _onTransferQtyChanged(index, val),
                                      ),
                                    ),
                                  ),
                                ),

                                // Unit Cost
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _currencyFormat.format(line.unitCost),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                  ),
                                ),

                                // Transfer Value
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    _currencyFormat.format(line.transferValue),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),

                                // Delete
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Color(0xFFDC2626)),
                                    onPressed: () {
                                      setState(() => _trfLines.removeAt(index));
                                    },
                                  ),
                                ),
                              ],
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

          // Quick actions and total value
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: _onAddItemToTransfer,
                      child: const Text('+ Add item', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ),
                    const Text('·', style: TextStyle(color: AppColors.textMuted)),
                    InkWell(
                      onTap: _onScanBarcode,
                      child: const Text('Scan barcode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Total transfer value', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(
                      'AED ${_currencyFormat.format(_trfTotalValue)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferBottomCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isStacked = constraints.maxWidth < 750;

          const info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stock Transfer Impact', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 4),
              Text(
                'Creates TRANSFER_OUT from source warehouse and TRANSFER_IN to destination warehouse.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              SizedBox(height: 2),
              Text(
                'No GL impact occurs as both warehouses share the parent 1300 Inventory asset account.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: () => _submitTransfer(dispatch: false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Save Draft', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
              ),
              ElevatedButton(
                onPressed: () => _submitTransfer(dispatch: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: const Text('Dispatch Transfer', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              ),
            ],
          );

          if (isStacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 16),
                actions,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: info),
              const SizedBox(width: 16),
              actions,
            ],
          );
        },
      ),
    );
  }
}
