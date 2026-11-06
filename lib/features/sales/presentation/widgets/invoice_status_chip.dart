import 'package:flutter/material.dart';

class InvoiceStatusChip extends StatelessWidget {
  final String status;

  const InvoiceStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF64748B);
    String label = status;

    switch (status.toUpperCase()) {
      case 'DRAFT':
        bg = const Color(0xFFF1F5F9); // Grey
        text = const Color(0xFF64748B);
        label = 'Draft';
        break;
      case 'SENT':
        bg = const Color(0xFFEFF6FF); // Blue
        text = const Color(0xFF2563EB);
        label = 'Sent';
        break;
      case 'PARTIAL':
        bg = const Color(0xFFFEF3C7); // Amber
        text = const Color(0xFFD97706);
        label = 'Partial';
        break;
      case 'PAID':
        bg = const Color(0xFFDCFCE7); // Green
        text = const Color(0xFF16A34A);
        label = 'Paid';
        break;
      case 'OVERDUE':
        bg = const Color(0xFFFEE2E2); // Red
        text = const Color(0xFFDC2626);
        label = 'Overdue';
        break;
      case 'VOID':
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF94A3B8);
        label = 'Void';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
