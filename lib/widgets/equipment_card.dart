import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../utils/constants.dart';
import 'equipment_image.dart';
import 'quantity_stepper.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final availabilityColor = equipment.isAvailable
        ? AppColors.green
        : AppColors.mutedText;
    final selected = quantity > 0;

    return AnimatedScale(
      scale: selected ? 1.015 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Semantics(
        button: equipment.isAvailable,
        selected: selected,
        label:
            '${equipment.name}, ${equipment.category}, ${equipment.isAvailable ? '${equipment.available} available' : 'unavailable'}${selected ? ', $quantity selected' : ''}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? AppColors.coralWash : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.universityRed : Colors.transparent,
              width: selected ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkText.withValues(
                  alpha: selected ? 0.09 : 0.045,
                ),
                blurRadius: selected ? 22 : 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Material(
              color: selected ? AppColors.coralWash : Colors.white,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: equipment.isAvailable && !selected
                    ? () => onQuantityChanged(1)
                    : null,
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          EquipmentImage(
                            imageUrl: equipment.imageUrl,
                            radius: 0,
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Text(
                                  equipment.isAvailable
                                      ? '${equipment.available} available'
                                      : 'Unavailable',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: availabilityColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          if (selected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: AppColors.universityRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipment.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              equipment.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.mutedText),
                            ),
                            const SizedBox(height: 8),
                            if (selected)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: QuantityStepper(
                                  quantity: quantity,
                                  maximum: equipment.available,
                                  onChanged: onQuantityChanged,
                                ),
                              )
                            else
                              Text(
                                equipment.isAvailable
                                    ? 'Tap to add'
                                    : 'Not available',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppColors.universityRed,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                          ],
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
  }
}
