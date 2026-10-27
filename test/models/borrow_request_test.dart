import 'package:equipment_borrowing_application/models/borrow_request.dart';
import 'package:equipment_borrowing_application/models/request_status.dart';
import 'package:flutter_test/flutter_test.dart';

BorrowRequest _request({
  required List<String> equipment,
  Map<String, int> quantities = const {},
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
    status: RequestStatus.pending,
    createdAt: DateTime(2026, 10, 26),
  );
}

void main() {
  group('BorrowRequest equipment quantities', () {
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
  });
}
