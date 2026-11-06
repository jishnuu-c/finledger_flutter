import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/crm_models.dart';

class OpportunityCardWidget extends StatefulWidget {
  final Opportunity opportunity;
  final VoidCallback onTap;

  const OpportunityCardWidget({
    super.key,
    required this.opportunity,
    required this.onTap,
  });

  @override
  State<OpportunityCardWidget> createState() => _OpportunityCardWidgetState();
}

class _OpportunityCardWidgetState extends State<OpportunityCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    final currencyFormatter = NumberFormat('#,##0', 'en_US');
    final formattedValue = '${opp.currencyCode} ${currencyFormatter.format(opp.expectedValue)}';

    final cardContent = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered ? const Color(0xFF93C5FD) : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 8 : 3,
              offset: Offset(0, _isHovered ? 3 : 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Deal Title
            Text(
              opp.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),

            // Customer Name
            Text(
              opp.customerName,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Value & Owner Avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    formattedValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Circular Owner Badge with Initial
                Tooltip(
                  message: 'Owner: ${opp.ownerName}',
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: opp.ownerBadgeColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      opp.ownerInitial,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Close Date with clock icon
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    opp.expectedCloseDate.startsWith('Close')
                        ? opp.expectedCloseDate
                        : 'Close ${opp.expectedCloseDate}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Draggable<Opportunity>(
        data: opp,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 260,
            child: cardContent,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.35,
          child: cardContent,
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: cardContent,
        ),
      ),
    );
  }
}
