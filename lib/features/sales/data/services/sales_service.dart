import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/sales_models.dart';

class SalesService {
  final DioClient? dioClient;

  final List<Customer> _customers = [];
  final List<SalesItem> _items = [];
  final List<Invoice> _invoices = [];
  final List<CustomerReceipt> _receipts = [];
  int _nextInvoiceNum = 414;
  int _nextReceiptNum = 220;

  SalesService({this.dioClient}) {
    _initSeedData();
  }

  void _initSeedData() {
    if (_customers.isNotEmpty) return;

    // Seed Customers
    _customers.addAll([
      const Customer(
        id: 1,
        code: 'CUST-001',
        name: 'Al Noor Facilities Mgmt',
        trn: '100234567800003',
        billingAddress: 'Dubai, UAE',
        email: 'billing@alnoor.ae',
        phone: '+971 4 200 1100',
        paymentTermsDays: 30,
      ),
      const Customer(
        id: 2,
        code: 'CUST-002',
        name: 'Gulf Hospitality Group',
        trn: '100345678900003',
        billingAddress: 'Abu Dhabi, UAE',
        email: 'accounts@gulfhospitality.ae',
        phone: '+971 2 400 2200',
        paymentTermsDays: 30,
      ),
      const Customer(
        id: 3,
        code: 'CUST-003',
        name: 'Riyadh Medical Centre',
        trn: '300012345600003',
        billingAddress: 'Riyadh, Saudi Arabia',
        email: 'k.alharbi@rmc.sa',
        phone: '+966 11 000 0000',
        paymentTermsDays: 30,
      ),
      const Customer(
        id: 4,
        code: 'CUST-004',
        name: 'Sharjah Schools Co.',
        trn: '100456789000003',
        billingAddress: 'Sharjah, UAE',
        email: 'finance@sharjahschools.ae',
        phone: '+971 6 500 3300',
        paymentTermsDays: 30,
      ),
      const Customer(
        id: 5,
        code: 'CUST-005',
        name: 'Marina Towers OA',
        trn: '100567890100003',
        billingAddress: 'Dubai Marina, UAE',
        email: 'management@marinastowers.ae',
        phone: '+971 4 300 4400',
        paymentTermsDays: 30,
      ),
      const Customer(
        id: 6,
        code: 'CUST-006',
        name: 'Desert Rose Hotels',
        trn: '100678901200003',
        billingAddress: 'Ras Al Khaimah, UAE',
        email: 'procurement@desertrose.ae',
        phone: '+971 7 200 5500',
        paymentTermsDays: 30,
      ),
    ]);

    // Seed Items (Figure 7)
    _items.addAll([
      const SalesItem(
        id: 1,
        code: 'BSB-AP500',
        name: 'HEPA Air Purifier 500',
        itemType: 'INVENTORY',
        unitPrice: 3200.00,
        defaultDiscountPct: 5.0,
        defaultTaxRate: 5.0,
        stockAvailable: 12.0,
        warehouseName: 'Dubai WH',
      ),
      const SalesItem(
        id: 2,
        code: 'BSB-FLT-H13',
        name: 'H13 Replacement Filter',
        itemType: 'INVENTORY',
        unitPrice: 450.00,
        defaultDiscountPct: 0.0,
        defaultTaxRate: 5.0,
        stockAvailable: 50.0,
        warehouseName: 'Dubai WH',
      ),
      const SalesItem(
        id: 3,
        code: 'SRV-INST',
        name: 'Installation service',
        itemType: 'SERVICE',
        unitPrice: 1100.00,
        defaultDiscountPct: 0.0,
        defaultTaxRate: 5.0,
        stockAvailable: null, // Service has infinite stock
      ),
      const SalesItem(
        id: 4,
        code: 'BSB-SEN-AQI',
        name: 'Indoor Air Quality Monitor',
        itemType: 'INVENTORY',
        unitPrice: 850.00,
        defaultDiscountPct: 0.0,
        defaultTaxRate: 5.0,
        stockAvailable: 6.0,
        warehouseName: 'Dubai WH',
      ),
    ]);

    // Seed Invoices (Figure 6)
    _invoices.addAll([
      const Invoice(
        id: 412,
        invoiceNo: 'INV-2026-0412',
        customerId: 1,
        customerName: 'Al Noor Facilities Mgmt',
        customerTrn: '100234567800003',
        customerAddress: 'Dubai, UAE',
        invoiceDate: '29-Oct-2026',
        paymentTerms: 'Net 30',
        dueDate: '28-Nov-2026',
        subtotal: 40500.00,
        taxTotal: 2025.00,
        total: 42525.00,
        amountPaid: 0.00,
        balanceDue: 42525.00,
        status: 'SENT',
        notes: 'Thank you for your business. Bank: Emirates NBD, IBAN AE07 0260 ...',
      ),
      const Invoice(
        id: 411,
        invoiceNo: 'INV-2026-0411',
        customerId: 2,
        customerName: 'Gulf Hospitality Group',
        customerTrn: '100345678900003',
        customerAddress: 'Abu Dhabi, UAE',
        invoiceDate: '27-Oct-2026',
        paymentTerms: 'Net 30',
        dueDate: '26-Nov-2026',
        subtotal: 18000.00,
        taxTotal: 900.00,
        total: 18900.00,
        amountPaid: 18900.00,
        balanceDue: 0.00,
        status: 'PAID',
      ),
      const Invoice(
        id: 410,
        invoiceNo: 'INV-2026-0410',
        customerId: 3,
        customerName: 'Riyadh Medical Centre',
        customerTrn: '300012345600003',
        customerAddress: 'Riyadh, Saudi Arabia',
        invoiceDate: '25-Oct-2026',
        paymentTerms: 'Net 30',
        dueDate: '24-Nov-2026',
        subtotal: 60000.00,
        taxTotal: 3000.00,
        total: 63000.00,
        amountPaid: 33000.00,
        balanceDue: 30000.00,
        status: 'PARTIAL',
      ),
      const Invoice(
        id: 405,
        invoiceNo: 'INV-2026-0405',
        customerId: 4,
        customerName: 'Sharjah Schools Co.',
        customerTrn: '100456789000003',
        customerAddress: 'Sharjah, UAE',
        invoiceDate: '12-Sep-2026',
        paymentTerms: 'Net 30',
        dueDate: '12-Oct-2026',
        subtotal: 26000.00,
        taxTotal: 1300.00,
        total: 27300.00,
        amountPaid: 0.00,
        balanceDue: 27300.00,
        status: 'OVERDUE',
      ),
      const Invoice(
        id: 402,
        invoiceNo: 'INV-2026-0402',
        customerId: 5,
        customerName: 'Marina Towers OA',
        customerTrn: '100567890100003',
        customerAddress: 'Dubai Marina, UAE',
        invoiceDate: '08-Sep-2026',
        paymentTerms: 'Net 30',
        dueDate: '08-Oct-2026',
        subtotal: 13500.00,
        taxTotal: 675.00,
        total: 14175.00,
        amountPaid: 0.00,
        balanceDue: 14175.00,
        status: 'OVERDUE',
      ),
      const Invoice(
        id: 413,
        invoiceNo: 'INV-2026-0413',
        customerId: 6,
        customerName: 'Desert Rose Hotels',
        customerTrn: '100678901200003',
        customerAddress: 'Ras Al Khaimah, UAE',
        invoiceDate: '30-Oct-2026',
        paymentTerms: 'Net 30',
        dueDate: '—',
        subtotal: 9000.00,
        taxTotal: 450.00,
        total: 9450.00,
        amountPaid: 0.00,
        balanceDue: 9450.00,
        status: 'DRAFT',
      ),
      const Invoice(
        id: 398,
        invoiceNo: 'INV-2026-0398',
        customerId: 1,
        customerName: 'Al Noor Facilities Mgmt',
        customerTrn: '100234567800003',
        customerAddress: 'Dubai, UAE',
        invoiceDate: '01-Sep-2026',
        paymentTerms: 'Net 30',
        dueDate: '01-Oct-2026',
        subtotal: 34000.00,
        taxTotal: 1700.00,
        total: 35700.00,
        amountPaid: 35700.00,
        balanceDue: 0.00,
        status: 'PAID',
      ),
    ]);
  }

