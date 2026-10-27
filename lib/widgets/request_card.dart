import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../utils/constants.dart';
import '../utils/date_format.dart';
import 'glass_panel.dart';
import 'status_chip.dart';

// Card displaying a submitted borrowing request, its items, status timeline, dates, and photo.
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

  String get _shortRequestId {
    if (request.id.isEmpty) return 'BATCH';
    final clean = request.id.toUpperCase();
    return clean.length > 6 ? clean.substring(0, 6) : clean;
  }

  @override
  Widget build(BuildContext context) {
    final quantities = request.effectiveEquipmentQuantities;
    final totalUnits = quantities.values.fold<int>(0, (a, b) => a + b);

    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      blur: 18,
      opacity: 0.76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.universityRed.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'REQ-$_shortRequestId \u00B7 $totalUnits ${totalUnits == 1 ? 'UNIT' : 'UNITS'}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: AppColors.universityRed,
                  ),
                ),
              ),
              const Spacer(),
              if (onStatusChanged == null)
                StatusChip(status: request.status)
              else
                PopupMenuButton<RequestStatus>(
                  tooltip: 'Update request stage (demo)',
                  onSelected: onStatusChanged,
                  itemBuilder: (context) => RequestStatus.values
                      .map(
                        (status) => PopupMenuItem<RequestStatus>(
                          value: status,
                          child: Row(
                            children: [
                              Icon(status.icon, size: 17, color: status.color),
                              const SizedBox(width: 8),
                              Text(
                                status.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  child: StatusChip(status: request.status, showArrow: true),
                ),
            ],
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quantities.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: AppColors.universityRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    if (entry.value > 1) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.universityRed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '\u00D7${entry.value}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Visual progress bar showing the current lifecycle stage of the request.
          _RequestLifecycleTimeline(currentStatus: request.status),
          // If the request was rejected, display the reason provided in a red callout box.
          if (request.status == RequestStatus.rejected &&
              request.rejectionReason.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: RequestStatus.rejected.bgColor.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: RequestStatus.rejected.color.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.report_gmailerrorred_rounded,
                    size: 18,
                    color: RequestStatus.rejected.color,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REASON FOR REJECTION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: RequestStatus.rejected.color,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          request.rejectionReason.trim(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _RequestDateTile(
                  icon: Icons.event_outlined,
                  label: 'DATE NEEDED',
                  date: formatDate(request.dateNeeded),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RequestDateTile(
                  icon: Icons.event_available_outlined,
                  label: 'RETURN DATE',
                  date: formatDate(request.returnDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'PURPOSE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
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
                height: 145,
                width: double.infinity,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          ],

          if (onCancel != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Withdraw Request'),
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

// Step-by-step lifecycle indicator (Pending -> Approved -> Borrowed -> Returned, or Pending -> Rejected).
class _RequestLifecycleTimeline extends StatelessWidget {
  final RequestStatus currentStatus;

  const _RequestLifecycleTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final isRejected = currentStatus == RequestStatus.rejected;
    final stages = isRejected
        ? const [
            RequestStatus.pending,
            RequestStatus.rejected,
          ]
        : const [
            RequestStatus.pending,
            RequestStatus.approved,
            RequestStatus.borrowed,
            RequestStatus.returned,
          ];
    final currentIndex = stages.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(stages.length * 2 - 1, (idx) {
              if (idx.isOdd) {
                final stepBefore = idx ~/ 2;
                final isCompletedLine = stepBefore < currentIndex;
                return Expanded(
                  child: Container(
                    height: 2.5,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: isCompletedLine
                          ? LinearGradient(
                              colors: [
                                AppColors.universityRed,
                                isRejected
                                    ? RequestStatus.rejected.color
                                    : AppColors.gold,
                              ],
                            )
                          : null,
                      color: isCompletedLine
                          ? null
                          : AppColors.mutedText.withValues(alpha: 0.20),
                    ),
                  ),
                );
              }

              final stageIndex = idx ~/ 2;
              final stage = stages[stageIndex];
              final isCompleted = stageIndex < currentIndex;
              final isCurrent = stageIndex == currentIndex;
              final activeColor = stage.color;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: isCurrent ? 28 : 22,
                    height: isCurrent ? 28 : 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? activeColor
                          : isCompleted
                              ? AppColors.gold.withValues(alpha: 0.30)
                              : AppColors.field,
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.brightGold
                            : isCompleted
                                ? AppColors.universityRed.withValues(alpha: 0.5)
                                : AppColors.mutedText.withValues(alpha: 0.25),
                        width: isCurrent ? 1.8 : 1.1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.28),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_rounded : stage.icon,
                      size: isCurrent ? 14 : 12,
                      color: isCurrent
                          ? Colors.white
                          : isCompleted
                              ? AppColors.universityRed
                              : AppColors.mutedText,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(stages.length, (stageIndex) {
              final stage = stages[stageIndex];
              final isCurrent = stageIndex == currentIndex;
              final isCompleted = stageIndex < currentIndex;
              return Text(
                stage.label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isCurrent || isCompleted
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: isCurrent
                      ? stage.color
                      : isCompleted
                          ? AppColors.darkText
                          : AppColors.mutedText,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RequestDateTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;

  const _RequestDateTile({
    required this.icon,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.universityRed),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
