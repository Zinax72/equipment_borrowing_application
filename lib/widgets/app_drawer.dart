import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenHistory;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.universityRed),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.universityRed,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'BorrowIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            selected: currentIndex == 0,
            onTap: () => onNavigate(0),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Borrow Equipment'),
            selected: currentIndex == 1,
            onTap: () => onNavigate(1),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('My Requests'),
            selected: currentIndex == 2,
            onTap: () => onNavigate(2),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Borrowing History'),
            subtitle: const Text('Completed transactions'),
            onTap: onOpenHistory,
          ),
        ],
      ),
    );
  }
}
