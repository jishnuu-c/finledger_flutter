class Customer {
  final int id;
  final String code; // e.g. CUST-001
  final String name; // e.g. Al Noor Facilities Mgmt
  final String? trn; // e.g. 100234567800003
  final String? email;
  final String? phone;
  final String? billingAddress; // e.g. Dubai, UAE
  final String countryCode;
  final String currencyCode;
  final int paymentTermsDays;
  final double? creditLimit;
  final int arAccountId;

  const Customer({
    required this.id,
    required this.code,
    required this.name,
    this.trn,
    this.email,
    this.phone,
    this.billingAddress,
    this.countryCode = 'AE',
    this.currencyCode = 'AED',
    this.paymentTermsDays = 30,
    this.creditLimit,
    this.arAccountId = 5, // 1200 Accounts Receivable
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      trn: json['trn'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      billingAddress: json['billing_address'] as String? ?? json['billingAddress'] as String?,
      countryCode: json['country_code'] as String? ?? json['countryCode'] as String? ?? 'AE',
      currencyCode: json['currency_code'] as String? ?? json['currencyCode'] as String? ?? 'AED',
      paymentTermsDays: json['payment_terms_days'] as int? ?? json['paymentTermsDays'] as int? ?? 30,
      creditLimit: (json['credit_limit'] as num? ?? json['creditLimit'] as num?)?.toDouble(),
      arAccountId: json['ar_account_id'] as int? ?? json['arAccountId'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'trn': trn,
      'email': email,
      'phone': phone,
      'billing_address': billingAddress,
      'country_code': countryCode,
      'currency_code': currencyCode,
      'payment_terms_days': paymentTermsDays,
      'credit_limit': creditLimit,
      'ar_account_id': arAccountId,
    };
  }
}

class SalesItem {
  final int id;
  final String code; // e.g. BSB-AP500
  final String name; // e.g. HEPA Air Purifier 500
  final String itemType; // INVENTORY, SERVICE, NON_INVENTORY
  final double unitPrice; // e.g. 3200.00
  final double defaultDiscountPct;
  final double defaultTaxRate; // 5.0
  final double? stockAvailable; // e.g. 12.0
  final String warehouseName; // e.g. Dubai WH

  const SalesItem({
    required this.id,
    required this.code,
    required this.name,
    this.itemType = 'INVENTORY',
    required this.unitPrice,
    this.defaultDiscountPct = 0.0,
    this.defaultTaxRate = 5.0,
    this.stockAvailable,
    this.warehouseName = 'Dubai WH',
  });

  bool get isInventory => itemType == 'INVENTORY';

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      itemType: json['item_type'] as String? ?? json['itemType'] as String? ?? 'INVENTORY',
      unitPrice: (json['unit_price'] as num? ?? json['unitPrice'] as num? ?? 0.0).toDouble(),
      defaultDiscountPct: (json['default_discount_pct'] as num? ?? json['defaultDiscountPct'] as num? ?? 0.0).toDouble(),
      defaultTaxRate: (json['default_tax_rate'] as num? ?? json['defaultTaxRate'] as num? ?? 5.0).toDouble(),
      stockAvailable: (json['stock_available'] as num? ?? json['stockAvailable'] as num?)?.toDouble(),
      warehouseName: json['warehouse_name'] as String? ?? json['warehouseName'] as String? ?? 'Dubai WH',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'item_type': itemType,
      'unit_price': unitPrice,
      'default_discount_pct': defaultDiscountPct,
      'default_tax_rate': defaultTaxRate,
      'stock_available': stockAvailable,
      'warehouse_name': warehouseName,
    };
  }
}

class InvoiceLine {
  final int? id;
  final int? itemId;
  final String itemCode; // e.g. BSB-AP500
  final String description; // e.g. HEPA Air Purifier 500
  final double quantity; // e.g. 10
  final double unitPrice; // e.g. 3200.00
  final double discountPct; // e.g. 5
  final double taxRatePct; // e.g. 5.0
  final double taxAmount;
  final double lineTotal; // Net excl. tax

  const InvoiceLine({
    this.id,
    this.itemId,
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discountPct = 0.0,
    this.taxRatePct = 5.0,
    required this.taxAmount,
    required this.lineTotal,
  });

  double get grossTotal => lineTotal + taxAmount;

