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

                final history = snapshot.data!
                    .where((request) => request.status == RequestStatus.returned)
                    .toList();

                final totalReturnedUnits = history.fold<int>(
                  0,
                  (sum, req) =>
                      sum +
                      req.effectiveEquipmentQuantities.values.fold<int>(
                        0,
                        (a, b) => a + b,
                      ),
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  children: [
                    const SectionTitle(
                      title: 'Completed Returns',
                      subtitle:
                          'Verified history of your returned BulSU equipment batches.',
                    ),
                    const SizedBox(height: 18),
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
                              color: AppColors.green.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.task_alt_rounded,
                              color: AppColors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${history.length} completed ${history.length == 1 ? 'batch' : 'batches'} \u00B7 $totalReturnedUnits units returned',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'All returned items verified in good standing',
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
                    const SizedBox(height: 18),
                    if (history.isEmpty)
                      const _HistoryEmptyState()
                    else
                      ...history.map((request) => RequestCard(request: request)),
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
            'No returned equipment yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            'Completed batch requests will be archived here automatically.',
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
