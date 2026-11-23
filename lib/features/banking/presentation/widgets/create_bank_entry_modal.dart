import 'package:flutter/material.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/banking_models.dart';

class CreateBankEntryModal extends StatefulWidget {
  final BankStatementLine line;
  final Function({
    required String accountCode,
    required String accountName,
    required double amount,
    required String reference,
    required String narration,
  }) onPost;

  const CreateBankEntryModal({
    super.key,
    required this.line,
    required this.onPost,
  });

  @override
  State<CreateBankEntryModal> createState() => _CreateBankEntryModalState();
}

class _CreateBankEntryModalState extends State<CreateBankEntryModal> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAccount = '6150 - Bank Service Charges & Fees';
  String _costCenter = 'Admin';
  late TextEditingController _refController;
  late TextEditingController _narrationController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final absAmount = widget.line.amount.abs();
    _refController = TextEditingController(text: 'JE-2026-0188');
    _narrationController = TextEditingController(
      text: '${widget.line.description} - Monthly bank service charge & processing',
    );
    _amountController = TextEditingController(text: absAmount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _refController.dispose();
    _narrationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: AppColors.cardBackground,
      child: Container(
        width: isMobile ? screenWidth - 24 : 520,
        padding: EdgeInsetsDirectional.all(isMobile ? 16 : 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Bank Charge Entry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Auto-generate double-entry journal for bank statement line',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: context.l10n.cancel,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 16),

                // Statement line preview banner
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.contentBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.line.date,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.line.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.line.amount < 0 ? '-' : '+'}AED ${widget.line.amount.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: widget.line.amount < 0 ? AppColors.overdue : AppColors.paid,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Account picker
                Text(
                  '${context.l10n.expenseAccount} *',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedAccount,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '6150 - Bank Service Charges & Fees',
                      child: Text('6150 - Bank Service Charges & Fees', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: '6160 - Interest Expense',
                      child: Text('6160 - Interest Expense', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: '6170 - Foreign Exchange Loss',
                      child: Text('6170 - Foreign Exchange Loss', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: '5210 - General Admin Expenses',
                      child: Text('5210 - General Admin Expenses', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAccount = val);
                  },
                ),
                const SizedBox(height: 14),

                // Cost Center & Amount
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 380) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.costCenter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _costCenter,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: [
                              DropdownMenuItem(value: 'Admin', child: Text(context.l10n.costCenterAdmin, style: const TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'Sales', child: Text(context.l10n.costCenterSales, style: const TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'Operations', child: Text(context.l10n.costCenterOperations, style: const TextStyle(fontSize: 13))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _costCenter = val);
                            },
                          ),
                          const SizedBox(height: 14),
                          Text('${context.l10n.amountAed} *', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.l10n.costCenter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _costCenter,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: [
                                  DropdownMenuItem(value: 'Admin', child: Text(context.l10n.costCenterAdmin, style: const TextStyle(fontSize: 13))),
                                  DropdownMenuItem(value: 'Sales', child: Text(context.l10n.costCenterSales, style: const TextStyle(fontSize: 13))),
                                  DropdownMenuItem(value: 'Operations', child: Text(context.l10n.costCenterOperations, style: const TextStyle(fontSize: 13))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _costCenter = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${context.l10n.amountAed} *', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _amountController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Reference
                Text(
                  '${context.l10n.journalReference} *',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _refController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // Narration
                Text(
                  context.l10n.narration,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _narrationController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 18),

                // Double entry preview note
                Container(
                  padding: const EdgeInsetsDirectional.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Will post: Dr 6150 Bank Charges 150.00 | Cr 1110 Emirates NBD 150.00 and auto-match this statement line.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.primaryDark,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Footer Actions
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 11),
                      ),
                      child: Text(context.l10n.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final amt = double.tryParse(_amountController.text) ?? widget.line.amount.abs();
                          final parts = _selectedAccount.split(' - ');
                          widget.onPost(
                            accountCode: parts[0],
                            accountName: parts.length > 1 ? parts[1] : parts[0],
                            amount: amt,
                            reference: _refController.text.trim(),
                            narration: _narrationController.text.trim(),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 11),
                      ),
                      child: Text(context.l10n.postAndClearEntry),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
