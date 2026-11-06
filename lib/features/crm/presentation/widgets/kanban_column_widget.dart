import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/crm_models.dart';
import 'opportunity_card_widget.dart';

class KanbanColumnWidget extends StatelessWidget {
  final String stageName;
  final List<Opportunity> opportunities;
  final double totalValue;
  final Function(Opportunity opp, String targetStage) onDropOpportunity;
  final Function(Opportunity opp) onOpportunityClick;

  const KanbanColumnWidget({
    super.key,
    required this.stageName,
    required this.opportunities,
    required this.totalValue,
    required this.onDropOpportunity,
    required this.onOpportunityClick,
  });

  Color get _topStripeColor {
    switch (stageName) {
      case 'New':
        return const Color(0xFF64748B); // Slate
      case 'Qualified':
        return const Color(0xFF0284C7); // Cyan / Sky Blue
      case 'Proposal':
        return const Color(0xFF2563EB); // Royal Blue
      case 'Negotiation':
        return const Color(0xFFD97706); // Amber
      case 'Won':
        return const Color(0xFF10B981); // Emerald Green
      case 'Lost':
        return const Color(0xFFEF4444); // Red
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'en_US');
    final formattedTotal = 'AED ${currencyFormatter.format(totalValue)}';

    return Container(
      width: 275,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light slate container background
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Colored Stripe
          Container(
            height: 3.5,
            decoration: BoxDecoration(
              color: _topStripeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
          ),

          // Header: Stage Title • Count & Total Value
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$stageName • ${opportunities.length}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  formattedTotal,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Drag Target & List Area
          Expanded(
            child: DragTarget<Opportunity>(
              onWillAcceptWithDetails: (details) {
                // Can accept if not already in this stage
                return details.data.stage != stageName;
              },
              onAcceptWithDetails: (details) {
                onDropOpportunity(details.data, stageName);
              },
              builder: (context, candidateData, rejectedData) {
                final isCandidate = candidateData.isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isCandidate
                        ? _topStripeColor.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    border: isCandidate
                        ? Border.all(color: _topStripeColor, width: 1.5)
                        : null,
                  ),
                  child: opportunities.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Drop deals here',
                              style: TextStyle(
                                fontSize: 12,
                                color: isCandidate ? _topStripeColor : AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 2, bottom: 8),
                          itemCount: opportunities.length,
                          itemBuilder: (context, index) {
                            final opp = opportunities[index];
                            return OpportunityCardWidget(
                              opportunity: opp,
                              onTap: () => onOpportunityClick(opp),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
