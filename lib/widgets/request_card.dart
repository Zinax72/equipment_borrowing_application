import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../utils/date_format.dart';
import 'status_chip.dart';
import 'dart:convert';

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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.equipment.join(', '),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (onStatusChanged == null)
                  StatusChip(status: request.status)
                else
                  PopupMenuButton<RequestStatus>(
                    tooltip: 'Change status (demo)',
                    onSelected: onStatusChanged,
                    itemBuilder: (context) => RequestStatus.values
                        .map(
                          (s) => PopupMenuItem<RequestStatus>(
                            value: s,
                            child: Text(s.label),
                          ),
                        )
                        .toList(),
                    child: StatusChip(status: request.status, showArrow: true),
                  ),
              ],
            ),
            const Divider(height: 22),
            Text('Date needed: ${formatDate(request.dateNeeded)}'),
            Text('Return date: ${formatDate(request.returnDate)}'),
            const SizedBox(height: 6),
            Text(
              'Purpose: ${request.purpose}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
            if (request.photoBase64.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(request.photoBase64),
                  height: 120,
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
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Cancel request'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
