import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EquipmentImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final double radius;

  const EquipmentImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.field,
              child: const Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.mutedText,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.field,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.universityRed,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
