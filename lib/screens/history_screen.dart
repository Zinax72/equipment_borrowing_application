import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';
import '../utils/constants.dart';
import '../widgets/status_chip.dart';

class HistoryScreen extends StatelessWidget {
  final List<BorrowRequest> requests;

  const HistoryScreen({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    final history = requests
        .where((r) => r.status == RequestStatus.returned)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing History'),
        backgroundColor: AppColors.universityRed,
        foregroundColor: Colors.white,
      ),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.softYellow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.history,
                        size: 42,
                        color: AppColors.universityRed,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No borrowing history yet',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Completed (returned) transactions will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final request = history[index];
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
                        const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Completed Transaction',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusChip(status: RequestStatus.returned),
                          ],
                        ),
                        const Divider(height: 22),
                        Text(
                          request.organization,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Requester: ${request.requester}'),
                        Text('Borrowed: ${request.date}'),
                        Text('Returned: ${request.returnDate}'),
                        Text('Equipment: ${request.equipment.join(', ')}'),
                        const SizedBox(height: 6),
                        Text(
                          'Purpose: ${request.purpose}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
