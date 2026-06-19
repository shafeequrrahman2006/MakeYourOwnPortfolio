import 'package:flutter/material.dart';
import '../../core/theme.dart';

class StepperWidget extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepTap;
  final bool isMobile;

  const StepperWidget({
    super.key,
    required this.currentStep,
    required this.onStepTap,
    required this.isMobile,
  });

  static const List<String> stepTitles = [
    'Personal Details',
    'Career Details',
    'Resume Upload',
    'Package Selection',
    'Confirmation',
  ];

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileStepper(context);
    } else {
      return _buildDesktopStepper(context);
    }
  }

  Widget _buildDesktopStepper(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stepTitles.length, (index) {
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;
        final isPending = index > currentStep;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: isCompleted || isActive ? () => onStepTap(index) : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                child: Row(
                  children: [
                    _buildStepIndicator(index, isCompleted, isActive, isPending),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stepTitles[index],
                            style: TextStyle(
                              color: isPending ? MUOPTheme.secondaryText.withOpacity(0.5) : MUOPTheme.primaryText,
                              fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCompleted
                                ? 'COMPLETED'
                                : (isActive ? 'ACTIVE' : 'PENDING'),
                            style: TextStyle(
                              color: isCompleted
                                  ? const Color(0xFF4CAF50)
                                  : (isActive ? MUOPTheme.primaryYellow : MUOPTheme.secondaryText.withOpacity(0.4)),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (index < stepTitles.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 17.0), // Align with center of indicator (16px size + 1.2px border)
                child: Container(
                  width: 2,
                  height: 30,
                  color: isCompleted ? MUOPTheme.primaryYellow.withOpacity(0.5) : MUOPTheme.border,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildMobileStepper(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MUOPTheme.border, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stepTitles.length, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          final isPending = index > currentStep;

          return Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: isCompleted || isActive ? () => onStepTap(index) : null,
                  child: _buildStepIndicator(index, isCompleted, isActive, isPending),
                ),
                if (index < stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isCompleted ? MUOPTheme.primaryYellow.withOpacity(0.5) : MUOPTheme.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepIndicator(int index, bool isCompleted, bool isActive, bool isPending) {
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1B5E20).withOpacity(0.3),
          border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
        ),
        child: const Icon(
          Icons.check,
          color: Color(0xFF4CAF50),
          size: 16,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MUOPTheme.primaryYellow.withOpacity(0.1),
          border: Border.all(color: MUOPTheme.primaryYellow, width: 2.0),
          boxShadow: MUOPTheme.glowShadow(color: MUOPTheme.primaryYellow.withOpacity(0.2), radius: 10),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: MUOPTheme.primaryYellow,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(color: MUOPTheme.border, width: 1.5),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: MUOPTheme.secondaryText.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
