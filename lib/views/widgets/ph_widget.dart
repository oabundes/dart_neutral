import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class PhWidget extends StatelessWidget {
  final double phValue;

  const PhWidget({super.key, required this.phValue});

  Color _getPhColor(double ph) {
    if (ph < 3) return Colors.red;
    if (ph < 6) return Colors.orange;
    if (ph <= 8) return AppTheme.solenisMint;
    if (ph <= 11) return Colors.blue;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final phColor = _getPhColor(phValue);

    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
      child: Column(
        children: [
          Text(
            'pH',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: phColor,
                  boxShadow: [
                    BoxShadow(
                      color: phColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    phValue.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                      color: AppTheme.diverseyNavy,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
