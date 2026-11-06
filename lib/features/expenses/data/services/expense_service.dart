import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/expense_models.dart';

class ExpenseService {
  final DioClient? dioClient;
  final Dio? _dio;

  ExpenseService({this.dioClient, Dio? dio}) : _dio = dio ?? dioClient?.dio;

  // Categories (Table 45 & Page 70)
  static final List<ExpenseCategory> _defaultCategories = [
    const ExpenseCategory(
      id: 1,
      name: 'Travel & Fuel',
      accountId: 6100,
      accountCode: '6100',
      accountName: 'Travel & Transportation',
      defaultTaxRatePct: 5.0,
      defaultTaxRateName: 'VAT 5%',
      limitPerClaim: null,
      receiptRequired: true,
    ),
    const ExpenseCategory(
      id: 2,
      name: 'Client Meals',
      accountId: 6110,
      accountCode: '6110',
      accountName: 'Business Meals & Entertainment',
      defaultTaxRatePct: 5.0,
      defaultTaxRateName: 'VAT 5%',
      limitPerClaim: 500.0,
      receiptRequired: true,
    ),
    const ExpenseCategory(
      id: 3,
      name: 'Tolls & Parking',
      accountId: 6120,
      accountCode: '6120',
      accountName: 'Tolls & Parking Charges',
      defaultTaxRatePct: 0.0,
      defaultTaxRateName: 'Exempt',
      limitPerClaim: 150.0,
      receiptRequired: true,
    ),
    const ExpenseCategory(
      id: 4,
      name: 'Utilities',
      accountId: 6200,
      accountCode: '6200',
      accountName: 'Utilities (Electricity & Water)',
      defaultTaxRatePct: 5.0,
      defaultTaxRateName: 'VAT 5%',
      limitPerClaim: null,
      receiptRequired: true,
    ),
    const ExpenseCategory(
      id: 5,
      name: 'Marketing',
      accountId: 6300,
      accountCode: '6300',
      accountName: 'Marketing & Digital Advertising',
      defaultTaxRatePct: 5.0,
      defaultTaxRateName: 'VAT 5%',
      limitPerClaim: null,
      receiptRequired: true,
    ),
    const ExpenseCategory(
      id: 6,
      name: 'Accommodation',
      accountId: 6130,
      accountCode: '6130',
      accountName: 'Hotel & Lodging',
      defaultTaxRatePct: 5.0,
      defaultTaxRateName: 'VAT 5%',
      limitPerClaim: 1000.0,
      receiptRequired: true,
    ),
    const ExpenseCategory(
      id: 7,
      name: 'Telecom',
      accountId: 6210,
      accountCode: '6210',
      accountName: 'Telephone & Internet Service',
      defaultTaxRatePct: 5.0,
      defaultTaxRateName: 'VAT 5%',
      limitPerClaim: null,
      receiptRequired: true,
    ),
    const ExpenseCategory(
      id: 8,
      name: 'Office Supplies',
      accountId: 6400,
      accountCode: '6400',
      accountName: 'Printing & Office Stationery',
      defaultTaxRatePct: 5.0,
      defaultTaxRateName: 'VAT 5%',
      limitPerClaim: 300.0,
      receiptRequired: true,
    ),
  ];

