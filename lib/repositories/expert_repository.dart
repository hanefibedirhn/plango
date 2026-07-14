import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expert_model.dart';

class ExpertNotFoundException implements Exception {
  const ExpertNotFoundException();

  @override
  String toString() {
    return 'Uzman profili bulunamadı.';
  }
}

class ExpertRepository {
  ExpertRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _expertsCollection {
    return _firestore.collection('experts');
  }

  /// Aktif uzman profilini getirir.
  Future<Expert> getExpert(
    String uid,
  ) async {
    final document =
        await _expertsCollection.doc(uid).get();

    if (!document.exists || document.data() == null) {
      throw const ExpertNotFoundException();
    }

    return Expert.fromDocument(document);
  }

  /// Uzman profilini gerçek zamanlı dinler.
  Stream<Expert?> watchExpert(
    String uid,
  ) {
    return _expertsCollection.doc(uid).snapshots().map(
      (document) {
        if (!document.exists ||
            document.data() == null) {
          return null;
        }

        return Expert.fromDocument(document);
      },
    );
  }

  /// Yeni uzman profili oluşturur.
  Future<void> createExpert(
    Expert expert,
  ) async {
    await _expertsCollection.doc(expert.uid).set(
          expert.toMap(),
        );
  }

  /// Uzmanı geçici olarak pasife alır.
  Future<void> suspendExpert({
    required String uid,
    required String reason,
  }) async {
    await _expertsCollection.doc(uid).update({
      'status': 'suspended',
      'verificationStatus': 'pendingUpdate',
      'acceptsNewRequests': false,
      'suspendedAt': FieldValue.serverTimestamp(),
      'suspensionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Uzmanı tekrar aktif hale getirir.
  Future<void> activateExpert({
    required Expert expert,
  }) async {
    await _expertsCollection.doc(expert.uid).update({
      'companyName': expert.companyName,
      'branch': expert.branch,
      'position': expert.position,
      'corporateEmail':
          expert.corporateEmail.toLowerCase(),
      'phone': expert.phone,
      'status': 'active',
      'verificationStatus': 'approved',
      'acceptsNewRequests': true,
      'lastVerifiedAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
      'suspendedAt': null,
      'suspensionReason': null,
    });
  }

  /// Uzmanın yeni talep alıp almayacağını değiştirir.
  Future<void> setAcceptsNewRequests({
    required String uid,
    required bool value,
  }) async {
    await _expertsCollection.doc(uid).update({
      'acceptsNewRequests': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}