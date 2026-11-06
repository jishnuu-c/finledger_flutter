import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/expense_models.dart';
import '../../data/services/expense_service.dart';

class MobileCameraModal extends StatefulWidget {
  final ExpenseService expenseService;
  final ValueChanged<ExpenseAttachment> onReceiptCaptured;

  const MobileCameraModal({
    super.key,
    required this.expenseService,
    required this.onReceiptCaptured,
  });

  static Future<void> show(
    BuildContext context, {
    required ExpenseService expenseService,
    required ValueChanged<ExpenseAttachment> onReceiptCaptured,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => MobileCameraModal(
        expenseService: expenseService,
        onReceiptCaptured: onReceiptCaptured,
      ),
    );
  }

  @override
  State<MobileCameraModal> createState() => _MobileCameraModalState();
}

class _MobileCameraModalState extends State<MobileCameraModal> {
  bool _isCapturing = false;
  String _selectedReceiptName = 'fuel_2910.jpg';

  final List<String> _sampleReceipts = [
    'fuel_2910.jpg',
    'salik_oct.pdf',
    'difc_bistro_meal.jpg',
    'stationery_invoice.pdf',
    'taxi_careem_receipt.jpg',
  ];

  Future<void> _capturePhoto() async {
    setState(() => _isCapturing = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final attachment = await widget.expenseService.uploadAttachment(
      _selectedReceiptName,
      sizeBytes: 215000,
    );

    if (!mounted) return;
    widget.onReceiptCaptured(attachment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: screenHeight * 0.9,
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.photo_camera, color: Color(0xFF2563EB), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mobile Receipt Camera',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

              // Viewfinder simulation
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1B33),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Corner brackets
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white30, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.receipt_long, color: Colors.white60, size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedReceiptName,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Tax Invoice / Cash Receipt',
                                  style: TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 8,
                      child: Text(
                        'Align receipt edges inside the frame',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick template selector
              const Text('Select Receipt Document:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _sampleReceipts.map((name) {
                  final isSel = name == _selectedReceiptName;
                  return ChoiceChip(
                    label: Text(name, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.textPrimary)),
                    selected: isSel,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFF1F5F9),
                    onSelected: (val) {
                      if (val) setState(() => _selectedReceiptName = name);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Capture shutter button
              Center(
                child: InkWell(
                  onTap: _isCapturing ? null : _capturePhoto,
                  borderRadius: BorderRadius.circular(35),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2563EB), width: 3),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: _isCapturing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF2563EB),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Tap to capture & attach', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
