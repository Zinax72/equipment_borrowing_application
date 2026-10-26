import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/request_card.dart';
import '../widgets/section_title.dart';

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

  Future<void> _cancel(BorrowRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel request?'),
          content: const Text('This will delete your borrowing request.'),
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
              child: const Text('Delete request'),
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
      child: StreamBuilder<List<BorrowRequest>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load your requests.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final active = snapshot.data!
              .where((request) => request.status != RequestStatus.returned)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              const SectionTitle(
                title: 'My requests',
                subtitle: 'Follow each request from review to return.',
              ),
              const SizedBox(height: 20),
              if (active.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 32,
                        color: AppColors.universityRed,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No active requests',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Your submitted requests will show up here.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...active.map(
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
