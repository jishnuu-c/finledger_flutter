import 'package:flutter/material.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';

class ImportStatementModal extends StatefulWidget {
  final Function(String csvData) onImport;

  const ImportStatementModal({
    super.key,
    required this.onImport,
  });

  @override
  State<ImportStatementModal> createState() => _ImportStatementModalState();
}

class _ImportStatementModalState extends State<ImportStatementModal> {
  late TextEditingController _csvController;

  static const String sampleCsv = '''Date,Description,Amount,Reference
31-Oct,CHEQUE DEPOSIT - AL NOOR,45000.00,RCT-2026-0221
31-Oct,OUTWARD TT SUPPLIER BATCH,-12400.00,PAY-2026-0145
30-Oct,ATM CASH WITHDRAWAL,-2500.00,
30-Oct,POS SETTLEMENT ENBD,8620.00,POS-OCT-30''';

  @override
  void initState() {
    super.initState();
    _csvController = TextEditingController();
  }

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    setState(() {
      _csvController.text = sampleCsv;
    });
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
        width: isMobile ? screenWidth - 24 : 580,
        padding: EdgeInsetsDirectional.all(isMobile ? 16 : 24),
        child: SingleChildScrollView(
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
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import Bank Statement (CSV)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Upload or paste CSV transactions exported from your online banking',
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

              // Expected format banner
              Container(
                padding: const EdgeInsetsDirectional.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Format: Date, Description, Amount (positive for deposit, negative for withdrawal), Reference',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        onPressed: _loadSampleData,
                        icon: const Icon(Icons.add_rounded, size: 14),
                        label: Text(
                          context.l10n.loadSampleCsv,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'CSV Content *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _csvController,
                maxLines: 7,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
                decoration: const InputDecoration(
                  hintText: 'Date,Description,Amount,Reference\n28-Oct,TT IN GULF HOSPITALITY,18900.00,RCT-0219',
                  hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  contentPadding: EdgeInsets.all(12),
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
                  ElevatedButton.icon(
                    onPressed: () {
                      final text = _csvController.text.trim();
                      if (text.isNotEmpty) {
                        widget.onImport(text);
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.file_download_done_rounded, size: 16),
                    label: Text(context.l10n.importAndAutoMatch),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
