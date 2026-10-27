import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final int maximum;
  final ValueChanged<int> onChanged;
  final bool compact;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.maximum,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final incrementEnabled = quantity < maximum;
    final height = compact ? 34.0 : 40.0;
    final buttonSize = compact ? 28.0 : 32.0;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.universityRed.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.universityRed.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepIconButton(
            size: buttonSize,
            tooltip: 'Remove one',
            icon: Icons.remove_rounded,
            onPressed: () => onChanged(quantity - 1),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: compact ? 22 : 26),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              semanticsLabel: '$quantity selected',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.universityRed,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
          _StepIconButton(
            size: buttonSize,
            tooltip: incrementEnabled
                ? 'Add one'
                : 'Maximum available quantity reached',
            icon: Icons.add_rounded,
            onPressed: incrementEnabled ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepIconButton extends StatelessWidget {
  final double size;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepIconButton({
    required this.size,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled
            ? Colors.white.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size * 0.56,
              color: enabled
                  ? AppColors.universityRed
                  : AppColors.mutedText.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
