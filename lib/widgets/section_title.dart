import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? eyebrow;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.55),
                width: 0.9,
              ),
            ),
            child: Text(
              eyebrow!.toUpperCase(),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: AppColors.universityRed,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
                height: 1.45,
              ),
        ),
      ],
    );
  }
}
