import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';

class KycStepIndicator extends StatelessWidget {
  final int currentStep;

  const KycStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(AppConstants.kycSteps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIndex < currentStep && currentStep >= 0
                  ? AppTheme.primaryBlue
                  : AppTheme.borderLight,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep && currentStep >= 0;
        final isCurrent = stepIndex == currentStep && currentStep >= 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppTheme.primaryBlue
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || isCurrent
                      ? AppTheme.primaryBlue
                      : AppTheme.borderLight,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Center(
                      child: Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              AppConstants.kycSteps[stepIndex],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                color: isCompleted || isCurrent
                    ? AppTheme.primaryBlue
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
