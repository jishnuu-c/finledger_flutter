import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/models/sales_models.dart';
import '../data/services/sales_service.dart';

class EditableOpenInvoiceRow {
  final CustomerOpenInvoice invoice;
  bool isSelected;
  final TextEditingController paymentController;

  EditableOpenInvoiceRow({
    required this.invoice,
    required this.isSelected,
    required double initialPayment,
  }) : paymentController = TextEditingController(
          text: initialPayment > 0 ? initialPayment.toStringAsFixed(2) : '0.00',
        );

  double get paymentAmount => double.tryParse(paymentController.text) ?? 0.0;

  void dispose() {
    paymentController.dispose();
  }
}

class RecordCustomerReceiptScreen extends StatefulWidget {
  final SalesService? salesService;

  const RecordCustomerReceiptScreen({
    super.key,
    this.salesService,
  });

  @override
  State<RecordCustomerReceiptScreen> createState() => _RecordCustomerReceiptScreenState();
}

class _RecordCustomerReceiptScreenState extends State<RecordCustomerReceiptScreen> {
  late final SalesService _salesService;

  final TextEditingController _receiptDateController = TextEditingController(text: '30-Oct-2026');
  final TextEditingController _amountReceivedController = TextEditingController(text: '33,000.00');
  final TextEditingController _referenceController = TextEditingController(text: 'TT-889123');

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  String _depositTo = '1110 – Emirates NBD Current';
  String _paymentMethod = 'Bank Transfer';

