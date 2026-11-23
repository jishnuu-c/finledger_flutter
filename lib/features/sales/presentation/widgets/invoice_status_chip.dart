import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';

class InvoiceStatusChip extends StatelessWidget {
  final String status;

  const InvoiceStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.draftBg;
    Color text = AppColors.draft;
    String label = status;

    final l = context.l10n;
    switch (status.toUpperCase()) {
      case 'DRAFT':
        bg = AppColors.draftBg;
        text = AppColors.draft;
        label = l.statusDraft;
        break;
      case 'SENT':
        bg = AppColors.sentBg;
        text = AppColors.sent;
        label = l.statusSent;
        break;
      case 'PARTIAL':
        bg = AppColors.partialBg;
        text = AppColors.partial;
        label = l.statusPartial;
        break;
      case 'PAID':
        bg = AppColors.paidBg;
        text = AppColors.paid;
        label = l.statusPaid;
        break;
      case 'OVERDUE':
        bg = AppColors.overdueBg;
        text = AppColors.overdue;
        label = l.statusOverdue;
        break;
      case 'VOID':
        bg = AppColors.draftBg;
        text = AppColors.textMuted;
        label = l.statusVoid;
        break;
      default:
        bg = AppColors.draftBg;
        text = AppColors.draft;
        break;
    }

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: text,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: text,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
