import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_status.dart';

// Represents a single status change event in a request's history log.
class StatusLogEntry {
  final RequestStatus status;
  final DateTime timestamp;
  final String note;

  const StatusLogEntry({
    required this.status,
    required this.timestamp,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }

  factory StatusLogEntry.fromMap(Map<String, dynamic> map) {
    return StatusLogEntry(
      status: RequestStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RequestStatus.pending,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: (map['note'] as String?) ?? '',
    );
  }
}

// Data model for a student's batch equipment borrowing request.
class BorrowRequest {
  final String id;
  final String userId;
  final String requesterName;
  final String email;
  final List<String> equipment;
  final Map<String, int> equipmentQuantities;
  final String purpose;
  final DateTime dateNeeded;
  final DateTime returnDate;
  final String photoBase64;
  final RequestStatus status;
  final String rejectionReason;
  final List<StatusLogEntry> statusHistory;
  final DateTime createdAt;

  const BorrowRequest({
    required this.id,
    required this.userId,
    required this.requesterName,
    required this.email,
    required this.equipment,
    this.equipmentQuantities = const {},
    required this.purpose,
    required this.dateNeeded,
    required this.returnDate,
    required this.photoBase64,
    required this.status,
    this.rejectionReason = '',
    this.statusHistory = const [],
    required this.createdAt,
  });

  // Creates a modified copy of this request (used when updating status, reason, or history logs).
  BorrowRequest copyWith({
    RequestStatus? status,
    String? rejectionReason,
    List<StatusLogEntry>? statusHistory,
  }) {
    return BorrowRequest(
      id: id,
      userId: userId,
      requesterName: requesterName,
      email: email,
      equipment: equipment,
      equipmentQuantities: equipmentQuantities,
      purpose: purpose,
      dateNeeded: dateNeeded,
      returnDate: returnDate,
      photoBase64: photoBase64,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt,
    );
  }

  // Returns the recorded status history, or builds a fallback log trail for older requests.
  List<StatusLogEntry> get effectiveStatusHistory {
    if (statusHistory.isNotEmpty) return statusHistory;

    final entries = <StatusLogEntry>[
      StatusLogEntry(
        status: RequestStatus.pending,
        timestamp: createdAt,
        note: 'Borrowing request submitted',
      ),
    ];

    if (status == RequestStatus.rejected) {
      entries.add(
        StatusLogEntry(
          status: RequestStatus.rejected,
          timestamp: createdAt,
          note: rejectionReason.trim().isNotEmpty
              ? 'Rejected: ${rejectionReason.trim()}'
              : 'Request declined',
        ),
      );
    } else {
      if (status == RequestStatus.approved ||
          status == RequestStatus.borrowed ||
          status == RequestStatus.returned) {
        entries.add(
          StatusLogEntry(
            status: RequestStatus.approved,
            timestamp: createdAt,
            note: 'Request approved (stock reserved)',
          ),
        );
      }
      if (status == RequestStatus.borrowed ||
          status == RequestStatus.returned) {
        entries.add(
          StatusLogEntry(
            status: RequestStatus.borrowed,
            timestamp: createdAt,
            note: 'Equipment checked out by student',
          ),
        );
      }
      if (status == RequestStatus.returned) {
        entries.add(
          StatusLogEntry(
            status: RequestStatus.returned,
            timestamp: createdAt,
            note: 'Equipment returned & stock restored',
          ),
        );
      }
    }
    return entries;
  }

  // Returns a map of item names to quantities, supporting older requests too.
  Map<String, int> get effectiveEquipmentQuantities {
    if (equipmentQuantities.isNotEmpty) return equipmentQuantities;
    final quantities = <String, int>{};
    for (final item in equipment) {
      quantities.update(
        item,
        (currentQuantity) => currentQuantity + 1,
        ifAbsent: () => 1,
      );
    }
    return quantities;
  }

  // Formats selected items into a single readable string (e.g. "Camera x 2, Projector").
  String get equipmentSummary => effectiveEquipmentQuantities.entries
      .map(
        (entry) =>
            entry.value > 1 ? '${entry.key} \u00D7 ${entry.value}' : entry.key,
      )
      .join(', ');

  // Converts this request into a Map to save in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'requesterName': requesterName,
      'email': email,
      'equipment': equipment,
      'equipmentQuantities': equipmentQuantities,
      'purpose': purpose,
      'dateNeeded': Timestamp.fromDate(dateNeeded),
      'returnDate': Timestamp.fromDate(returnDate),
      'photoBase64': photoBase64,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'statusHistory': effectiveStatusHistory.map((e) => e.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Builds a BorrowRequest object from a Firestore document snapshot.
  factory BorrowRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final equipment = List<String>.from(data['equipment'] ?? []);
    final rawQuantities = data['equipmentQuantities'];
    final quantities = rawQuantities is Map
        ? rawQuantities.map(
            (key, value) => MapEntry(key.toString(), (value as num).toInt()),
          )
        : _countEquipment(equipment);

    final rawHistory = data['statusHistory'];
    final parsedHistory = rawHistory is List
        ? rawHistory
            .whereType<Map>()
            .map((item) => StatusLogEntry.fromMap(Map<String, dynamic>.from(item)))
            .toList()
        : <StatusLogEntry>[];

    return BorrowRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      email: data['email'] ?? '',
      equipment: equipment,
      equipmentQuantities: quantities,
      purpose: data['purpose'] ?? '',
      dateNeeded:
          (data['dateNeeded'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnDate:
          (data['returnDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoBase64: data['photoBase64'] ?? '',
      status: RequestStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => RequestStatus.pending,
      ),
      rejectionReason: (data['rejectionReason'] as String?) ?? '',
      statusHistory: parsedHistory,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, int> _countEquipment(List<String> equipment) {
    final quantities = <String, int>{};
    for (final item in equipment) {
      quantities.update(
        item,
        (currentQuantity) => currentQuantity + 1,
        ifAbsent: () => 1,
      );
    }
    return quantities;
  }
}
