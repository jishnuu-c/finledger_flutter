import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/settings_models.dart';

class SettingsService {
  final DioClient? dioClient;
  final Dio? _dio;
  CompanyProfile _cachedProfile = CompanyProfile.defaultBsb();

  SettingsService({this.dioClient, Dio? dio}) : _dio = dio ?? dioClient?.dio;

  Future<CompanyProfile> getCompanyProfile() async {
    try {
      final response = await _dio?.get(Endpoints.companyProfile);
      if (response != null && response.data != null && response.data is Map<String, dynamic>) {
        // parse if available
      }
    } catch (_) {}
    return _cachedProfile;
  }

  Future<bool> updateCompanyProfile(CompanyProfile profile) async {
    _cachedProfile = profile;
    try {
      await _dio?.put(
        Endpoints.companyProfile,
        data: profile.toJson(),
      );
    } catch (_) {}
    return true;
  }

  List<FiscalYear> getFiscalYears() {
    return const [
      FiscalYear(year: 2026, startDate: '01-Jan-2026', endDate: '31-Dec-2026', isOpen: true, isCurrent: true),
      FiscalYear(year: 2025, startDate: '01-Jan-2025', endDate: '31-Dec-2025', isOpen: false, isCurrent: false),
      FiscalYear(year: 2024, startDate: '01-Jan-2024', endDate: '31-Dec-2024', isOpen: false, isCurrent: false),
    ];
  }

  List<TaxRateConfig> getTaxRates() {
    return const [
      TaxRateConfig(name: 'Standard Rate (5%)', code: 'VAT-STD-5', ratePercent: 5.0, type: 'Standard', description: 'UAE standard rate applicable to all commercial supplies'),
      TaxRateConfig(name: 'Zero Rated (0%)', code: 'VAT-ZERO-0', ratePercent: 0.0, type: 'Zero-Rated', description: 'Exports of goods/services, international transport, qualifying medical & education'),
      TaxRateConfig(name: 'Exempt Supplies', code: 'VAT-EXEMPT', ratePercent: 0.0, type: 'Exempt', description: 'Financial services without explicit fee, residential buildings, bare land'),
      TaxRateConfig(name: 'Out of Scope', code: 'VAT-OOS', ratePercent: 0.0, type: 'Out of Scope', description: 'Supplies outside UAE territory or outside the scope of VAT law'),
    ];
  }

  List<CurrencyItem> getCurrencies() {
    return const [
      CurrencyItem(code: 'AED', name: 'UAE Dirham', symbol: 'AED', exchangeRate: 1.0000, isBase: true),
      CurrencyItem(code: 'USD', name: 'US Dollar', symbol: '\$', exchangeRate: 3.6725, isBase: false),
      CurrencyItem(code: 'EUR', name: 'Euro', symbol: '€', exchangeRate: 4.0210, isBase: false),
      CurrencyItem(code: 'GBP', name: 'British Pound', symbol: '£', exchangeRate: 4.6540, isBase: false),
      CurrencyItem(code: 'SAR', name: 'Saudi Riyal', symbol: 'SAR', exchangeRate: 0.9790, isBase: false),
    ];
  }

  List<NumberSeriesItem> getNumberSeries() {
    return const [
      NumberSeriesItem(module: 'Sales Invoices', prefix: 'INV-2026-', nextNumber: 896, padding: 4),
      NumberSeriesItem(module: 'Customer Receipts', prefix: 'RCT-2026-', nextNumber: 221, padding: 4),
      NumberSeriesItem(module: 'Vendor Bills', prefix: 'BIL-2026-', nextNumber: 345, padding: 4),
      NumberSeriesItem(module: 'Vendor Payments', prefix: 'PAY-2026-', nextNumber: 145, padding: 4),
      NumberSeriesItem(module: 'Journal Entries', prefix: 'JE-2026-', nextNumber: 189, padding: 4),
      NumberSeriesItem(module: 'Expense Claims', prefix: 'EXP-2026-', nextNumber: 235, padding: 4),
    ];
  }

  List<UserRoleItem> getUsersAndRoles() {
    return const [
      UserRoleItem(name: 'Ahmed Jaber Al Hamri', email: 'ahmed.alhamri@bsbtrading.ae', role: 'Super Admin', status: 'Active'),
      UserRoleItem(name: 'Sara Mathew', email: 'sara.mathew@bsbtrading.ae', role: 'Senior Accountant', status: 'Active'),
      UserRoleItem(name: 'Raj Patel', email: 'raj.p@bsbtrading.ae', role: 'Sales Manager', status: 'Active'),
      UserRoleItem(name: 'Ahmed Khan', email: 'ahmed.k@bsbtrading.ae', role: 'Operations Officer', status: 'Active'),
    ];
  }

  List<AuditLogItem> getAuditLogs() {
    return const [
      AuditLogItem(timestamp: '30-Oct-2026 15:42', user: 'Ahmed Jaber', action: 'Reconciliation Cleared', entity: 'Bank Account 1110', details: 'Cleared statement lines up to 30-Oct', ipAddress: '194.170.82.10'),
      AuditLogItem(timestamp: '30-Oct-2026 14:15', user: 'Sara Mathew', action: 'Created Claim', entity: 'EXP-2026-0234', details: 'Submitted claim for Abu Dhabi visits (AED 831.00)', ipAddress: '194.170.82.12'),
      AuditLogItem(timestamp: '30-Oct-2026 11:04', user: 'System Auto-Post', action: 'Exchange Rate Refresh', entity: 'Currencies', details: 'Updated USD exchange rate 3.6725', ipAddress: '127.0.0.1'),
      AuditLogItem(timestamp: '29-Oct-2026 16:30', user: 'Ahmed Jaber', action: 'Role Modified', entity: 'User: Raj Patel', details: 'Added quotation approval permission', ipAddress: '194.170.82.10'),
    ];
  }
}
