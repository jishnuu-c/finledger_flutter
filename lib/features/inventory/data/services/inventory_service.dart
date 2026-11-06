import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/inventory_models.dart';

class InventoryService {
  final DioClient? dioClient;
  final Dio? _dio;

  InventoryService({this.dioClient, Dio? dio}) : _dio = dio ?? dioClient?.dio;

  // Warehouses (Table 38)
  static final List<Warehouse> _defaultWarehouses = [
    const Warehouse(
      id: 1,
      code: 'DXB-WH',
      name: 'Dubai Warehouse',
      address: 'Al Quoz Industrial Area 3, Dubai, UAE',
      isDefault: true,
    ),
    const Warehouse(
      id: 2,
      code: 'RUH-WH',
      name: 'Riyadh Warehouse',
      address: 'Al Sulay Logistics Park, Riyadh, KSA',
      isDefault: false,
    ),
  ];

  // Categories (Page 33 & 65)
  static final List<ItemCategory> _defaultCategories = [
    const ItemCategory(id: 1, name: 'Air Purifiers', code: 'AIR'),
    const ItemCategory(id: 2, name: 'Filters', code: 'FLT'),
    const ItemCategory(id: 3, name: 'Duct Systems', code: 'DCT'),
    const ItemCategory(id: 4, name: 'Accessories', code: 'ACC'),
  ];

  // Stock summary items from Figure 9 (Page 18)
  static final List<StockSummaryItem> _defaultStockItems = [
    const StockSummaryItem(
      id: 1,
      sku: 'BSB-AP500',
      name: 'HEPA Air Purifier 500',
      category: 'Air Purifiers',
      warehouseStock: {'DXB-WH': 64, 'RUH-WH': 38},
      onHand: 102,
      reorderLevel: 40,
      reorderQty: 50,
      avgCost: 2150.00,
      stockValue: 219300.00,
      status: 'IN_STOCK',
      barcode: '629104800500',
    ),
    const StockSummaryItem(
      id: 2,
      sku: 'BSB-AP900',
      name: 'HEPA Air Purifier 900 Pro',
      category: 'Air Purifiers',
      warehouseStock: {'DXB-WH': 12, 'RUH-WH': 6},
      onHand: 18,
      reorderLevel: 20,
      reorderQty: 25,
      avgCost: 3480.00,
      stockValue: 62640.00,
      status: 'LOW',
      barcode: '629104800900',
    ),
    const StockSummaryItem(
      id: 3,
      sku: 'BSB-FLT-H13',
      name: 'H13 Replacement Filter',
      category: 'Filters',
      warehouseStock: {'DXB-WH': 420, 'RUH-WH': 260},
      onHand: 680,
      reorderLevel: 300,
      reorderQty: 400,
      avgCost: 185.00,
      stockValue: 125800.00,
      status: 'IN_STOCK',
      barcode: '629104800130',
    ),
    const StockSummaryItem(
      id: 4,
      sku: 'BSB-FLT-CRB',
      name: 'Activated Carbon Filter',
      category: 'Filters',
      warehouseStock: {'DXB-WH': 35, 'RUH-WH': 10},
      onHand: 45,
      reorderLevel: 120,
      reorderQty: 100,
      avgCost: 95.00,
      stockValue: 4275.00,
      status: 'LOW',
      barcode: '629104800140',
    ),
    const StockSummaryItem(
      id: 5,
      sku: 'BSB-UV-200',
      name: 'UV-C Duct Sterilizer',
      category: 'Duct Systems',
      warehouseStock: {'DXB-WH': 0, 'RUH-WH': 0},
      onHand: 0,
      reorderLevel: 10,
      reorderQty: 20,
      avgCost: 1920.00,
      stockValue: 0.00,
      status: 'OUT_OF_STOCK',
      barcode: '629104800200',
    ),
    const StockSummaryItem(
      id: 6,
      sku: 'BSB-SNS-01',
      name: 'Indoor Air Quality Sensor',
      category: 'Accessories',
      warehouseStock: {'DXB-WH': 88, 'RUH-WH': 52},
      onHand: 140,
      reorderLevel: 50,
      reorderQty: 60,
      avgCost: 240.00,
      stockValue: 33600.00,
      status: 'IN_STOCK',
      barcode: '629104800010',
    ),
    const StockSummaryItem(
      id: 7,
      sku: 'BSB-MNT-WL',
      name: 'Wall-mount Bracket Kit',
      category: 'Accessories',
      warehouseStock: {'DXB-WH': 150, 'RUH-WH': 95},
      onHand: 245,
      reorderLevel: 60,
      reorderQty: 100,
      avgCost: 38.00,
      stockValue: 9310.00,
      status: 'IN_STOCK',
      barcode: '629104800990',
    ),
    const StockSummaryItem(
      id: 8,
      sku: 'BSB-AP300',
      name: 'Compact Purifier 300',
      category: 'Air Purifiers',
      warehouseStock: {'DXB-WH': 4, 'RUH-WH': 0},
      onHand: 4,
      reorderLevel: 25,
      reorderQty: 30,
      avgCost: 1150.00,
      stockValue: 4600.00,
      status: 'LOW',
      barcode: '629104800300',
    ),
  ];

