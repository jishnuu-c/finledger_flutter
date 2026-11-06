import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/inventory_models.dart';
import '../../data/services/inventory_service.dart';

class StockLedgerModal extends StatefulWidget {
  final StockSummaryItem item;
  final InventoryService inventoryService;

  const StockLedgerModal({
    super.key,
    required this.item,
    required this.inventoryService,
  });

  static Future<void> show(
    BuildContext context, {
    required StockSummaryItem item,
    required InventoryService inventoryService,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => StockLedgerModal(
        item: item,
        inventoryService: inventoryService,
      ),
    );
  }

  @override
  State<StockLedgerModal> createState() => _StockLedgerModalState();
}

class _StockLedgerModalState extends State<StockLedgerModal> {
  late Future<List<StockMovement>> _movementsFuture;
  String _selectedWarehouse = 'All';
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  void _loadMovements() {
    setState(() {
      _movementsFuture = widget.inventoryService.getItemMovements(
        widget.item.id,
        warehouseCode: _selectedWarehouse == 'All' ? null : _selectedWarehouse,
      );
    });
  }

  Color _getMovementColor(String type) {
    if (type.contains('IN') || type == 'PURCHASE' || type == 'OPENING') {
      return const Color(0xFF16A34A);
    }
    if (type.contains('OUT') || type == 'SALE') {
      return const Color(0xFFDC2626);
    }
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isMobile ? screenWidth - 24 : 960,
        height: isMobile ? screenHeight * 0.85 : 600,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Text(
                                widget.item.sku,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.item.name,
                                style: TextStyle(
                                  fontSize: isMobile ? 15 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${widget.item.category}  ·  Reorder Level: ${widget.item.reorderLevel} ${widget.item.unit}  ·  Avg Cost: AED ${_currencyFormat.format(widget.item.avgCost)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.borderSubtle),
              const SizedBox(height: 14),

              // Summary Stats + Warehouse Filter
              if (isMobile) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMiniBadge('Total On Hand', '${widget.item.onHand} ${widget.item.unit}', const Color(0xFF1E293B)),
                      const SizedBox(width: 8),
                      _buildMiniBadge('Dubai WH', '${widget.item.getStockForWarehouse('DXB-WH')} ${widget.item.unit}', const Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      _buildMiniBadge('Riyadh WH', '${widget.item.getStockForWarehouse('RUH-WH')} ${widget.item.unit}', const Color(0xFF0D9488)),
                      const SizedBox(width: 8),
                      _buildMiniBadge('Total Value', 'AED ${_currencyFormat.format(widget.item.stockValue)}', const Color(0xFF16A34A)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedWarehouse,
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All Warehouses', style: TextStyle(fontSize: 12.5))),
                          DropdownMenuItem(value: 'DXB-WH', child: Text('Dubai WH (DXB-WH)', style: TextStyle(fontSize: 12.5))),
                          DropdownMenuItem(value: 'RUH-WH', child: Text('Riyadh WH (RUH-WH)', style: TextStyle(fontSize: 12.5))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedWarehouse = val);
                            _loadMovements();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMiniBadge('Total On Hand', '${widget.item.onHand} ${widget.item.unit}', const Color(0xFF1E293B)),
                            const SizedBox(width: 12),
                            _buildMiniBadge('Dubai WH', '${widget.item.getStockForWarehouse('DXB-WH')} ${widget.item.unit}', const Color(0xFF2563EB)),
                            const SizedBox(width: 12),
                            _buildMiniBadge('Riyadh WH', '${widget.item.getStockForWarehouse('RUH-WH')} ${widget.item.unit}', const Color(0xFF0D9488)),
                            const SizedBox(width: 12),
                            _buildMiniBadge('Total Value', 'AED ${_currencyFormat.format(widget.item.stockValue)}', const Color(0xFF16A34A)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedWarehouse,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Warehouses', style: TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'DXB-WH', child: Text('Dubai WH (DXB-WH)', style: TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'RUH-WH', child: Text('Riyadh WH (RUH-WH)', style: TextStyle(fontSize: 12.5))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedWarehouse = val);
                              _loadMovements();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Ledger Table
              Expanded(
                child: FutureBuilder<List<StockMovement>>(
                  future: _movementsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final movements = snapshot.data ?? [];
                    if (movements.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text('No stock movements recorded for this filter.', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const minTableWidth = 840.0;
                          final effectiveWidth = constraints.maxWidth < minTableWidth
                              ? minTableWidth
                              : constraints.maxWidth;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: effectiveWidth,
                              child: Column(
                                children: [
                                  // Header Row
                                  Container(
                                    color: const Color(0xFFF8FAFC),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    child: const Row(
                                      children: [
                                        Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                        Expanded(flex: 2, child: Text('Type', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                        Expanded(flex: 3, child: Text('Reference #', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                        Expanded(flex: 2, child: Text('Warehouse', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                        Expanded(flex: 2, child: Text('Qty In/Out', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                        Expanded(flex: 2, child: Text('Balance Qty', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                        Expanded(flex: 2, child: Text('Unit Cost', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                        Expanded(flex: 3, child: Text('Total Cost (AED)', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1, color: AppColors.borderSubtle),

                                  // Rows
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: movements.length,
                                      separatorBuilder: (context, _) => const Divider(height: 1, color: AppColors.borderSubtle),
                                      itemBuilder: (context, index) {
                                        final mov = movements[index];
                                        final isPositive = mov.quantity > 0;
                                        final color = _getMovementColor(mov.movementType);

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          child: Row(
                                            children: [
                                              Expanded(flex: 2, child: Text(mov.movementDate, style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary))),
                                              Expanded(
                                                flex: 2,
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: color.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      mov.movementType,
                                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(flex: 3, child: Text(mov.sourceRef, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF2563EB)))),
                                              Expanded(flex: 2, child: Text(mov.warehouseCode, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${isPositive ? '+' : ''}${mov.quantity.toStringAsFixed(0)}',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  mov.balanceQty.toStringAsFixed(0),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  _currencyFormat.format(mov.unitCost),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  _currencyFormat.format(mov.totalCost.abs()),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: mov.totalCost < 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Close', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildMiniBadge(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
