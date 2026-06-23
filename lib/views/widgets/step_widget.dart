import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class StepWidget extends StatelessWidget {
  final int step;
  final String description;

  const StepWidget({super.key, required this.step, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Row(
        children: [
          // Step Number Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.solenisMint.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.solenisMint, width: 2),
            ),
            child: Center(
              child: Text(
                '$step',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.solenisMint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PASO ACTUAL',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.diverseyNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
