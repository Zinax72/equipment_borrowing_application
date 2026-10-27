import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../utils/constants.dart';
import 'equipment_image.dart';
import 'glass_panel.dart';
import 'quantity_stepper.dart';

// Catalog grid card showing equipment image, stock badge, category, and Add / Quantity stepper.
class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback? onTap;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.quantity,
    required this.onQuantityChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;
    final availabilityColor = equipment.isAvailable
        ? AppColors.green
        : AppColors.mutedText;

    return AnimatedScale(
      scale: selected ? 1.012 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Semantics(
        button: true,
        selected: selected,
        label:
            '${equipment.name}, ${equipment.category}, ${equipment.isAvailable ? '${equipment.available} available' : 'unavailable'}${selected ? ', $quantity in Borrowing Basket' : ''}',
        child: GlassPanel(
          onTap: onTap ??
              (equipment.isAvailable && !selected
                  ? () => onQuantityChanged(1)
                  : null),
          borderRadius: 24,
          blur: 18,
          opacity: selected ? 0.82 : 0.66,
          tintColor: selected ? AppColors.coralWash : Colors.white,
          borderColor: selected
              ? AppColors.universityRed.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.78),
          borderWidth: selected ? 1.6 : 1.1,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'equipment-img-${equipment.id.isEmpty ? equipment.name : equipment.id}',
                      child: EquipmentImage(
                        imageUrl: equipment.imageUrl,
                        radius: 18,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.12),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.22),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.84),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.5,
                                  height: 6.5,
                                  decoration: BoxDecoration(
                                    color: availabilityColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  equipment.isAvailable
                                      ? '${equipment.available} avail'
                                      : 'Out of stock',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.darkText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.5,
                                      ),
                                ),
                              ],
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
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.universityRed,
                                AppColors.maroonRuby,
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.brightGold,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.universityRed
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.universityRed,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        equipment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                      ),
                      const Spacer(),
                      if (selected)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: QuantityStepper(
                            compact: true,
                            quantity: quantity,
                            maximum: equipment.available,
                            onChanged: onQuantityChanged,
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: Material(
                            color: equipment.isAvailable
                                ? AppColors.universityRed
                                    .withValues(alpha: 0.08)
                                : AppColors.field.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: equipment.isAvailable
                                  ? () => onQuantityChanged(1)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      equipment.isAvailable
                                          ? Icons.add_rounded
                                          : Icons.block_rounded,
                                      size: 16,
                                      color: equipment.isAvailable
                                          ? AppColors.universityRed
                                          : AppColors.mutedText,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        equipment.isAvailable
                                            ? 'Add to Request'
                                            : 'Unavailable',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: equipment.isAvailable
                                              ? AppColors.universityRed
                                              : AppColors.mutedText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
    );
  }
}
