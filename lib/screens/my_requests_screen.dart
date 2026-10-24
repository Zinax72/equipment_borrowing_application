import 'package:flutter/material.dart';
import '../models/borrow_request.dart';
import '../models/request_status.dart';

class MyRequestsScreen extends StatelessWidget {
  final List<BorrowRequest> requests;
  final ValueChanged<int> onCancelRequest;
  final VoidCallback onCancelAllRequests;
  final void Function(int, RequestStatus) onUpdateStatus;

  const MyRequestsScreen({
    super.key,
    required this.requests,
    required this.onCancelRequest,
    required this.onCancelAllRequests,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('My requests: coming soon'));
  }
}
