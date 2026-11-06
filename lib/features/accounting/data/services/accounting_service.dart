import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/account_model.dart';
import '../models/journal_entry_model.dart';

class AccountingService {
  final DioClient dioClient;

  // In-memory cache & fallback mock state
  final List<Account> _accounts = [];
  final List<JournalEntry> _journalEntries = [];
  int _nextJournalId = 88;

  AccountingService({required this.dioClient}) {
    _initDefaultData();
  }

  void _initDefaultData() {
    if (_accounts.isNotEmpty) return;

    // Seed accounts hierarchy matching Figure 13
    _accounts.addAll([
      // Assets
      const Account(
        id: 1,
        code: '1000',
        name: 'Assets',
        accountType: AccountType.asset,
        isGroup: true,
        normalBalance: 'DEBIT',
        currentBalance: 2145870.00,
        level: 0,
      ),
      const Account(
        id: 2,
        code: '1100',
        name: 'Cash & Bank',
        accountType: AccountType.asset,
        parentId: 1,
        parentCode: '1000',
        isGroup: true,
        normalBalance: 'DEBIT',
        currentBalance: 918450.00,
        level: 1,
      ),
      const Account(
        id: 3,
        code: '1110',
        name: 'Emirates NBD – Current',
        accountType: AccountType.asset,
        subType: 'BANK',
        parentId: 2,
        parentCode: '1100',
        isGroup: false,
        normalBalance: 'DEBIT',
        currentBalance: 702300.00,
        level: 2,
      ),
      const Account(
        id: 4,
        code: '1120',
        name: 'Petty Cash',
        accountType: AccountType.asset,
        subType: 'CASH',
        parentId: 2,
        parentCode: '1100',
        isGroup: false,
        normalBalance: 'DEBIT',
        currentBalance: 4150.00,
        level: 2,
      ),
      const Account(
        id: 5,
        code: '1200',
        name: 'Accounts Receivable',
        accountType: AccountType.asset,
        subType: 'RECEIVABLE',
        parentId: 1,
        parentCode: '1000',
        isGroup: false,
        normalBalance: 'DEBIT',
        currentBalance: 384920.00,
        level: 1,
      ),
      const Account(
        id: 6,
        code: '1300',
        name: 'Inventory',
        accountType: AccountType.asset,
        subType: 'INVENTORY',
        parentId: 1,
        parentCode: '1000',
        isGroup: false,
        normalBalance: 'DEBIT',
        currentBalance: 612500.00,
        level: 1,
      ),

      // Liabilities
      const Account(
        id: 7,
        code: '2000',
        name: 'Liabilities',
        accountType: AccountType.liability,
        isGroup: true,
        normalBalance: 'CREDIT',
        currentBalance: 498210.00,
        level: 0,
      ),
      const Account(
        id: 8,
        code: '2100',
        name: 'Accounts Payable',
        accountType: AccountType.liability,
        subType: 'PAYABLE',
        parentId: 7,
        parentCode: '2000',
        isGroup: false,
        normalBalance: 'CREDIT',
        currentBalance: 213640.00,
        level: 1,
      ),
      const Account(
        id: 9,
        code: '2200',
        name: 'VAT Payable (Output)',
        accountType: AccountType.liability,
        subType: 'TAX',
        parentId: 7,
        parentCode: '2000',
        isGroup: false,
        normalBalance: 'CREDIT',
        currentBalance: 58320.00,
        level: 1,
      ),
      const Account(
        id: 10,
        code: '2300',
        name: 'Accrued Expenses',
        accountType: AccountType.liability,
        parentId: 7,
        parentCode: '2000',
        isGroup: false,
        normalBalance: 'CREDIT',
        currentBalance: 25000.00,
        level: 1,
      ),

      // Equity
      const Account(
        id: 11,
        code: '3000',
        name: 'Equity',
        accountType: AccountType.equity,
        isGroup: true,
        normalBalance: 'CREDIT',
        currentBalance: 1647660.00,
        level: 0,
      ),

      // Revenue
      const Account(
        id: 12,
        code: '4000',
        name: 'Revenue',
        accountType: AccountType.income,
        isGroup: true,
        normalBalance: 'CREDIT',
        currentBalance: 2485300.00,
        level: 0,
      ),

      // Expenses
      const Account(
        id: 13,
        code: '5000',
        name: 'Expenses',
        accountType: AccountType.expense,
        isGroup: true,
        normalBalance: 'DEBIT',
        currentBalance: 1692140.00,
        level: 0,
      ),
      const Account(
        id: 14,
        code: '5100',
        name: 'Cost of Goods Sold',
        accountType: AccountType.expense,
        subType: 'COGS',
        parentId: 13,
        parentCode: '5000',
        isGroup: false,
        normalBalance: 'DEBIT',
        currentBalance: 1120800.00,
        level: 1,
      ),
      const Account(
        id: 15,
        code: '5210',
        name: 'Rent Expense',
        accountType: AccountType.expense,
        parentId: 13,
        parentCode: '5000',
        isGroup: false,
        normalBalance: 'DEBIT',
        currentBalance: 180000.00,
        level: 1,
      ),
      const Account(
        id: 16,
        code: '5220',
        name: 'Utilities & Telco',
        accountType: AccountType.expense,
        parentId: 13,
        parentCode: '5000',
        isGroup: false,
        normalBalance: 'DEBIT',
        currentBalance: 45200.00,
        level: 1,
      ),
    ]);

    // Seed Journal Entries
    _journalEntries.addAll([
      const JournalEntry(
        id: 86,
        entryNo: 'JV-2026-0086',
        entryDate: '29-Oct-2026',
        reference: 'Depreciation – Vehicle fleet',
        narration: 'Monthly vehicle fleet straight-line depreciation',
        totalDebit: 12400.00,
        totalCredit: 12400.00,
        status: 'POSTED',
        lines: [
          JournalLine(
            id: 1,
            lineNo: 1,
            accountId: 13,
            accountCode: '5220',
            accountName: 'Utilities & Telco',
            description: 'Vehicle depreciation',
            costCenter: 'HQ',
            debit: 12400.00,
            credit: 0.0,
          ),
          JournalLine(
            id: 2,
            lineNo: 2,
            accountId: 1,
            accountCode: '1000',
            accountName: 'Assets',
            description: 'Accumulated depreciation',
            costCenter: 'HQ',
            debit: 0.0,
            credit: 12400.00,
          ),
        ],
      ),
      const JournalEntry(
        id: 87,
        entryNo: 'JV-2026-0087',
        entryDate: '30-Oct-2026',
        reference: 'Accrual – Oct rent',
        narration: 'Monthly accrual of warehouse rent for October 2026',
        totalDebit: 25000.00,
        totalCredit: 25000.00,
        status: 'POSTED',
        lines: [
          JournalLine(
            id: 3,
            lineNo: 1,
            accountId: 15,
            accountCode: '5210',
            accountName: 'Rent Expense',
            description: 'Warehouse rent Oct',
            costCenter: 'Dubai WH',
            debit: 25000.00,
            credit: 0.0,
          ),
          JournalLine(
            id: 4,
            lineNo: 2,
            accountId: 10,
            accountCode: '2300',
            accountName: 'Accrued Expenses',
            description: 'Accrued rent',
            costCenter: 'Dubai WH',
            debit: 0.0,
            credit: 25000.00,
          ),
        ],
      ),
    ]);
  }

