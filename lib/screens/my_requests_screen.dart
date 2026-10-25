import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/request_card.dart';
import '../widgets/section_title.dart';
import '../services/notification_service.dart';

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
              child: const Text('Keep'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
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

          // Returned requests live in Borrowing History.
          final active = snapshot.data!
              .where((r) => r.status != RequestStatus.returned)
              .toList();

          if (active.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 50,
                      color: AppColors.universityRed,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No requests yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Submit a borrow request and it will show up here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const SectionTitle(
                title: 'My Requests',
                subtitle: 'Track the status of your borrowing requests.',
              ),
              const SizedBox(height: 16),
              ...active.map((request) {
                return RequestCard(
                  request: request,
                  onStatusChanged: (status) {
                    _firestore.updateStatus(request.id, status);
                  },
                  onCancel: request.status == RequestStatus.pending
                      ? () => _cancel(request)
                      : null,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
