import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/api/dio_client.dart';
import '../data/models/account_model.dart';
import '../data/services/accounting_service.dart';
import 'widgets/new_account_dialog.dart';

class ChartOfAccountsScreen extends StatefulWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  State<ChartOfAccountsScreen> createState() => _ChartOfAccountsScreenState();
}

class _ChartOfAccountsScreenState extends State<ChartOfAccountsScreen> {
  late final AccountingService _accountingService;
  final TextEditingController _searchController = TextEditingController();

  String _selectedType = 'All Types';
  String _selectedStatus = 'Active';
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final dioClient = context.read<DioClient>();
    _accountingService = AccountingService(dioClient: dioClient);
    _loadAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    final data = await _accountingService.getAccountsTree(
      search: _searchController.text,
      type: _selectedType,
      status: _selectedStatus,
    );
    if (mounted) {
      setState(() {
        _accounts = data;
        _isLoading = false;
      });
    }
  }

  void _openNewAccountModal() {
    final groupAccounts = _accounts.where((a) => a.isGroup).toList();
    showDialog(
      context: context,
      builder: (ctx) => NewAccountDialog(
        groupAccounts: groupAccounts,
        onSave: (newAccount) async {
          await _accountingService.createAccount(newAccount);
          _loadAccounts();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb & Page Title matching Figure 13
          _buildHeader(),
          const SizedBox(height: 18),

          // Search and Filters Bar matching Figure 13
          _buildFilterBar(),
          const SizedBox(height: 16),

          // Hierarchical Table matching Figure 13
          _buildAccountsTable(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Text('Accounting', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            SizedBox(width: 4),
            Text('/', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            SizedBox(width: 4),
            Text('Chart of Accounts', style: TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Chart of Accounts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? constraints.maxWidth : 220,
                    maxHeight: 36,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 12.5),
                    onChanged: (_) => _loadAccounts(),
                    decoration: InputDecoration(
                      hintText: 'Search account...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                      icon: const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF64748B)),
                      items: ['All Types', 'Asset', 'Liability', 'Equity', 'Income', 'Expense']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedType = val);
                          _loadAccounts();
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                      icon: const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF64748B)),
                      items: ['All', 'Active', 'Inactive']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStatus = val);
                          _loadAccounts();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Importing Chart of Accounts from Excel template (.xlsx)'), duration: Duration(seconds: 2)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Import', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exporting Chart of Accounts to Excel (.xlsx)'), duration: Duration(seconds: 2)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Export', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                ),
                ElevatedButton(
                  onPressed: _openNewAccountModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    '+ New Account',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountsTable() {
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth = constraints.maxWidth > 1100 ? constraints.maxWidth : 1100.0;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: effectiveWidth,
                    child: DataTable(
                  headingRowHeight: 40,
                  dataRowMinHeight: 46,
                  dataRowMaxHeight: 46,
                  horizontalMargin: 20,
                  columnSpacing: 28,
                  columns: const [
                    DataColumn(
                      label: Text('Code', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                    DataColumn(
                      label: Text('Account Name', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                    DataColumn(
                      label: Text('Type', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                    DataColumn(
                      label: Text('Parent', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text('Balance (AED)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                    DataColumn(
                      label: Text('Status', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                    DataColumn(
                      label: Text('Actions', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                  ],
                  rows: _accounts.map((acc) {
                    final isGroup = acc.isGroup;
                    final indent = acc.level * 18.0;

                    return DataRow(
                      cells: [
                        // Code
                        DataCell(
                          Text(
                            acc.code,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isGroup ? FontWeight.w700 : FontWeight.w400,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),

                        // Account Name with Hierarchical Indentation
                        DataCell(
                          Padding(
                            padding: EdgeInsets.only(left: indent),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (acc.level > 0) ...[
                                  Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: isGroup ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                                Flexible(
                                  child: Text(
                                    acc.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isGroup ? FontWeight.w700 : FontWeight.w400,
                                      color: isGroup ? const Color(0xFF0F172A) : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Type Chip (Grey pill matching Figure 13)
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              acc.accountType.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),

                        // Parent Code
                        DataCell(
                          Text(
                            acc.parentCode ?? '—',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ),

                        // Balance (AED)
                        DataCell(
                          Text(
                            currencyFormat.format(acc.currentBalance),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isGroup ? FontWeight.w700 : FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),

                        // Status Chip (Green Active matching Figure 13)
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: acc.isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              acc.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: acc.isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),

                        // Actions: Edit · Ledger matching Figure 13
                        DataCell(
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _openEditAccountModal(acc),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const Text(' · ', style: TextStyle(color: Color(0xFF94A3B8))),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Opening General Ledger trail for ${acc.code} - ${acc.name}')),
                                    );
                                  },
                                  child: const Text(
                                    'Ledger',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
    );
  }

  void _openEditAccountModal(Account acc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing account ${acc.code} - ${acc.name}'), duration: const Duration(seconds: 2)),
    );
  }
}
