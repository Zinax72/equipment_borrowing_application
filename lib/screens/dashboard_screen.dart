import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../utils/constants.dart';
import '../widgets/equipment_card.dart';
import '../widgets/campus_primary_button.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  final Stream<List<Equipment>> equipmentStream;
  final VoidCallback onBorrowPressed;
  final VoidCallback onViewAllPressed;
  final Map<String, int> selectedEquipment;
  final void Function(String name, int quantity) onQuantityChanged;
  final int approvalCount;

  const DashboardScreen({
    super.key,
    required this.equipmentStream,
    required this.onBorrowPressed,
    required this.onViewAllPressed,
    required this.selectedEquipment,
    required this.onQuantityChanged,
    required this.approvalCount,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    final greetingName = displayName == null || displayName.isEmpty
        ? 'there'
        : displayName.split(RegExp(r'\s+')).first;

    return SafeArea(
      child: StreamBuilder<List<Equipment>>(
        stream: equipmentStream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final totalAvailable = items.fold<int>(
            0,
            (sum, item) => sum + item.available,
          );
          final selectedCount = selectedEquipment.values.fold<int>(
            0,
            (sum, quantity) => sum + quantity,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Text(
                'Hello, $greetingName!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Find what you need for class and campus life.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Items available',
                      value: '$totalAvailable',
                      icon: Icons.inventory_2_outlined,
                      iconColor: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Awaiting review',
                      value: '$approvalCount',
                      icon: Icons.schedule_outlined,
                      iconColor: AppColors.universityRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 27),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Find equipment',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onViewAllPressed,
                    child: const Text('Browse all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (snapshot.hasError)
                _CatalogMessage(
                  icon: Icons.wifi_off_outlined,
                  message: 'Could not load equipment. Check your connection.',
                )
              else if (!snapshot.hasData)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                _CatalogMessage(
                  icon: Icons.inventory_2_outlined,
                  message: 'No equipment is listed right now.',
                )
              else
                GridView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return EquipmentCard(
                      equipment: item,
                      quantity: selectedEquipment[item.name] ?? 0,
                      onQuantityChanged: (quantity) =>
                          onQuantityChanged(item.name, quantity),
                    );
                  },
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: selectedEquipment.isEmpty
                    ? const SizedBox.shrink(key: ValueKey('no-selection'))
                    : Padding(
                        key: const ValueKey('selection-summary'),
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.coralWash,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$selectedCount ${selectedCount == 1 ? 'item' : 'items'} selected',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.darkText,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      selectedEquipment.entries
                                          .map(
                                            (entry) => entry.value > 1
                                                ? '${entry.key} × ${entry.value}'
                                                : entry.key,
                                          )
                                          .join(', '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.mutedText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              CampusPrimaryButton(
                                label: 'Continue',
                                onPressed: onBorrowPressed,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _CatalogMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.mutedText, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