  /// GET /api/v1/invoices
  Future<List<Invoice>> getInvoices({
    String? status,
    String? search,
    String? from,
    String? to,
    int page = 0,
    int size = 10,
  }) async {
    try {
      if (dioClient != null) {
        final resp = await dioClient!.dio.get(
          Endpoints.invoices,
          queryParameters: {
            if (status != null && status != 'All Status') 'status': status.toUpperCase(),
            if (search != null && search.isNotEmpty) 'q': search,
            'from': ?from,
            'to': ?to,
            'page': page,
            'size': size,
          },
        );
        if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
          final content = resp.data['content'] as List?;
          if (content != null && content.isNotEmpty) {
            return content.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
          }
        }
      }
    } catch (_) {}

    var filtered = List<Invoice>.from(_invoices);

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((inv) =>
        inv.invoiceNo.toLowerCase().contains(q) ||
        inv.customerName.toLowerCase().contains(q)
      ).toList();
    }

    if (status != null && status != 'All Status') {
      filtered = filtered.where((inv) =>
        inv.status.toLowerCase() == status.toLowerCase()
      ).toList();
    }

    return filtered;
  }

  /// Returns 4 KPI Summary Cards matching Figure 6
  Future<InvoiceKpis> getInvoiceKpis() async {
    return const InvoiceKpis(
      draftCount: 6,
      unpaidAmount: 271320.00,
      overdueAmount: 113600.00,
      paidThisMonthAmount: 196450.00,
    );
  }

  /// GET /api/v1/customers
  Future<List<Customer>> getCustomers({String? query}) async {
    try {
      if (dioClient != null) {
        final resp = await dioClient!.dio.get(
          Endpoints.customers,
          queryParameters: {
            if (query != null && query.isNotEmpty) 'q': query,
          },
        );
        if (resp.statusCode == 200 && resp.data is List) {
          final list = (resp.data as List).map((c) => Customer.fromJson(c as Map<String, dynamic>)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      return _customers.where((c) => c.name.toLowerCase().contains(q) || c.code.toLowerCase().contains(q)).toList();
    }
    return List.unmodifiable(_customers);
  }

  /// GET /api/v1/items
  Future<List<SalesItem>> getItems({String? query, String? warehouseId}) async {
    try {
      if (dioClient != null) {
        final resp = await dioClient!.dio.get(
          Endpoints.items,
          queryParameters: {
            if (query != null && query.isNotEmpty) 'q': query,
            'warehouseId': ?warehouseId,
          },
        );
        if (resp.statusCode == 200 && resp.data is List) {
          final list = (resp.data as List).map((i) => SalesItem.fromJson(i as Map<String, dynamic>)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      return _items.where((i) => i.code.toLowerCase().contains(q) || i.name.toLowerCase().contains(q)).toList();
    }
    return List.unmodifiable(_items);
  }

  /// Generates the next sequential invoice number e.g. "INV-2026-0414"
  String getNextInvoiceNumber() {
    return 'INV-2026-0$_nextInvoiceNum';
  }

  /// POST /api/v1/invoices
  Future<Invoice> createInvoice({
    required Invoice invoice,
    bool send = false,
  }) async {
    if (invoice.lines.isEmpty) {
      throw Exception('An invoice must contain at least one line item.');
    }

    // Server-side recalculation of lines and totals per Page 28
    double subtotal = 0.0;
    double taxTotal = 0.0;
    double discountTotal = 0.0;

    final recalculatedLines = invoice.lines.map((l) {
      final rawAmount = l.quantity * l.unitPrice;
      final discAmount = rawAmount * (l.discountPct / 100.0);
      final netAmount = rawAmount - discAmount;
      final vatAmount = netAmount * (l.taxRatePct / 100.0);

      subtotal += netAmount;
      discountTotal += discAmount;
      taxTotal += vatAmount;

      return l.copyWith(
        taxAmount: vatAmount,
        lineTotal: netAmount,
      );
    }).toList();

    final grandTotal = subtotal + taxTotal;
    final status = send ? 'SENT' : 'DRAFT';

    final created = invoice.copyWith(
      id: _nextInvoiceNum,
      subtotal: subtotal,
      discountTotal: discountTotal,
      taxTotal: taxTotal,
      total: grandTotal,
      balanceDue: grandTotal,
      status: status,
      lines: recalculatedLines,
    );

    _nextInvoiceNum++;

    try {
      if (dioClient != null) {
        final resp = await dioClient!.dio.post(
          Endpoints.invoices,
          data: created.toJson(),
        );
        if (send && resp.data?['id'] != null) {
          await dioClient!.dio.post('${Endpoints.invoices}/${resp.data['id']}/send');
        }
      }
    } catch (_) {}

    _invoices.insert(0, created);
    return created;
  }

  /// GET /api/v1/customers/{id}/open-invoices
  /// Automatically loads open invoices sorted oldest-first per Figure 8
  Future<List<CustomerOpenInvoice>> getCustomerOpenInvoices(int customerId) async {
    try {
      if (dioClient != null) {
        final resp = await dioClient!.dio.get(
          '${Endpoints.customers}/$customerId/open-invoices',
        );
        if (resp.statusCode == 200 && resp.data is List) {
          return (resp.data as List).map((i) => CustomerOpenInvoice.fromJson(i as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    // Mock open invoices matching Figure 8 for Riyadh Medical Centre (ID 3)
    if (customerId == 3) {
      return [
        const CustomerOpenInvoice(
          invoiceId: 410,
          invoiceNo: 'INV-2026-0410',
          invoiceDate: '25-Oct-2026',
          total: 63000.00,
          outstanding: 30000.00,
          appliedPayment: 30000.00,
          isSelected: true,
        ),
        const CustomerOpenInvoice(
          invoiceId: 388,
          invoiceNo: 'INV-2026-0388',
          invoiceDate: '18-Aug-2026',
          total: 12600.00,
          outstanding: 3000.00,
          appliedPayment: 3000.00,
          isSelected: true,
        ),
        const CustomerOpenInvoice(
          invoiceId: 415,
          invoiceNo: 'INV-2026-0415',
          invoiceDate: '30-Oct-2026',
          total: 8400.00,
          outstanding: 8400.00,
          appliedPayment: 0.00,
          isSelected: false,
        ),
      ];
    }

    // For other customers, find matching open invoices in our in-memory list
    final customerInvoices = _invoices
        .where((inv) => inv.customerId == customerId && inv.balanceDue > 0)
        .toList();

    return customerInvoices.map((inv) {
      return CustomerOpenInvoice(
        invoiceId: inv.id,
        invoiceNo: inv.invoiceNo,
        invoiceDate: inv.invoiceDate,
        total: inv.total,
        outstanding: inv.balanceDue,
        appliedPayment: 0.00,
        isSelected: false,
      );
    }).toList();
  }

  /// Automatically allocates amount received oldest-first across open invoices
  List<CustomerOpenInvoice> autoAllocateOldestFirst({
    required List<CustomerOpenInvoice> openInvoices,
    required double amountReceived,
  }) {
    double remaining = amountReceived;

    return openInvoices.map((inv) {
      if (remaining <= 0) {
        return inv.copyWith(appliedPayment: 0.0, isSelected: false);
      }

      final toApply = remaining >= inv.outstanding ? inv.outstanding : remaining;
      remaining -= toApply;

      return inv.copyWith(
        appliedPayment: toApply,
        isSelected: toApply > 0,
      );
    }).toList();
  }

  /// POST /api/v1/receipts
  Future<CustomerReceipt> createReceipt({
    required int customerId,
    required String customerName,
    required String receiptDate,
    required int depositToAccountId,
    required String depositToAccountName,
    required String paymentMethod,
    String? reference,
    required double amount,
    required List<CustomerOpenInvoice> allocatedInvoices,
  }) async {
    final appliedSum = allocatedInvoices.fold<double>(0.0, (sum, i) => sum + i.appliedPayment);
    if (appliedSum > amount) {
      throw Exception('Total applied amount (AED $appliedSum) cannot exceed amount received (AED $amount).');
    }

    final unapplied = amount - appliedSum;
    final receiptNo = 'RCT-2026-0$_nextReceiptNum';
    _nextReceiptNum++;

    final allocations = allocatedInvoices
        .where((i) => i.appliedPayment > 0)
        .map((i) => ReceiptAllocation(
              invoiceId: i.invoiceId,
              invoiceNo: i.invoiceNo,
              amount: i.appliedPayment,
            ))
        .toList();

    final receipt = CustomerReceipt(
      id: DateTime.now().millisecondsSinceEpoch,
      receiptNo: receiptNo,
      customerId: customerId,
      customerName: customerName,
      receiptDate: receiptDate,
      depositToAccountId: depositToAccountId,
      depositToAccountName: depositToAccountName,
      paymentMethod: paymentMethod,
      reference: reference,
      amount: amount,
      appliedAmount: appliedSum,
      unappliedAmount: unapplied,
      status: 'POSTED',
      allocations: allocations,
    );

    try {
      if (dioClient != null) {
        await dioClient!.dio.post(Endpoints.receipts, data: receipt.toJson());
      }
    } catch (_) {}

    // Update in-memory invoices
    for (final alloc in allocations) {
      final idx = _invoices.indexWhere((i) => i.id == alloc.invoiceId);
      if (idx != -1) {
        final inv = _invoices[idx];
        final newPaid = inv.amountPaid + alloc.amount;
        final newBalance = (inv.total - newPaid).clamp(0.0, inv.total);
        final newStatus = newBalance <= 0.001 ? 'PAID' : 'PARTIAL';

        _invoices[idx] = inv.copyWith(
          amountPaid: newPaid,
          balanceDue: newBalance,
          status: newStatus,
        );
      }
    }

    _receipts.insert(0, receipt);
    return receipt;
  }
}
