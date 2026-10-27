import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Reusable primary action button (supports BulSU Maroon default or palette Green for submit actions).
class CampusPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool compact;
  final bool useGreen;

  const CampusPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.compact = false,
    this.useGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final gradientColors = useGreen
        ? const [Color(0xFF1E6649), AppColors.green]
        : const [AppColors.universityRed, AppColors.maroonRuby];
    final shadowColor = useGreen ? AppColors.green : AppColors.universityRed;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.55,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(compact ? 14 : 18),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: BorderRadius.circular(compact ? 14 : 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: compact ? 42 : 52,
                  minWidth: compact ? 88 : 110,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 16 : 22,
                    vertical: compact ? 10 : 14,
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                Icon(
                                  icon,
                                  color: AppColors.brightGold,
                                  size: compact ? 17 : 19,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      fontSize: compact ? 13 : 14.5,
                                    ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
