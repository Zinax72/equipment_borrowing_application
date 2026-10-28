import 'package:equipment_borrowing_application/models/borrow_request.dart';
import 'package:equipment_borrowing_application/models/request_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

BorrowRequest _request({
  required List<String> equipment,
  Map<String, int> quantities = const {},
  RequestStatus status = RequestStatus.pending,
  String rejectionReason = '',
}) {
  return BorrowRequest(
    id: 'request-1',
    userId: 'student-1',
    requesterName: 'Student',
    email: 'student@example.edu',
    equipment: equipment,
    equipmentQuantities: quantities,
    purpose: 'Coursework project',
    dateNeeded: DateTime(2026, 10, 27),
    returnDate: DateTime(2026, 10, 28),
    photoBase64: '',
    status: status,
    rejectionReason: rejectionReason,
    createdAt: DateTime(2026, 10, 26),
  );
}

void main() {
  group('BorrowRequest equipment quantities and status', () {
    test('formats and persists quantities for new requests', () {
      final request = _request(
        equipment: ['Camera', 'Extension Cord'],
        quantities: {'Camera': 2, 'Extension Cord': 1},
      );

      expect(request.equipmentSummary, 'Camera \u00D7 2, Extension Cord');
      expect(request.toMap()['equipment'], ['Camera', 'Extension Cord']);
      expect(request.toMap()['equipmentQuantities'], {
        'Camera': 2,
        'Extension Cord': 1,
      });
    });

    test('infers quantities from legacy duplicate equipment names', () {
      final request = _request(
        equipment: ['Camera', 'Camera', 'Extension Cord'],
      );

      expect(request.effectiveEquipmentQuantities, {
        'Camera': 2,
        'Extension Cord': 1,
      });
      expect(request.equipmentSummary, 'Camera \u00D7 2, Extension Cord');
    });

    test('persists rejected status and rejection reason', () {
      final request = _request(
        equipment: ['Camera'],
        quantities: {'Camera': 1},
        status: RequestStatus.rejected,
        rejectionReason: 'Reserved for laboratory practicals',
      );

      expect(request.toMap()['status'], 'rejected');
      expect(
        request.toMap()['rejectionReason'],
        'Reserved for laboratory practicals',
      );
      expect(RequestStatus.approved.color, const Color(0xFF287D5C));
      expect(RequestStatus.returned.color, const Color(0xFF1F6E8C));
      expect(request.effectiveStatusHistory.length, 2);
      expect(request.effectiveStatusHistory.last.status, RequestStatus.rejected);
    });

    test('enforces strict forward-only status transition rules and stock reservation', () {
      expect(RequestStatus.pending.canTransitionTo(RequestStatus.approved), isTrue);
      expect(RequestStatus.pending.canTransitionTo(RequestStatus.rejected), isTrue);
      expect(RequestStatus.pending.canTransitionTo(RequestStatus.borrowed), isFalse);

      expect(RequestStatus.approved.canTransitionTo(RequestStatus.borrowed), isTrue);
      expect(RequestStatus.approved.canTransitionTo(RequestStatus.pending), isFalse);
      expect(RequestStatus.approved.canTransitionTo(RequestStatus.rejected), isFalse);

      expect(RequestStatus.borrowed.canTransitionTo(RequestStatus.returned), isTrue);
      expect(RequestStatus.borrowed.canTransitionTo(RequestStatus.approved), isFalse);
      expect(RequestStatus.borrowed.canTransitionTo(RequestStatus.pending), isFalse);
      expect(RequestStatus.borrowed.canTransitionTo(RequestStatus.rejected), isFalse);

      expect(RequestStatus.returned.allowedNextStatuses, isEmpty);
      expect(RequestStatus.rejected.allowedNextStatuses, isEmpty);

      expect(RequestStatus.pending.reservesStock, isFalse);
      expect(RequestStatus.approved.reservesStock, isTrue);
      expect(RequestStatus.borrowed.reservesStock, isTrue);
      expect(RequestStatus.returned.reservesStock, isFalse);
      expect(RequestStatus.rejected.reservesStock, isFalse);
    });
  });
}
