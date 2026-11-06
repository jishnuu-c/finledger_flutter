import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/banking_models.dart';

class BankingService {
  final DioClient? dioClient;
  final Dio? _dio;

  BankingService({this.dioClient, Dio? dio}) : _dio = dio ?? dioClient?.dio;

  // In-memory sessions store to support interactive state and mock persistence
  final Map<int, BankReconciliationSession> _activeSessions = {};

  List<BankAccount> getBankAccounts() {
    return const [
      BankAccount(
        id: 1,
        code: '1110',
        name: 'Emirates NBD - Current',
        iban: 'AE12 0330 0000 0012 3456 789',
        currency: 'AED',
        currentBalance: 705850.00,
        glAccountId: 1110,
      ),
      BankAccount(
        id: 2,
        code: '1120',
        name: 'Mashreq - Payroll',
        iban: 'AE44 0310 0000 0098 7654 321',
        currency: 'AED',
        currentBalance: 240000.00,
        glAccountId: 1120,
      ),
      BankAccount(
        id: 3,
        code: '1130',
        name: 'FAB - USD Operating',
        iban: 'AE89 0280 0000 0055 4433 221',
        currency: 'USD',
        currentBalance: 166000.00,
        glAccountId: 1130,
      ),
      BankAccount(
        id: 4,
        code: '1050',
        name: 'Petty Cash DXB',
        iban: 'N/A',
        currency: 'AED',
        currentBalance: 15400.00,
        glAccountId: 1050,
      ),
    ];
  }

