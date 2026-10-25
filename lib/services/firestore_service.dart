import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/borrow_request.dart';
import '../models/equipment.dart';
import '../models/request_status.dart';
import '../utils/sample_data.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _equipment =>
      _db.collection('equipment');

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('requests');

  // ---------- Equipment ----------

  Stream<List<Equipment>> equipmentStream() {
    return _equipment
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Equipment.fromDoc).toList());
  }

  Future<void> seedEquipmentIfEmpty() async {
    final existing = await _equipment.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final item in sampleEquipment) {
      batch.set(_equipment.doc(), item);
    }
    await batch.commit();
  }

  // ---------- Requests ----------

  // Create (returns the new request's id)
  Future<String> addRequest(BorrowRequest request) async {
    final doc = await _requests.add(request.toMap());
    return doc.id;
  }

  // Read (only this user's requests, newest first)
  Stream<List<BorrowRequest>> requestsStream(String userId) {
    return _requests.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs.map(BorrowRequest.fromDoc).toList();
      // Sorted here instead of in the query, so no Firestore index is needed.
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Update
  Future<void> updateStatus(String id, RequestStatus status) {
    return _requests.doc(id).update({'status': status.name});
  }

  // Delete
  Future<void> deleteRequest(String id) {
    return _requests.doc(id).delete();
  }
}