  InvoiceLine copyWith({
    int? id,
    int? itemId,
    String? itemCode,
    String? description,
    double? quantity,
    double? unitPrice,
    double? discountPct,
    double? taxRatePct,
    double? taxAmount,
    double? lineTotal,
  }) {
    return InvoiceLine(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemCode: itemCode ?? this.itemCode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPct: discountPct ?? this.discountPct,
      taxRatePct: taxRatePct ?? this.taxRatePct,
      taxAmount: taxAmount ?? this.taxAmount,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }

  factory InvoiceLine.fromJson(Map<String, dynamic> json) {
    return InvoiceLine(
      id: json['id'] as int?,
      itemId: json['item_id'] as int? ?? json['itemId'] as int?,
      itemCode: json['item_code'] as String? ?? json['itemCode'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 1.0).toDouble(),
      unitPrice: (json['unit_price'] as num? ?? json['unitPrice'] as num? ?? 0.0).toDouble(),
      discountPct: (json['discount_pct'] as num? ?? json['discountPct'] as num? ?? 0.0).toDouble(),
      taxRatePct: (json['tax_rate_pct'] as num? ?? json['taxRatePct'] as num? ?? 5.0).toDouble(),
      taxAmount: (json['tax_amount'] as num? ?? json['taxAmount'] as num? ?? 0.0).toDouble(),
      lineTotal: (json['line_total'] as num? ?? json['lineTotal'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_code': itemCode,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_pct': discountPct,
      'tax_rate_pct': taxRatePct,
      'tax_amount': taxAmount,
      'line_total': lineTotal,
    };
  }
}

class Invoice {
  final int id;
  final String invoiceNo; // e.g. INV-2026-0412
  final String docType; // INVOICE, CREDIT_NOTE
  final int customerId;
  final String customerName; // e.g. Al Noor Facilities Mgmt
  final String? customerTrn;
  final String? customerAddress;
  final String invoiceDate; // e.g. 29-Oct-2026
  final String paymentTerms; // e.g. Net 30
  final String dueDate; // e.g. 28-Nov-2026 or —
  final String currencyCode; // AED
  final double subtotal; // e.g. 40500.00
  final double discountTotal;
  final double taxTotal; // e.g. 2025.00
  final double total; // e.g. 42525.00
  final double amountPaid;
  final double balanceDue; // e.g. 42525.00
  final String status; // DRAFT, SENT, PARTIAL, PAID, OVERDUE, VOID
  final String? notes;
  final List<InvoiceLine> lines;

  const Invoice({
    required this.id,
    required this.invoiceNo,
    this.docType = 'INVOICE',
    required this.customerId,
    required this.customerName,
    this.customerTrn,
    this.customerAddress,
    required this.invoiceDate,
    this.paymentTerms = 'Net 30',
    required this.dueDate,
    this.currencyCode = 'AED',
    required this.subtotal,
    this.discountTotal = 0.0,
    required this.taxTotal,
    required this.total,
    this.amountPaid = 0.0,
    required this.balanceDue,
    required this.status,
    this.notes,
    this.lines = const [],
  });

  Invoice copyWith({
    int? id,
    String? invoiceNo,
    String? docType,
    int? customerId,
    String? customerName,
    String? customerTrn,
    String? customerAddress,
    String? invoiceDate,
    String? paymentTerms,
    String? dueDate,
    String? currencyCode,
    double? subtotal,
    double? discountTotal,
    double? taxTotal,
    double? total,
    double? amountPaid,
    double? balanceDue,
    String? status,
    String? notes,
    List<InvoiceLine>? lines,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      docType: docType ?? this.docType,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerTrn: customerTrn ?? this.customerTrn,
      customerAddress: customerAddress ?? this.customerAddress,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      dueDate: dueDate ?? this.dueDate,
      currencyCode: currencyCode ?? this.currencyCode,
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      total: total ?? this.total,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      lines: lines ?? this.lines,
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int? ?? 0,
      invoiceNo: json['invoice_no'] as String? ?? json['invoiceNo'] as String? ?? '',
      docType: json['doc_type'] as String? ?? json['docType'] as String? ?? 'INVOICE',
      customerId: json['customer_id'] as int? ?? json['customerId'] as int? ?? 0,
      customerName: json['customer_name'] as String? ?? json['customerName'] as String? ?? '',
      customerTrn: json['customer_trn'] as String? ?? json['customerTrn'] as String?,
      customerAddress: json['customer_address'] as String? ?? json['customerAddress'] as String?,
      invoiceDate: json['invoice_date'] as String? ?? json['invoiceDate'] as String? ?? '',
      paymentTerms: json['payment_terms'] as String? ?? json['paymentTerms'] as String? ?? 'Net 30',
      dueDate: json['due_date'] as String? ?? json['dueDate'] as String? ?? '—',
      currencyCode: json['currency_code'] as String? ?? json['currencyCode'] as String? ?? 'AED',
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
      discountTotal: (json['discount_total'] as num? ?? json['discountTotal'] as num? ?? 0.0).toDouble(),
      taxTotal: (json['tax_total'] as num? ?? json['taxTotal'] as num? ?? 0.0).toDouble(),
      total: (json['total'] as num? ?? 0.0).toDouble(),
      amountPaid: (json['amount_paid'] as num? ?? json['amountPaid'] as num? ?? 0.0).toDouble(),
      balanceDue: (json['balance_due'] as num? ?? json['balanceDue'] as num? ?? 0.0).toDouble(),
      status: json['status'] as String? ?? 'DRAFT',
      notes: json['notes'] as String?,
      lines: ((json['lines'] as List?) ?? [])
          .map((l) => InvoiceLine.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'doc_type': docType,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_trn': customerTrn,
      'customer_address': customerAddress,
      'invoice_date': invoiceDate,
      'payment_terms': paymentTerms,
      'due_date': dueDate,
      'currency_code': currencyCode,
      'subtotal': subtotal,
      'discount_total': discountTotal,
      'tax_total': taxTotal,
      'total': total,
      'amount_paid': amountPaid,
      'balance_due': balanceDue,
      'status': status,
      'notes': notes,
      'lines': lines.map((l) => l.toJson()).toList(),
    };
  }
}

class InvoiceKpis {
  final int draftCount; // 6
  final double unpaidAmount; // AED 271,320
  final double overdueAmount; // AED 113,600
  final double paidThisMonthAmount; // AED 196,450

  const InvoiceKpis({
    required this.draftCount,
    required this.unpaidAmount,
    required this.overdueAmount,
    required this.paidThisMonthAmount,
  });

  factory InvoiceKpis.fromJson(Map<String, dynamic> json) {
    return InvoiceKpis(
      draftCount: json['draft_count'] as int? ?? json['draftCount'] as int? ?? 0,
      unpaidAmount: (json['unpaid_amount'] as num? ?? json['unpaidAmount'] as num? ?? 0.0).toDouble(),
      overdueAmount: (json['overdue_amount'] as num? ?? json['overdueAmount'] as num? ?? 0.0).toDouble(),
      paidThisMonthAmount: (json['paid_this_month_amount'] as num? ?? json['paidThisMonthAmount'] as num? ?? 0.0).toDouble(),
    );
  }
}

class CustomerOpenInvoice {
  final int invoiceId;
  final String invoiceNo; // e.g. INV-2026-0410
  final String invoiceDate; // e.g. 25-Oct-2026
  final double total; // e.g. 63000.00
  final double outstanding; // e.g. 30000.00
  final double appliedPayment; // e.g. 30000.00
  final bool isSelected;

  const CustomerOpenInvoice({
    required this.invoiceId,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.total,
    required this.outstanding,
    this.appliedPayment = 0.0,
    this.isSelected = false,
  });

  CustomerOpenInvoice copyWith({
    int? invoiceId,
    String? invoiceNo,
    String? invoiceDate,
    double? total,
    double? outstanding,
    double? appliedPayment,
    bool? isSelected,
  }) {
    return CustomerOpenInvoice(
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      total: total ?? this.total,
      outstanding: outstanding ?? this.outstanding,
      appliedPayment: appliedPayment ?? this.appliedPayment,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory CustomerOpenInvoice.fromJson(Map<String, dynamic> json) {
    return CustomerOpenInvoice(
      invoiceId: json['invoice_id'] as int? ?? json['invoiceId'] as int? ?? 0,
      invoiceNo: json['invoice_no'] as String? ?? json['invoiceNo'] as String? ?? '',
      invoiceDate: json['invoice_date'] as String? ?? json['invoiceDate'] as String? ?? '',
      total: (json['total'] as num? ?? 0.0).toDouble(),
      outstanding: (json['outstanding'] as num? ?? 0.0).toDouble(),
      appliedPayment: (json['applied_payment'] as num? ?? json['appliedPayment'] as num? ?? 0.0).toDouble(),
      isSelected: json['is_selected'] as bool? ?? json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
      'total': total,
      'outstanding': outstanding,
      'applied_payment': appliedPayment,
      'is_selected': isSelected,
    };
  }
}

class CustomerReceipt {
  final int id;
  final String receiptNo; // e.g. RCT-2026-0220
  final int customerId;
  final String customerName; // e.g. Riyadh Medical Centre
  final String receiptDate; // e.g. 30-Oct-2026
  final int depositToAccountId; // e.g. 3 (1110)
  final String depositToAccountName; // e.g. 1110 – Emirates NBD Current
  final String paymentMethod; // Bank Transfer, Cheque, Cash, Card
  final String? reference; // e.g. TT-889123
  final String currencyCode; // AED
  final double amount; // e.g. 33000.00
  final double appliedAmount; // e.g. 33000.00
  final double unappliedAmount; // e.g. 0.00
  final String status; // DRAFT, POSTED, VOID
  final List<ReceiptAllocation> allocations;

  const CustomerReceipt({
    required this.id,
    required this.receiptNo,
    required this.customerId,
    required this.customerName,
    required this.receiptDate,
    required this.depositToAccountId,
    required this.depositToAccountName,
    required this.paymentMethod,
    this.reference,
    this.currencyCode = 'AED',
    required this.amount,
    required this.appliedAmount,
    this.unappliedAmount = 0.0,
    this.status = 'POSTED',
    this.allocations = const [],
  });

  factory CustomerReceipt.fromJson(Map<String, dynamic> json) {
    return CustomerReceipt(
      id: json['id'] as int? ?? 0,
      receiptNo: json['receipt_no'] as String? ?? json['receiptNo'] as String? ?? '',
      customerId: json['customer_id'] as int? ?? json['customerId'] as int? ?? 0,
      customerName: json['customer_name'] as String? ?? json['customerName'] as String? ?? '',
      receiptDate: json['receipt_date'] as String? ?? json['receiptDate'] as String? ?? '',
      depositToAccountId: json['deposit_to_account_id'] as int? ?? json['depositToAccountId'] as int? ?? 3,
      depositToAccountName: json['deposit_to_account_name'] as String? ?? json['depositToAccountName'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? json['paymentMethod'] as String? ?? 'Bank Transfer',
      reference: json['reference'] as String?,
      currencyCode: json['currency_code'] as String? ?? json['currencyCode'] as String? ?? 'AED',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      appliedAmount: (json['applied_amount'] as num? ?? json['appliedAmount'] as num? ?? 0.0).toDouble(),
      unappliedAmount: (json['unapplied_amount'] as num? ?? json['unappliedAmount'] as num? ?? 0.0).toDouble(),
      status: json['status'] as String? ?? 'POSTED',
      allocations: ((json['allocations'] as List?) ?? [])
          .map((a) => ReceiptAllocation.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_no': receiptNo,
      'customer_id': customerId,
      'customer_name': customerName,
      'receipt_date': receiptDate,
      'deposit_to_account_id': depositToAccountId,
      'deposit_to_account_name': depositToAccountName,
      'payment_method': paymentMethod,
      'reference': reference,
      'currency_code': currencyCode,
      'amount': amount,
      'applied_amount': appliedAmount,
      'unapplied_amount': unappliedAmount,
      'status': status,
      'allocations': allocations.map((a) => a.toJson()).toList(),
    };
  }
}

class ReceiptAllocation {
  final int invoiceId;
  final String invoiceNo;
  final double amount;

  const ReceiptAllocation({
    required this.invoiceId,
    required this.invoiceNo,
    required this.amount,
  });

  factory ReceiptAllocation.fromJson(Map<String, dynamic> json) {
    return ReceiptAllocation(
      invoiceId: json['invoice_id'] as int? ?? json['invoiceId'] as int? ?? 0,
      invoiceNo: json['invoice_no'] as String? ?? json['invoiceNo'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'invoice_no': invoiceNo,
      'amount': amount,
    };
  }
}