  // In-memory collections for stateful UI manipulation
  final List<StockSummaryItem> _stockItems = List.from(_defaultStockItems);
  final List<StockAdjustment> _adjustments = [];
  final List<StockTransfer> _transfers = [];

  // Default Stock movements for Stock Ledger modal (Page 18 & 66)
  static final List<StockMovement> _defaultMovements = [
    const StockMovement(
      id: 101,
      itemId: 1,
      sku: 'BSB-AP500',
      itemName: 'HEPA Air Purifier 500',
      warehouseCode: 'DXB-WH',
      movementDate: '01-Oct-2026',
      movementType: 'OPENING',
      quantity: 50,
      unitCost: 2150.00,
      totalCost: 107500.00,
      balanceQty: 50,
      sourceType: 'OPENING',
      sourceRef: 'OPN-2026-001',
    ),
    const StockMovement(
      id: 102,
      itemId: 1,
      sku: 'BSB-AP500',
      itemName: 'HEPA Air Purifier 500',
      warehouseCode: 'DXB-WH',
      movementDate: '10-Oct-2026',
      movementType: 'PURCHASE',
      quantity: 30,
      unitCost: 2150.00,
      totalCost: 64500.00,
      balanceQty: 80,
      sourceType: 'BILL',
      sourceRef: 'BILL-2026-0182',
    ),
    const StockMovement(
      id: 103,
      itemId: 1,
      sku: 'BSB-AP500',
      itemName: 'HEPA Air Purifier 500',
      warehouseCode: 'DXB-WH',
      movementDate: '18-Oct-2026',
      movementType: 'TRANSFER_OUT',
      quantity: -10,
      unitCost: 2150.00,
      totalCost: -21500.00,
      balanceQty: 70,
      sourceType: 'TRANSFER',
      sourceRef: 'TRF-2026-0005',
    ),
    const StockMovement(
      id: 104,
      itemId: 1,
      sku: 'BSB-AP500',
      itemName: 'HEPA Air Purifier 500',
      warehouseCode: 'RUH-WH',
      movementDate: '19-Oct-2026',
      movementType: 'TRANSFER_IN',
      quantity: 10,
      unitCost: 2150.00,
      totalCost: 21500.00,
      balanceQty: 38,
      sourceType: 'TRANSFER',
      sourceRef: 'TRF-2026-0005',
    ),
    const StockMovement(
      id: 105,
      itemId: 1,
      sku: 'BSB-AP500',
      itemName: 'HEPA Air Purifier 500',
      warehouseCode: 'DXB-WH',
      movementDate: '29-Oct-2026',
      movementType: 'SALE',
      quantity: -5,
      unitCost: 2150.00,
      totalCost: -10750.00,
      balanceQty: 65,
      sourceType: 'INVOICE',
      sourceRef: 'INV-2026-0412',
    ),
    const StockMovement(
      id: 106,
      itemId: 1,
      sku: 'BSB-AP500',
      itemName: 'HEPA Air Purifier 500',
      warehouseCode: 'DXB-WH',
      movementDate: '30-Oct-2026',
      movementType: 'ADJUSTMENT_OUT',
      quantity: -1,
      unitCost: 2150.00,
      totalCost: -2150.00,
      balanceQty: 64,
      sourceType: 'ADJUSTMENT',
      sourceRef: 'ADJ-2026-0021',
    ),
    // H13 movements
    const StockMovement(
      id: 107,
      itemId: 3,
      sku: 'BSB-FLT-H13',
      itemName: 'H13 Replacement Filter',
      warehouseCode: 'DXB-WH',
      movementDate: '01-Oct-2026',
      movementType: 'OPENING',
      quantity: 450,
      unitCost: 185.00,
      totalCost: 83250.00,
      balanceQty: 450,
      sourceType: 'OPENING',
      sourceRef: 'OPN-2026-001',
    ),
    const StockMovement(
      id: 108,
      itemId: 3,
      sku: 'BSB-FLT-H13',
      itemName: 'H13 Replacement Filter',
      warehouseCode: 'DXB-WH',
      movementDate: '25-Oct-2026',
      movementType: 'SALE',
      quantity: -22,
      unitCost: 185.00,
      totalCost: -4070.00,
      balanceQty: 428,
      sourceType: 'INVOICE',
      sourceRef: 'INV-2026-0408',
    ),
    const StockMovement(
      id: 109,
      itemId: 3,
      sku: 'BSB-FLT-H13',
      itemName: 'H13 Replacement Filter',
      warehouseCode: 'DXB-WH',
      movementDate: '30-Oct-2026',
      movementType: 'ADJUSTMENT_OUT',
      quantity: -8,
      unitCost: 185.00,
      totalCost: -1480.00,
      balanceQty: 420,
      sourceType: 'ADJUSTMENT',
      sourceRef: 'ADJ-2026-0021',
    ),
  ];

