import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finledger/core/api/dio_client.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/features/accounting/data/models/account_model.dart';
import 'package:finledger/features/accounting/data/models/journal_entry_model.dart';
import 'package:finledger/features/accounting/data/services/accounting_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Chart of Accounts & Model Tests', () {
    test('Default accounts hierarchy matches Figure 13 and Table 16', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
      final service = AccountingService(dioClient: dioClient);

      final accounts = await service.getAccountsTree();
      expect(accounts.isNotEmpty, true);

      // Verify top-level group accounts are bold/group headers
      final assetsGroup = accounts.firstWhere((a) => a.code == '1000');
      expect(assetsGroup.name, 'Assets');
      expect(assetsGroup.isGroup, true);
      expect(assetsGroup.accountType, AccountType.asset);
      expect(assetsGroup.currentBalance, 2145870.00);

      final liabilitiesGroup = accounts.firstWhere((a) => a.code == '2000');
      expect(liabilitiesGroup.name, 'Liabilities');
      expect(liabilitiesGroup.isGroup, true);
      expect(liabilitiesGroup.currentBalance, 498210.00);

      final revenueGroup = accounts.firstWhere((a) => a.code == '4000');
      expect(revenueGroup.name, 'Revenue');
      expect(revenueGroup.isGroup, true);
      expect(revenueGroup.currentBalance, 2485300.00);

      final expensesGroup = accounts.firstWhere((a) => a.code == '5000');
      expect(expensesGroup.name, 'Expenses');
      expect(expensesGroup.isGroup, true);
      expect(expensesGroup.currentBalance, 1692140.00);
    });

    test('getPostingAccounts excludes group accounts from selection', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
      final service = AccountingService(dioClient: dioClient);

      final postingAccounts = await service.getPostingAccounts();

      // None of the posting accounts should have isGroup == true
      for (final acc in postingAccounts) {
        expect(acc.isGroup, false, reason: '${acc.code} ${acc.name} must not be a group account');
      }

      // Check specific posting accounts from Figure 13 & 14 exist
      expect(postingAccounts.any((a) => a.code == '5210' && a.name == 'Rent Expense'), true);
      expect(postingAccounts.any((a) => a.code == '2300' && a.name == 'Accrued Expenses'), true);
      expect(postingAccounts.any((a) => a.code == '1110' && a.name.contains('Emirates NBD')), true);
    });

    test('Creates new account and links to parent correctly', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
      final service = AccountingService(dioClient: dioClient);

      const newAccount = Account(
        id: 0,
        code: '5230',
        name: 'Cloud Hosting & Servers',
        accountType: AccountType.expense,
        subType: 'IT_EXPENSE',
        parentId: 13, // 5000 - Expenses
        isGroup: false,
        currentBalance: 0.0,
      );

      final created = await service.createAccount(newAccount);
      expect(created.id > 0, true);
      expect(created.code, '5230');
      expect(created.parentCode, '5000');
      expect(created.level, 1);

      final searchResult = await service.getAccountsTree(search: 'Cloud Hosting');
      expect(searchResult.any((a) => a.code == '5230'), true);
    });
  });

  group('Journal Entry Double-Entry Validation Tests', () {
    test('Validates double-entry balance and post entry successfully', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
      final service = AccountingService(dioClient: dioClient);

      // Balanced entry: AED 25,000.00 Rent Expense (Debit) and AED 25,000.00 Accrued Expenses (Credit)
      final lines = [
        const JournalLine(
          lineNo: 1,
          accountId: 15,
          accountCode: '5210',
          accountName: 'Rent Expense',
          description: 'Warehouse rent Oct',
          costCenter: 'Dubai WH',
          debit: 25000.00,
          credit: 0.0,
        ),
        const JournalLine(
          lineNo: 2,
          accountId: 10,
          accountCode: '2300',
          accountName: 'Accrued Expenses',
          description: 'Accrued rent',
          costCenter: 'Dubai WH',
          debit: 0.0,
          credit: 25000.00,
        ),
      ];

      final entry = await service.postJournalEntry(
        entryDate: '30-Oct-2026',
        reference: 'Accrual – Oct rent',
        narration: 'Monthly accrual of warehouse rent for October 2026',
        currencyCode: 'AED',
        lines: lines,
      );

      expect(entry.status, 'POSTED');
      expect(entry.totalDebit, 25000.00);
      expect(entry.totalCredit, 25000.00);
      expect(entry.isBalanced, true);
    });

    test('Throws error when journal entry is unbalanced (debit != credit)', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
      final service = AccountingService(dioClient: dioClient);

      final unbalancedLines = [
        const JournalLine(
          lineNo: 1,
          accountId: 15,
          accountCode: '5210',
          accountName: 'Rent Expense',
          description: 'Warehouse rent Oct',
          debit: 25000.00,
          credit: 0.0,
        ),
        const JournalLine(
          lineNo: 2,
          accountId: 10,
          accountCode: '2300',
          accountName: 'Accrued Expenses',
          description: 'Accrued rent',
          debit: 0.0,
          credit: 20000.00, // Unbalanced by 5000
        ),
      ];

      expect(
        () async => await service.postJournalEntry(
          entryDate: '30-Oct-2026',
          reference: 'Test',
          narration: 'Unbalanced test',
          currencyCode: 'AED',
          lines: unbalancedLines,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Throws error when journal entry has fewer than 2 lines', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
      final service = AccountingService(dioClient: dioClient);

      final singleLine = [
        const JournalLine(
          lineNo: 1,
          accountId: 15,
          accountCode: '5210',
          accountName: 'Rent Expense',
          description: 'Warehouse rent Oct',
          debit: 25000.00,
          credit: 0.0,
        ),
      ];

      expect(
        () async => await service.postJournalEntry(
          entryDate: '30-Oct-2026',
          reference: 'Test Single',
          narration: 'Single line test',
          currencyCode: 'AED',
          lines: singleLine,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Saves draft journal entry even if pending complete balance', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(tokenService: tokenService, loadingService: loadingService);
      final service = AccountingService(dioClient: dioClient);

      final lines = [
        const JournalLine(
          lineNo: 1,
          accountId: 15,
          accountCode: '5210',
          accountName: 'Rent Expense',
          description: 'Draft rent',
          debit: 10000.00,
          credit: 0.0,
        ),
      ];

      final draft = await service.createJournalDraft(
        entryDate: '30-Oct-2026',
        reference: 'DRAFT-REF',
        narration: 'Work in progress draft entry',
        currencyCode: 'AED',
        lines: lines,
      );

      expect(draft.status, 'DRAFT');
      expect(draft.totalDebit, 10000.00);
      expect(draft.entryNo.startsWith('JV-2026-'), true);
    });
  });
}
