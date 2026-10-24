import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/sample_data.dart';
import '../widgets/equipment_card.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onBorrowPressed;
  final VoidCallback onViewAllPressed;
  final List<String> selectedEquipment;
  final ValueChanged<String> onEquipmentChanged;
  final int approvalCount;

  const DashboardScreen({
    super.key,
    required this.onBorrowPressed,
    required this.onViewAllPressed,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
    required this.approvalCount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.universityRed,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Equipment made easier.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Browse school equipment and submit borrowing requests.',
                        style: TextStyle(color: Colors.white, height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: onBorrowPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.darkText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                        ),
                        child: const Text(
                          'Start Borrowing',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 70,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Quick Overview',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: SummaryCard(
                  title: 'Available',
                  value: '56',
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'For Approval',
                  value: '$approvalCount',
                  icon: Icons.pending_actions_outlined,
                  iconColor: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Equipment',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onViewAllPressed,
                child: const Text('View all'),
              ),
            ],
          ),
          ListView.builder(
            itemCount: equipmentList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = equipmentList[index];
              return EquipmentCard(
                equipment: item,
                selected: selectedEquipment.contains(item.name),
                onTap: () => onEquipmentChanged(item.name),
              );
            },
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softYellow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: AppColors.universityRed,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ready to request equipment? Continue to the borrowing form.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: onBorrowPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