  final List<EditableOpenInvoiceRow> _openInvoiceRows = [];
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
    _receiptDateController.dispose();
    _amountReceivedController.dispose();
    _referenceController.dispose();
    for (final r in _openInvoiceRows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final customers = await _salesService.getCustomers();

    // Default to Riyadh Medical Centre matching Figure 8
    Customer? defaultCust;
    if (customers.isNotEmpty) {
      defaultCust = customers.firstWhere(
        (c) => c.name.contains('Riyadh Medical'),
        orElse: () => customers.first,
      );
    }

    _customers = customers;
    _selectedCustomer = defaultCust;

    if (defaultCust != null) {
      await _loadOpenInvoicesForCustomer(defaultCust.id);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOpenInvoicesForCustomer(int customerId) async {
    for (final r in _openInvoiceRows) {
      r.dispose();
    }
    _openInvoiceRows.clear();

    final openInvoices = await _salesService.getCustomerOpenInvoices(customerId);
    final amountRec = _parsedAmountReceived;

    // Auto-allocate oldest-first per Figure 8 & Page 17
    final allocated = _salesService.autoAllocateOldestFirst(
      openInvoices: openInvoices,
      amountReceived: amountRec,
    );

    for (final inv in allocated) {
      _openInvoiceRows.add(
        EditableOpenInvoiceRow(
          invoice: inv,
          isSelected: inv.isSelected,
          initialPayment: inv.appliedPayment,
        ),
      );
    }
  }

  double get _parsedAmountReceived {
    final clean = _amountReceivedController.text.replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  double get _appliedTotal {
    return _openInvoiceRows.fold(0.0, (sum, r) => sum + (r.isSelected ? r.paymentAmount : 0.0));
  }

  double get _unappliedTotal {
    final diff = _parsedAmountReceived - _appliedTotal;
    return diff > 0.0001 ? diff : 0.0;
  }

  void _onCustomerChanged(Customer? customer) async {
    if (customer == null) return;
    setState(() {
      _selectedCustomer = customer;
      _isLoading = true;
    });

    await _loadOpenInvoicesForCustomer(customer.id);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onAmountReceivedChanged(String _) {
    final amount = _parsedAmountReceived;
    final invoices = _openInvoiceRows.map((r) => r.invoice).toList();
    final allocated = _salesService.autoAllocateOldestFirst(
      openInvoices: invoices,
      amountReceived: amount,
    );

    for (int i = 0; i < _openInvoiceRows.length; i++) {
      final alloc = allocated[i];
      _openInvoiceRows[i].isSelected = alloc.isSelected;
      _openInvoiceRows[i].paymentController.text = alloc.appliedPayment.toStringAsFixed(2);
    }
    setState(() {});
  }

  void _toggleInvoiceRow(EditableOpenInvoiceRow row, bool? selected) {
    setState(() {
      row.isSelected = selected ?? false;
      if (row.isSelected && row.paymentAmount <= 0) {
        // Calculate remaining available amount
        final remaining = (_parsedAmountReceived - _appliedTotal).clamp(0.0, row.invoice.outstanding);
        row.paymentController.text = (remaining > 0 ? remaining : row.invoice.outstanding).toStringAsFixed(2);
      } else if (!row.isSelected) {
        row.paymentController.text = '0.00';
      }
    });
  }

  Future<void> _submitReceipt() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer'), backgroundColor: AppColors.error),
      );
      return;
    }

    final amount = _parsedAmountReceived;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount received must be greater than zero'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_appliedTotal > amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total applied (${_appliedTotal.toStringAsFixed(2)}) exceeds amount received (${amount.toStringAsFixed(2)}).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Convert allocated rows
    final allocatedInvoices = _openInvoiceRows.where((r) => r.isSelected && r.paymentAmount > 0).map((r) {
      return r.invoice.copyWith(appliedPayment: r.paymentAmount);
    }).toList();

    try {
      final receipt = await _salesService.createReceipt(
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        receiptDate: _receiptDateController.text.trim(),
        depositToAccountId: 3, // 1110
        depositToAccountName: _depositTo,
        paymentMethod: _paymentMethod,
        reference: _referenceController.text.trim(),
        amount: amount,
        allocatedInvoices: allocatedInvoices,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer receipt ${receipt.receiptNo} recorded and posted to ledger!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/sales/invoices');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save receipt: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Title
            _buildBreadcrumbsAndTitle(),
            const SizedBox(height: 18),

            // Two-Column Layout: Left Form & Invoices Table | Right Summary & Auto Journal (Figure 8)
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 960;

                if (!isDesktop) {
                  return Column(
                    children: [
                      _buildLeftFormCard(currencyFormatter, isMobile: isMobile),
                      const SizedBox(height: 18),
                      _buildRightSummaryCard(currencyFormatter, isMobile: isMobile),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Form Card (Expanded)
                    Expanded(
                      child: _buildLeftFormCard(currencyFormatter, isMobile: isMobile),
                    ),
                    const SizedBox(width: 18),

                    // Right Summary Card (Fixed width 330)
                    SizedBox(
                      width: 330,
                      child: _buildRightSummaryCard(currencyFormatter, isMobile: isMobile),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbsAndTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => context.go('/sales/invoices'),
              child: const Text('Sales', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('Receipts', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('New', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Record Customer Receipt',
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

  Widget _buildLeftFormCard(NumberFormat currencyFormatter, {bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 580;

          Widget customerField = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Customer>(
                    value: _selectedCustomer,
                    isExpanded: true,
                    items: _customers.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                    onChanged: _onCustomerChanged,
                  ),
                ),
              ),
            ],
          );

          Widget receiptDateField = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Receipt Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _receiptDateController,
                  style: const TextStyle(fontSize: 13),
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
          );

          Widget depositToField = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deposit To *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _depositTo,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '1110 – Emirates NBD Current', child: Text('1110 – Emirates NBD Current', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: '1120 – Petty Cash', child: Text('1120 – Petty Cash', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: '1130 – ADCB Operations', child: Text('1130 – ADCB Operations', style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _depositTo = val);
                    },
                  ),
                ),
              ),
            ],
          );

          Widget paymentMethodField = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Method', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _paymentMethod,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'Cheque', child: Text('Cheque', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'Card', child: Text('Card', style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentMethod = val);
                    },
                  ),
                ),
              ),
            ],
          );

          Widget amountReceivedField = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Amount Received *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _amountReceivedController,
                  onChanged: _onAmountReceivedChanged,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
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
          );

          Widget referenceField = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reference / Cheque No.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _referenceController,
                  style: const TextStyle(fontSize: 13),
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
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Customer * & Receipt Date *
              if (isNarrow) ...[
                customerField,
                const SizedBox(height: 12),
                receiptDateField,
              ] else ...[
                Row(
                  children: [
                    Expanded(child: customerField),
                    const SizedBox(width: 14),
                    Expanded(child: receiptDateField),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Row 2: Deposit To * & Payment Method
              if (isNarrow) ...[
                depositToField,
                const SizedBox(height: 12),
                paymentMethodField,
              ] else ...[
                Row(
                  children: [
                    Expanded(child: depositToField),
                    const SizedBox(width: 14),
                    Expanded(child: paymentMethodField),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Row 3: Amount Received * & Reference / Cheque No.
              if (isNarrow) ...[
                amountReceivedField,
                const SizedBox(height: 12),
                referenceField,
              ] else ...[
                Row(
                  children: [
                    Expanded(child: amountReceivedField),
                    const SizedBox(width: 14),
                    Expanded(child: referenceField),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Section Header: Apply to Outstanding Invoices (Figure 8)
              const Text(
                'Apply to Outstanding Invoices',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Invoices Table
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (_openInvoiceRows.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No open invoices found for this customer.', style: TextStyle(color: AppColors.textMuted)),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 550),
                    child: SizedBox(
                      width: constraints.maxWidth > 550 ? constraints.maxWidth : 550,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              color: const Color(0xFFF8FAFC),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              child: const Row(
                                children: [
                                  SizedBox(width: 32), // checkbox space
                                  Expanded(flex: 3, child: Text('Invoice #', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                  Expanded(flex: 3, child: Text('Date', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                  Expanded(flex: 3, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                  Expanded(flex: 3, child: Text('Outstanding', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                  SizedBox(width: 14),
                                  SizedBox(width: 95, child: Text('Payment', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.border),

                            // Table Rows
                            for (final row in _openInvoiceRows) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    // Checkbox
                                    SizedBox(
                                      width: 32,
                                      child: Checkbox(
                                        value: row.isSelected,
                                        onChanged: (val) => _toggleInvoiceRow(row, val),
                                        activeColor: const Color(0xFF2563EB),
                                      ),
                                    ),
                                    // Invoice #
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        row.invoice.invoiceNo,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    // Date
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        row.invoice.invoiceDate,
                                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                      ),
                                    ),
                                    // Total
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        currencyFormatter.format(row.invoice.total),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    // Outstanding
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        currencyFormatter.format(row.invoice.outstanding),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    // Payment Amount editable textfield
                                    SizedBox(
                                      width: 95,
                                      height: 34,
                                      child: TextField(
                                        controller: row.paymentController,
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => setState(() {}),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4),
                                            borderSide: const BorderSide(color: AppColors.border),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: AppColors.borderSubtle),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRightSummaryCard(NumberFormat currencyFormatter, {bool isMobile = false}) {
    final amountRec = _parsedAmountReceived;
    final applied = _appliedTotal;
    final unapplied = _unappliedTotal;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          _buildSummaryRow('Amount received', currencyFormatter.format(amountRec)),
          const SizedBox(height: 10),
          _buildSummaryRow('Applied to invoices', currencyFormatter.format(applied)),
          const SizedBox(height: 10),
          _buildSummaryRow('Unapplied (advance)', currencyFormatter.format(unapplied)),
          const SizedBox(height: 20),

          // Live "Auto journal" preview box (Figure 8)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto journal:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dr 1110 Emirates NBD   ${currencyFormatter.format(amountRec)}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF334155)),
                  ),
                  Text(
                    'Cr 1200 Accounts Receivable   ${currencyFormatter.format(applied)}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF334155)),
                  ),
                  if (unapplied > 0)
                    Text(
                      'Cr 2150 Customer Advances   ${currencyFormatter.format(unapplied)}',
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFFD97706)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Receipt Button (Figure 8)
          ElevatedButton(
            onPressed: _submitReceipt,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB), // Solid blue from Figure 8
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              elevation: 0,
            ),
            child: const Text(
              'Save Receipt',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
