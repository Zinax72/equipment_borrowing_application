import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Soft blurred BulSU background with maroon and gold ambient glow orbs used across main screens.
class CampusBackdrop extends StatelessWidget {
  const CampusBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.canvas),

        Opacity(
          opacity: 0.14,
          child: Image.asset(
            'assets/images/BULSU_BG.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),

        Positioned(
          top: -90,
          right: -70,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.universityRed.withValues(alpha: 0.22),
                  AppColors.maroonRuby.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 140,
          left: -90,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.24),
                  AppColors.brightGold.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -80,
          right: -50,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.18),
                  AppColors.universityRed.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.52),
                  AppColors.canvas.withValues(alpha: 0.68),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
