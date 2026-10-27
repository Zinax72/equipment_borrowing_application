import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Animated campus background and primary button used on the Landing and Auth screens.
class AuthBackdropColors {
  const AuthBackdropColors._();

  static const Color lightCanvas = Color(0xFFF8F6F8);
}

// Renders the drifting BulSU campus photo, soft light gradient, and blurred ambient orbs.
class AuthBackdrop extends StatefulWidget {
  final double photoFraction;

  const AuthBackdrop({super.key, this.photoFraction = 0.56});

  @override
  State<AuthBackdrop> createState() => _AuthBackdropState();
}

class _AuthBackdropState extends State<AuthBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final photoHeight = height * widget.photoFraction;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AuthBackdropColors.lightCanvas),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: photoHeight,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _drift,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_drift.value);
                return Transform.scale(
                  scale: 1.04 + t * 0.06,
                  alignment: Alignment(-0.25 + t * 0.5, -0.2),
                  child: child,
                );
              },
              child: Opacity(
                opacity: 0.42,
                child: Image.asset(
                  'assets/images/BULSU_BG.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(-0.2, 0),
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.canvas),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: photoHeight + 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.45),
                  AppColors.softYellow.withValues(alpha: 0.40),
                  AuthBackdropColors.lightCanvas.withValues(alpha: 0.92),
                  AuthBackdropColors.lightCanvas,
                ],
                stops: const [0.0, 0.35, 0.78, 1.0],
              ),
            ),
          ),
        ),

        Positioned(
          top: -60,
          left: -80,
          child: _Glow(
            size: 320,
            color: AppColors.gold.withValues(alpha: 0.28),
          ),
        ),

        Positioned(
          top: height * 0.22,
          right: -110,
          child: _Glow(
            size: 340,
            color: AppColors.universityRed.withValues(alpha: 0.16),
          ),
        ),

        Positioned(
          bottom: -100,
          left: -90,
          child: _Glow(
            size: 340,
            color: AppColors.gold.withValues(alpha: 0.20),
          ),
        ),

        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: ColoredBox(
            color: Colors.white.withValues(alpha: 0.22),
          ),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

// Primary BulSU Maroon CTA button used on the Landing and Authentication screens.
class GoldButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  const GoldButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.universityRed, AppColors.maroonRuby],
          ),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.55),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.universityRed.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 54,
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (icon != null) ...[
                            const SizedBox(width: 8),
                            Icon(icon, size: 19, color: AppColors.brightGold),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
