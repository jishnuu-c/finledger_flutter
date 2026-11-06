import 'package:flutter/foundation.dart';

/// Physical or logical stock location (Table 38)
@immutable
class Warehouse {
  final int id;
  final String code;
  final String name;
  final String? address;
  final bool isDefault;
  final bool isActive;

  const Warehouse({
    required this.id,
    required this.code,
    required this.name,
    this.address,
    this.isDefault = false,
    this.isActive = true,
  });

  String get displayName => '$code - $name';

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      isDefault: json['is_default'] as bool? ?? (json['isDefault'] as bool? ?? false),
      isActive: json['is_active'] as bool? ?? (json['isActive'] as bool? ?? true),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'address': ?address,
    'is_default': isDefault,
    'is_active': isActive,
  };
}

/// Item Category (Page 33 & 65)
@immutable
class ItemCategory {
  final int id;
  final String name;
  final String? code;

  const ItemCategory({
    required this.id,
    required this.name,
    this.code,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': ?code,
  };
}

/// Stock summary item for Table in Figure 9 (Page 18)
@immutable
class StockSummaryItem {
  final int id;
  final String sku;
  final String name;
  final String category;
  final Map<String, int> warehouseStock; // e.g. {'DXB-WH': 64, 'RUH-WH': 38}
  final int onHand;
  final int reorderLevel;
  final int reorderQty;
  final double avgCost;
  final double stockValue;
  final String status; // 'IN_STOCK', 'LOW', 'OUT_OF_STOCK'
  final String barcode;
  final String unit;

