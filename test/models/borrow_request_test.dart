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
    });
  });
}
