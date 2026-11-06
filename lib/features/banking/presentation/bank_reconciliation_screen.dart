import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/banking_models.dart';
import '../data/services/banking_service.dart';
import 'widgets/create_bank_entry_modal.dart';
import 'widgets/import_statement_modal.dart';

class BankReconciliationScreen extends StatefulWidget {
  final BankingService? bankingService;
  final int initialBankAccountId;

  const BankReconciliationScreen({
    super.key,
    this.bankingService,
    this.initialBankAccountId = 1,
  });

  @override
  State<BankReconciliationScreen> createState() => _BankReconciliationScreenState();
}

class _BankReconciliationScreenState extends State<BankReconciliationScreen> {
  late BankingService _service;
  late List<BankAccount> _bankAccounts;
  late int _selectedBankAccountId;
  BankReconciliationSession? _session;
  bool _isLoading = true;

  late TextEditingController _dateController;
  late TextEditingController _statementEndingBalanceController;
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _service = widget.bankingService ?? BankingService();
    _bankAccounts = _service.getBankAccounts();
    _selectedBankAccountId = widget.initialBankAccountId;
    _dateController = TextEditingController(text: '31-Oct-2026');
    _statementEndingBalanceController = TextEditingController(text: '705,850.00');
    _loadSession();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _statementEndingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    final session = await _service.getReconciliationSession(_selectedBankAccountId);
    setState(() {
      _session = session;
      _dateController.text = session.statementDate;
      _statementEndingBalanceController.text = _currencyFormat.format(session.statementEndingBalance);
      _isLoading = false;
    });
  }

  void _onStatementEndingBalanceChanged(String value) {
    if (_session == null) return;
    final sanitized = value.replaceAll(',', '').trim();
    final parsed = double.tryParse(sanitized);
    if (parsed != null) {
      setState(() {
        _session!.statementEndingBalance = parsed;
      });
    }
  }

  void _toggleStatementLine(String lineId, bool isChecked) {
    if (_session == null) return;
    setState(() {
      _service.toggleStatementLine(_session!, lineId, isChecked);
    });
  }

  void _toggleBookTransaction(String txId, bool isChecked) {
    if (_session == null) return;
    setState(() {
      _service.toggleBookTransaction(_session!, txId, isChecked);
    });
  }

  void _acceptSuggestion(String stmtLineId) {
    if (_session == null) return;
    setState(() {
      _service.acceptSuggestion(_session!, stmtLineId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Matched and cleared bank transaction with book receipt RCT-2026-0220'),
        backgroundColor: Color(0xFF16A34A),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openCreateBankEntryModal(BankStatementLine line) {
    showDialog(
      context: context,
      builder: (ctx) => CreateBankEntryModal(
        line: line,
        onPost: ({
          required String accountCode,
          required String accountName,
          required double amount,
          required String reference,
          required String narration,
        }) async {
          if (_session == null) return;
          await _service.createBankEntry(
            session: _session!,
            stmtLineId: line.id,
            accountCode: accountCode,
            accountName: accountName,
            amount: amount,
            reference: reference,
            narration: narration,
          );
          setState(() {});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Posted journal entry $reference for $narration'),
                backgroundColor: const Color(0xFF16A34A),
              ),
            );
          }
        },
      ),
    );
  }

  void _openImportCsvModal() {
    showDialog(
      context: context,
      builder: (ctx) => ImportStatementModal(
        onImport: (csv) {
          if (_session == null) return;
          final count = _service.importCsvStatement(_session!, csv);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported $count bank statement line(s) successfully'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSaveProgress() async {
    if (_session == null) return;
    await _service.saveProgress(_session!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reconciliation progress saved successfully'),
          backgroundColor: Color(0xFF2563EB),
        ),
      );
    }
  }

  Future<void> _handleFinishReconciliation() async {
    if (_session == null) return;
    if (!_session!.canFinishReconciliation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot finish reconciliation: Statement and cleared book balance have a difference of AED ${_session!.difference.toStringAsFixed(2)}. Difference must be 0.00 AED.',
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    final success = await _service.finishReconciliation(_session!);
    if (success && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text('Reconciliation Complete'),
              ),
            ],
          ),
          content: Text(
            'Bank account "${_session!.bankAccountName}" has been successfully reconciled for period ending ${_session!.statementDate} with zero variance (Difference: AED 0.00).',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final session = _session!;
    final diff = session.difference;
    final isDifferenceZero = session.canFinishReconciliation;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb & Title
          _buildHeader(),
          const SizedBox(height: 16),

          // Parameters Top Card
          _buildParametersCard(),
          const SizedBox(height: 16),

          // Split View Table
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 950;
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBankStatementCard(session)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBookTransactionsCard(session)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildBankStatementCard(session),
                    const SizedBox(height: 16),
                    _buildBookTransactionsCard(session),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Bottom Summary Bar
          _buildSummaryBar(session, diff, isDifferenceZero),
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
            const Text(
              'Banking',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Text('/', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(width: 4),
            Text(
              'Reconciliation',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Bank Reconciliation',
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

  Widget _buildParametersCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 800;
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBankAccountSelector(),
                const SizedBox(height: 12),
                _buildStatementDateField(),
                const SizedBox(height: 12),
                _buildStatementEndingBalanceField(),
                const SizedBox(height: 16),
                _buildImportCsvButton(),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 3, child: _buildBankAccountSelector()),
              const SizedBox(width: 14),
              Expanded(flex: 2, child: _buildStatementDateField()),
              const SizedBox(width: 14),
              Expanded(flex: 2, child: _buildStatementEndingBalanceField()),
              const SizedBox(width: 16),
              _buildImportCsvButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBankAccountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bank Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: _selectedBankAccountId,
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: _bankAccounts.map((a) {
            return DropdownMenuItem<int>(
              value: a.id,
              child: Text(a.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedBankAccountId = val;
              });
              _loadSession();
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatementDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Statement Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _dateController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatementEndingBalanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Statement Ending Balance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _statementEndingBalanceController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: _onStatementEndingBalanceChanged,
        ),
      ],
    );
  }

  Widget _buildImportCsvButton() {
    return OutlinedButton.icon(
      onPressed: _openImportCsvModal,
      icon: const Icon(Icons.upload_file_outlined, size: 16),
      label: const Text('Import Statement (CSV)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildBankStatementCard(BankReconciliationSession session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Bank Statement Lines',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const Divider(height: 1),

          LayoutBuilder(
            builder: (context, constraints) {
              final effectiveWidth = constraints.maxWidth > 460 ? constraints.maxWidth : 460.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: const Row(
                          children: [
                            SizedBox(width: 28), // Checkbox spacing
                            SizedBox(width: 55, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                            Expanded(child: Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                            SizedBox(width: 95, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                            SizedBox(width: 14),
                            SizedBox(width: 115, child: Text('Match', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Statement Lines
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: session.statementLines.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final line = session.statementLines[index];
                          return _buildStatementLineRow(line);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatementLineRow(BankStatementLine line) {
    final isCredit = line.amount >= 0;
    final formattedAmount = '${isCredit ? '+' : ''}${_currencyFormat.format(line.amount)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: line.isChecked ? const Color(0x66F0FDF4) : Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: line.isChecked,
              onChanged: (val) {
                _toggleStatementLine(line.id, val ?? false);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              activeColor: const Color(0xFF2563EB),
            ),
          ),
          SizedBox(
            width: 55,
            child: Text(
              line.date,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              line.description,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 95,
            child: Text(
              formattedAmount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 115,
            child: _buildStatementMatchWidget(line),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementMatchWidget(BankStatementLine line) {
    // 1. If requiresCreateEntry (Figure 15: Create entry)
    if (line.requiresCreateEntry) {
      return InkWell(
        onTap: () => _openCreateBankEntryModal(line),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Text(
            'Create entry',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 2. If suggested match (Figure 15: Suggest RCT-0220)
    if (line.isSuggested && line.matchRef != null) {
      return InkWell(
        onTap: () => _acceptSuggestion(line.id),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Text(
            'Suggest ${line.matchRef}',
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    // 3. If matched (Figure 15: RCT-0219, PAY-0144)
    if (line.matchRef != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          line.matchRef!,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return const Text(
      '—',
      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBookTransactionsCard(BankReconciliationSession session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Book Transactions (unreconciled)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const Divider(height: 1),

          LayoutBuilder(
            builder: (context, constraints) {
              final effectiveWidth = constraints.maxWidth > 400 ? constraints.maxWidth : 400.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: const Row(
                          children: [
                            SizedBox(width: 28), // Checkbox spacing
                            SizedBox(width: 60, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                            Expanded(child: Text('Reference', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                            SizedBox(width: 95, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Transactions List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: session.bookTransactions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = session.bookTransactions[index];
                          return _buildBookTransactionRow(tx);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookTransactionRow(BookTransaction tx) {
    final formattedAmount = _currencyFormat.format(tx.amount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: tx.isChecked ? const Color(0x66F0FDF4) : Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: tx.isChecked,
              onChanged: (val) {
                _toggleBookTransaction(tx.id, val ?? false);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              activeColor: const Color(0xFF2563EB),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              tx.date,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              tx.reference,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 95,
            child: Text(
              formattedAmount,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BankReconciliationSession session, double diff, bool isDifferenceZero) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1180;
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricsRow(session, diff, isDifferenceZero),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildActionsRow(isDifferenceZero),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildMetricsRow(session, diff, isDifferenceZero)),
              const SizedBox(width: 16),
              _buildActionsRow(isDifferenceZero),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricsRow(BankReconciliationSession session, double diff, bool isDifferenceZero) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildMetricItem('Statement balance', _currencyFormat.format(session.statementEndingBalance), AppColors.textPrimary),
        _buildMetricItem('Cleared book balance', _currencyFormat.format(session.clearedBookBalance), AppColors.textPrimary),
        _buildMetricItem(
          'Difference',
          _currencyFormat.format(diff),
          isDifferenceZero ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: valueColor,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow(bool isDifferenceZero) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton(
          onPressed: _handleSaveProgress,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('Save Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Tooltip(
          message: isDifferenceZero
              ? 'Complete reconciliation'
              : 'Statement balance and cleared book balance must match (Difference must be 0.00 AED)',
          child: ElevatedButton(
            // Finish Reconciliation is ONLY enabled when Difference == 0.00
            onPressed: isDifferenceZero ? _handleFinishReconciliation : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              disabledBackgroundColor: const Color(0x9993C5FD),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Finish Reconciliation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
