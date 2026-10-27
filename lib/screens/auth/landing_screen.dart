import 'package:flutter/material.dart';
import '../../models/request_status.dart';
import '../../utils/constants.dart';
import '../../widgets/auth_backdrop.dart';
import '../../widgets/borrowit_logo.dart';
import '../../widgets/equipment_image.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/status_chip.dart';
import 'auth_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  late final List<Animation<double>> _steps = List.generate(6, (i) {
    final begin = i * 0.1;
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, begin + 0.5, curve: Curves.easeOutCubic),
    );
  });

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  Widget _reveal(int step, Widget child) {
    final anim = _steps[step];
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.16),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  void _openAuth(AuthMode mode) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            AuthScreen(initialMode: mode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthBackdropColors.lightCanvas,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _reveal(0, _topBar()),
                                const Spacer(),
                                _reveal(1, _floatingPreview()),
                                const SizedBox(height: 26),
                                _reveal(2, _headline(context)),
                                const SizedBox(height: 20),
                                _reveal(3, _featureRow()),
                                const SizedBox(height: 26),
                                _reveal(4, _actions()),
                                const SizedBox(height: 14),
                                _reveal(
                                  5,
                                  const Text(
                                    'For Bulacan State University students',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.mutedText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        const BorrowItLogo(compact: true),
        const Spacer(),
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          borderRadius: 999,
          opacity: 0.78,
          borderColor: Colors.white.withValues(alpha: 0.9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Student Portal',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _floatingPreview() {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_float.value);
        return Transform.translate(
          offset: Offset(0, -5 + t * 10),
          child: child,
        );
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Transform.rotate(
          angle: -0.025,
          child: SizedBox(
            width: 300,
            child: GlassPanel(
              padding: const EdgeInsets.all(15),
              borderRadius: 24,
              blur: 22,
              opacity: 0.82,
              borderColor: Colors.white.withValues(alpha: 0.92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.universityRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'REQ-7F2KQ \u00B7 3 UNITS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: AppColors.universityRed,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const StatusChip(status: RequestStatus.approved),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      EquipmentImage(
                        imageUrl:
                            'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=300',
                        width: 50,
                        height: 50,
                        radius: 14,
                      ),
                      SizedBox(width: 8),
                      EquipmentImage(
                        imageUrl:
                            'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=300',
                        width: 50,
                        height: 50,
                        radius: 14,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Camera \u00D7 2, Projector',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.darkText,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Ready for pickup \u00B7 Custodian',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(4, (i) {
                      final done = i <= 1;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: done
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.universityRed,
                                      AppColors.gold,
                                    ],
                                  )
                                : null,
                            color: done
                                ? null
                                : AppColors.darkText.withValues(alpha: 0.10),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/BULSU LOGO.png',
              width: 26,
              height: 26,
              cacheWidth: 104,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            const Text(
              'BULACAN STATE UNIVERSITY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: AppColors.universityRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 36,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.3,
              color: AppColors.darkText,
            ),
            children: [
              TextSpan(text: 'Campus equipment,\n'),
              TextSpan(
                text: 'one batch request',
                style: TextStyle(color: AppColors.universityRed),
              ),
              TextSpan(text: ' away.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Student equipment borrowing platform for BulSU - build your Borrowing Basket and monitor every item from approval to return.',
          style: TextStyle(
            fontSize: 14.5,
            height: 1.5,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _featureRow() {
    const features = [
      (Icons.shopping_basket_outlined, 'Batch\nrequests'),
      (Icons.timeline_rounded, 'Live\ntracking'),
      (Icons.notifications_active_outlined, 'Return\nreminders'),
    ];
    return Row(
      children: [
        for (var i = 0; i < features.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              borderRadius: 18,
              opacity: 0.76,
              borderColor: Colors.white.withValues(alpha: 0.9),
              child: Row(
                children: [
                  Icon(
                    features[i].$1,
                    size: 18,
                    color: AppColors.universityRed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      features[i].$2,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _actions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GoldButton(
          label: 'Sign in',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => _openAuth(AuthMode.signIn),
        ),
        const SizedBox(height: 12),
        GlassPanel(
          onTap: () => _openAuth(AuthMode.register),
          borderRadius: 18,
          opacity: 0.80,
          borderColor: AppColors.universityRed.withValues(alpha: 0.25),
          child: const SizedBox(
            height: 54,
            child: Center(
              child: Text(
                'Create an account',
                style: TextStyle(
                  color: AppColors.universityRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
