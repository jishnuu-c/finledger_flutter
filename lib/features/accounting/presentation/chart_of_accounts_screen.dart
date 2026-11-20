import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/localization/locale_provider.dart';
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
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
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
          children: [
            Text(
              context.l10n.accounting,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(width: 4),
            const Text('/', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(width: 4),
            Text(
              context.l10n.chartOfAccounts,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.chartOfAccounts,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
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
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      hintText: context.l10n.searchAccount,
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
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
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
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
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
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
                      SnackBar(content: Text(context.l10n.importCoaXlsxPrompt), duration: const Duration(seconds: 2)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Text(context.l10n.importAction, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.exportCoaXlsxPrompt), duration: const Duration(seconds: 2)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Text(context.l10n.export, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                ),
                ElevatedButton(
                  onPressed: _openNewAccountModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth = constraints.maxWidth > 1200 ? constraints.maxWidth : 1200.0;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: effectiveWidth,
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 46,
                      dataRowMaxHeight: 46,
                      horizontalMargin: 20,
                      columnSpacing: 20,
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: [
                        DataColumn(
                          label: Text(
                            context.l10n.colCode,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.colAccountName,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.accountType,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.colParent,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                        DataColumn(
                          numeric: true,
                          label: Text(
                            context.l10n.colBalanceAed,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.status,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.actions,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),

                            // Account Name with Hierarchical Indentation (Directional)
                            DataCell(
                              Padding(
                                padding: EdgeInsetsDirectional.only(start: indent),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (acc.level > 0) ...[
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsetsDirectional.only(end: 8),
                                        decoration: BoxDecoration(
                                          color: isGroup ? AppColors.sidebarGroupLabel : AppColors.textMuted,
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
                                          fontWeight: isGroup ? FontWeight.w700 : FontWeight.w500,
                                          color: isGroup ? AppColors.textPrimary : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Type Chip
                            DataCell(
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.borderSubtle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  acc.accountType.label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),

                            // Parent Code
                            DataCell(
                              Text(
                                acc.parentCode ?? '—',
                                style: const TextStyle(fontSize: 12, color: AppColors.sidebarGroupLabel),
                              ),
                            ),

                            // Balance (AED)
                            DataCell(
                              Text(
                                currencyFormat.format(acc.currentBalance),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isGroup ? FontWeight.w700 : FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),

                            // Status Chip
                            DataCell(
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: acc.isActive ? AppColors.paidBg : AppColors.draftBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (acc.isActive ? AppColors.paid : AppColors.draft).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  acc.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: acc.isActive ? AppColors.paid : AppColors.draft,
                                  ),
                                ),
                              ),
                            ),

                            // Actions: Edit · Ledger
                            DataCell(
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => _openEditAccountModal(acc),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primaryLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Text(' · ', style: TextStyle(color: AppColors.textMuted)),
                                    InkWell(
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Opening General Ledger trail for ${acc.code} - ${acc.name}')),
                                        );
                                      },
                                      child: const Text(
                                        'Ledger',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primaryLight,
                                          fontWeight: FontWeight.w600,
                                        ),
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
