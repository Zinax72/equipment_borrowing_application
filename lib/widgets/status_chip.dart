import 'package:flutter/material.dart';
import '../models/request_status.dart';

class StatusChip extends StatelessWidget {
  final RequestStatus status;
  final bool showArrow;

  const StatusChip({super.key, required this.status, this.showArrow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: status.bgColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: status.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13.5, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              letterSpacing: 0.1,
            ),
          ),
          if (showArrow) ...[
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: status.color,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }
}
