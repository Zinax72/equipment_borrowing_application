import 'package:flutter/material.dart';

// Possible lifecycle states of a borrowing request.
enum RequestStatus { pending, approved, borrowed, returned, rejected }

// Helper properties (label, description, icon, and colors) for each RequestStatus.
extension RequestStatusX on RequestStatus {
  // Display name shown on chips and filters.
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.borrowed:
        return 'Borrowed';
      case RequestStatus.returned:
        return 'Returned';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }

  String get description {
    switch (this) {
      case RequestStatus.pending:
        return 'Awaiting custodian approval';
      case RequestStatus.approved:
        return 'Ready for campus pickup';
      case RequestStatus.borrowed:
        return 'Currently checked out';
      case RequestStatus.returned:
        return 'Returned & verified';
      case RequestStatus.rejected:
        return 'Request declined';
    }
  }

  IconData get icon {
    switch (this) {
      case RequestStatus.pending:
        return Icons.hourglass_top_rounded;
      case RequestStatus.approved:
        return Icons.verified_outlined;
      case RequestStatus.borrowed:
        return Icons.outbound_outlined;
      case RequestStatus.returned:
        return Icons.task_alt_rounded;
      case RequestStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  // Foreground/text color for each status badge.
  Color get color {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFB26B00);
      case RequestStatus.approved:
        return const Color(0xFF287D5C);
      case RequestStatus.borrowed:
        return const Color(0xFF7A132F);
      case RequestStatus.returned:
        return const Color(0xFF1F6E8C);
      case RequestStatus.rejected:
        return const Color(0xFFC22952);
    }
  }

  // Light background tint for each status badge.
  Color get bgColor {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFFFF4DC);
      case RequestStatus.approved:
        return const Color(0xFFE6F5EE);
      case RequestStatus.borrowed:
        return const Color(0xFFFBECEF);
      case RequestStatus.returned:
        return const Color(0xFFE6F4F9);
      case RequestStatus.rejected:
        return const Color(0xFFFDECEF);
    }
  }

  // Defines the strict forward-only status transitions allowed from the current status.
  List<RequestStatus> get allowedNextStatuses {
    switch (this) {
      case RequestStatus.pending:
        return const [RequestStatus.approved, RequestStatus.rejected];
      case RequestStatus.approved:
        return const [RequestStatus.borrowed];
      case RequestStatus.borrowed:
        return const [RequestStatus.returned];
      case RequestStatus.returned:
      case RequestStatus.rejected:
        return const [];
    }
  }

  // Returns true only if moving from the current status to [next] is permitted.
  bool canTransitionTo(RequestStatus next) =>
      allowedNextStatuses.contains(next);

  // Returns true when this status deducts equipment from available stock.
  bool get reservesStock =>
      this == RequestStatus.approved || this == RequestStatus.borrowed;
}
