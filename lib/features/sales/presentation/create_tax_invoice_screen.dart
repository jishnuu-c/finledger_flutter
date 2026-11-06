import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/models/sales_models.dart';
import '../data/services/sales_service.dart';
import 'widgets/invoice_pdf_preview_dialog.dart';

class LineItemRow {
  SalesItem? item;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController(text: '0.00');
  final TextEditingController discController = TextEditingController(text: '0');
  double taxRatePct = 5.0;

  LineItemRow({
    this.item,
    String? description,
    double qty = 1.0,
    double price = 0.0,
    double disc = 0.0,
    double tax = 5.0,
  }) {
    if (description != null) descriptionController.text = description;
    qtyController.text = qty.toStringAsFixed(0);
    priceController.text = price.toStringAsFixed(2);
    discController.text = disc.toStringAsFixed(0);
    taxRatePct = tax;
  }

  double get quantity => double.tryParse(qtyController.text) ?? 0.0;
  double get unitPrice => double.tryParse(priceController.text) ?? 0.0;
  double get discountPct => double.tryParse(discController.text) ?? 0.0;

  double get rawTotal => quantity * unitPrice;
  double get discountAmount => rawTotal * (discountPct / 100.0);
  double get netAmount => rawTotal - discountAmount;
  double get taxAmount => netAmount * (taxRatePct / 100.0);
  double get grossAmount => netAmount + taxAmount;

  bool get hasStockWarning {
    if (item == null || !item!.isInventory || item!.stockAvailable == null) {
      return false;
    }
    return quantity > item!.stockAvailable!;
  }

  void dispose() {
    descriptionController.dispose();
    qtyController.dispose();
    priceController.dispose();
    discController.dispose();
  }
}

class CreateTaxInvoiceScreen extends StatefulWidget {
  final SalesService? salesService;

  const CreateTaxInvoiceScreen({
    super.key,
    this.salesService,
  });

  @override
  State<CreateTaxInvoiceScreen> createState() => _CreateTaxInvoiceScreenState();
}

class _CreateTaxInvoiceScreenState extends State<CreateTaxInvoiceScreen> {
  late final SalesService _salesService;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _invoiceNoController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController(text: '30-Oct-2026');
  final TextEditingController _dueDateController = TextEditingController(text: '29-Nov-2026');
  final TextEditingController _notesController = TextEditingController(
    text: 'Thank you for your business. Bank: Emirates NBD, IBAN AE07 0260 ...',
  );

  List<Customer> _customers = [];
  List<SalesItem> _availableItems = [];
  Customer? _selectedCustomer;
  String _paymentTerms = 'Net 30';

