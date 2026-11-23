import 'package:flutter/material.dart';
import '../../../../core/localization/locale_provider.dart';

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
    final l = context.l10n;

    switch (norm) {
      case 'SUBMITTED':
      case 'PENDING':
        label = l.statusSubmitted;
        textColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFEF3C7);
        break;
      case 'POSTED':
        label = l.statusPosted;
        textColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        break;
      case 'APPROVED':
        label = l.statusApproved;
        textColor = const Color(0xFF2563EB);
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        break;
      case 'REJECTED':
        label = l.statusRejected;
        textColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFEE2E2);
        break;
      case 'REIMBURSED':
        label = l.statusReimbursed;
        textColor = const Color(0xFF059669);
        bgColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFFA7F3D0);
        break;
      case 'DRAFT':
      default:
        label = l.statusDraft;
        textColor = const Color(0xFF64748B);
        bgColor = const Color(0xFFF1F5F9);
        borderColor = const Color(0xFFE2E8F0);
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
