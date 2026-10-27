import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.blur = 18,
    this.tintColor,
    this.opacity = 0.68,
    this.borderColor,
    this.borderWidth = 1.2,
    this.gradient,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final effectiveBorderColor =
        borderColor ?? Colors.white.withValues(alpha: 0.72);
    final baseColor = (tintColor ?? Colors.white).withValues(alpha: opacity);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: gradient == null ? baseColor : null,
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (tintColor ?? Colors.white).withValues(
                      alpha: (opacity + 0.12).clamp(0.0, 1.0),
                    ),
                    (tintColor ?? Colors.white).withValues(
                      alpha: (opacity - 0.08).clamp(0.0, 1.0),
                    ),
                  ],
                ),
            borderRadius: radius,
            border: Border.all(
              color: effectiveBorderColor,
              width: borderWidth,
            ),
          ),
          child: onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: radius,
                    splashColor: AppColors.universityRed.withValues(alpha: 0.06),
                    highlightColor: AppColors.gold.withValues(alpha: 0.08),
                    child: Padding(
                      padding: padding ?? EdgeInsets.zero,
                      child: child,
                    ),
                  ),
                )
              : Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
        ),
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: AppColors.universityRed.withValues(alpha: 0.05),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.darkText.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: content,
    );
  }
}

