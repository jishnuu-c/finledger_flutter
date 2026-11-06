import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/expense_models.dart';
import '../data/services/expense_service.dart';
import 'widgets/expense_approval_stepper.dart';
import 'widgets/mobile_camera_modal.dart';
import 'widgets/receipt_badge.dart';

class NewExpenseClaimScreen extends StatefulWidget {
  final ExpenseService? expenseService;

  const NewExpenseClaimScreen({super.key, this.expenseService});

  @override
  State<NewExpenseClaimScreen> createState() => _NewExpenseClaimScreenState();
}

class _NewExpenseClaimScreenState extends State<NewExpenseClaimScreen> {
  late final ExpenseService _expenseService;

  // Header State (Figure 12)
  String _paidBy = 'EMPLOYEE'; // 'EMPLOYEE' or 'COMPANY'
  String _selectedEmployee = 'Sara Mathew';
  String _selectedPaidFromAccount = '1110 - Emirates NBD Current';
  final TextEditingController _expenseNoController = TextEditingController(text: 'EXP-2026-0234 (auto)');
  final TextEditingController _dateController = TextEditingController(text: '30-Oct-2026');
  String _currency = 'AED';
  final TextEditingController _purposeController = TextEditingController(
    text: 'Abu Dhabi client visits - Al Noor & Gulf Hospitality',
  );

  // Categories & Lookup data
  List<ExpenseCategory> _categories = [];
  bool _isLoading = true;

  // Line items (Figure 12)
  final List<ExpenseLine> _lines = [];

