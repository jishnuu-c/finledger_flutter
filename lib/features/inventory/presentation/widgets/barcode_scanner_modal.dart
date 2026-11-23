import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../data/models/inventory_models.dart';
import '../../data/services/inventory_service.dart';

class BarcodeScannerModal extends StatefulWidget {
  final InventoryService inventoryService;
  final ValueChanged<StockSummaryItem> onItemScanned;

  const BarcodeScannerModal({
    super.key,
    required this.inventoryService,
    required this.onItemScanned,
  });

  static Future<void> show(
    BuildContext context, {
    required InventoryService inventoryService,
    required ValueChanged<StockSummaryItem> onItemScanned,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => BarcodeScannerModal(
        inventoryService: inventoryService,
        onItemScanned: onItemScanned,
      ),
    );
  }

  @override
  State<BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<BarcodeScannerModal> with SingleTickerProviderStateMixin {
  final TextEditingController _barcodeController = TextEditingController();
  late AnimationController _laserController;
  String? _errorMessage;
  bool _isSearching = false;

  final List<Map<String, String>> _sampleBarcodes = [
    {'code': '629104800130', 'sku': 'BSB-FLT-H13', 'name': 'H13 Replacement Filter'},
    {'code': '629104800010', 'sku': 'BSB-SNS-01', 'name': 'Indoor Air Quality Sensor'},
    {'code': '629104800500', 'sku': 'BSB-AP500', 'name': 'HEPA Air Purifier 500'},
    {'code': '629104800990', 'sku': 'BSB-MNT-WL', 'name': 'Wall-mount Bracket Kit'},
    {'code': '629104800900', 'sku': 'BSB-AP900', 'name': 'HEPA Air Purifier 900 Pro'},
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String code) async {
    if (code.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final item = await widget.inventoryService.findItemByBarcode(code.trim());
    if (!mounted) return;

    setState(() => _isSearching = false);

    if (item != null) {
      widget.onItemScanned(item);
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = 'No item matching barcode / SKU "$code" found.';
      });
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
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isMobile ? screenWidth - 24 : 480,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2563EB), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.l10n.scanItemBarcode,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Viewfinder simulation
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1B33),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Corner guides
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    // Animated laser scan line
                    AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, child) {
                        return Positioned(
                          top: 30 + (120 * _laserController.value),
                          left: 30,
                          right: 30,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const Positioned(
                      bottom: 12,
                      child: Text(
                        'Point hardware scanner or select quick barcode below',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Input field
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _barcodeController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.qr_code_rounded, size: 16, color: AppColors.textMuted),
                          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          hintText: context.l10n.enterBarcodeSku,
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                            borderSide: const BorderSide(color: Color(0xFF2563EB)),
                          ),
                        ),
                        onSubmitted: _handleScan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : () => _handleScan(_barcodeController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      child: _isSearching
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(context.l10n.scanBtn, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                ),
              ],

              const SizedBox(height: 16),
              Text(
                context.l10n.quickTestBarcodes,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _sampleBarcodes.map((item) {
                  return ActionChip(
                    label: Text(
                      '${item['sku']} (${item['code']})',
                      style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                    ),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _handleScan(item['code']!),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
