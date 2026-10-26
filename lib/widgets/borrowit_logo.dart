import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BorrowItLogo extends StatelessWidget {
  final bool compact;

  const BorrowItLogo({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final style =
        (compact
                ? Theme.of(context).textTheme.titleLarge
                : Theme.of(context).textTheme.headlineMedium)
            ?.copyWith(
              color: AppColors.universityRed,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            );

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          const TextSpan(text: 'Borrow'),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.only(left: 2),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 5 : 7,
                vertical: compact ? 1 : 2,
              ),
              child: Text(
                'IT',
                style: style?.copyWith(
                  color: AppColors.universityRed,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
