import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../utils/constants.dart';
import '../widgets/equipment_image.dart';

class EquipmentDetailsScreen extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onBorrow;

  const EquipmentDetailsScreen({
    super.key,
    required this.equipment,
    required this.onBorrow,
  });

  @override
  Widget build(BuildContext context) {
    final availabilityColor = equipment.isAvailable
        ? AppColors.green
        : AppColors.mutedText;

    return Scaffold(
      appBar: AppBar(title: Text(equipment.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkText.withValues(alpha: 0.07),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: EquipmentImage(
                  imageUrl: equipment.imageUrl,
                  height: 260,
                  radius: 18,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              equipment.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(equipment.category),
                  backgroundColor: AppColors.field,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
                Chip(
                  avatar: Icon(
                    Icons.circle,
                    size: 10,
                    color: availabilityColor,
                  ),
                  label: Text(
                    equipment.isAvailable
                        ? '${equipment.available} available'
                        : 'Unavailable',
                    style: TextStyle(
                      color: availabilityColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  backgroundColor: availabilityColor.withValues(alpha: 0.10),
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'About this item',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              equipment.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedText,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: equipment.isAvailable ? onBorrow : null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add to borrowing request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