  // Default Expenses matching Figure 11 (Page 20)
  static final List<Expense> _defaultExpenses = [
    Expense(
      id: 1,
      expenseNo: 'EXP-2026-0233',
      expenseDate: '29-Oct',
      paidBy: 'EMPLOYEE',
      paidByDisplay: 'Employee',
      employeeName: 'Sara Mathew',
      purpose: 'Abu Dhabi client meetings travel & fuel',
      categorySummary: 'Travel & Fuel',
      subtotal: 1240.00,
      taxTotal: 62.00,
      total: 1302.00,
      attachmentCount: 2,
      hasMissingReceipt: false,
      status: 'SUBMITTED',
      lines: const [
        ExpenseLine(
          id: 1,
          lineNo: 1,
          categoryId: 1,
          categoryName: 'Travel & Fuel',
          description: 'Fuel & Highway toll charges',
          costCenter: 'Sales',
          amount: 1240.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 62.00,
          totalAmount: 1302.00,
          receiptCount: 2,
        ),
      ],
      attachments: const [
        ExpenseAttachment(
          id: 1,
          fileName: 'fuel_adnoc.jpg',
          contentType: 'image/jpeg',
          sizeBytes: 245000,
          storageKey: 'expenses/fuel_adnoc.jpg',
          uploadedAt: '29-Oct-2026',
        ),
        ExpenseAttachment(
          id: 2,
          fileName: 'toll_receipt.pdf',
          contentType: 'application/pdf',
          sizeBytes: 112000,
          storageKey: 'expenses/toll_receipt.pdf',
          uploadedAt: '29-Oct-2026',
        ),
      ],
    ),
    Expense(
      id: 2,
      expenseNo: 'EXP-2026-0232',
      expenseDate: '29-Oct',
      paidBy: 'EMPLOYEE',
      paidByDisplay: 'Employee',
      employeeName: 'Ahmed Khan',
      purpose: 'Client business lunch with prospective accounts',
      categorySummary: 'Client Meals',
      subtotal: 480.00,
      taxTotal: 24.00,
      total: 504.00,
      attachmentCount: 1,
      hasMissingReceipt: false,
      status: 'SUBMITTED',
      lines: const [
        ExpenseLine(
          id: 2,
          lineNo: 1,
          categoryId: 2,
          categoryName: 'Client Meals',
          description: 'Lunch meeting - DIFC Bistro',
          costCenter: 'Sales',
          amount: 480.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 24.00,
          totalAmount: 504.00,
          receiptCount: 1,
        ),
      ],
      attachments: const [
        ExpenseAttachment(
          id: 3,
          fileName: 'difc_bistro_bill.jpg',
          contentType: 'image/jpeg',
          sizeBytes: 310000,
          storageKey: 'expenses/difc_bistro_bill.jpg',
          uploadedAt: '29-Oct-2026',
        ),
      ],
    ),
    const Expense(
      id: 3,
      expenseNo: 'EXP-2026-0231',
      expenseDate: '28-Oct',
      paidBy: 'COMPANY',
      paidByDisplay: 'Company - ENBD',
      employeeName: 'DEWA',
      payeeName: 'Dubai Electricity & Water Authority',
      bankAccountId: 1,
      bankAccountName: '1110 - Emirates NBD Current',
      purpose: 'HQ office utility invoice October 2026',
      categorySummary: 'Utilities',
      subtotal: 6800.00,
      taxTotal: 340.00,
      total: 7140.00,
      attachmentCount: 1,
      hasMissingReceipt: false,
      status: 'POSTED',
      lines: [
        ExpenseLine(
          id: 3,
          lineNo: 1,
          categoryId: 4,
          categoryName: 'Utilities',
          description: 'October Electricity & Water bill',
          costCenter: 'Administration',
          amount: 6800.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 340.00,
          totalAmount: 7140.00,
          receiptCount: 1,
        ),
      ],
    ),
    const Expense(
      id: 4,
      expenseNo: 'EXP-2026-0229',
      expenseDate: '27-Oct',
      paidBy: 'COMPANY',
      paidByDisplay: 'Company - Card',
      employeeName: 'Raj',
      purpose: 'LinkedIn and Google Ads regional promotion',
      categorySummary: 'Marketing',
      subtotal: 3500.00,
      taxTotal: 175.00,
      total: 3675.00,
      attachmentCount: 3,
      hasMissingReceipt: false,
      status: 'POSTED',
      lines: [
        ExpenseLine(
          id: 4,
          lineNo: 1,
          categoryId: 5,
          categoryName: 'Marketing',
          description: 'Q4 B2B Lead generation campaigns',
          costCenter: 'Marketing',
          amount: 3500.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 175.00,
          totalAmount: 3675.00,
          receiptCount: 3,
        ),
      ],
    ),
    const Expense(
      id: 5,
      expenseNo: 'EXP-2026-0227',
      expenseDate: '25-Oct',
      paidBy: 'EMPLOYEE',
      paidByDisplay: 'Employee',
      employeeName: 'Sara Mathew',
      purpose: 'Riyadh Exhibition accommodation',
      categorySummary: 'Accommodation',
      subtotal: 2100.00,
      taxTotal: 105.00,
      total: 2205.00,
      attachmentCount: 1,
      hasMissingReceipt: false,
      status: 'APPROVED',
      lines: [
        ExpenseLine(
          id: 5,
          lineNo: 1,
          categoryId: 6,
          categoryName: 'Accommodation',
          description: 'Hotel stay in Riyadh (2 nights)',
          costCenter: 'Sales',
          amount: 2100.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 105.00,
          totalAmount: 2205.00,
          receiptCount: 1,
        ),
      ],
    ),
    const Expense(
      id: 6,
      expenseNo: 'EXP-2026-0225',
      expenseDate: '24-Oct',
      paidBy: 'EMPLOYEE',
      paidByDisplay: 'Employee',
      employeeName: 'Ahmed Khan',
      purpose: 'Fujairah trip without receipt attached',
      categorySummary: 'Travel & Fuel',
      subtotal: 960.00,
      taxTotal: 48.00,
      total: 1008.00,
      attachmentCount: 0,
      hasMissingReceipt: true,
      status: 'REJECTED',
      rejectionReason: 'Mandatory tax invoice receipt missing as per company expense policy.',
      lines: [
        ExpenseLine(
          id: 6,
          lineNo: 1,
          categoryId: 1,
          categoryName: 'Travel & Fuel',
          description: 'Client visit transportation',
          costCenter: 'Sales',
          amount: 960.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 48.00,
          totalAmount: 1008.00,
          receiptCount: 0,
          isReceiptMissing: true,
        ),
      ],
    ),
    const Expense(
      id: 7,
      expenseNo: 'EXP-2026-0221',
      expenseDate: '22-Oct',
      paidBy: 'COMPANY',
      paidByDisplay: 'Company - ENBD',
      employeeName: 'Etisalat',
      payeeName: 'Emirates Telecom Corp',
      bankAccountId: 1,
      bankAccountName: '1110 - Emirates NBD Current',
      purpose: 'HQ leased line and mobile connections',
      categorySummary: 'Telecom',
      subtotal: 1450.00,
      taxTotal: 72.50,
      total: 1522.50,
      attachmentCount: 1,
      hasMissingReceipt: false,
      status: 'POSTED',
      lines: [
        ExpenseLine(
          id: 7,
          lineNo: 1,
          categoryId: 7,
          categoryName: 'Telecom',
          description: 'Monthly office fibre & mobile plan',
          costCenter: 'Administration',
          amount: 1450.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 72.50,
          totalAmount: 1522.50,
          receiptCount: 1,
        ),
      ],
    ),
    const Expense(
      id: 8,
      expenseNo: 'EXP-2026-0218',
      expenseDate: '20-Oct',
      paidBy: 'EMPLOYEE',
      paidByDisplay: 'Employee',
      employeeName: 'Sara Mathew',
      purpose: 'Stationery and printer toner replenishment',
      categorySummary: 'Office Supplies',
      subtotal: 310.00,
      taxTotal: 15.50,
      total: 325.50,
      attachmentCount: 1,
      hasMissingReceipt: false,
      status: 'REIMBURSED',
      lines: [
        ExpenseLine(
          id: 8,
          lineNo: 1,
          categoryId: 8,
          categoryName: 'Office Supplies',
          description: 'A4 paper cartons & cartridge toner',
          costCenter: 'Administration',
          amount: 310.00,
          taxRateName: 'VAT 5%',
          taxRatePct: 5.0,
          taxAmount: 15.50,
          totalAmount: 325.50,
          receiptCount: 1,
        ),
      ],
    ),
  ];

