import 'package:flutter/material.dart';
import '../../../../core/localization/locale_provider.dart';

/// Stock Status Chips matching Figure 9 (Page 18)
/// In stock = green (#16A34A / #F0FDF4)
/// Low = amber (#D97706 / #FFFBEB)
/// Out of stock = red (#DC2626 / #FEF2F2)
class StockStatusChip extends StatelessWidget {
  final String status;

  const StockStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    String label;

    final norm = status.toUpperCase().replaceAll(' ', '_');
    final l = context.l10n;

    switch (norm) {
      case 'IN_STOCK':
      case 'INSTOCK':
      case 'IN_STOCK_':
        label = l.inStock;
        textColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        break;
      case 'LOW':
      case 'LOW_STOCK':
        label = l.statusLow;
        textColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFEF3C7);
        break;
      case 'OUT_OF_STOCK':
      case 'OUTOFSTOCK':
      default:
        label = l.outOfStock;
        textColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFEE2E2);
        break;
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
