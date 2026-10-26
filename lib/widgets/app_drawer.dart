import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

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
        final drawerWidth = (mediaQuery.size.width - 48).clamp(0.0, 380.0);
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
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: ColoredBox(
                      color: AppColors.darkText.withValues(alpha: 0.24),
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
                      child: NavigationDrawer(
                        selectedIndex: currentIndex,
                        onDestinationSelected: (index) {
                          closeAnd(() => onNavigate(index));
                        },
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        indicatorColor: AppColors.goldWash,
                        indicatorShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.goldWash,
                                  foregroundColor: AppColors.universityRed,
                                  child: Text(
                                    initials.isEmpty ? 'B' : initials,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(dialogContext)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppColors.darkText,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      if (user?.email case final email?)
                                        Text(
                                          email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(dialogContext)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.mutedText,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const NavigationDrawerDestination(
                            icon: Icon(Icons.grid_view_outlined),
                            selectedIcon: Icon(Icons.grid_view_rounded),
                            label: Text('Dashboard'),
                          ),
                          const NavigationDrawerDestination(
                            icon: Icon(Icons.add_box_outlined),
                            selectedIcon: Icon(Icons.add_box_rounded),
                            label: Text('Borrow equipment'),
                          ),
                          const NavigationDrawerDestination(
                            icon: Icon(Icons.receipt_long_outlined),
                            selectedIcon: Icon(Icons.receipt_long_rounded),
                            label: Text('My requests'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Divider(height: 1),
                          ),
                          ListTile(
                            minLeadingWidth: 24,
                            leading: const Icon(Icons.history_rounded),
                            title: const Text('Borrowing history'),
                            onTap: () => closeAnd(onOpenHistory),
                          ),
                          ListTile(
                            minLeadingWidth: 24,
                            leading: const Icon(
                              Icons.notifications_active_outlined,
                            ),
                            title: const Text('Test notification'),
                            subtitle: const Text('Send a quick test'),
                            onTap: () {
                              closeAnd(() {
                                NotificationService.instance.sendTest();
                              });
                            },
                          ),
                          ListTile(
                            minLeadingWidth: 24,
                            leading: const Icon(Icons.logout_rounded),
                            title: const Text('Log out'),
                            onTap: () => closeAnd(() => AuthService().logout()),
                          ),
                        ],
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
