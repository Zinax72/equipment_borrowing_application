import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/request_card.dart';
import '../widgets/section_title.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Stream<List<BorrowRequest>> _stream = FirestoreService()
      .requestsStream(FirebaseAuth.instance.currentUser?.uid ?? '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrowing history')),
      body: SafeArea(
        child: StreamBuilder<List<BorrowRequest>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load your history.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final history = snapshot.data!
                .where((request) => request.status == RequestStatus.returned)
                .toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const SectionTitle(
                  title: 'Borrowing history',
                  subtitle: 'Your completed equipment returns.',
                ),
                const SizedBox(height: 20),
                if (history.isEmpty)
                  _HistoryEmptyState()
                else
                  ...history.map((request) => RequestCard(request: request)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.history_rounded,
            size: 32,
            color: AppColors.universityRed,
          ),
          const SizedBox(height: 12),
          Text(
            'Nothing returned yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Completed requests will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
