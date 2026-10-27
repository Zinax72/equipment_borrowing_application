import 'package:flutter/material.dart';

enum RequestStatus { pending, approved, borrowed, returned }

extension RequestStatusX on RequestStatus {
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
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFB26B00);
      case RequestStatus.approved:
        return const Color(0xFF1F6E8C);
      case RequestStatus.borrowed:
        return const Color(0xFF7A132F);
      case RequestStatus.returned:
        return const Color(0xFF287D5C);
    }
  }

  Color get bgColor {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFFFF4DC);
      case RequestStatus.approved:
        return const Color(0xFFE6F4F9);
      case RequestStatus.borrowed:
        return const Color(0xFFFBECEF);
      case RequestStatus.returned:
        return const Color(0xFFE6F5EE);
    }
  }
}
