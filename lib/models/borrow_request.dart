import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_status.dart';

class BorrowRequest {
  final String id;
  final String userId;
  final String requesterName;
  final String email;
  final List<String> equipment;
  final String purpose;
  final DateTime dateNeeded;
  final DateTime returnDate;
  final String photoBase64;
  final RequestStatus status;
  final DateTime createdAt;

  const BorrowRequest({
    required this.id,
    required this.userId,
    required this.requesterName,
    required this.email,
    required this.equipment,
    required this.purpose,
    required this.dateNeeded,
    required this.returnDate,
    required this.photoBase64,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'requesterName': requesterName,
      'email': email,
      'equipment': equipment,
      'purpose': purpose,
      'dateNeeded': Timestamp.fromDate(dateNeeded),
      'returnDate': Timestamp.fromDate(returnDate),
      'photoBase64': photoBase64,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory BorrowRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BorrowRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      email: data['email'] ?? '',
      equipment: List<String>.from(data['equipment'] ?? []),
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
