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

  Color get color {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFFFA000);
      case RequestStatus.approved:
        return const Color(0xFF1976D2);
      case RequestStatus.borrowed:
        return const Color(0xFF7B1FA2);
      case RequestStatus.returned:
        return const Color(0xFF2E7D32);
    }
  }

  Color get bgColor {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFFFF3E0);
      case RequestStatus.approved:
        return const Color(0xFFE3F2FD);
      case RequestStatus.borrowed:
        return const Color(0xFFF3E5F5);
      case RequestStatus.returned:
        return const Color(0xFFE8F5E9);
    }
  }
}
