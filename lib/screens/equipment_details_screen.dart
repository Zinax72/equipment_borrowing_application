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
    final color = equipment.isAvailable ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(equipment.name),
        backgroundColor: AppColors.universityRed,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          EquipmentImage(imageUrl: equipment.imageUrl, height: 220, radius: 18),
          const SizedBox(height: 18),
          Text(
            equipment.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Chip(
                label: Text(equipment.category),
                backgroundColor: AppColors.softYellow,
                side: BorderSide.none,
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  equipment.isAvailable
                      ? '${equipment.available} available'
                      : 'Unavailable',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                backgroundColor: color.withValues(alpha: 0.10),
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(equipment.description, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: equipment.isAvailable ? onBorrow : null,
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Borrow this item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.universityRed,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
