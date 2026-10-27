import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_panel.dart';
import '../widgets/request_card.dart';
import '../widgets/section_title.dart';
import 'history_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _firestore = FirestoreService();
  late final Stream<List<BorrowRequest>> _stream = _firestore.requestsStream(
    FirebaseAuth.instance.currentUser?.uid ?? '',
  );
  RequestStatus? _statusFilter;

  Future<void> _cancel(BorrowRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Withdraw request?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'This will remove your pending batch borrowing request.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep request'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brightRed,
              ),
              child: const Text('Withdraw'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _firestore.deleteRequest(request.id);
      await NotificationService.instance.cancelReminder(request.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<BorrowRequest>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load your requests.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRequests = snapshot.data!;
          final active = allRequests
              .where((request) => request.status != RequestStatus.returned)
              .toList();
          final returnedCount = allRequests
              .where((request) => request.status == RequestStatus.returned)
              .length;

          final filteredActive = _statusFilter == null
              ? active
              : active.where((r) => r.status == _statusFilter).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: SectionTitle(
                      title: 'Request Management',
                      subtitle:
                          'Monitor each batched equipment request from approval to return.',
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassPanel(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    borderRadius: 16,
                    opacity: 0.75,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 16,
                          color: AppColors.universityRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Log ($returnedCount)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _StageFilterChip(
                      label: 'All Active (${active.length})',
                      selected: _statusFilter == null,
                      onTap: () => setState(() => _statusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    for (final status in [
                      RequestStatus.pending,
                      RequestStatus.approved,
                      RequestStatus.borrowed,
                    ]) ...[
                      _StageFilterChip(
                        label: status.label,
                        selected: _statusFilter == status,
                        onTap: () => setState(() => _statusFilter = status),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              if (filteredActive.isEmpty)
                GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 34,
                  ),
                  borderRadius: 24,
                  opacity: 0.70,
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.timeline_rounded,
                          size: 26,
                          color: AppColors.universityRed,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusFilter == null
                            ? 'No active batch requests'
                            : 'No ${_statusFilter!.label.toLowerCase()} requests',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Submitted Borrowing Basket requests will appear here with live timeline tracking.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedText,
                            ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredActive.map(
                  (request) => RequestCard(
                    request: request,
                    onStatusChanged: (status) {
                      _firestore.updateStatus(request.id, status);
                    },
                    onCancel: request.status == RequestStatus.pending
                        ? () => _cancel(request)
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StageFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StageFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.universityRed
              : Colors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.gold.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.85),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? Colors.white : AppColors.darkText,
            ),
          ),
        ),
      ),
    );
  }
}