  final List<Expense> _expenses = List.from(_defaultExpenses);
  int _nextClaimNumber = 234;

  /// Fetch 4 KPI Cards (Figure 11)
  Future<ExpenseKpis> getExpenseKpis() async {
    try {
      final response = await _dio?.get('/expenses/kpis');
      if (response != null && response.data != null) {
        return ExpenseKpis.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback
    }
    return const ExpenseKpis(
      thisMonthPosted: 46320.0,
      vsPreviousMonthPct: 4.2,
      awaitingApproval: 14860.0,
      awaitingClaimsCount: 9,
      toReimburse: 6215.0,
      toReimburseClaimsCount: 4,
      topCategory: 'Travel & Fuel',
      topCategoryAmount: 12480.0,
    );
  }

  /// Fetch Categories (GET /api/v1/expense-categories)
  Future<List<ExpenseCategory>> getCategories() async {
    try {
      final response = await _dio?.get(Endpoints.expenseCategories);
      if (response != null && response.data != null) {
        final list = response.data is List ? response.data as List : response.data['data'] as List;
        return list.map((json) => ExpenseCategory.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultCategories;
  }

  /// Fetch Expenses by tab (GET /api/v1/expenses?tab=)
  Future<List<Expense>> getExpenses({
    String tab = 'all',
    String? search,
    String? from,
    String? to,
  }) async {
    try {
      final response = await _dio?.get(
        Endpoints.expenses,
        queryParameters: {
          'tab': tab,
          'search': ?search,
          'from': ?from,
          'to': ?to,
        },
      );
      if (response != null && response.data != null) {
        final list = response.data is List ? response.data as List : response.data['data'] as List;
        return list.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback
    }

    var result = List<Expense>.from(_expenses);

    // Filter by tab
    switch (tab.toLowerCase()) {
      case 'my':
      case 'my expenses':
        result = result.where((e) => e.employeeName == 'Sara Mathew').toList();
        break;
      case 'approvals':
      case 'awaiting my approval':
        result = result.where((e) => e.status == 'SUBMITTED').toList();
        break;
      case 'reimburse':
      case 'to reimburse':
        result = result.where((e) => e.status == 'APPROVED' && e.paidBy == 'EMPLOYEE').toList();
        break;
      case 'all':
      default:
        break;
    }

    // Filter by search
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      result = result.where((e) {
        return e.expenseNo.toLowerCase().contains(q) ||
            e.employeeName.toLowerCase().contains(q) ||
            e.categorySummary.toLowerCase().contains(q) ||
            e.purpose.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  /// Approve expense (POST /api/v1/expenses/{id}/approve)
  Future<Expense> approveExpense(int id) async {
    try {
      final response = await _dio?.post('${Endpoints.expenses}/$id/approve');
      if (response != null && response.data != null) {
        return Expense.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback
    }

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      final cur = _expenses[index];
      final newStatus = cur.paidBy == 'COMPANY' ? 'POSTED' : 'APPROVED';
      final updated = cur.copyWith(
        status: newStatus,
        approvedBy: 'Raj (Line Manager)',
      );
      _expenses[index] = updated;
      return updated;
    }
    throw Exception('Expense with ID $id not found');
  }

  /// Reject expense (POST /api/v1/expenses/{id}/reject)
  Future<Expense> rejectExpense(int id, {String reason = 'Policy compliance rejected'}) async {
    try {
      final response = await _dio?.post(
        '${Endpoints.expenses}/$id/reject',
        data: {'reason': reason},
      );
      if (response != null && response.data != null) {
        return Expense.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback
    }

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      final cur = _expenses[index];
      final updated = cur.copyWith(
        status: 'REJECTED',
        rejectionReason: reason,
      );
      _expenses[index] = updated;
      return updated;
    }
    throw Exception('Expense with ID $id not found');
  }

  /// Reimburse expense (POST /api/v1/expenses/reimburse)
  Future<Expense> reimburseExpense(int id) async {
    try {
      final response = await _dio?.post(
        '${Endpoints.expenses}/reimburse',
        data: {'expenseId': id},
      );
      if (response != null && response.data != null) {
        return Expense.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback
    }

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      final cur = _expenses[index];
      final updated = cur.copyWith(
        status: 'REIMBURSED',
      );
      _expenses[index] = updated;
      return updated;
    }
    throw Exception('Expense with ID $id not found');
  }

  /// Bulk Approve selected claims
  Future<int> bulkApprove(List<int> ids) async {
    int count = 0;
    for (final id in ids) {
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1 && _expenses[index].status == 'SUBMITTED') {
        _expenses[index] = _expenses[index].copyWith(status: 'APPROVED');
        count++;
      }
    }
    return count;
  }

  /// Bulk Reimburse selected claims
  Future<int> bulkReimburse(List<int> ids) async {
    int count = 0;
    for (final id in ids) {
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1 && _expenses[index].status == 'APPROVED') {
        _expenses[index] = _expenses[index].copyWith(status: 'REIMBURSED');
        count++;
      }
    }
    return count;
  }

  /// Create new Expense Claim (POST /api/v1/expenses & /submit)
  Future<Expense> createExpenseClaim(
    Expense expense, {
    bool submitForApproval = false,
  }) async {
    if (expense.lines.isEmpty) {
      throw Exception('Expense claim must contain at least one line item.');
    }

    try {
      final endpoint = submitForApproval
          ? '${Endpoints.expenses}/submit'
          : Endpoints.expenses;
      final response = await _dio?.post(
        endpoint,
        data: expense.toJson(),
      );
      if (response != null && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['data'] ?? response.data)
            : response.data;
        return Expense.fromJson(data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback
    }

    final newId = _expenses.length + 1;
    final expNo = expense.expenseNo.isNotEmpty && !expense.expenseNo.contains('(auto)')
        ? expense.expenseNo
        : 'EXP-2026-0$_nextClaimNumber';
    _nextClaimNumber++;

    final saved = Expense(
      id: newId,
      expenseNo: expNo,
      expenseDate: expense.expenseDate,
      paidBy: expense.paidBy,
      paidByDisplay: expense.paidByDisplay,
      employeeName: expense.employeeName,
      payeeName: expense.payeeName,
      bankAccountId: expense.bankAccountId,
      bankAccountName: expense.bankAccountName,
      currencyCode: expense.currencyCode,
      purpose: expense.purpose,
      categorySummary: expense.lines.first.categoryName,
      subtotal: expense.subtotal,
      taxTotal: expense.taxTotal,
      total: expense.total,
      attachmentCount: expense.attachments.length,
      hasMissingReceipt: expense.lines.any((l) => l.isReceiptMissing),
      status: submitForApproval ? 'SUBMITTED' : 'DRAFT',
      submittedAt: submitForApproval ? '30-Oct-2026' : null,
      lines: expense.lines,
      attachments: expense.attachments,
    );

    _expenses.insert(0, saved);
    return saved;
  }

  /// Simulates multipart attachment upload (POST /api/v1/attachments)
  Future<ExpenseAttachment> uploadAttachment(
    String fileName, {
    int sizeBytes = 180000,
    String? localPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'entityType': 'EXPENSE',
        'file': MultipartFile.fromString('mock-bytes', filename: fileName),
      });
      final response = await _dio?.post('/attachments', data: formData);
      if (response != null && response.data != null) {
        return ExpenseAttachment.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback
    }

    return ExpenseAttachment(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      fileName: fileName,
      contentType: fileName.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
      sizeBytes: sizeBytes,
      storageKey: 'expenses/$fileName',
      localPath: localPath,
      uploadedAt: '30-Oct-2026',
    );
  }
}
