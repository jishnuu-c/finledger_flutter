import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/expense_models.dart';

class ExpenseApprovalStepper extends StatelessWidget {
  final double totalAmount;
  final String employeeName;

  const ExpenseApprovalStepper({
    super.key,
    required this.totalAmount,
    this.employeeName = 'Sara Mathew',
  });

  @override
  Widget build(BuildContext context) {
    final requiresFinanceReview = totalAmount > 2000.0;

    final steps = [
      ApprovalStep(
        stepNumber: 1,
        title: 'Submitted by $employeeName',
        approver: '',
        statusText: 'Pending',
        circleColor: const Color(0xFF2563EB), // Active blue from Figure 12
        statusColor: const Color(0xFF64748B),
      ),
      const ApprovalStep(
        stepNumber: 2,
        title: 'Line manager — Raj',
        approver: 'Raj',
        statusText: 'Waiting',
        circleColor: Color(0xFF94A3B8), // Slate grey
        statusColor: Color(0xFF94A3B8),
      ),
      ApprovalStep(
        stepNumber: 3,
        title: 'Finance review (> AED 2,000 only)',
        approver: 'Finance Controller',
        statusText: requiresFinanceReview ? 'Waiting' : 'Skipped',
        circleColor: const Color(0xFFCBD5E1),
        statusColor: requiresFinanceReview ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
      ),
      const ApprovalStep(
        stepNumber: 4,
        title: 'Reimbursement via payroll / bank',
        approver: 'Payroll Dept',
        statusText: '—',
        circleColor: Color(0xFFE2E8F0),
        statusColor: Color(0xFF94A3B8),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Approval flow',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Stepper lines
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, _) => Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Container(
                width: 2,
                height: 18,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            itemBuilder: (context, index) {
              final step = steps[index];
              final isStep1 = step.stepNumber == 1;

              return Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: step.circleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.stepNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isStep1 ? FontWeight.w600 : FontWeight.w500,
                        color: isStep1 ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    step.statusText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isStep1 ? FontWeight.bold : FontWeight.w500,
                      color: isStep1 ? const Color(0xFF2563EB) : step.statusColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