  final List<LineItemRow> _lines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.salesService != null) {
      _salesService = widget.salesService!;
    } else {
      DioClient? dio;
      try {
        dio = context.read<DioClient>();
      } catch (_) {}
      _salesService = SalesService(dioClient: dio);
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    _invoiceNoController.dispose();
    _invoiceDateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final customers = await _salesService.getCustomers();
    final items = await _salesService.getItems();
    final nextNo = _salesService.getNextInvoiceNumber();

    Customer? defaultCustomer;
    if (customers.isNotEmpty) {
      // Default to Al Noor Facilities Mgmt matching Figure 7
      defaultCustomer = customers.firstWhere((c) => c.name.contains('Al Noor'), orElse: () => customers.first);
    }

    _customers = customers;
    _availableItems = items;
    _selectedCustomer = defaultCustomer;
    _invoiceNoController.text = nextNo;

    // Pre-seed the 3 lines from Figure 7
    if (_lines.isEmpty && items.length >= 3) {
      final ap500 = items.firstWhere((i) => i.code == 'BSB-AP500', orElse: () => items[0]);
      final flt = items.firstWhere((i) => i.code == 'BSB-FLT-H13', orElse: () => items[1]);
      final srv = items.firstWhere((i) => i.code == 'SRV-INST', orElse: () => items[2]);

      _lines.addAll([
        LineItemRow(
          item: ap500,
          description: ap500.name,
          qty: 10,
          price: 3200.00,
          disc: 5,
          tax: 5.0,
        ),
        LineItemRow(
          item: flt,
          description: flt.name,
          qty: 20,
          price: 450.00,
          disc: 0,
          tax: 5.0,
        ),
        LineItemRow(
          item: srv,
          description: srv.name,
          qty: 1,
          price: 1100.00,
          disc: 0,
          tax: 5.0,
        ),
      ]);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onCustomerChanged(Customer? customer) {
    if (customer == null) return;
    setState(() {
      _selectedCustomer = customer;
      _updateDueDate();
    });
  }

  void _onPaymentTermsChanged(String? terms) {
    if (terms == null) return;
    setState(() {
      _paymentTerms = terms;
      _updateDueDate();
    });
  }

  void _updateDueDate() {
    int days = 30;
    if (_paymentTerms == 'Due on Receipt') {
      days = 0;
    } else if (_paymentTerms == 'Net 15') {
      days = 15;
    } else if (_paymentTerms == 'Net 30') {
      days = 30;
    } else if (_paymentTerms == 'Net 60') {
      days = 60;
    }

    // Default base date: 30-Oct-2026
    final baseDate = DateTime(2026, 10, 30);
    final calculated = baseDate.add(Duration(days: days));
    final formatter = DateFormat('dd-MMM-yyyy');
    _dueDateController.text = formatter.format(calculated);
  }

  void _addLineItem() {
    setState(() {
      final defaultItem = _availableItems.isNotEmpty ? _availableItems.first : null;
      _lines.add(
        LineItemRow(
          item: defaultItem,
          description: defaultItem?.name ?? '',
          qty: 1,
          price: defaultItem?.unitPrice ?? 0.0,
          disc: defaultItem?.defaultDiscountPct ?? 0.0,
          tax: defaultItem?.defaultTaxRate ?? 5.0,
        ),
      );
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lines[index].dispose();
      _lines.removeAt(index);
    });
  }

  double get _subtotal => _lines.fold(0.0, (sum, l) => sum + l.netAmount);
  double get _discountTotal => _lines.fold(0.0, (sum, l) => sum + l.discountAmount);
  double get _vatTotal => _lines.fold(0.0, (sum, l) => sum + l.taxAmount);
  double get _grandTotal => _subtotal + _vatTotal;

  Invoice _buildInvoiceObject({required String status}) {
    final invoiceLines = _lines.map((l) {
      return InvoiceLine(
        itemId: l.item?.id,
        itemCode: l.item?.code ?? 'ITEM',
        description: l.descriptionController.text.trim(),
        quantity: l.quantity,
        unitPrice: l.unitPrice,
        discountPct: l.discountPct,
        taxRatePct: l.taxRatePct,
        taxAmount: l.taxAmount,
        lineTotal: l.netAmount,
      );
    }).toList();

    return Invoice(
      id: 0,
      invoiceNo: _invoiceNoController.text.trim(),
      customerId: _selectedCustomer?.id ?? 1,
      customerName: _selectedCustomer?.name ?? 'Customer',
      customerTrn: _selectedCustomer?.trn,
      customerAddress: _selectedCustomer?.billingAddress,
      invoiceDate: _invoiceDateController.text.trim(),
      paymentTerms: _paymentTerms,
      dueDate: _dueDateController.text.trim(),
      subtotal: _subtotal,
      discountTotal: _discountTotal,
      taxTotal: _vatTotal,
      total: _grandTotal,
      balanceDue: _grandTotal,
      status: status,
      notes: _notesController.text.trim(),
      lines: invoiceLines,
    );
  }

  void _openPdfPreview() {
    final inv = _buildInvoiceObject(status: 'DRAFT');
    showDialog(
      context: context,
      builder: (ctx) => InvoicePdfPreviewDialog(invoice: inv),
    );
  }

  Future<void> _submitInvoice({required bool send}) async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one line item'), backgroundColor: AppColors.error),
      );
      return;
    }

    final invoice = _buildInvoiceObject(status: send ? 'SENT' : 'DRAFT');

    try {
      final created = await _salesService.createInvoice(invoice: invoice, send: send);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(send
                ? 'Tax Invoice ${created.invoiceNo} saved & sent successfully!'
                : 'Invoice ${created.invoiceNo} saved as Draft.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/sales/invoices');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving invoice: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.contentBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs & Title
              _buildBreadcrumbsAndTitle(),
              const SizedBox(height: 18),

              // Top Header Details Card (Figure 7)
              _buildHeaderCard(),
              const SizedBox(height: 20),

              // Line Items Grid Card (Figure 7)
              _buildLineItemsCard(currencyFormatter),
              const SizedBox(height: 20),

              // Bottom Section: Notes & Totals Box (Figure 7)
              _buildBottomSection(currencyFormatter),
              const SizedBox(height: 24),

              // Action Buttons: Cancel, Save Draft, Preview PDF, Save & Send (Figure 7)
              _buildActionButtons(),
            ],
          ),
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
              onTap: () => context.go('/sales/invoices'),
              child: const Text('Sales', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            InkWell(
              onTap: () => context.go('/sales/invoices'),
              child: const Text('Invoices', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('New', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'New Tax Invoice',
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

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 950) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildCustomerField()),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: _buildInvoiceNoField()),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: _buildInvoiceDateField()),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: _buildPaymentTermsField()),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: _buildDueDateField()),
              ],
            );
          } else if (constraints.maxWidth >= 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildCustomerField()),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: _buildInvoiceNoField()),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildInvoiceDateField()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildPaymentTermsField()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildDueDateField()),
                  ],
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerField(),
                const SizedBox(height: 12),
                _buildInvoiceNoField(),
                const SizedBox(height: 12),
                _buildInvoiceDateField(),
                const SizedBox(height: 12),
                _buildPaymentTermsField(),
                const SizedBox(height: 12),
                _buildDueDateField(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCustomerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Customer *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Customer>(
              value: _selectedCustomer,
              isExpanded: true,
              items: _customers.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                );
              }).toList(),
              onChanged: _onCustomerChanged,
            ),
          ),
        ),
        if (_selectedCustomer != null) ...[
          const SizedBox(height: 5),
          Text(
            'TRN: ${_selectedCustomer!.trn ?? '—'} · ${_selectedCustomer!.billingAddress ?? ''}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceNoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Invoice No.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: _invoiceNoController,
          readOnly: true,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Invoice Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: _invoiceDateController,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTermsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Terms', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _paymentTerms,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Due on Receipt', child: Text('Due on Receipt')),
                DropdownMenuItem(value: 'Net 15', child: Text('Net 15')),
                DropdownMenuItem(value: 'Net 30', child: Text('Net 30')),
                DropdownMenuItem(value: 'Net 60', child: Text('Net 60')),
              ],
              onChanged: _onPaymentTermsChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Due Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: _dueDateController,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineItemsCard(NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 800),
              child: SizedBox(
                width: constraints.maxWidth > 800 ? constraints.maxWidth : 800,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          SizedBox(width: 12),
                          Expanded(flex: 4, child: Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          SizedBox(width: 12),
                          Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          SizedBox(width: 12),
                          Expanded(flex: 2, child: Text('Unit Price', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          SizedBox(width: 12),
                          Expanded(flex: 1, child: Text('Disc %', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          SizedBox(width: 12),
                          Expanded(flex: 1, child: Text('Tax', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          SizedBox(width: 12),
                          Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          SizedBox(width: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dynamic Line Item Rows
                    for (int i = 0; i < _lines.length; i++) ...[
                      _buildLineItemRowWidget(_lines[i], i, currencyFormatter),
                      const SizedBox(height: 10),
                    ],

                    // + Add Item Button
                    TextButton.icon(
                      onPressed: _addLineItem,
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF2563EB)),
                      label: const Text(
                        'Add item',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLineItemRowWidget(LineItemRow row, int index, NumberFormat currencyFormatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Item Picker Dropdown
            Expanded(
              flex: 2,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SalesItem>(
                    value: row.item,
                    isExpanded: true,
                    items: _availableItems.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.code, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (selected) {
                      if (selected != null) {
                        setState(() {
                          row.item = selected;
                          row.descriptionController.text = selected.name;
                          row.priceController.text = selected.unitPrice.toStringAsFixed(2);
                          row.discController.text = selected.defaultDiscountPct.toStringAsFixed(0);
                          row.taxRatePct = selected.defaultTaxRate;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Description TextField
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: row.descriptionController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Qty
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: row.qtyController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Unit Price
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: row.priceController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Disc %
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: row.discController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Tax Rate Dropdown
            Expanded(
              flex: 1,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: row.taxRatePct,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 5.0, child: Text('VAT 5%', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 0.0, child: Text('VAT 0%', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => row.taxRatePct = val);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Amount (Calculated)
            Expanded(
              flex: 2,
              child: Text(
                currencyFormatter.format(row.netAmount),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),

            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
              onPressed: _lines.length > 1 ? () => _removeLineItem(index) : null,
              tooltip: 'Delete line',
            ),
          ],
        ),

        // Live Stock Warning per Page 16 specifications
        if (row.hasStockWarning) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      'Stock warning: Only ${row.item!.stockAvailable!.toInt()} units available in ${row.item!.warehouseName}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBottomSection(NumberFormat currencyFormatter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 750;

        final notesWidget = Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notes to customer', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        );

        final totalsWidget = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildTotalRow('Subtotal', currencyFormatter.format(_subtotal)),
              const SizedBox(height: 8),
              _buildTotalRow('Discount', currencyFormatter.format(_discountTotal)),
              const SizedBox(height: 8),
              _buildTotalRow('VAT (5%)', currencyFormatter.format(_vatTotal)),
              const Divider(height: 24, color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total (AED)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        currencyFormatter.format(_grandTotal),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (!isDesktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              notesWidget,
              const SizedBox(height: 16),
              totalsWidget,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: notesWidget),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: totalsWidget),
          ],
        );
      },
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () => context.go('/sales/invoices'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: () => _submitInvoice(send: false),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('Save Draft'),
        ),
        OutlinedButton(
          onPressed: _openPdfPreview,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('Preview PDF'),
        ),
        ElevatedButton(
          onPressed: () => _submitInvoice(send: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB), // Solid blue from Figure 7
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            elevation: 0,
          ),
          child: const Text('Save & Send', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
