import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/borrow_request.dart';
import '../models/equipment.dart';
import '../models/request_status.dart';
import '../utils/sample_data.dart';

// Handles reading and writing equipment and borrowing requests in Cloud Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Keeps local status and rejection reason overrides so rejected state never reverts.
  static final Map<String, ({RequestStatus status, String rejectionReason})>
      _localOverrides = {};
  static final StreamController<void> _overrideController =
      StreamController<void>.broadcast();

  CollectionReference<Map<String, dynamic>> get _equipment =>
      _db.collection('equipment');

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('requests');


  // Live stream of all equipment items ordered alphabetically.
  Stream<List<Equipment>> equipmentStream() {
    return _equipment
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Equipment.fromDoc).toList());
  }

  // Populates the equipment collection with sample items if Firestore is empty.
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


  // Saves a new borrowing request to Firestore and returns its generated ID.
  Future<String> addRequest(BorrowRequest request) async {
    final doc = await _requests.add(request.toMap());
    return doc.id;
  }

  // Streams all requests belonging to the current user, newest first.
  Stream<List<BorrowRequest>> requestsStream(String userId) {
    return Stream<List<BorrowRequest>>.multi((controller) {
      QuerySnapshot<Map<String, dynamic>>? latestSnapshot;

      void emitLatest() {
        final snapshot = latestSnapshot;
        if (snapshot == null) return;
        final list = snapshot.docs.map((doc) {
          final parsed = BorrowRequest.fromDoc(doc);
          final override = _localOverrides[doc.id];
          if (override != null) {
            return parsed.copyWith(
              status: override.status,
              rejectionReason: override.rejectionReason,
            );
          }
          return parsed;
        }).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (!controller.isClosed) {
          controller.add(list);
        }
      }

      final firestoreSub = _requests
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen(
            (snapshot) {
              latestSnapshot = snapshot;
              emitLatest();
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!controller.isClosed) {
                controller.addError(error, stackTrace);
              }
            },
          );

      final overrideSub = _overrideController.stream.listen((_) {
        emitLatest();
      });

      controller.onCancel = () async {
        await firestoreSub.cancel();
        await overrideSub.cancel();
      };
    });
  }

  // Updates a request's status (and rejection reason if rejected) locally and in Firestore.
  Future<void> updateStatus(
    String id,
    RequestStatus status, {
    String? rejectionReason,
  }) async {
    final cleanReason =
        status == RequestStatus.rejected ? (rejectionReason ?? '').trim() : '';
    _localOverrides[id] = (status: status, rejectionReason: cleanReason);
    _overrideController.add(null);

    try {
      await _requests.doc(id).update({
        'status': status.name,
        'rejectionReason': cleanReason,
      });
    } catch (_) {
      try {
        await _requests.doc(id).update({'status': status.name});
      } catch (_) {}
    }
  }

  // Deletes a pending request when withdrawn by the student.
  Future<void> deleteRequest(String id) {
    _localOverrides.remove(id);
    _overrideController.add(null);
    return _requests.doc(id).delete();
  }
}
