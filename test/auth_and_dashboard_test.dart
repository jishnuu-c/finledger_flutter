import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finledger/core/api/dio_client.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/features/auth/data/auth_service.dart';
import 'package:finledger/features/dashboard/data/dashboard_models.dart';
import 'package:finledger/features/dashboard/data/dashboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService Lockout & Login Tests', () {
    test('Records failed attempts and locks out after 5 failures', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(
        tokenService: tokenService,
        loadingService: loadingService,
      );

      final authService = AuthService(
        dioClient: dioClient,
        tokenService: tokenService,
      );

      // Attempt 1 to 4 should not be locked out
      for (int i = 1; i <= 4; i++) {
        final result = await authService.recordFailedAttempt();
        expect(result.success, false);
        expect(result.isLockedOut, false);
        expect(result.message, contains('${5 - i} attempt'));
      }

      // Attempt 5 should trigger lockout
      final lockoutResult = await authService.recordFailedAttempt();
      expect(lockoutResult.success, false);
      expect(lockoutResult.isLockedOut, true);
      expect(lockoutResult.message, contains('Account temporarily locked after 5 failed attempts'));

      // Check remaining lockout seconds is non-null
      final remaining = await authService.getRemainingLockoutSeconds();
      expect(remaining, isNotNull);
      expect(remaining! > 0, true);
    });

    test('Saves and retrieves remembered email', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(
        tokenService: tokenService,
        loadingService: loadingService,
      );

      final authService = AuthService(
        dioClient: dioClient,
        tokenService: tokenService,
      );

      await authService.login(
        email: 'accountant@company.com',
        password: 'Password@2026',
        rememberMe: true,
      );

      final saved = await authService.getRememberedEmail();
      expect(saved, 'accountant@company.com');
    });
  });

  group('Dashboard Models & Service Tests', () {
    test('Default mock contains exact figures from Figure 3', () {
      final summary = DashboardSummary.defaultMock();

      // Row 1 Financial
      expect(summary.financial.revenueYtd, 2485300.00);
      expect(summary.financial.revenueGrowth, 12.4);
      expect(summary.financial.expensesYtd, 1692140.00);
      expect(summary.financial.expensesGrowth, 8.1);
      expect(summary.financial.receivables, 384920.00);
      expect(summary.financial.openInvoicesCount, 42);
      expect(summary.financial.cashAndBank, 918450.00);
      expect(summary.financial.bankAccountsCount, 3);

      // Row 2 Operational
      expect(summary.operational.openPipelineCrm, 1264000.00);
      expect(summary.operational.opportunitiesCount, 31);
      expect(summary.operational.weightedProbability, 38);
      expect(summary.operational.inventoryValue, 612500.00);
      expect(summary.operational.lowStockCount, 7);
      expect(summary.operational.expensesAwaitingApproval, 14860.00);
      expect(summary.operational.pendingClaimsCount, 9);
      expect(summary.operational.accountsPayable, 213640.00);
      expect(summary.operational.openBillsCount, 18);

      // 6-month bar chart
      expect(summary.monthlyData.length, 6);
      expect(summary.monthlyData.first.month, 'May');
      expect(summary.monthlyData.last.month, 'Oct');

      // Receivables Ageing
      expect(summary.ageing.current, 184200.00);
      expect(summary.ageing.days1To30, 98400.00);
      expect(summary.ageing.days31To60, 62100.00);
      expect(summary.ageing.days61To90, 28620.00);
      expect(summary.ageing.daysOver90, 11600.00);

      // Recent Transactions
      expect(summary.recentTransactions.length, 3);
      expect(summary.recentTransactions[0].reference, 'INV-2026-0412');
      expect(summary.recentTransactions[0].amount, 42525.00);
      expect(summary.recentTransactions[1].reference, 'RCT-2026-0219');
      expect(summary.recentTransactions[1].amount, 18900.00);
      expect(summary.recentTransactions[2].reference, 'BILL-2026-0158');
      expect(summary.recentTransactions[2].amount, 6300.00);
    });

    test('DashboardService returns summary successfully', () async {
      final tokenService = TokenService();
      final loadingService = LoadingService();
      final dioClient = DioClient(
        tokenService: tokenService,
        loadingService: loadingService,
      );

      final service = DashboardService(dioClient: dioClient);
      final result = await service.getSummary();

      expect(result.financial.revenueYtd, 2485300.00);
      expect(result.recentTransactions.length, 3);
    });
  });
}