  // Uploaded attachments (Right panel)
  final List<ExpenseAttachment> _attachments = [];

  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _expenseService = widget.expenseService ?? ExpenseService();
    _initData();
  }

  Future<void> _initData() async {
    final cats = await _expenseService.getCategories();
    if (!mounted) return;

    setState(() {
      _categories = cats;
      _isLoading = false;

      // Populate default lines matching Figure 12:
      // Line 1: Travel & Fuel | Fuel DXB <-> AUH | Sales | — | 280.00 | VAT 5% | 294.00 | 📎 1
      // Line 2: Tolls & Parking | Salik + parking | Sales | — | 96.00 | Exempt | 96.00 | 📎 1
      // Line 3: Client Meals | Lunch - Al Noor team | Sales | Al Noor | 420.00 | VAT 5% | 441.00 | ⚠️ Missing
      _lines.clear();
      _lines.addAll([
        const ExpenseLine(
          id: 1,
          lineNo: 1,
          categoryId: 1,
          categoryName: 'Travel & Fuel',
          description: 'Fuel DXB ↔ AUH',
          costCenter: 'Sales',
          billableTo: '—',
          amount: 280.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 14.00,
          totalAmount: 294.00,
          receiptCount: 1,
          isReceiptMissing: false,
        ),
        const ExpenseLine(
          id: 2,
          lineNo: 2,
          categoryId: 3,
          categoryName: 'Tolls & Parking',
          description: 'Salik + parking',
          costCenter: 'Sales',
          billableTo: '—',
          amount: 96.00,
          taxRateName: 'Exempt',
          taxRatePct: 0.0,
          taxAmount: 0.00,
          totalAmount: 96.00,
          receiptCount: 1,
          isReceiptMissing: false,
        ),
        const ExpenseLine(
          id: 3,
          lineNo: 3,
          categoryId: 2,
          categoryName: 'Client Meals',
          description: 'Lunch - Al Noor team',
          costCenter: 'Sales',
          billableTo: 'Al Noor',
          amount: 420.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 21.00,
          totalAmount: 441.00,
          receiptCount: 0,
          isReceiptMissing: true,
        ),
      ]);

      // Populate default attachments matching Figure 12
      _attachments.clear();
      _attachments.addAll([
        const ExpenseAttachment(
          id: 101,
          fileName: 'fuel_2910.jpg',
          contentType: 'image/jpeg',
          sizeBytes: 198000,
          storageKey: 'expenses/fuel_2910.jpg',
          uploadedAt: '30-Oct-2026',
        ),
        const ExpenseAttachment(
          id: 102,
          fileName: 'salik_oct.pdf',
          contentType: 'application/pdf',
          sizeBytes: 88000,
          storageKey: 'expenses/salik_oct.pdf',
          uploadedAt: '30-Oct-2026',
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _expenseNoController.dispose();
    _dateController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  // Calculated Totals
  double get _subtotalNet => _lines.fold<double>(0.0, (sum, l) => sum + l.amount);
  double get _taxTotal => _lines.fold<double>(0.0, (sum, l) => sum + l.taxAmount);
  double get _grandTotal => _lines.fold<double>(0.0, (sum, l) => sum + l.totalAmount);

  // Category policy check message
  String? get _categoryPolicyWarning {
    for (final line in _lines) {
      final cat = _categories.firstWhere(
        (c) => c.id == line.categoryId,
        orElse: () => ExpenseCategory(
          id: line.categoryId,
          name: line.categoryName,
          accountId: 6100,
          accountCode: '6100',
          accountName: 'Expense',
        ),
      );

      if (cat.name == 'Client Meals') {
        final limit = cat.limitPerClaim ?? 500.0;
        final isUnderLimit = line.amount <= limit;
        return 'Client Meals requires a receipt (category policy). Limit per claim AED ${limit.toStringAsFixed(0)} Net — ${isUnderLimit ? 'OK' : 'EXCEEDED'}.';
      }
    }
    return null;
  }

  void _onAddLine() {
    final defaultCat = _categories.firstOrNull ??
        const ExpenseCategory(
          id: 1,
          name: 'Travel & Fuel',
          accountId: 6100,
          accountCode: '6100',
          accountName: 'Travel',
        );

    setState(() {
      _lines.add(
        ExpenseLine(
          lineNo: _lines.length + 1,
          categoryId: defaultCat.id,
          categoryName: defaultCat.name,
          description: '',
          costCenter: 'Sales',
          billableTo: '—',
          amount: 0.0,
          taxRateName: defaultCat.defaultTaxRateName,
          taxRatePct: defaultCat.defaultTaxRatePct,
          taxAmount: 0.0,
          totalAmount: 0.0,
          receiptCount: 0,
          isReceiptMissing: defaultCat.receiptRequired,
        ),
      );
    });
  }

  void _onCategoryChanged(int index, String catName) {
    final cat = _categories.firstWhere((c) => c.name == catName);
    setState(() {
      final cur = _lines[index];
      final taxAmt = cur.amount * (cat.defaultTaxRatePct / 100);
      _lines[index] = cur.copyWith(
        categoryId: cat.id,
        categoryName: cat.name,
        taxRateName: cat.defaultTaxRateName,
        taxRatePct: cat.defaultTaxRatePct,
        taxAmount: taxAmt,
        totalAmount: cur.amount + taxAmt,
        isReceiptMissing: cat.receiptRequired && cur.receiptCount == 0,
      );
    });
  }

  void _onAmountChanged(int index, String val) {
    final parsed = double.tryParse(val) ?? 0.0;
    setState(() {
      final cur = _lines[index];
      final taxAmt = parsed * (cur.taxRatePct / 100);
      _lines[index] = cur.copyWith(
        amount: parsed,
        taxAmount: taxAmt,
        totalAmount: parsed + taxAmt,
      );
    });
  }

  void _openMobileCamera() {
    MobileCameraModal.show(
      context,
      expenseService: _expenseService,
      onReceiptCaptured: (attachment) {
        setState(() {
          _attachments.add(attachment);
          // If third line was missing receipt, mark attached
          if (_lines.length >= 3 && _lines[2].isReceiptMissing) {
            _lines[2] = _lines[2].copyWith(receiptCount: 1, isReceiptMissing: false);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attached receipt: ${attachment.fileName}'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      },
    );
  }

  Future<void> _submitClaim({required bool submitForApproval}) async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one line item.'), backgroundColor: Color(0xFFDC2626)),
      );
      return;
    }

    try {
      final expense = Expense(
        id: 0,
        expenseNo: _expenseNoController.text,
        expenseDate: _dateController.text,
        paidBy: _paidBy,
        paidByDisplay: _paidBy == 'EMPLOYEE' ? 'Employee' : 'Company - ENBD',
        employeeName: _paidBy == 'EMPLOYEE' ? _selectedEmployee : 'Company Account',
        purpose: _purposeController.text,
        categorySummary: _lines.first.categoryName,
        subtotal: _subtotalNet,
        taxTotal: _taxTotal,
        total: _grandTotal,
        lines: _lines,
        attachments: _attachments,
      );

      await _expenseService.createExpenseClaim(expense, submitForApproval: submitForApproval);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            submitForApproval
                ? 'Expense claim submitted for approval.'
                : 'Expense claim saved as draft.',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      context.go('/expenses');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving claim: $e'), backgroundColor: const Color(0xFFDC2626)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Breadcrumbs & Title (Figure 12)
                  _buildBreadcrumbsAndTitle(),
                  const SizedBox(height: 18),

                  // Main 2-Column Split Layout (Desktop) or Column (Mobile)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 1024;

                      if (!isDesktop) {
                        return Column(
                          children: [
                            _buildLeftClaimForm(),
                            const SizedBox(height: 20),
                            _buildRightPanel(),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildLeftClaimForm(),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 320,
                            child: _buildRightPanel(),
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
              onTap: () => context.go('/expenses'),
              child: const Text('Expenses', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const Text('  /  ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Text('New', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'New Expense Claim',
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

  Widget _buildLeftClaimForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Card (Paid by, Employee, Expense No., Date, Currency, Purpose)
        _buildHeaderCard(),
        const SizedBox(height: 20),

        // Line Items Card (Figure 12)
        _buildLinesCard(),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isStacked = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 950;

          if (isStacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaidByToggle(),
                const SizedBox(height: 14),
                _buildEmployeeOrAccountField(),
                const SizedBox(height: 14),
                _buildExpenseNoField(),
                const SizedBox(height: 14),
                _buildDateField(),
                const SizedBox(height: 14),
                _buildCurrencyField(),
                const SizedBox(height: 14),
                _buildPurposeField(),
              ],
            );
          }

          if (isTablet) {
            final halfWidth = (constraints.maxWidth - 14) / 2;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(width: halfWidth, child: _buildPaidByToggle()),
                SizedBox(width: halfWidth, child: _buildEmployeeOrAccountField()),
                SizedBox(width: halfWidth, child: _buildExpenseNoField()),
                SizedBox(width: halfWidth, child: _buildDateField()),
                SizedBox(width: (constraints.maxWidth - 14) * 0.35, child: _buildCurrencyField()),
                SizedBox(width: (constraints.maxWidth - 14) * 0.65, child: _buildPurposeField()),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: _buildPaidByToggle()),
                  const SizedBox(width: 14),
                  Expanded(flex: 4, child: _buildEmployeeOrAccountField()),
                  const SizedBox(width: 14),
                  Expanded(flex: 4, child: _buildExpenseNoField()),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildDateField()),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: _buildCurrencyField()),
                  const SizedBox(width: 14),
                  Expanded(flex: 7, child: _buildPurposeField()),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaidByToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Paid by *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _paidBy = 'COMPANY'),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _paidBy == 'COMPANY' ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business,
                          size: 14,
                          color: _paidBy == 'COMPANY' ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Company',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _paidBy == 'COMPANY' ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _paidBy = 'EMPLOYEE'),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _paidBy == 'EMPLOYEE' ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Employee\n(reimbursable)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: _paidBy == 'EMPLOYEE' ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeOrAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _paidBy == 'EMPLOYEE' ? 'Employee' : 'Paid From Account *',
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _paidBy == 'EMPLOYEE' ? _selectedEmployee : _selectedPaidFromAccount,
              isExpanded: true,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              items: _paidBy == 'EMPLOYEE'
                  ? const [
                      DropdownMenuItem(value: 'Sara Mathew', child: Text('Sara Mathew')),
                      DropdownMenuItem(value: 'Ahmed Khan', child: Text('Ahmed Khan')),
                      DropdownMenuItem(value: 'Raj', child: Text('Raj')),
                    ]
                  : const [
                      DropdownMenuItem(value: '1110 - Emirates NBD Current', child: Text('1110 - Emirates NBD Current')),
                      DropdownMenuItem(value: 'Company Credit Card - 4821', child: Text('Company Credit Card - 4821')),
                      DropdownMenuItem(value: 'Petty Cash DXB', child: Text('Petty Cash DXB')),
                    ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    if (_paidBy == 'EMPLOYEE') {
                      _selectedEmployee = val;
                    } else {
                      _selectedPaidFromAccount = val;
                    }
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseNoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expense No.', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            _expenseNoController.text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _dateController,
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

  Widget _buildCurrencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Currency', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currency,
              isExpanded: true,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
              items: const [
                DropdownMenuItem(value: 'AED', child: Text('AED')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'SAR', child: Text('SAR')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _currency = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Purpose', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _purposeController,
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
    );
  }

  Widget _buildLinesCard() {
    final policyWarning = _categoryPolicyWarning;

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
              const minWidth = 850.0;
              final effectiveWidth = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Column(
                    children: [
                      // Header Row (Figure 12)
                      Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text('Category *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 5, child: Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Cost center', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Billable to', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Net', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('VAT', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            SizedBox(width: 85, child: Center(child: Text('Receipt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))),
                            SizedBox(width: 24),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),

                      // Dynamic Line Rows
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _lines.length,
                        separatorBuilder: (context, _) => const Divider(height: 1, color: AppColors.borderSubtle),
                        itemBuilder: (context, index) {
                          final line = _lines[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                // Category Dropdown
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
                                        value: line.categoryName,
                                        isExpanded: true,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        items: _categories.map((c) {
                                          return DropdownMenuItem(value: c.name, child: Text(c.name));
                                        }).toList(),
                                        onChanged: (catName) {
                                          if (catName != null) _onCategoryChanged(index, catName);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Description Input
                                Expanded(
                                  flex: 5,
                                  child: SizedBox(
                                    height: 36,
                                    child: TextFormField(
                                      initialValue: line.description,
                                      style: const TextStyle(fontSize: 12.5),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          borderSide: const BorderSide(color: AppColors.border),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        _lines[index] = line.copyWith(description: val);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Cost center
                                Expanded(
                                  flex: 2,
                                  child: Text(line.costCenter, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                                ),

                                // Billable to
                                Expanded(
                                  flex: 2,
                                  child: Text(line.billableTo ?? '—', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                                ),

                                // Net Input
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: 76,
                                      height: 36,
                                      child: TextFormField(
                                        initialValue: line.amount.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            borderSide: const BorderSide(color: AppColors.border),
                                          ),
                                        ),
                                        onChanged: (val) => _onAmountChanged(index, val),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // VAT Code
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(line.taxRateName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ),
                                ),

                                // Total
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _currencyFormat.format(line.totalAmount),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),

                                // Receipt badge
                                SizedBox(
                                  width: 85,
                                  child: Center(
                                    child: ReceiptBadge(
                                      count: line.receiptCount,
                                      isMissing: line.isReceiptMissing,
                                      showLabel: true,
                                    ),
                                  ),
                                ),

                                // Remove line
                                SizedBox(
                                  width: 24,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 14, color: Color(0xFFDC2626)),
                                    onPressed: () {
                                      setState(() => _lines.removeAt(index));
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

          // + Add line action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: _onAddLine,
                  child: const Text(
                    '+ Add line',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
          ),

          // Policy check alert box (Figure 12)
          if (policyWarning != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: Row(
                children: [
                  const Text('⚠️ ', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      policyWarning,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
            ),

          // Subtotal, VAT, Total Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: const Color(0xFFF8FAFC),
            child: Wrap(
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Net', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Text(_currencyFormat.format(_subtotalNet), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('VAT', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Text(_currencyFormat.format(_taxTotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total (AED)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(width: 10),
                    Text(
                      _currencyFormat.format(_grandTotal),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // Bottom Action Buttons (Figure 12: Cancel, Save Draft, Submit for Approval)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/expenses'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
                ),
                OutlinedButton(
                  onPressed: () => _submitClaim(submitForApproval: false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Save Draft', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
                ),
                ElevatedButton(
                  onPressed: () => _submitClaim(submitForApproval: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Submit for Approval', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Receipts Upload Area (Figure 12)
        _buildReceiptsArea(),
        const SizedBox(height: 16),

        // 2. Approval Flow Stepper (Figure 12)
        ExpenseApprovalStepper(
          totalAmount: _grandTotal,
          employeeName: _selectedEmployee,
        ),
        const SizedBox(height: 16),

        // 3. "On approval posts" Journal Preview Box (Figure 12)
        _buildJournalPreviewBox(),
      ],
    );
  }

  Widget _buildReceiptsArea() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Receipts', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          // Drop / Camera click container
          InkWell(
            onTap: _openMobileCamera,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 28, color: Color(0xFF2563EB)),
                    SizedBox(height: 6),
                    Text(
                      'Drop receipt images or PDFs\nor take a photo on mobile',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Uploaded receipt cards matching Figure 12: fuel_2910.jpg & salik_oct.pdf
          if (_attachments.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _attachments.map((att) {
                return Container(
                  width: 95,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        att.isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                        size: 24,
                        color: const Color(0xFF38BDF8),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        att.fileName,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildJournalPreviewBox() {
    final net = _subtotalNet;
    final vat = _taxTotal;
    final total = _grandTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'On approval posts:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dr Expense accounts   ${_currencyFormat.format(net)}',
            style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: Color(0xFF334155)),
          ),
          const SizedBox(height: 2),
          Text(
            'Dr Input VAT          ${_currencyFormat.format(vat)}',
            style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: Color(0xFF334155)),
          ),
          const SizedBox(height: 2),
          Text(
            _paidBy == 'EMPLOYEE'
                ? 'Cr 2150 Employee Reimbursements  ${_currencyFormat.format(total)}'
                : 'Cr 1110 Emirates NBD Current      ${_currencyFormat.format(total)}',
            style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
