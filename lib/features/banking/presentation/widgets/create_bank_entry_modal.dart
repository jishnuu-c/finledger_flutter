import 'package:flutter/material.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isMobile ? screenWidth - 24 : 520,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long, color: Color(0xFFD97706), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Bank Charge Entry',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Statement line preview banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.contentBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.line.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            Text(widget.line.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.line.amount < 0 ? '-' : '+'}AED ${widget.line.amount.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: widget.line.amount < 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Account picker
                const Text('Expense Account *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cost Center', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _costCenter,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Admin', child: Text('Admin', style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'Sales', child: Text('Sales', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Operations', child: Text('Operations', style: TextStyle(fontSize: 13))),
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
                        const Text('Amount (AED) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
              ),
              const SizedBox(height: 14),

              // Reference
              const Text('Journal Reference *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
              const Text('Narration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _narrationController,
                maxLines: 2,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),

              // Double entry preview note
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Will post: Dr 6150 Bank Charges 150.00 | Cr 1110 Emirates NBD 150.00 and auto-match this statement line.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
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
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                    child: const Text('Post & Clear Entry'),
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
