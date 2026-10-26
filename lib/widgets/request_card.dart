import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../utils/constants.dart';
import '../utils/date_format.dart';
import 'status_chip.dart';

class RequestCard extends StatelessWidget {
  final BorrowRequest request;
  final ValueChanged<RequestStatus>? onStatusChanged;
  final VoidCallback? onCancel;

  const RequestCard({
    super.key,
    required this.request,
    this.onStatusChanged,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.darkText,
      fontWeight: FontWeight.w700,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(request.equipmentSummary, style: titleStyle),
              ),
              const SizedBox(width: 10),
              if (onStatusChanged == null)
                StatusChip(status: request.status)
              else
                PopupMenuButton<RequestStatus>(
                  tooltip: 'Change status (demo)',
                  onSelected: onStatusChanged,
                  itemBuilder: (context) => RequestStatus.values
                      .map(
                        (status) => PopupMenuItem<RequestStatus>(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  child: StatusChip(status: request.status, showArrow: true),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RequestDate(
                icon: Icons.event_outlined,
                label: 'Needed',
                date: formatDate(request.dateNeeded),
              ),
              _RequestDate(
                icon: Icons.event_available_outlined,
                label: 'Return',
                date: formatDate(request.returnDate),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Purpose',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            request.purpose,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.darkText,
              height: 1.45,
            ),
          ),
          if (request.photoBase64.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                base64Decode(request.photoBase64),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Cancel request'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brightRed,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestDate extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;

  const _RequestDate({
    required this.icon,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.mutedText),
          const SizedBox(width: 7),
          Text(
            '$label · $date',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
