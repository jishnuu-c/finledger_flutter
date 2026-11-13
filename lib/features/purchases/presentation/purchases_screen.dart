import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/status_chip.dart';

class PurchasesScreen extends StatefulWidget {
  final String initialTab;

  const PurchasesScreen({super.key, this.initialTab = 'bills'});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  void didUpdateWidget(PurchasesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _activeTab = widget.initialTab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bills = [
      {'num': 'BIL-2026-0344', 'vendor': 'Gulf Petrochem Distribution', 'date': '28-Oct-2026', 'dueDate': '27-Nov-2026', 'amount': 'AED 78,120.00', 'status': 'Partial'},
      {'num': 'BIL-2026-0343', 'vendor': 'Schneider Electric UAE', 'date': '20-Oct-2026', 'dueDate': '19-Nov-2026', 'amount': 'AED 44,500.00', 'status': 'Paid'},
      {'num': 'BIL-2026-0342', 'vendor': 'Al Habtoor Motors Spares', 'date': '14-Oct-2026', 'dueDate': '13-Nov-2026', 'amount': 'AED 29,800.00', 'status': 'Paid'},
      {'num': 'BIL-2026-0341', 'vendor': 'Canon Middle East FZ', 'date': '02-Oct-2026', 'dueDate': '01-Nov-2026', 'amount': 'AED 12,350.00', 'status': 'Draft'},
    ];

    final vendors = [
      {'code': 'VND-001', 'name': 'Gulf Petrochem Distribution', 'trn': '100928374600003', 'terms': 'Net 30', 'openPayables': 'AED 78,120.00', 'status': 'Active'},
      {'code': 'VND-002', 'name': 'Schneider Electric UAE', 'trn': '100192837400003', 'terms': 'Net 30', 'openPayables': 'AED 0.00', 'status': 'Active'},
      {'code': 'VND-003', 'name': 'Al Habtoor Motors Spares', 'trn': '100384726100003', 'terms': 'Net 30', 'openPayables': 'AED 0.00', 'status': 'Active'},
      {'code': 'VND-004', 'name': 'Canon Middle East FZ', 'trn': '100582910200003', 'terms': 'Net 30', 'openPayables': 'AED 12,350.00', 'status': 'Active'},
    ];

    final payments = [
      {'num': 'PAY-2026-0188', 'vendor': 'Schneider Electric UAE', 'bill': 'BIL-2026-0343', 'date': '22-Oct-2026', 'amount': 'AED 44,500.00', 'method': 'Bank Transfer', 'status': 'Cleared'},
      {'num': 'PAY-2026-0187', 'vendor': 'Al Habtoor Motors Spares', 'bill': 'BIL-2026-0342', 'date': '16-Oct-2026', 'amount': 'AED 29,800.00', 'method': 'Cheque #4001', 'status': 'Cleared'},
      {'num': 'PAY-2026-0186', 'vendor': 'Gulf Petrochem Distribution', 'bill': 'BIL-2026-0344', 'date': '30-Oct-2026', 'amount': 'AED 39,060.00', 'method': 'Bank Transfer', 'status': 'Cleared'},
    ];

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Purchases & Accounts Payable',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Procure-to-pay cycle: Vendor purchase bills, debit notes, and payment orders',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ Enter Vendor Bill'),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchases & Accounts Payable',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Procure-to-pay cycle: Vendor purchase bills, debit notes, and payment orders',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ Enter Vendor Bill'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Sub-navigation tabs matching Angular and Figure specifications
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton('bills', 'Vendor Bills', Icons.receipt_long_outlined),
                const SizedBox(width: 8),
                _buildTabButton('vendors', 'Vendors & Suppliers', Icons.store_mall_directory_outlined),
                const SizedBox(width: 8),
                _buildTabButton('payments', 'Payment Orders', Icons.payments_outlined),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_activeTab == 'vendors') ...[
            RoundedCard(
              title: 'Vendor Accounts Directory (AP)',
              subtitle: '4 active approved suppliers',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 720),
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 48,
                    columns: const [
                      DataColumn(label: Text('CODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('VENDOR NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('TRN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('PAYMENT TERMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('OPEN PAYABLES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                    rows: vendors.map((v) {
                      return DataRow(
                        cells: [
                          DataCell(Text(v['code']!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13))),
                          DataCell(Text(v['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          DataCell(Text(v['trn']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(v['terms']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(v['openPayables']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                          DataCell(StatusChip.fromStatusString(v['status']!)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ] else if (_activeTab == 'payments') ...[
            RoundedCard(
              title: 'Vendor Payments & Vouchers',
              subtitle: 'AED 113,360 total disbursements',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 720),
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 48,
                    columns: const [
                      DataColumn(label: Text('PAYMENT #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('VENDOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('AGAINST BILL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('METHOD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                    rows: payments.map((p) {
                      return DataRow(
                        cells: [
                          DataCell(Text(p['num']!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13))),
                          DataCell(Text(p['vendor']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          DataCell(Text(p['bill']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(p['date']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(p['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                          DataCell(Text(p['method']!, style: const TextStyle(fontSize: 12))),
                          DataCell(StatusChip.fromStatusString(p['status']!)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ] else ...[
            RoundedCard(
              title: 'Vendor Bills & Payables (AP)',
              subtitle: 'AED 195,400 total active payables',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 720),
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 48,
                    columns: const [
                      DataColumn(label: Text('BILL #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('VENDOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('BILL DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('DUE DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('AMOUNT (AED)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                    rows: bills.map((b) {
                      return DataRow(
                        cells: [
                          DataCell(Text(b['num']!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13))),
                          DataCell(Text(b['vendor']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          DataCell(Text(b['date']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(b['dueDate']!, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(b['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                          DataCell(StatusChip.fromStatusString(b['status']!)),
                          DataCell(
                            TextButton(
                              onPressed: () {},
                              child: const Text('Record Payment', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabKey, String label, IconData icon) {
    final isSelected = _activeTab == tabKey;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tabKey;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