  final List<StockMovement> _movements = List.from(_defaultMovements);

  /// Fetch Warehouses (GET /api/v1/warehouses)
  Future<List<Warehouse>> getWarehouses() async {
    try {
      final response = await _dio?.get(Endpoints.warehouses);
      if (response != null && response.data != null) {
        final list = response.data is List ? response.data as List : response.data['data'] as List;
        return list.map((json) => Warehouse.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback to local default warehouses
    }
    return _defaultWarehouses;
  }

  /// Fetch Categories (GET /api/v1/item-categories)
  Future<List<ItemCategory>> getCategories() async {
    try {
      final response = await _dio?.get('/item-categories');
      if (response != null && response.data != null) {
        final list = response.data is List ? response.data as List : response.data['data'] as List;
        return list.map((json) => ItemCategory.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultCategories;
  }

  /// Fetch 4 KPI Cards (Figure 9)
  Future<StockKpis> getStockKpis() async {
    try {
      final response = await _dio?.get('/items/stock-kpis');
      if (response != null && response.data != null) {
        return StockKpis.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Return Figure 9 KPIs
    }
    return const StockKpis(
      totalStockValue: 612500.0,
      activeSkus: 148,
      totalWarehouses: 2,
      belowReorderCount: 7,
      suggestedPoValue: 84200.0,
      outOfStockCount: 2,
      openQuotationsCount: 1,
    );
  }

  /// Fetch Stock Summary (GET /api/v1/items/stock-summary)
  Future<List<StockSummaryItem>> getStockSummary({
    String? search,
    String? category,
    String? warehouseCode,
    String? status,
  }) async {
    try {
      final response = await _dio?.get(
        Endpoints.itemStockSummary,
        queryParameters: {
          'search': ?search,
          'category': ?category,
          'warehouseId': ?warehouseCode,
          'status': ?status,
        },
      );
      if (response != null && response.data != null) {
        final list = response.data is List ? response.data as List : response.data['data'] as List;
        return list.map((json) => StockSummaryItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback to local data
    }

    var result = List<StockSummaryItem>.from(_stockItems);

    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      result = result.where((item) {
        return item.sku.toLowerCase().contains(query) ||
            item.name.toLowerCase().contains(query) ||
            item.barcode.contains(query);
      }).toList();
    }

    if (category != null && category.isNotEmpty && category != 'All categories') {
      result = result.where((item) => item.category == category).toList();
    }

    if (warehouseCode != null && warehouseCode.isNotEmpty && warehouseCode != 'All warehouses') {
      result = result.where((item) => (item.warehouseStock[warehouseCode] ?? 0) > 0 || item.onHand == 0).toList();
    }

    if (status != null && status.isNotEmpty && status != 'Stock status' && status != 'All') {
      final normalizedStatus = status.replaceAll(' ', '_').toUpperCase();
      result = result.where((item) => item.status == normalizedStatus || item.status.contains(normalizedStatus)).toList();
    }

    return result;
  }

  /// Fetch movements / Stock Ledger for an item (GET /api/v1/items/{id}/movements - Page 18)
  Future<List<StockMovement>> getItemMovements(int itemId, {String? warehouseCode}) async {
    try {
      final response = await _dio?.get(
        '/items/$itemId/movements',
        queryParameters: {
          'warehouseId': ?warehouseCode,
        },
      );
      if (response != null && response.data != null) {
        final list = response.data is List ? response.data as List : response.data['data'] as List;
        return list.map((json) => StockMovement.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback
    }

    return _movements.where((m) {
      if (m.itemId != itemId) return false;
      if (warehouseCode != null && warehouseCode.isNotEmpty && warehouseCode != 'All') {
        return m.warehouseCode == warehouseCode;
      }
      return true;
    }).toList();
  }

  /// Get live stock balances for all items in a warehouse (GET /api/v1/stock-balances?warehouseId=)
  Future<List<StockSummaryItem>> getStockBalancesForWarehouse(String warehouseCode) async {
    try {
      final response = await _dio?.get(
        Endpoints.stockBalances,
        queryParameters: {'warehouseId': warehouseCode},
      );
      if (response != null && response.data != null) {
        final list = response.data is List ? response.data as List : response.data['data'] as List;
        return list.map((json) => StockSummaryItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback
    }

    return List<StockSummaryItem>.from(_stockItems);
  }

  /// Find item by barcode or exact SKU
  Future<StockSummaryItem?> findItemByBarcode(String code) async {
    final query = code.trim().toLowerCase();
    for (final item in _stockItems) {
      if (item.barcode.toLowerCase() == query || item.sku.toLowerCase() == query) {
        return item;
      }
    }
    return null;
  }

  /// Create and optionally post stock adjustment (POST /api/v1/stock-adjustments & /post)
  Future<StockAdjustment> createStockAdjustment(
    StockAdjustment adjustment, {
    bool postImmediately = false,
  }) async {
    if (adjustment.lines.isEmpty) {
      throw Exception('Adjustment must have at least one line item.');
    }

    try {
      final endpoint = postImmediately
          ? '${Endpoints.stockAdjustments}/post'
          : Endpoints.stockAdjustments;
      final response = await _dio?.post(
        endpoint,
        data: adjustment.toJson(),
      );
      if (response != null && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['data'] ?? response.data)
            : response.data;
        return StockAdjustment.fromJson(data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback local update
    }

    final finalStatus = postImmediately ? 'POSTED' : adjustment.status;
    final saved = StockAdjustment(
      id: adjustment.id == 0 ? (_adjustments.length + 1) : adjustment.id,
      adjustmentNo: adjustment.adjustmentNo.isNotEmpty
          ? adjustment.adjustmentNo
          : 'ADJ-2026-0021',
      adjustmentDate: adjustment.adjustmentDate,
      warehouseId: adjustment.warehouseId,
      warehouseCode: adjustment.warehouseCode,
      warehouseName: adjustment.warehouseName,
      reason: adjustment.reason,
      adjustmentAccount: adjustment.adjustmentAccount,
      notes: adjustment.notes,
      totalValue: adjustment.totalValue,
      status: finalStatus,
      lines: adjustment.lines,
    );

    _adjustments.add(saved);

    // If posted, update local stock items and movements
    if (finalStatus == 'POSTED') {
      for (final line in saved.lines) {
        final itemIndex = _stockItems.indexWhere((it) => it.id == line.itemId || it.sku == line.sku);
        if (itemIndex != -1) {
          final it = _stockItems[itemIndex];
          final currentMap = Map<String, int>.from(it.warehouseStock);
          currentMap[saved.warehouseCode] = line.countedQty;
          final newOnHand = currentMap.values.fold<int>(0, (sum, val) => sum + val);

          String newStatus = it.status;
          if (newOnHand <= 0) {
            newStatus = 'OUT_OF_STOCK';
          } else if (newOnHand <= it.reorderLevel) {
            newStatus = 'LOW';
          } else {
            newStatus = 'IN_STOCK';
          }

          _stockItems[itemIndex] = StockSummaryItem(
            id: it.id,
            sku: it.sku,
            name: it.name,
            category: it.category,
            warehouseStock: currentMap,
            onHand: newOnHand,
            reorderLevel: it.reorderLevel,
            reorderQty: it.reorderQty,
            avgCost: it.avgCost,
            stockValue: newOnHand * it.avgCost,
            status: newStatus,
            barcode: it.barcode,
            unit: it.unit,
          );

          // Add movement to ledger
          if (line.difference != 0) {
            _movements.add(
              StockMovement(
                id: _movements.length + 1,
                itemId: it.id,
                sku: it.sku,
                itemName: it.name,
                warehouseCode: saved.warehouseCode,
                movementDate: saved.adjustmentDate,
                movementType: line.difference > 0 ? 'ADJUSTMENT_IN' : 'ADJUSTMENT_OUT',
                quantity: line.difference.toDouble(),
                unitCost: line.avgCost,
                totalCost: line.valueImpact,
                balanceQty: line.countedQty.toDouble(),
                sourceType: 'ADJUSTMENT',
                sourceRef: saved.adjustmentNo,
              ),
            );
          }
        }
      }
    }

    return saved;
  }

  /// Create and optionally dispatch stock transfer (POST /api/v1/stock-transfers)
  Future<StockTransfer> createStockTransfer(
    StockTransfer transfer, {
    bool dispatchImmediately = false,
  }) async {
    if (transfer.fromWarehouseCode == transfer.toWarehouseCode) {
      throw Exception('Source and destination warehouses cannot be the same.');
    }
    if (transfer.lines.isEmpty) {
      throw Exception('Transfer must have at least one line item.');
    }

    try {
      final endpoint = dispatchImmediately
          ? '${Endpoints.stockTransfers}/dispatch'
          : Endpoints.stockTransfers;
      final response = await _dio?.post(
        endpoint,
        data: transfer.toJson(),
      );
      if (response != null && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['data'] ?? response.data)
            : response.data;
        return StockTransfer.fromJson(data as Map<String, dynamic>);
      }
    } catch (_) {
      // Local fallback
    }

    final finalStatus = dispatchImmediately ? 'IN_TRANSIT' : transfer.status;
    final saved = StockTransfer(
      id: transfer.id == 0 ? (_transfers.length + 1) : transfer.id,
      transferNo: transfer.transferNo.isNotEmpty ? transfer.transferNo : 'TRF-2026-0009',
      transferDate: transfer.transferDate,
      fromWarehouseId: transfer.fromWarehouseId,
      fromWarehouseCode: transfer.fromWarehouseCode,
      toWarehouseId: transfer.toWarehouseId,
      toWarehouseCode: transfer.toWarehouseCode,
      status: finalStatus,
      notes: transfer.notes,
      totalValue: transfer.totalValue,
      lines: transfer.lines,
    );

    _transfers.add(saved);

    // If dispatched, update stock
    if (finalStatus == 'IN_TRANSIT' || finalStatus == 'RECEIVED') {
      for (final line in saved.lines) {
        final itemIndex = _stockItems.indexWhere((it) => it.id == line.itemId || it.sku == line.sku);
        if (itemIndex != -1) {
          final it = _stockItems[itemIndex];
          final currentMap = Map<String, int>.from(it.warehouseStock);
          final fromCurrent = currentMap[saved.fromWarehouseCode] ?? 0;
          currentMap[saved.fromWarehouseCode] = (fromCurrent - line.transferQty).clamp(0, 999999);

          if (finalStatus == 'RECEIVED') {
            final toCurrent = currentMap[saved.toWarehouseCode] ?? 0;
            currentMap[saved.toWarehouseCode] = toCurrent + line.transferQty;
          }

          final newOnHand = currentMap.values.fold<int>(0, (sum, val) => sum + val);
          _stockItems[itemIndex] = StockSummaryItem(
            id: it.id,
            sku: it.sku,
            name: it.name,
            category: it.category,
            warehouseStock: currentMap,
            onHand: newOnHand,
            reorderLevel: it.reorderLevel,
            reorderQty: it.reorderQty,
            avgCost: it.avgCost,
            stockValue: newOnHand * it.avgCost,
            status: newOnHand <= 0 ? 'OUT_OF_STOCK' : (newOnHand <= it.reorderLevel ? 'LOW' : 'IN_STOCK'),
            barcode: it.barcode,
            unit: it.unit,
          );
        }
      }
    }

    return saved;
  }
}
