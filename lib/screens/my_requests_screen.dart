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

// Displays the student's active and rejected requests with filter pills and status updates.
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _firestore = FirestoreService();
  late Stream<List<BorrowRequest>> _stream = _createStream();
  // Null means "All Active" pill is selected; otherwise filters by the chosen RequestStatus.
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

  // Asks for confirmation and deletes a pending request from Firestore.
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

  // Updates request status; if Rejected is selected, prompts for a rejection reason first.
  Future<void> _handleStatusChange(
    BorrowRequest request,
    RequestStatus status,
  ) async {
    if (status == RequestStatus.rejected) {
      final reason = await _promptRejectionReason(request);
      if (reason == null) return;
      await _firestore.updateStatus(
        request.id,
        RequestStatus.rejected,
        rejectionReason: reason,
      );
      return;
    }
    await _firestore.updateStatus(request.id, status);
  }

  // Opens the popup dialog where the user types the reason for rejection.
  Future<String?> _promptRejectionReason(BorrowRequest request) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => _RejectionReasonDialog(
        initialReason: request.rejectionReason,
      ),
    );
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
          // Active requests exclude both Returned and Rejected items.
          final active = allRequests
              .where(
                (request) =>
                    request.status != RequestStatus.returned &&
                    request.status != RequestStatus.rejected,
              )
              .toList();
          // Rejected requests have their own dedicated filter list and pill.
          final rejected = allRequests
              .where((request) => request.status == RequestStatus.rejected)
              .toList();
          final returnedCount = allRequests
              .where((request) => request.status == RequestStatus.returned)
              .length;

          // Determines which list of requests to display based on the selected filter pill.
          final filteredRequests = _statusFilter == null
              ? active
              : _statusFilter == RequestStatus.rejected
                  ? rejected
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

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StageFilterChip(
                    label: 'All Active (${active.length})',
                    selected: _statusFilter == null,
                    onTap: () => setState(() => _statusFilter = null),
                  ),
                  for (final status in [
                    RequestStatus.pending,
                    RequestStatus.approved,
                    RequestStatus.borrowed,
                    RequestStatus.rejected,
                  ])
                    _StageFilterChip(
                      label: status == RequestStatus.rejected
                          ? 'Rejected (${rejected.length})'
                          : status.label,
                      selected: _statusFilter == status,
                      isRejectedChip: status == RequestStatus.rejected,
                      onTap: () => setState(() => _statusFilter = status),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              if (filteredRequests.isEmpty)
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
                ...filteredRequests.map(
                  (request) => RequestCard(
                    request: request,
                    onStatusChanged: request.status == RequestStatus.rejected
                        ? null
                        : (status) => _handleStatusChange(request, status),
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

// Popup dialog widget for entering a required reason when rejecting a request.
class _RejectionReasonDialog extends StatefulWidget {
  final String initialReason;

  const _RejectionReasonDialog({required this.initialReason});

  @override
  State<_RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<_RejectionReasonDialog> {
  late String _reason = widget.initialReason;
  String? _errorText;

  void _submit() {
    final trimmed = _reason.trim();
    if (trimmed.isEmpty) {
      setState(() => _errorText = 'Please enter a reason for rejection');
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withValues(alpha: 0.96),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Text(
        'Reason for Rejection',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provide a brief explanation why this borrowing request was declined.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: widget.initialReason,
              autofocus: true,
              maxLines: 3,
              maxLength: 160,
              onChanged: (value) {
                _reason = value;
                if (_errorText != null && value.trim().isNotEmpty) {
                  setState(() => _errorText = null);
                }
              },
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Rejection reason',
                hintText: 'e.g. Equipment reserved for scheduled lab exam',
                prefixIcon: const Icon(Icons.comment_bank_outlined),
                errorText: _errorText,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit Reason'),
        ),
      ],
    );
  }
}

class _StageFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isRejectedChip;
  final VoidCallback onTap;

  const _StageFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isRejectedChip = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg =
        isRejectedChip ? RequestStatus.rejected.color : AppColors.universityRed;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? activeBg
              : isRejectedChip
                  ? RequestStatus.rejected.bgColor.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.gold.withValues(alpha: 0.55)
                : isRejectedChip
                    ? RequestStatus.rejected.color.withValues(alpha: 0.28)
                    : Colors.white.withValues(alpha: 0.85),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected
                ? Colors.white
                : isRejectedChip
                    ? RequestStatus.rejected.color
                    : AppColors.darkText,
          ),
        ),
      ),
    );
  }
}
