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
        return const Color(0xFF9A6415);
      case RequestStatus.approved:
        return const Color(0xFF356A9B);
      case RequestStatus.borrowed:
        return const Color(0xFF745293);
      case RequestStatus.returned:
        return const Color(0xFF34785E);
    }
  }

  Color get bgColor {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFFFF1D9);
      case RequestStatus.approved:
        return const Color(0xFFEAF2F8);
      case RequestStatus.borrowed:
        return const Color(0xFFF1ECF5);
      case RequestStatus.returned:
        return const Color(0xFFE8F2ED);
    }
  }
}
