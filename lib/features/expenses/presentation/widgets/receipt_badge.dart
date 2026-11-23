import 'package:flutter/material.dart';

class ReceiptBadge extends StatelessWidget {
  final int count;
  final bool isMissing;
  final bool showLabel;

  const ReceiptBadge({
    super.key,
    required this.count,
    this.isMissing = false,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMissing || count == 0) {
      if (showLabel) {
        return Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFB45309)),
                SizedBox(width: 3),
                Text(
                  'Missing',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Center(
          child: Text(
            '!',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFDC2626), height: 1.0),
          ),
        ),
      );
    }

    if (showLabel) {
      return Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFDCFCE7)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_file_rounded, size: 12, color: Color(0xFF16A34A)),
              const SizedBox(width: 2),
              Text(
                '$count',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.attach_file_rounded, size: 13, color: Color(0xFF64748B)),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
      ],
    );
  }
}
