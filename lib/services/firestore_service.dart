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


  Stream<List<Equipment>> equipmentStream() {
    return _equipment
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Equipment.fromDoc).toList());
  }

  Future<void> seedEquipmentIfEmpty() async {
    final existing = await _equipment.get();
    if (existing.docs.isEmpty) {
      final batch = _db.batch();
      for (final item in sampleEquipment) {
        batch.set(_equipment.doc(), item);
      }
      await batch.commit();
      return;
    }

    for (final doc in existing.docs) {
      final data = doc.data();
      if (data['name'] == 'Extension Cord' &&
          (data['imageUrl'] as String? ?? '').contains('1601999009162')) {
        await doc.reference.update({
          'imageUrl':
              'https://images.unsplash.com/photo-1650501386688-41f6d0251875?w=600',
        });
      }
    }
  }


  Future<String> addRequest(BorrowRequest request) async {
    final doc = await _requests.add(request.toMap());
    return doc.id;
  }

  Stream<List<BorrowRequest>> requestsStream(String userId) {
    return _requests.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs.map(BorrowRequest.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateStatus(String id, RequestStatus status) {
    return _requests.doc(id).update({'status': status.name});
  }

  Future<void> deleteRequest(String id) {
    return _requests.doc(id).delete();
  }
}
