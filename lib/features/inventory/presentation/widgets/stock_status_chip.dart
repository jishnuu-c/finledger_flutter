import 'package:flutter/material.dart';

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

    switch (norm) {
      case 'IN_STOCK':
      case 'INSTOCK':
      case 'IN_STOCK_':
        label = 'In stock';
        textColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        break;
      case 'LOW':
      case 'LOW_STOCK':
        label = 'Low';
        textColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFEF3C7);
        break;
      case 'OUT_OF_STOCK':
      case 'OUTOFSTOCK':
      default:
        label = 'Out of stock';
        textColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFEE2E2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
