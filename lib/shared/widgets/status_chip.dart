import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum StatusType {
  draft,
  sent,
  partial,
  paid,
  overdue,
  won,
  lost,
  pending,
  approved,
  rejected,
}

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusChip({
    super.key,
    required this.label,
    required this.type,
  });

  factory StatusChip.fromStatusString(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('draft')) {
      return StatusChip(label: status, type: StatusType.draft);
    } else if (lower.contains('sent')) {
      return StatusChip(label: status, type: StatusType.sent);
    } else if (lower.contains('partial')) {
      return StatusChip(label: status, type: StatusType.partial);
    } else if (lower.contains('paid') || lower.contains('posted')) {
      return StatusChip(label: status, type: StatusType.paid);
    } else if (lower.contains('overdue')) {
      return StatusChip(label: status, type: StatusType.overdue);
    } else if (lower.contains('won') || lower.contains('approved')) {
      return StatusChip(label: status, type: StatusType.won);
    } else if (lower.contains('lost') || lower.contains('rejected')) {
      return StatusChip(label: status, type: StatusType.lost);
    } else {
      return StatusChip(label: status, type: StatusType.pending);
    }
  }

  Color get _textColor {
    switch (type) {
      case StatusType.draft:
        return AppColors.draft;
      case StatusType.sent:
        return AppColors.sent;
      case StatusType.partial:
        return AppColors.partial;
      case StatusType.paid:
      case StatusType.won:
      case StatusType.approved:
        return AppColors.paid;
      case StatusType.overdue:
      case StatusType.lost:
      case StatusType.rejected:
        return AppColors.overdue;
      case StatusType.pending:
        return AppColors.partial;
    }
  }

  Color get _bgColor {
    switch (type) {
      case StatusType.draft:
        return AppColors.draftBg;
      case StatusType.sent:
        return AppColors.sentBg;
      case StatusType.partial:
        return AppColors.partialBg;
      case StatusType.paid:
      case StatusType.won:
      case StatusType.approved:
        return AppColors.paidBg;
      case StatusType.overdue:
      case StatusType.lost:
      case StatusType.rejected:
        return AppColors.overdueBg;
      case StatusType.pending:
        return AppColors.partialBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _textColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
