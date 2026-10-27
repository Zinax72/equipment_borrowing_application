import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import 'borrowit_logo.dart';

class AppDrawer {
  const AppDrawer._();

  static Future<void> show(
    BuildContext context, {
    required int currentIndex,
    required ValueChanged<int> onNavigate,
    required VoidCallback onOpenHistory,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close navigation menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final mediaQuery = MediaQuery.of(dialogContext);
        final drawerWidth = (mediaQuery.size.width - 48).clamp(0.0, 360.0);
        final drawerHeight =
            mediaQuery.size.height - mediaQuery.padding.vertical - 24;
        final user = FirebaseAuth.instance.currentUser;
        final name = user?.displayName?.trim();
        final displayName = name == null || name.isEmpty ? 'Student' : name;
        final initials = displayName
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

        void closeAnd(VoidCallback action) {
          Navigator.of(dialogContext).pop();
          action();
        }

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: ColoredBox(
                      color: AppColors.darkText.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 12,
                      bottom: 12,
                    ),
                    child: SizedBox(
                      width: drawerWidth.toDouble(),
                      height: drawerHeight.clamp(0.0, mediaQuery.size.height),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.86),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 1.2,
                              ),
                            ),
                            child: NavigationDrawer(
                              selectedIndex: currentIndex,
                              onDestinationSelected: (index) {
                                closeAnd(() => onNavigate(index));
                              },
                              backgroundColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              indicatorColor: AppColors.universityRed
                                  .withValues(alpha: 0.12),
                              indicatorShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 22, 20, 6),
                                  child: BorrowItLogo(compact: true),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 16, 20, 20),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.45),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppColors.universityRed,
                                          foregroundColor: AppColors.brightGold,
                                          child: Text(
                                            initials.isEmpty ? 'B' : initials,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                displayName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(dialogContext)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      color: AppColors.darkText,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                              if (user?.email
                                                  case final email?)
                                                Text(
                                                  email,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(dialogContext)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            AppColors.mutedText,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const NavigationDrawerDestination(
                                  icon: Icon(Icons.grid_view_outlined),
                                  selectedIcon: Icon(Icons.grid_view_rounded),
                                  label: Text('Equipment Catalog'),
                                ),
                                const NavigationDrawerDestination(
                                  icon: Icon(Icons.shopping_basket_outlined),
                                  selectedIcon:
                                      Icon(Icons.shopping_basket_rounded),
                                  label: Text('Borrowing Basket'),
                                ),
                                const NavigationDrawerDestination(
                                  icon: Icon(Icons.timeline_outlined),
                                  selectedIcon: Icon(Icons.timeline_rounded),
                                  label: Text('Request Management'),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Divider(height: 1),
                                ),
                                ListTile(
                                  minLeadingWidth: 24,
                                  leading: const Icon(
                                    Icons.history_rounded,
                                    color: AppColors.universityRed,
                                  ),
                                  title: const Text('Borrowing History Log'),
                                  onTap: () => closeAnd(onOpenHistory),
                                ),
                                ListTile(
                                  minLeadingWidth: 24,
                                  leading: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: AppColors.universityRed,
                                  ),
                                  title: const Text('Test Notification'),
                                  subtitle:
                                      const Text('Send a sample status alert'),
                                  onTap: () {
                                    closeAnd(() {
                                      NotificationService.instance.sendTest();
                                    });
                                  },
                                ),
                                ListTile(
                                  minLeadingWidth: 24,
                                  leading: const Icon(
                                    Icons.logout_rounded,
                                    color: AppColors.brightRed,
                                  ),
                                  title: const Text('Sign out'),
                                  onTap: () =>
                                      closeAnd(() => AuthService().logout()),
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
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        );
      },
    );
  }
}
