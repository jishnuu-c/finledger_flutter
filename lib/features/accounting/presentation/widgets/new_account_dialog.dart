import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/account_model.dart';

class NewAccountDialog extends StatefulWidget {
  final List<Account> groupAccounts;
  final Future<void> Function(Account newAccount) onSave;

  const NewAccountDialog({
    super.key,
    required this.groupAccounts,
    required this.onSave,
  });

  @override
  State<NewAccountDialog> createState() => _NewAccountDialogState();
}

class _NewAccountDialogState extends State<NewAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _subTypeController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0.00');

  AccountType _selectedType = AccountType.asset;
  int? _selectedParentId;
  bool _isGroup = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupAccounts.isNotEmpty) {
      _selectedParentId = widget.groupAccounts.first.id;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _subTypeController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final account = Account(
        id: 0,
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        accountType: _selectedType,
        subType: _subTypeController.text.trim().isNotEmpty ? _subTypeController.text.trim().toUpperCase() : null,
        parentId: _selectedParentId,
        isGroup: _isGroup,
        normalBalance: (_selectedType == AccountType.asset || _selectedType == AccountType.expense) ? 'DEBIT' : 'CREDIT',
        openingBalance: double.tryParse(_openingBalanceController.text) ?? 0.0,
        currentBalance: double.tryParse(_openingBalanceController.text) ?? 0.0,
      );

      await widget.onSave(account);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: screenHeight * 0.9),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'New General Ledger Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add a new group header or posting account to BSB Trading LLC chart of accounts.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                const SizedBox(height: 20),

                // Row 1: Code and Name
                if (isMobile) ...[
                  const Text('Account Code *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(hintText: 'e.g. 5230', isDense: true),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  const Text('Account Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'e.g. Software Licenses', isDense: true),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  const Text('Account Type *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<AccountType>(
                    isExpanded: true,
                    initialValue: _selectedType,
                    isDense: true,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: AccountType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Sub-Type (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _subTypeController,
                    decoration: const InputDecoration(hintText: 'e.g. BANK, EXPENSE', isDense: true),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Account Code *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(hintText: 'e.g. 5230', isDense: true),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Account Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(hintText: 'e.g. Software Licenses', isDense: true),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Account Type and Sub-type
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Account Type *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<AccountType>(
                              isExpanded: true,
                              initialValue: _selectedType,
                              isDense: true,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              items: AccountType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedType = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sub-Type (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _subTypeController,
                              decoration: const InputDecoration(hintText: 'e.g. BANK, EXPENSE', isDense: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Row 3: Parent Account
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Parent Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int?>(
                      isExpanded: true,
                      initialValue: _selectedParentId,
                      isDense: true,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('— None (Top-level Group) —', style: TextStyle(fontSize: 13, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                        ),
                        ...widget.groupAccounts.map(
                          (a) => DropdownMenuItem<int?>(
                            value: a.id,
                            child: Text('${a.code} - ${a.name} (${a.accountType.label})', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedParentId = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Group toggle & Opening Balance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isGroup,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) => setState(() => _isGroup = val ?? false),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Is Group Account', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                          Text('Header account used for grouping; cannot be posted to directly.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
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
                      onPressed: _isSaving ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}
