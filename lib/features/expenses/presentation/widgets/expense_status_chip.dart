import 'package:flutter/material.dart';

/// Expense Status Chips matching Figure 11 (Page 20)
/// Submitted = amber (#D97706 / #FFFBEB)
/// Posted = green (#16A34A / #F0FDF4)
/// Approved = blue (#2563EB / #EFF6FF)
/// Rejected = red (#DC2626 / #FEF2F2)
/// Reimbursed = emerald (#059669 / #ECFDF5)
/// Draft = slate grey (#64748B / #F1F5F9)
class ExpenseStatusChip extends StatelessWidget {
  final String status;

  const ExpenseStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    String label;

    final norm = status.toUpperCase().replaceAll(' ', '_');

    switch (norm) {
      case 'SUBMITTED':
      case 'PENDING':
        label = 'Submitted';
        textColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFEF3C7);
        break;
      case 'POSTED':
        label = 'Posted';
        textColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        break;
      case 'APPROVED':
        label = 'Approved';
        textColor = const Color(0xFF2563EB);
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        break;
      case 'REJECTED':
        label = 'Rejected';
        textColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFEE2E2);
        break;
      case 'REIMBURSED':
        label = 'Reimbursed';
        textColor = const Color(0xFF059669);
        bgColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFFA7F3D0);
        break;
      case 'DRAFT':
      default:
        label = 'Draft';
        textColor = const Color(0xFF64748B);
        bgColor = const Color(0xFFF1F5F9);
        borderColor = const Color(0xFFE2E8F0);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
