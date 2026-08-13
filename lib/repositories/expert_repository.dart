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

  CollectionReference<Map<String, dynamic>>
      get _expertProfilesCollection {
    return _firestore.collection('expertProfiles');
  }

  /// Uzmanın özel profilini getirir.
  Future<Expert> getExpert(
    String uid,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _expertsCollection.doc(uid).get();

    if (!document.exists || document.data() == null) {
      throw const ExpertNotFoundException();
    }

    return Expert.fromDocument(document);
  }

  /// Uzmanın özel profilini gerçek zamanlı dinler.
  Stream<Expert?> watchExpert(
    String uid,
  ) {
    return _expertsCollection.doc(uid).snapshots().map(
      (document) {
        if (!document.exists || document.data() == null) {
          return null;
        }

        return Expert.fromDocument(document);
      },
    );
  }

  /// Sistemdeki tüm uzmanları gerçek zamanlı olarak izler.
  ///
  /// Yönetici panelindeki Uzman Yönetimi ekranı tarafından
  /// kullanılır. Uzman kayıtlarında yapılan değişiklikler
  /// ekrana otomatik olarak yansır.
  Stream<List<Expert>> watchAllExperts() {
    return _expertsCollection
        .orderBy('companyName')
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              (document) => Expert.fromDocument(document),
            )
            .toList();
      },
    );
  }

  /// Yeni uzman profili oluşturur.
  ///
  /// Normal kullanıcı istemcisinden çağrılmamalıdır.
  /// Uzman onayı, yönetici repository'si üzerinden yapılır.
  Future<void> createExpert(
    Expert expert,
  ) async {
    final WriteBatch batch = _firestore.batch();

    final DocumentReference<Map<String, dynamic>>
        expertReference =
        _expertsCollection.doc(expert.uid);

    final DocumentReference<Map<String, dynamic>>
        publicProfileReference =
        _expertProfilesCollection.doc(expert.uid);

    batch.set(
      expertReference,
      expert.toMap(),
    );

    batch.set(
      publicProfileReference,
      {
        'uid': expert.uid,
        'firstName': expert.firstName.trim(),
        'lastName': expert.lastName.trim(),
        'companyName': expert.companyName.trim(),
        'branch': expert.branch.trim(),
        'position': expert.position.trim(),
        'status': expert.status,
        'acceptsNewRequests': expert.acceptsNewRequests,
        'createdAt': Timestamp.fromDate(expert.createdAt),
        'updatedAt': Timestamp.fromDate(expert.updatedAt),
      },
    );

    await batch.commit();
  }

  /// Uzmanı geçici olarak pasife alır.
  ///
  /// Askıya alındığında açık profil de görünmez hâle gelir.
  Future<void> suspendExpert({
    required String uid,
    required String reason,
  }) async {
    final WriteBatch batch = _firestore.batch();

    final DocumentReference<Map<String, dynamic>>
        expertReference =
        _expertsCollection.doc(uid);

    final DocumentReference<Map<String, dynamic>>
        publicProfileReference =
        _expertProfilesCollection.doc(uid);

    batch.update(
      expertReference,
      {
        'status': 'suspended',
        'verificationStatus': 'pendingUpdate',
        'acceptsNewRequests': false,
        'suspendedAt': FieldValue.serverTimestamp(),
        'suspensionReason': reason.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    batch.set(
      publicProfileReference,
      {
        'status': 'suspended',
        'acceptsNewRequests': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Uzmanı onaylı bilgilerle tekrar aktif hâle getirir.
  Future<void> activateExpert({
    required Expert expert,
  }) async {
    final WriteBatch batch = _firestore.batch();

    final DocumentReference<Map<String, dynamic>>
        expertReference =
        _expertsCollection.doc(expert.uid);

    final DocumentReference<Map<String, dynamic>>
        publicProfileReference =
        _expertProfilesCollection.doc(expert.uid);

    batch.update(
      expertReference,
      {
        'firstName': expert.firstName.trim(),
        'lastName': expert.lastName.trim(),
        'companyName': expert.companyName.trim(),
        'branch': expert.branch.trim(),
        'position': expert.position.trim(),
        'corporateEmail':
            expert.corporateEmail.trim().toLowerCase(),
        'phone': expert.phone.trim(),
        'status': 'active',
        'verificationStatus': 'approved',
        'acceptsNewRequests': true,
        'lastVerifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'suspendedAt': null,
        'suspensionReason': null,
      },
    );

    batch.set(
      publicProfileReference,
      {
        'uid': expert.uid,
        'firstName': expert.firstName.trim(),
        'lastName': expert.lastName.trim(),
        'companyName': expert.companyName.trim(),
        'branch': expert.branch.trim(),
        'position': expert.position.trim(),
        'status': 'active',
        'acceptsNewRequests': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Uzmanın yeni danışma talebi alıp almayacağını değiştirir.
  ///
  /// Özel uzman kaydı ile kullanıcıların göreceği açık uzman
  /// profili aynı transaction içinde birlikte güncellenir.
  Future<void> setAcceptsNewRequests({
    required String uid,
    required bool value,
  }) async {
    final DocumentReference<Map<String, dynamic>>
        expertReference =
        _expertsCollection.doc(uid);

    final DocumentReference<Map<String, dynamic>>
        publicProfileReference =
        _expertProfilesCollection.doc(uid);

    await _firestore.runTransaction(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            expertSnapshot =
            await transaction.get(expertReference);

        if (!expertSnapshot.exists ||
            expertSnapshot.data() == null) {
          throw const ExpertNotFoundException();
        }

        final Map<String, dynamic> expertData =
            expertSnapshot.data()!;

        final String status =
            expertData['status'] as String? ?? 'inactive';

        final String verificationStatus =
            expertData['verificationStatus'] as String? ??
                'rejected';

        if (value &&
            (status != 'active' ||
                verificationStatus != 'approved')) {
          throw StateError(
            'Aktif ve onaylı olmayan uzman yeni talep alımını açamaz.',
          );
        }

        transaction.update(
          expertReference,
          {
            'acceptsNewRequests': value,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        transaction.set(
          publicProfileReference,
          {
            'uid': uid,
            'firstName':
                expertData['firstName'] as String? ?? '',
            'lastName':
                expertData['lastName'] as String? ?? '',
            'companyName':
                expertData['companyName'] as String? ?? '',
            'branch':
                expertData['branch'] as String? ?? '',
            'position':
                expertData['position'] as String? ?? '',
            'status': status,
            'acceptsNewRequests': value,
            'createdAt':
                expertData['createdAt'] ??
                    FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      },
    );
  }

  /// Uzmanlığı sistemden kalıcı olarak kaldırır.
///
/// Bu işlem kullanıcının normal Tasarruf Planım hesabını silmez.
/// Sadece uzman kayıtlarını kaldırır ve kullanıcı profilini
/// tekrar normal kullanıcı durumuna döndürür.
///
/// Silinen kayıtlar:
/// - experts/{uid}
/// - expertProfiles/{uid}
///
/// Güncellenen kayıt:
/// - users/{uid}
Future<void> deleteExpert({
  required String uid,
}) async {
  final String normalizedUid = uid.trim();

  if (normalizedUid.isEmpty) {
    throw ArgumentError(
      'Silinecek uzman kimliği bulunamadı.',
    );
  }

  final DocumentReference<Map<String, dynamic>>
      expertReference =
      _expertsCollection.doc(normalizedUid);

  final DocumentReference<Map<String, dynamic>>
      publicProfileReference =
      _expertProfilesCollection.doc(normalizedUid);

  final DocumentReference<Map<String, dynamic>>
      userReference =
      _firestore.collection('users').doc(normalizedUid);

  await _firestore.runTransaction(
    (transaction) async {
      final DocumentSnapshot<Map<String, dynamic>>
          expertSnapshot =
          await transaction.get(expertReference);

      if (!expertSnapshot.exists ||
          expertSnapshot.data() == null) {
        throw const ExpertNotFoundException();
      }

      final DocumentSnapshot<Map<String, dynamic>>
          userSnapshot =
          await transaction.get(userReference);

      transaction.delete(
        expertReference,
      );

      transaction.delete(
        publicProfileReference,
      );

      if (userSnapshot.exists) {
        transaction.update(
          userReference,
          {
            'roles': const ['user'],
            'expertStatus': 'none',
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      }
    },
  );
}
}