  /// GET /api/v1/accounts/tree
  Future<List<Account>> getAccountsTree({String? search, String? type, String? status}) async {
    try {
      final response = await dioClient.dio.get(
        Endpoints.accountTree,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'q': search,
          if (type != null && type != 'All Types') 'type': type.toUpperCase(),
          if (status != null && status != 'All') 'active': status == 'Active',
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List).map((e) => Account.fromJson(e as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {
      // Fallback to local mock state
    }

    var filtered = List<Account>.from(_accounts);

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((a) => a.code.toLowerCase().contains(q) || a.name.toLowerCase().contains(q)).toList();
    }

    if (type != null && type != 'All Types') {
      filtered = filtered.where((a) => a.accountType.label.toLowerCase() == type.toLowerCase()).toList();
    }

    if (status != null && status != 'All') {
      final isActive = status == 'Active';
      filtered = filtered.where((a) => a.isActive == isActive).toList();
    }

    return filtered;
  }

  /// Get only posting accounts (isGroup == false) for selection in journal lines
  Future<List<Account>> getPostingAccounts() async {
    final all = await getAccountsTree();
    return all.where((a) => !a.isGroup && a.isActive).toList();
  }

  /// POST /api/v1/accounts
  Future<Account> createAccount(Account account) async {
    try {
      final response = await dioClient.dio.post(
        Endpoints.accounts,
        data: account.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) {
        final created = Account.fromJson(response.data as Map<String, dynamic>);
        _accounts.add(created);
        return created;
      }
    } catch (_) {
      // Offline fallback
    }

    final newId = (_accounts.map((a) => a.id).fold<int>(0, (max, id) => id > max ? id : max)) + 1;
    final parent = account.parentId != null ? _accounts.firstWhere((a) => a.id == account.parentId, orElse: () => account) : null;
    final created = account.copyWith(
      id: newId,
      parentCode: parent?.code,
      level: (parent != null ? parent.level + 1 : 0),
    );

    _accounts.add(created);
    return created;
  }

  /// GET /api/v1/journal-entries
  Future<List<JournalEntry>> getJournalEntries() async {
    try {
      final response = await dioClient.dio.get(Endpoints.journalEntries);
      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List).map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}

    return List.unmodifiable(_journalEntries);
  }

  /// Generate next entry number e.g. "JV-2026-0088"
  String getNextEntryNumber() {
    final numStr = _nextJournalId.toString().padLeft(4, '0');
    return 'JV-2026-$numStr';
  }

  /// POST /api/v1/journal-entries (Draft)
  Future<JournalEntry> createJournalDraft({
    required String entryDate,
    required String reference,
    required String narration,
    required String currencyCode,
    required List<JournalLine> lines,
  }) async {
    final totalDebit = lines.fold<double>(0.0, (sum, l) => sum + l.debit);
    final totalCredit = lines.fold<double>(0.0, (sum, l) => sum + l.credit);
    final entryNo = getNextEntryNumber();
    _nextJournalId++;

    final entry = JournalEntry(
      id: _nextJournalId,
      entryNo: entryNo,
      entryDate: entryDate,
      reference: reference,
      narration: narration,
      currencyCode: currencyCode,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      status: 'DRAFT',
      lines: lines,
    );

    try {
      await dioClient.dio.post(Endpoints.journalEntries, data: entry.toJson());
    } catch (_) {}

    _journalEntries.insert(0, entry);
    return entry;
  }

  /// POST /api/v1/journal-entries/{id}/post (Validate and Post)
  Future<JournalEntry> postJournalEntry({
    required String entryDate,
    required String reference,
    required String narration,
    required String currencyCode,
    required List<JournalLine> lines,
  }) async {
    final totalDebit = lines.fold<double>(0.0, (sum, l) => sum + l.debit);
    final totalCredit = lines.fold<double>(0.0, (sum, l) => sum + l.credit);

    // Business validation rule per Page 28
    if (lines.length < 2) {
      throw Exception('A journal entry must contain at least two lines.');
    }
    if ((totalDebit - totalCredit).abs() > 0.001 || totalDebit <= 0) {
      throw Exception('Unbalanced journal entry: Total debits (AED $totalDebit) must equal total credits (AED $totalCredit).');
    }

    final entryNo = getNextEntryNumber();
    _nextJournalId++;

    final entry = JournalEntry(
      id: _nextJournalId,
      entryNo: entryNo,
      entryDate: entryDate,
      reference: reference,
      narration: narration,
      currencyCode: currencyCode,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      status: 'POSTED',
      lines: lines,
    );

    try {
      // 1. Create draft
      final createResp = await dioClient.dio.post(Endpoints.journalEntries, data: entry.toJson());
      final id = createResp.data?['id'] ?? entry.id;

      // 2. Post entry
      await dioClient.dio.post('${Endpoints.journalEntries}/$id/post');
    } catch (_) {}

    _journalEntries.insert(0, entry);
    return entry;
  }
}
