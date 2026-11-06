import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ConvertCustomerDialogResult {
  final String customerName;
  final String contactName;
  final String email;
  final String phone;
  final String trn;
  final String currency;

  ConvertCustomerDialogResult({
    required this.customerName,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.trn,
    required this.currency,
  });
}

class ConvertCustomerDialog extends StatefulWidget {
  final String initialCustomerName;
  final String? initialContactName;
  final String? initialEmail;
  final String? initialPhone;
  final bool isWinningDeal;

  const ConvertCustomerDialog({
    super.key,
    required this.initialCustomerName,
    this.initialContactName,
    this.initialEmail,
    this.initialPhone,
    this.isWinningDeal = false,
  });

  @override
  State<ConvertCustomerDialog> createState() => _ConvertCustomerDialogState();
}

class _ConvertCustomerDialogState extends State<ConvertCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _trnController;
  String _currency = 'AED';

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.initialCustomerName);
    _contactController = TextEditingController(text: widget.initialContactName ?? 'Primary Contact');
    _emailController = TextEditingController(text: widget.initialEmail ?? 'info@${widget.initialCustomerName.toLowerCase().replaceAll(' ', '')}.com');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '+971 4 000 0000');
    _trnController = TextEditingController(text: '100345678900003');
  }

  @override
  void dispose() {
    _companyController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _trnController.dispose();
    super.dispose();
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
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isWinningDeal
                            ? 'Link Customer to Win Deal'
                            : 'Convert to Customer Account',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: const Icon(Icons.close, size: 20),
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isWinningDeal
                      ? 'Moving an opportunity to Won requires a linked customer record in the Sales Ledger.'
                      : 'Create a permanent Customer record in the Sales Ledger with VAT & contact coordinates.',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                // Company Name
                const Text('Company / Organization Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _companyController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Company name is required' : null,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Row: Contact Name & TRN
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Primary Contact Person', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _contactController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tax / TRN Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _trnController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row: Email & Phone
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Billing Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Phone / WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Currency selector
                Row(
                  children: [
                    const Text('Billing Currency: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _currency,
                        items: const [
                          DropdownMenuItem(value: 'AED', child: Text('AED (UAE Dirham)')),
                          DropdownMenuItem(value: 'SAR', child: Text('SAR (Saudi Riyal)')),
                          DropdownMenuItem(value: 'USD', child: Text('USD (US Dollar)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _currency = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Buttons
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop(
                              ConvertCustomerDialogResult(
                                customerName: _companyController.text.trim(),
                                contactName: _contactController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                trn: _trnController.text.trim(),
                                currency: _currency,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        child: Text(widget.isWinningDeal ? 'Save & Mark Won' : 'Convert & Link Customer'),
                      ),
                    ],
                  ),
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
