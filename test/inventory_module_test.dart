import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finledger/features/inventory/data/models/inventory_models.dart';
import 'package:finledger/features/inventory/data/services/inventory_service.dart';
import 'package:finledger/features/inventory/presentation/items_and_stock_screen.dart';
import 'package:finledger/features/inventory/presentation/stock_adjustment_transfer_screen.dart';
import 'package:finledger/features/inventory/presentation/widgets/stock_status_chip.dart';

void main() {
  group('Inventory Models & Service Tests', () {
    test('Default stock summary matches Figure 9 (Page 18)', () async {
      final service = InventoryService();
      final items = await service.getStockSummary();
      final kpis = await service.getStockKpis();

      // Check KPIs
      expect(kpis.totalStockValue, 612500.0);
      expect(kpis.activeSkus, 148);
      expect(kpis.totalWarehouses, 2);
      expect(kpis.belowReorderCount, 7);
      expect(kpis.suggestedPoValue, 84200.0);
      expect(kpis.outOfStockCount, 2);
      expect(kpis.openQuotationsCount, 1);

      // Verify Row 1: BSB-AP500
      final ap500 = items.firstWhere((it) => it.sku == 'BSB-AP500');
      expect(ap500.name, 'HEPA Air Purifier 500');
      expect(ap500.category, 'Air Purifiers');
      expect(ap500.warehouseStock['DXB-WH'], 64);
      expect(ap500.warehouseStock['RUH-WH'], 38);
      expect(ap500.onHand, 102);
      expect(ap500.reorderLevel, 40);
      expect(ap500.avgCost, 2150.0);
      expect(ap500.stockValue, 219300.0);
      expect(ap500.status, 'IN_STOCK');

      // Verify Row 2: BSB-AP900 (Low)
      final ap900 = items.firstWhere((it) => it.sku == 'BSB-AP900');
      expect(ap900.onHand, 18);
      expect(ap900.reorderLevel, 20);
      expect(ap900.status, 'LOW');

      // Verify Row 5: BSB-UV-200 (Out of stock)
      final uv200 = items.firstWhere((it) => it.sku == 'BSB-UV-200');
      expect(uv200.onHand, 0);
      expect(uv200.stockValue, 0.0);
      expect(uv200.status, 'OUT_OF_STOCK');
    });

    test('Filtering stock summary by search, category, and status works properly', () async {
      final service = InventoryService();

      // Search
      final searchResults = await service.getStockSummary(search: 'Sensor');
      expect(searchResults.length, 1);
      expect(searchResults.first.sku, 'BSB-SNS-01');

      // Category filter
      final filterCat = await service.getStockSummary(category: 'Filters');
      expect(filterCat.length, 2);
      expect(filterCat.every((it) => it.category == 'Filters'), isTrue);

      // Status filter
      final lowItems = await service.getStockSummary(status: 'Low');
      expect(lowItems.every((it) => it.status == 'LOW'), isTrue);
    });

    test('Stock ledger movements return running balance for item (Page 18)', () async {
      final service = InventoryService();
      final movements = await service.getItemMovements(1); // BSB-AP500

      expect(movements.isNotEmpty, isTrue);
      expect(movements.first.movementType, 'OPENING');
      expect(movements.first.balanceQty, 50.0);

      // Check warehouse filter
      final dxbMovements = await service.getItemMovements(1, warehouseCode: 'DXB-WH');
      expect(dxbMovements.every((m) => m.warehouseCode == 'DXB-WH'), isTrue);
    });

    test('Stock Adjustment calculations and posting update stock ledger (Figure 10)', () async {
      final service = InventoryService();

      // Lines from Figure 10:
      // Line 1: H13 (-8, impact -1480.00)
      // Line 2: Sensor (+1, impact +240.00)
      // Line 3: HEPA 500 (-1, impact -2150.00)
      // Line 4: Bracket (0, impact 0.00)
      final lines = [
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
      ];

      final netImpact = lines.fold<double>(0.0, (sum, l) => sum + l.valueImpact);
      expect(netImpact, -3390.00);

      final adjustment = StockAdjustment(
        id: 0,
        adjustmentNo: 'ADJ-2026-0021',
        adjustmentDate: '30-Oct-2026',
        warehouseId: 1,
        warehouseCode: 'DXB-WH',
        warehouseName: 'Dubai Warehouse',
        reason: 'Stock count',
        adjustmentAccount: '5150 - Inventory Adjustments',
        totalValue: netImpact,
        lines: lines,
      );

      final posted = await service.createStockAdjustment(adjustment, postImmediately: true);
      expect(posted.status, 'POSTED');

      // Check that stock was updated
      final updatedItems = await service.getStockSummary();
      final updatedAp500 = updatedItems.firstWhere((it) => it.sku == 'BSB-AP500');
      expect(updatedAp500.warehouseStock['DXB-WH'], 63);
    });

    test('Stock Transfer validates same warehouse and updates stock', () async {
      final service = InventoryService();

      // Same warehouse throws exception
      expect(
        () async => await service.createStockTransfer(
          const StockTransfer(
            id: 0,
            transferNo: 'TRF-TEST',
            transferDate: '30-Oct-2026',
            fromWarehouseId: 1,
            fromWarehouseCode: 'DXB-WH',
            toWarehouseId: 1,
            toWarehouseCode: 'DXB-WH',
            totalValue: 100.0,
            lines: [
              StockTransferLine(
                itemId: 1,
                sku: 'BSB-AP500',
                description: 'HEPA 500',
                availableQty: 64,
                transferQty: 5,
                unitCost: 2150.0,
                transferValue: 10750.0,
              ),
            ],
          ),
        ),
        throwsA(isA<Exception>()),
      );

      // Valid transfer
      final transfer = await service.createStockTransfer(
        const StockTransfer(
          id: 0,
          transferNo: 'TRF-2026-0009',
          transferDate: '30-Oct-2026',
          fromWarehouseId: 1,
          fromWarehouseCode: 'DXB-WH',
          toWarehouseId: 2,
          toWarehouseCode: 'RUH-WH',
          totalValue: 21500.0,
          lines: [
            StockTransferLine(
              itemId: 1,
              sku: 'BSB-AP500',
              description: 'HEPA Air Purifier 500',
              availableQty: 64,
              transferQty: 10,
              unitCost: 2150.0,
              transferValue: 21500.0,
            ),
          ],
        ),
        dispatchImmediately: true,
      );

      expect(transfer.status, 'IN_TRANSIT');
    });

    test('Barcode lookup finds matching product SKU', () async {
      final service = InventoryService();
      final found = await service.findItemByBarcode('629104800130');
      expect(found, isNotNull);
      expect(found!.sku, 'BSB-FLT-H13');
    });
  });

  group('Inventory Widget Integration Tests', () {
    testWidgets('ItemsAndStockScreen renders 4 KPI cards, filters, and stock table (Figure 9)', (tester) async {
      final service = InventoryService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: ItemsAndStockScreen(inventoryService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Check Breadcrumbs & Title
      expect(find.text('Items & Stock'), findsWidgets);

      // Check 4 KPI Cards
      expect(find.text('Total stock value'), findsOneWidget);
      expect(find.text('AED 612,500'), findsOneWidget);
      expect(find.text('Active SKUs'), findsOneWidget);
      expect(find.text('148'), findsOneWidget);
      expect(find.text('Below reorder level'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Out of stock'), findsWidgets);
      expect(find.text('2'), findsWidgets);

      // Check Filter Toolbar
      expect(find.text('All categories'), findsOneWidget);
      expect(find.text('All warehouses'), findsOneWidget);
      expect(find.text('Stock status'), findsOneWidget);
      expect(find.text('Stock Ledger'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('+ New Item'), findsOneWidget);

      // Check Table headers & SKUs
      expect(find.text('BSB-AP500'), findsOneWidget);
      expect(find.text('BSB-AP900'), findsOneWidget);
      expect(find.text('BSB-FLT-H13'), findsOneWidget);
      expect(find.text('BSB-FLT-CRB'), findsOneWidget);
      expect(find.text('BSB-UV-200'), findsOneWidget);

      // Check Status Chips
      expect(find.byType(StockStatusChip), findsWidgets);
      expect(find.text('In stock'), findsWidgets);
      expect(find.text('Low'), findsWidgets);
      expect(find.text('Out of stock'), findsWidgets);

      // Check Footer
      expect(find.text('Showing 1-8 of 148 · services and non-inventory items hidden'), findsOneWidget);
    });

    testWidgets('StockAdjustmentTransferScreen renders adjustment form and preview cards (Figure 10)', (tester) async {
      final service = InventoryService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: StockAdjustmentTransferScreen(inventoryService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Check Title and Tabs
      expect(find.text('New Stock Adjustment'), findsOneWidget);
      expect(find.text('Stock Adjustment'), findsOneWidget);
      expect(find.text('Stock Transfer'), findsOneWidget);

      // Check Header Inputs
      expect(find.text('ADJ-2026-0021 (auto)'), findsOneWidget);
      expect(find.text('DXB-WH - Dubai Warehouse'), findsOneWidget);
      expect(find.text('Stock count'), findsOneWidget);
      expect(find.text('5150 - Inventory Adjustments'), findsWidgets);

      // Check Table Lines from Figure 10
      expect(find.text('H13 Replacement Filter'), findsOneWidget);
      expect(find.text('Indoor Air Quality Sensor'), findsOneWidget);
      expect(find.text('HEPA Air Purifier 500'), findsOneWidget);
      expect(find.text('Wall-mount Bracket Kit'), findsOneWidget);

      // Check Net value impact
      expect(find.text('Net value impact'), findsOneWidget);
      expect(find.text('-3,390.00'), findsWidgets);

      // Check Bottom Cards
      expect(find.text('Journal preview (on post)'), findsOneWidget);
      expect(find.text('5150 Inventory Adjustments'), findsWidgets);
      expect(find.text('1300 Inventory'), findsWidgets);
      expect(find.text('3,390.00'), findsWidgets);

      // Check Stock Effect Card
      expect(find.text('Stock effect'), findsOneWidget);
      expect(find.text('4 lines · 3 items changed'), findsOneWidget);
      expect(find.text('Units out: 9 · Units in: 1'), findsOneWidget);

      // Check Action Buttons
      expect(find.text('Save Draft'), findsOneWidget);
      expect(find.text('Post Adjustment'), findsOneWidget);
    });
  });
}
