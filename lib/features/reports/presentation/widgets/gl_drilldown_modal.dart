import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/report_models.dart';
import '../../data/services/report_service.dart';

class GlDrilldownModal extends StatefulWidget {
  final String accountCode;
  final String accountName;
  final ReportService reportService;

  const GlDrilldownModal({
    super.key,
    required this.accountCode,
    required this.accountName,
    required this.reportService,
  });

  @override
  State<GlDrilldownModal> createState() => _GlDrilldownModalState();
}

class _GlDrilldownModalState extends State<GlDrilldownModal> {
  late Future<List<GlTransaction>> _futureTxs;
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _futureTxs = widget.reportService.getGlTransactionsForAccount(widget.accountCode);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 680;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isMobile ? screenWidth - 24 : 850,
        height: isMobile ? screenHeight * 0.85 : 540,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_tree_outlined, color: Color(0xFF2563EB), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'General Ledger Drill-Down: ${widget.accountName}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Double-entry journal transactions contributing to this period balance',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
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
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Table of GL Transactions
            Expanded(
              child: FutureBuilder<List<GlTransaction>>(
                future: _futureTxs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading transactions: ${snapshot.error}'));
                  }
                  final txs = snapshot.data ?? [];
                  if (txs.isEmpty) {
                    return const Center(child: Text('No journal transactions found for this account.'));
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const minTableWidth = 740.0;
                        final effectiveWidth = constraints.maxWidth < minTableWidth
                            ? minTableWidth
                            : constraints.maxWidth;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: effectiveWidth,
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  color: const Color(0xFFF8FAFC),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: const Row(
                                    children: [
                                      SizedBox(width: 85, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                      SizedBox(width: 105, child: Text('Entry #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                      SizedBox(width: 105, child: Text('Reference', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                      Expanded(child: Text('Narration', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                      SizedBox(width: 90, child: Text('Debit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                      SizedBox(width: 90, child: Text('Credit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                      SizedBox(width: 100, child: Text('Balance', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),

                                // Lines
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: txs.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final item = txs[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 85,
                                              child: Text(item.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            ),
                                            SizedBox(
                                              width: 105,
                                              child: Text(
                                                item.entryNo,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 105,
                                              child: Text(item.reference, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                            ),
                                            Expanded(
                                              child: Text(
                                                item.narration,
                                                style: const TextStyle(fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 90,
                                              child: Text(
                                                item.debit > 0 ? _currencyFormat.format(item.debit) : '—',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 90,
                                              child: Text(
                                                item.credit > 0 ? _currencyFormat.format(item.credit) : '—',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                _currencyFormat.format(item.runningBalance),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Footer
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Clicking entry number opens the complete double-entry journal voucher',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
