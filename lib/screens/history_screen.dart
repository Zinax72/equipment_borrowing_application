import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/campus_backdrop.dart';
import '../widgets/glass_panel.dart';
import '../widgets/request_card.dart';
import '../widgets/section_title.dart';

// Displays the complete Borrowing History Log, including all requests and status changes (Pending, Approved, Borrowed, Returned, Rejected).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _firestore = FirestoreService();
  late Stream<List<BorrowRequest>> _stream = _createStream();
  // Null shows all logs; otherwise filters by the selected RequestStatus.
  RequestStatus? _statusFilter;

  Stream<List<BorrowRequest>> _createStream() {
    return _firestore.requestsStream(
      FirebaseAuth.instance.currentUser?.uid ?? '',
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _stream = _createStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
        title: Text(
          'Borrowing History Log',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
                letterSpacing: -0.4,
              ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CampusBackdrop()),
          SafeArea(
            child: StreamBuilder<List<BorrowRequest>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load your history.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // All borrowing requests are recorded in the log regardless of current status.
                final allLogs = snapshot.data!;
                final filteredLogs = _statusFilter == null
                    ? allLogs
                    : allLogs
                        .where((req) => req.status == _statusFilter)
                        .toList();

                final totalStatusEvents = allLogs.fold<int>(
                  0,
                  (sum, req) => sum + req.effectiveStatusHistory.length,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  children: [
                    const SectionTitle(
                      title: 'Activity & Status Logs',
                      subtitle:
                          'Complete record of all borrowed equipment requests and status changes (Pending, Approved, Borrowed, Returned, and Rejected).',
                    ),
                    const SizedBox(height: 18),

                    // Summary banner showing total requests and total status transitions logged.
                    GlassPanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      borderRadius: 20,
                      opacity: 0.72,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: RequestStatus.returned.color
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.history_edu_rounded,
                              color: RequestStatus.returned.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${allLogs.length} logged ${allLogs.length == 1 ? 'request' : 'requests'} \u00B7 $totalStatusEvents status ${totalStatusEvents == 1 ? 'update' : 'updates'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Includes all submissions, approvals, checkouts, returns, and rejections',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter pills to view all logs or filter by any specific status.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _LogFilterChip(
                          label: 'All Logs (${allLogs.length})',
                          selected: _statusFilter == null,
                          color: AppColors.universityRed,
                          onTap: () => setState(() => _statusFilter = null),
                        ),
                        for (final status in RequestStatus.values)
                          _LogFilterChip(
                            label:
                                '${status.label} (${allLogs.where((r) => r.status == status).length})',
                            selected: _statusFilter == status,
                            color: status.color,
                            onTap: () => setState(() => _statusFilter = status),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (filteredLogs.isEmpty)
                      const _HistoryEmptyState()
                    else
                      ...filteredLogs.map(
                        (request) => RequestCard(
                          request: request,
                          showStatusLogs: true,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Filter pill used on the History / Log screen to filter log entries by status.
class _LogFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _LogFilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.gold.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.85),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Colors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }
}

// Empty state card shown when no borrowing logs match the current filter.
class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      borderRadius: 24,
      opacity: 0.70,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 28,
              color: AppColors.universityRed,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No borrowing logs found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            'All submitted requests and status updates will be recorded here automatically.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
