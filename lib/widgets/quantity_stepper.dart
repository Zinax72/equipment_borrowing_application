import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final int maximum;
  final ValueChanged<int> onChanged;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.maximum,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final incrementEnabled = quantity < maximum;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.goldWash,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Remove one',
            onPressed: () => onChanged(quantity - 1),
            icon: const Icon(Icons.remove_rounded),
            visualDensity: VisualDensity.compact,
            color: AppColors.universityRed,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              semanticsLabel: '$quantity selected',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.universityRed,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton(
            tooltip: incrementEnabled
                ? 'Add one'
                : 'Maximum available quantity reached',
            onPressed: incrementEnabled ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add_rounded),
            visualDensity: VisualDensity.compact,
            color: AppColors.universityRed,
          ),
        ],
      ),
    );
  }
}
