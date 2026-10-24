import 'package:flutter/material.dart';
import '../models/request_status.dart';

class StatusChip extends StatelessWidget {
  final RequestStatus status;
  final bool showArrow;

  const StatusChip({super.key, required this.status, this.showArrow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.label,
            style: TextStyle(color: status.color, fontWeight: FontWeight.bold),
          ),
          if (showArrow) ...[
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: status.color, size: 18),
          ],
        ],
      ),
    );
  }
}