  const StockSummaryItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.warehouseStock,
    required this.onHand,
    required this.reorderLevel,
    this.reorderQty = 0,
    required this.avgCost,
    required this.stockValue,
    required this.status,
    this.barcode = '',
    this.unit = 'Units',
  });

  int getStockForWarehouse(String code) => warehouseStock[code] ?? 0;

  factory StockSummaryItem.fromJson(Map<String, dynamic> json) {
    final whMap = <String, int>{};
    if (json['warehouseStock'] != null) {
      final map = json['warehouseStock'] as Map<String, dynamic>;
      map.forEach((key, value) {
        whMap[key] = (value as num).toInt();
      });
    }

    final onHand = (json['onHand'] as num?)?.toInt() ?? 0;
    final reorder = (json['reorderLevel'] as num?)?.toInt() ?? 0;
    final avgCost = (json['avgCost'] as num?)?.toDouble() ?? 0.0;
    final stockVal = (json['stockValue'] as num?)?.toDouble() ?? (onHand * avgCost);

    String statusStr = json['status'] as String? ?? '';
    if (statusStr.isEmpty) {
      if (onHand <= 0) {
        statusStr = 'OUT_OF_STOCK';
      } else if (onHand <= reorder) {
        statusStr = 'LOW';
      } else {
        statusStr = 'IN_STOCK';
      }
    }

    return StockSummaryItem(
      id: json['id'] as int? ?? 0,
      sku: json['sku'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      warehouseStock: whMap,
      onHand: onHand,
      reorderLevel: reorder,
      reorderQty: (json['reorderQty'] as num?)?.toInt() ?? 0,
      avgCost: avgCost,
      stockValue: stockVal,
      status: statusStr,
      barcode: json['barcode'] as String? ?? '',
      unit: json['unit'] as String? ?? 'Units',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'name': name,
    'category': category,
    'warehouseStock': warehouseStock,
    'onHand': onHand,
    'reorderLevel': reorderLevel,
    'reorderQty': reorderQty,
    'avgCost': avgCost,
    'stockValue': stockValue,
    'status': status,
    'barcode': barcode,
    'unit': unit,
  };
}

/// 4 KPI Cards for Inventory (Figure 9)
@immutable
class StockKpis {
  final double totalStockValue;
  final int activeSkus;
  final int totalWarehouses;
  final int belowReorderCount;
  final double suggestedPoValue;
  final int outOfStockCount;
  final int openQuotationsCount;

  const StockKpis({
    required this.totalStockValue,
    required this.activeSkus,
    required this.totalWarehouses,
    required this.belowReorderCount,
    required this.suggestedPoValue,
    required this.outOfStockCount,
    required this.openQuotationsCount,
  });

  factory StockKpis.fromJson(Map<String, dynamic> json) {
    return StockKpis(
      totalStockValue: (json['totalStockValue'] as num?)?.toDouble() ?? 612500.0,
      activeSkus: (json['activeSkus'] as num?)?.toInt() ?? 148,
      totalWarehouses: (json['totalWarehouses'] as num?)?.toInt() ?? 2,
      belowReorderCount: (json['belowReorderCount'] as num?)?.toInt() ?? 7,
      suggestedPoValue: (json['suggestedPoValue'] as num?)?.toDouble() ?? 84200.0,
      outOfStockCount: (json['outOfStockCount'] as num?)?.toInt() ?? 2,
      openQuotationsCount: (json['openQuotationsCount'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalStockValue': totalStockValue,
    'activeSkus': activeSkus,
    'totalWarehouses': totalWarehouses,
    'belowReorderCount': belowReorderCount,
    'suggestedPoValue': suggestedPoValue,
    'outOfStockCount': outOfStockCount,
    'openQuotationsCount': openQuotationsCount,
  };
}

/// Stock movement / ledger row (Table 40, Page 18 & 66)
@immutable
class StockMovement {
  final int id;
  final int itemId;
  final String sku;
  final String itemName;
  final String warehouseCode;
  final String movementDate;
  final String movementType; // 'OPENING', 'PURCHASE', 'SALE', 'ADJUSTMENT_IN', 'ADJUSTMENT_OUT', 'TRANSFER_IN', 'TRANSFER_OUT'
  final double quantity; // + in / - out
  final double unitCost;
  final double totalCost;
  final double balanceQty;
  final String sourceType; // 'INVOICE', 'BILL', 'ADJUSTMENT', 'TRANSFER', 'OPENING'
  final String sourceRef;

  const StockMovement({
    required this.id,
    required this.itemId,
    required this.sku,
    required this.itemName,
    required this.warehouseCode,
    required this.movementDate,
    required this.movementType,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.balanceQty,
    required this.sourceType,
    required this.sourceRef,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as int? ?? 0,
      itemId: json['itemId'] as int? ?? (json['item_id'] as int? ?? 0),
      sku: json['sku'] as String? ?? '',
      itemName: json['itemName'] as String? ?? (json['item_name'] as String? ?? ''),
      warehouseCode: json['warehouseCode'] as String? ?? (json['warehouse_code'] as String? ?? ''),
      movementDate: json['movementDate'] as String? ?? (json['movement_date'] as String? ?? ''),
      movementType: json['movementType'] as String? ?? (json['movement_type'] as String? ?? ''),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitCost: (json['unitCost'] as num?)?.toDouble() ?? ((json['unit_cost'] as num?)?.toDouble() ?? 0.0),
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? ((json['total_cost'] as num?)?.toDouble() ?? 0.0),
      balanceQty: (json['balanceQty'] as num?)?.toDouble() ?? ((json['balance_qty'] as num?)?.toDouble() ?? 0.0),
      sourceType: json['sourceType'] as String? ?? (json['source_type'] as String? ?? ''),
      sourceRef: json['sourceRef'] as String? ?? (json['source_ref'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'sku': sku,
    'itemName': itemName,
    'warehouseCode': warehouseCode,
    'movementDate': movementDate,
    'movementType': movementType,
    'quantity': quantity,
    'unitCost': unitCost,
    'totalCost': totalCost,
    'balanceQty': balanceQty,
    'sourceType': sourceType,
    'sourceRef': sourceRef,
  };
}

/// Stock Adjustment line (Table 42 & Figure 10)
@immutable
class StockAdjustmentLine {
  final int? id;
  final int itemId;
  final String sku;
  final String description;
  final int systemQty;
  final int countedQty;
  final int difference;
  final double avgCost;
  final double valueImpact;

  const StockAdjustmentLine({
    this.id,
    required this.itemId,
    required this.sku,
    required this.description,
    required this.systemQty,
    required this.countedQty,
    required this.difference,
    required this.avgCost,
    required this.valueImpact,
  });

  StockAdjustmentLine copyWith({
    int? id,
    int? itemId,
    String? sku,
    String? description,
    int? systemQty,
    int? countedQty,
    int? difference,
    double? avgCost,
    double? valueImpact,
  }) {
    final finalSystem = systemQty ?? this.systemQty;
    final finalCounted = countedQty ?? this.countedQty;
    final finalDiff = difference ?? (finalCounted - finalSystem);
    final finalCost = avgCost ?? this.avgCost;
    final finalImpact = valueImpact ?? (finalDiff * finalCost);

    return StockAdjustmentLine(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      systemQty: finalSystem,
      countedQty: finalCounted,
      difference: finalDiff,
      avgCost: finalCost,
      valueImpact: finalImpact,
    );
  }

  factory StockAdjustmentLine.fromJson(Map<String, dynamic> json) {
    final system = (json['system_qty'] as num?)?.toInt() ?? ((json['systemQty'] as num?)?.toInt() ?? 0);
    final counted = (json['counted_qty'] as num?)?.toInt() ?? ((json['countedQty'] as num?)?.toInt() ?? 0);
    final diff = (json['difference_qty'] as num?)?.toInt() ?? ((json['difference'] as num?)?.toInt() ?? (counted - system));
    final cost = (json['unit_cost'] as num?)?.toDouble() ?? ((json['avgCost'] as num?)?.toDouble() ?? 0.0);
    final impact = (json['value_impact'] as num?)?.toDouble() ?? ((json['valueImpact'] as num?)?.toDouble() ?? (diff * cost));

    return StockAdjustmentLine(
      id: json['id'] as int?,
      itemId: json['item_id'] as int? ?? (json['itemId'] as int? ?? 0),
      sku: json['sku'] as String? ?? '',
      description: json['description'] as String? ?? '',
      systemQty: system,
      countedQty: counted,
      difference: diff,
      avgCost: cost,
      valueImpact: impact,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': ?id,
    'item_id': itemId,
    'sku': sku,
    'description': description,
    'system_qty': systemQty,
    'counted_qty': countedQty,
    'difference_qty': difference,
    'unit_cost': avgCost,
    'value_impact': valueImpact,
  };
}

/// Stock Adjustment document (Table 41 & Figure 10)
@immutable
class StockAdjustment {
  final int id;
  final String adjustmentNo;
  final String adjustmentDate;
  final int warehouseId;
  final String warehouseCode;
  final String warehouseName;
  final String reason;
  final String adjustmentAccount;
  final String? notes;
  final double totalValue;
  final String status; // 'DRAFT', 'POSTED', 'VOID'
  final List<StockAdjustmentLine> lines;

  const StockAdjustment({
    required this.id,
    required this.adjustmentNo,
    required this.adjustmentDate,
    required this.warehouseId,
    required this.warehouseCode,
    required this.warehouseName,
    required this.reason,
    required this.adjustmentAccount,
    this.notes,
    required this.totalValue,
    this.status = 'DRAFT',
    required this.lines,
  });

  factory StockAdjustment.fromJson(Map<String, dynamic> json) {
    return StockAdjustment(
      id: json['id'] as int? ?? 0,
      adjustmentNo: json['adjustment_no'] as String? ?? (json['adjustmentNo'] as String? ?? ''),
      adjustmentDate: json['adjustment_date'] as String? ?? (json['adjustmentDate'] as String? ?? ''),
      warehouseId: json['warehouse_id'] as int? ?? (json['warehouseId'] as int? ?? 0),
      warehouseCode: json['warehouseCode'] as String? ?? 'DXB-WH',
      warehouseName: json['warehouseName'] as String? ?? 'Dubai Warehouse',
      reason: json['reason'] as String? ?? 'Stock count',
      adjustmentAccount: json['adjustmentAccount'] as String? ?? '5150 - Inventory Adjustments',
      notes: json['notes'] as String?,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? ((json['totalValue'] as num?)?.toDouble() ?? 0.0),
      status: json['status'] as String? ?? 'DRAFT',
      lines: (json['lines'] as List<dynamic>?)
              ?.map((l) => StockAdjustmentLine.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'adjustment_no': adjustmentNo,
    'adjustment_date': adjustmentDate,
    'warehouse_id': warehouseId,
    'warehouseCode': warehouseCode,
    'warehouseName': warehouseName,
    'reason': reason,
    'adjustmentAccount': adjustmentAccount,
    'notes': ?notes,
    'total_value': totalValue,
    'status': status,
    'lines': lines.map((l) => l.toJson()).toList(),
  };
}

/// Stock Transfer line (Table 44)
@immutable
class StockTransferLine {
  final int? id;
  final int itemId;
  final String sku;
  final String description;
  final int availableQty;
  final int transferQty;
  final double unitCost;
  final double transferValue;

  const StockTransferLine({
    this.id,
    required this.itemId,
    required this.sku,
    required this.description,
    required this.availableQty,
    required this.transferQty,
    required this.unitCost,
    required this.transferValue,
  });

  StockTransferLine copyWith({
    int? id,
    int? itemId,
    String? sku,
    String? description,
    int? availableQty,
    int? transferQty,
    double? unitCost,
    double? transferValue,
  }) {
    final finalQty = transferQty ?? this.transferQty;
    final finalCost = unitCost ?? this.unitCost;
    return StockTransferLine(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      availableQty: availableQty ?? this.availableQty,
      transferQty: finalQty,
      unitCost: finalCost,
      transferValue: transferValue ?? (finalQty * finalCost),
    );
  }

  factory StockTransferLine.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? ((json['transferQty'] as num?)?.toInt() ?? 0);
    final cost = (json['unit_cost'] as num?)?.toDouble() ?? ((json['unitCost'] as num?)?.toDouble() ?? 0.0);
    return StockTransferLine(
      id: json['id'] as int?,
      itemId: json['item_id'] as int? ?? (json['itemId'] as int? ?? 0),
      sku: json['sku'] as String? ?? '',
      description: json['description'] as String? ?? '',
      availableQty: (json['available_qty'] as num?)?.toInt() ?? ((json['availableQty'] as num?)?.toInt() ?? 0),
      transferQty: qty,
      unitCost: cost,
      transferValue: (json['transfer_value'] as num?)?.toDouble() ?? (qty * cost),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': ?id,
    'item_id': itemId,
    'sku': sku,
    'description': description,
    'available_qty': availableQty,
    'quantity': transferQty,
    'unit_cost': unitCost,
    'transfer_value': transferValue,
  };
}

/// Stock Transfer document (Table 43)
@immutable
class StockTransfer {
  final int id;
  final String transferNo;
  final String transferDate;
  final int fromWarehouseId;
  final String fromWarehouseCode;
  final int toWarehouseId;
  final String toWarehouseCode;
  final String status; // 'DRAFT', 'IN_TRANSIT', 'RECEIVED', 'VOID'
  final String? notes;
  final double totalValue;
  final List<StockTransferLine> lines;

  const StockTransfer({
    required this.id,
    required this.transferNo,
    required this.transferDate,
    required this.fromWarehouseId,
    required this.fromWarehouseCode,
    required this.toWarehouseId,
    required this.toWarehouseCode,
    this.status = 'DRAFT',
    this.notes,
    required this.totalValue,
    required this.lines,
  });

  factory StockTransfer.fromJson(Map<String, dynamic> json) {
    return StockTransfer(
      id: json['id'] as int? ?? 0,
      transferNo: json['transfer_no'] as String? ?? (json['transferNo'] as String? ?? ''),
      transferDate: json['transfer_date'] as String? ?? (json['transferDate'] as String? ?? ''),
      fromWarehouseId: json['from_warehouse_id'] as int? ?? (json['fromWarehouseId'] as int? ?? 0),
      fromWarehouseCode: json['fromWarehouseCode'] as String? ?? 'DXB-WH',
      toWarehouseId: json['to_warehouse_id'] as int? ?? (json['toWarehouseId'] as int? ?? 0),
      toWarehouseCode: json['toWarehouseCode'] as String? ?? 'RUH-WH',
      status: json['status'] as String? ?? 'DRAFT',
      notes: json['notes'] as String?,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? ((json['totalValue'] as num?)?.toDouble() ?? 0.0),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((l) => StockTransferLine.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'transfer_no': transferNo,
    'transfer_date': transferDate,
    'from_warehouse_id': fromWarehouseId,
    'fromWarehouseCode': fromWarehouseCode,
    'to_warehouse_id': toWarehouseId,
    'toWarehouseCode': toWarehouseCode,
    'status': status,
    'notes': ?notes,
    'total_value': totalValue,
    'lines': lines.map((l) => l.toJson()).toList(),
  };
}
