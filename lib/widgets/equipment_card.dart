import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../utils/constants.dart';
import 'equipment_image.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final bool selected;
  final VoidCallback onTap;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: selected ? AppColors.softYellow : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.gold : const Color(0xFFE5E5E5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: EquipmentImage(
          imageUrl: equipment.imageUrl,
          width: 48,
          height: 48,
          radius: 13,
        ),
        title: Text(
          equipment.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${equipment.category} • ${equipment.available} available',
        ),
        trailing: IconButton(
          onPressed: equipment.isAvailable ? onTap : null,
          icon: Icon(
            selected ? Icons.check_circle : Icons.add_circle_outline,
            color: selected ? Colors.green : AppColors.universityRed,
          ),
        ),
      ),
    );
  }
}
