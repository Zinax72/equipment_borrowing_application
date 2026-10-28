import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/borrow_request.dart';
import '../models/equipment.dart';
import '../models/request_status.dart';
import '../utils/sample_data.dart';

// Handles reading and writing equipment and borrowing requests in Cloud Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Keeps local status, rejection reason, and status history overrides so updates never revert.
  static final Map<
    String,
    ({
      RequestStatus status,
      String rejectionReason,
      List<StatusLogEntry> statusHistory,
    })
  > _localOverrides = {};
  static final Map<String, BorrowRequest> _cachedRequests = {};
  static final Map<String, int> _fallbackStockDeltas = {};
  static final StreamController<void> _overrideController =
      StreamController<void>.broadcast();

  CollectionReference<Map<String, dynamic>> get _equipment =>
      _db.collection('equipment');

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('requests');


  // Live stream of all equipment items ordered alphabetically, reflecting stock changes.
  Stream<List<Equipment>> equipmentStream() {
    return Stream<List<Equipment>>.multi((controller) {
      QuerySnapshot<Map<String, dynamic>>? latestSnapshot;

      void emitLatest() {
        final snapshot = latestSnapshot;
        if (snapshot == null) return;
        final list = snapshot.docs.map((doc) {
          final item = Equipment.fromDoc(doc);
          final delta = _fallbackStockDeltas[item.name] ?? 0;
          if (delta != 0) {
            return item.copyWith(
              available: (item.available + delta).clamp(0, 9999),
            );
          }
          return item;
        }).toList();
        if (!controller.isClosed) {
          controller.add(list);
        }
      }

      final firestoreSub = _equipment.orderBy('name').snapshots().listen(
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
          final effective = override != null
              ? parsed.copyWith(
                  status: override.status,
                  rejectionReason: override.rejectionReason,
                  statusHistory: override.statusHistory,
                )
              : parsed;
          _cachedRequests[doc.id] = effective;
          return effective;
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

  // Updates a request's status, logs the status change, and adjusts equipment stock when approved/borrowed/returned.
  Future<void> updateStatus(
    String id,
    RequestStatus status, {
    String? rejectionReason,
  }) async {
    BorrowRequest? current = _cachedRequests[id];
    if (current == null) {
      try {
        final doc = await _requests.doc(id).get();
        if (doc.exists) {
          current = BorrowRequest.fromDoc(doc);
        }
      } catch (_) {}
    }

    // Enforce forward-only status transition rules.
    if (current != null && !current.status.canTransitionTo(status)) {
      return;
    }

    final cleanReason =
        status == RequestStatus.rejected ? (rejectionReason ?? '').trim() : '';

    final logNote = switch (status) {
      RequestStatus.pending => 'Borrowing request submitted',
      RequestStatus.approved => 'Request approved (stock reserved)',
      RequestStatus.borrowed => 'Equipment checked out by student',
      RequestStatus.returned => 'Equipment returned & stock restored',
      RequestStatus.rejected => cleanReason.isNotEmpty
          ? 'Rejected: $cleanReason'
          : 'Request declined',
    };

    final updatedHistory = <StatusLogEntry>[
      ...(current?.effectiveStatusHistory ?? const <StatusLogEntry>[]),
      StatusLogEntry(
        status: status,
        timestamp: DateTime.now(),
        note: logNote,
      ),
    ];

    _localOverrides[id] = (
      status: status,
      rejectionReason: cleanReason,
      statusHistory: updatedHistory,
    );
    if (current != null) {
      _cachedRequests[id] = current.copyWith(
        status: status,
        rejectionReason: cleanReason,
        statusHistory: updatedHistory,
      );
    }
    _overrideController.add(null);

    // Adjust available equipment stock when moving into Approved/Borrowed or back to Returned.
    if (current != null) {
      final wasReserved = current.status.reservesStock;
      final nowReserved = status.reservesStock;
      if (wasReserved != nowReserved) {
        await _adjustEquipmentStock(
          current.effectiveEquipmentQuantities,
          deduct: nowReserved,
        );
      }
    }

    try {
      await _requests.doc(id).update({
        'status': status.name,
        'rejectionReason': cleanReason,
        'statusHistory': updatedHistory.map((e) => e.toMap()).toList(),
      });
    } catch (_) {
      try {
        await _requests.doc(id).update({'status': status.name});
      } catch (_) {}
    }
  }

  // Deducts or restores available quantities for each equipment item in a request.
  Future<void> _adjustEquipmentStock(
    Map<String, int> quantities, {
    required bool deduct,
  }) async {
    for (final entry in quantities.entries) {
      final itemName = entry.key;
      final qty = entry.value;
      if (qty <= 0) continue;
      final delta = deduct ? -qty : qty;

      try {
        final snap = await _equipment.where('name', isEqualTo: itemName).get();
        if (snap.docs.isEmpty) {
          _fallbackStockDeltas[itemName] =
              (_fallbackStockDeltas[itemName] ?? 0) + delta;
          _overrideController.add(null);
          continue;
        }
        for (final doc in snap.docs) {
          final currentAvail = (doc.data()['available'] as num?)?.toInt() ?? 0;
          final nextAvail = (currentAvail + delta).clamp(0, 9999);
          await doc.reference.update({'available': nextAvail});
        }
      } catch (_) {
        _fallbackStockDeltas[itemName] =
            (_fallbackStockDeltas[itemName] ?? 0) + delta;
        _overrideController.add(null);
      }
    }
  }

  // Deletes a pending request when withdrawn by the student.
  Future<void> deleteRequest(String id) {
    _localOverrides.remove(id);
    _cachedRequests.remove(id);
    _overrideController.add(null);
    return _requests.doc(id).delete();
  }
}