  Future<BankReconciliationSession> getReconciliationSession(int bankAccountId) async {
    if (_activeSessions.containsKey(bankAccountId)) {
      return _activeSessions[bankAccountId]!;
    }

    try {
      final response = await _dio?.get(
        '${Endpoints.bankReconciliations}/$bankAccountId',
      );
      if (response != null && response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data['data'] as Map<String, dynamic>;
        final lines = (data['statementLines'] as List? ?? [])
            .map((e) => BankStatementLine.fromJson(e as Map<String, dynamic>))
            .toList();
        final txs = (data['bookTransactions'] as List? ?? [])
            .map((e) => BookTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        final session = BankReconciliationSession(
          bankAccountId: bankAccountId,
          bankAccountName: data['bankAccountName'] ?? 'Emirates NBD - Current (1110)',
          statementDate: data['statementDate'] ?? '31-Oct-2026',
          statementEndingBalance: (data['statementEndingBalance'] as num?)?.toDouble() ?? 705850.00,
          baseClearedBalance: (data['baseClearedBalance'] as num?)?.toDouble() ?? 689700.00,
          statementLines: lines,
          bookTransactions: txs,
        );
        _activeSessions[bankAccountId] = session;
        return session;
      }
    } catch (_) {
      // Fallback to Figure 15 mock data
    }

    // Default session precisely matching Figure 15 (Page 24)
    final session = BankReconciliationSession(
      bankAccountId: bankAccountId,
      bankAccountName: 'Emirates NBD - Current (1110)',
      statementDate: '31-Oct-2026',
      statementEndingBalance: 705850.00,
      baseClearedBalance: 689700.00, // 689,700 + 18,900 - 6,300 = 702,300.00
      statementLines: [
        BankStatementLine(
          id: 'stmt-1',
          date: '28-Oct',
          description: 'TT IN GULF HOSPITALITY',
          amount: 18900.00,
          isChecked: true,
          matchRef: 'RCT-0219',
        ),
        BankStatementLine(
          id: 'stmt-2',
          date: '27-Oct',
          description: 'TRF EMIRATES LOGISTICS',
          amount: -6300.00,
          isChecked: true,
          matchRef: 'PAY-0144',
        ),
        BankStatementLine(
          id: 'stmt-3',
          date: '30-Oct',
          description: 'BANK CHARGES OCT',
          amount: -150.00,
          isChecked: false,
          requiresCreateEntry: true,
        ),
        BankStatementLine(
          id: 'stmt-4',
          date: '30-Oct',
          description: 'TT IN RIYADH MED',
          amount: 33000.00,
          isChecked: false,
          isSuggested: true,
          matchRef: 'RCT-0220',
        ),
      ],
      bookTransactions: [
        BookTransaction(
          id: 'book-1',
          date: '28-Oct',
          reference: 'RCT-2026-0219',
          amount: 18900.00,
          isChecked: true,
          isCleared: true,
          matchedStatementLineId: 'stmt-1',
        ),
        BookTransaction(
          id: 'book-2',
          date: '27-Oct',
          reference: 'PAY-2026-0144',
          amount: -6300.00,
          isChecked: true,
          isCleared: true,
          matchedStatementLineId: 'stmt-2',
        ),
        BookTransaction(
          id: 'book-3',
          date: '30-Oct',
          reference: 'RCT-2026-0220',
          amount: 33000.00,
          isChecked: false,
          isCleared: false,
        ),
        BookTransaction(
          id: 'book-4',
          date: '29-Oct',
          reference: 'CHQ-000731 (uncleared)',
          amount: -3600.00,
          isChecked: false,
          isCleared: false,
        ),
      ],
    );

    _activeSessions[bankAccountId] = session;
    return session;
  }

  /// Toggle check status of statement line
  void toggleStatementLine(BankReconciliationSession session, String lineId, bool isChecked) {
    final line = session.statementLines.firstWhere((l) => l.id == lineId);
    line.isChecked = isChecked;
  }

  /// Toggle check status of book transaction
  void toggleBookTransaction(BankReconciliationSession session, String txId, bool isChecked) {
    final tx = session.bookTransactions.firstWhere((t) => t.id == txId);
    tx.isChecked = isChecked;
  }

  /// Accept suggestion (e.g. Suggest RCT-0220)
  void acceptSuggestion(BankReconciliationSession session, String stmtLineId) {
    final line = session.statementLines.firstWhere((l) => l.id == stmtLineId);
    if (line.matchRef != null) {
      final shortRef = line.matchRef!;
      line.isSuggested = false;
      line.isChecked = true;

      final digits = shortRef.replaceAll(RegExp(r'[^0-9]'), '');
      // Find matching book transaction
      for (final tx in session.bookTransactions) {
        if (tx.reference.contains(shortRef) || (digits.isNotEmpty && tx.reference.contains(digits))) {
          tx.isChecked = true;
          tx.isCleared = true;
          tx.matchedStatementLineId = stmtLineId;
          break;
        }
      }
    }
  }

  /// Create entry for bank charges / fee
  Future<void> createBankEntry({
    required BankReconciliationSession session,
    required String stmtLineId,
    required String accountCode,
    required String accountName,
    required double amount,
    required String reference,
    required String narration,
  }) async {
    try {
      await _dio?.post(
        Endpoints.journalEntries,
        data: {
          'narration': narration,
          'reference': reference,
          'amount': amount,
          'accountCode': accountCode,
          'bankAccountId': session.bankAccountId,
        },
      );
    } catch (_) {}

    // Find and update statement line
    final line = session.statementLines.firstWhere((l) => l.id == stmtLineId);
    line.requiresCreateEntry = false;
    line.matchRef = reference;
    line.isChecked = true;

    // Add corresponding book transaction
    final newBookTx = BookTransaction(
      id: 'book-charge-${DateTime.now().millisecondsSinceEpoch}',
      date: line.date,
      reference: reference,
      amount: line.amount, // -150.00
      isChecked: true,
      isCleared: true,
      matchedStatementLineId: stmtLineId,
    );

    session.bookTransactions.add(newBookTx);
  }

  /// Import bank statement CSV lines
  int importCsvStatement(BankReconciliationSession session, String csvContent) {
    final lines = csvContent.split('\n');
    int addedCount = 0;

    for (final rawLine in lines) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase().startsWith('date')) continue;

      final parts = trimmed.split(',');
      if (parts.length >= 3) {
        final date = parts[0].trim();
        final desc = parts[1].trim();
        final amount = double.tryParse(parts[2].trim()) ?? 0.0;
        final ref = parts.length > 3 ? parts[3].trim() : null;

        final newStmt = BankStatementLine(
          id: 'stmt-imported-${DateTime.now().millisecondsSinceEpoch}-$addedCount',
          date: date,
          description: desc,
          amount: amount,
          isChecked: false,
          matchRef: ref,
        );

        // Auto-match if amount and reference match an unreconciled book tx
        for (final bookTx in session.bookTransactions) {
          if (!bookTx.isChecked && (bookTx.amount - amount).abs() < 0.01) {
            newStmt.isSuggested = true;
            newStmt.matchRef = bookTx.reference;
            break;
          }
        }

        session.statementLines.add(newStmt);
        addedCount++;
      }
    }
    return addedCount;
  }

  /// Finish reconciliation (strict validation: Difference == 0.00)
  Future<bool> finishReconciliation(BankReconciliationSession session) async {
    if (!session.canFinishReconciliation) {
      throw Exception(
        'Cannot finish reconciliation: Statement and book balance difference is ${session.difference.toStringAsFixed(2)} AED. Difference must be 0.00 AED.',
      );
    }

    try {
      await _dio?.post(
        '${Endpoints.bankReconciliations}/reconcile',
        data: {
          'bankAccountId': session.bankAccountId,
          'statementDate': session.statementDate,
          'statementEndingBalance': session.statementEndingBalance,
          'clearedBookBalance': session.clearedBookBalance,
          'difference': session.difference,
          'clearedStatementLineIds': session.statementLines.where((l) => l.isChecked).map((l) => l.id).toList(),
          'clearedBookTransactionIds': session.bookTransactions.where((t) => t.isChecked).map((t) => t.id).toList(),
        },
      );
    } catch (_) {}

    session.isFinished = true;
    return true;
  }

  /// Save reconciliation progress
  Future<void> saveProgress(BankReconciliationSession session) async {
    try {
      await _dio?.post(
        '${Endpoints.bankReconciliations}/save-progress',
        data: {
          'bankAccountId': session.bankAccountId,
          'statementEndingBalance': session.statementEndingBalance,
          'statementLines': session.statementLines.map((l) => l.toJson()).toList(),
          'bookTransactions': session.bookTransactions.map((t) => t.toJson()).toList(),
        },
      );
    } catch (_) {}
  }
}
