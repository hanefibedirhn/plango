import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expert_application_model.dart';

class ExpertReviewException implements Exception {
  const ExpertReviewException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ExpertReviewRepository {
  ExpertReviewRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _applicationsCollection {
    return _firestore.collection(
      'expertApplications',
    );
  }

  CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection('users');
  }

  CollectionReference<Map<String, dynamic>>
      get _expertsCollection {
    return _firestore.collection('experts');
  }

  /// Bekleyen uzman başvurularını en eskiden
  /// en yeniye doğru gerçek zamanlı getirir.
  Stream<List<ExpertApplication>>
      watchPendingApplications() {
    return _applicationsCollection
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .orderBy(
          'createdAt',
          descending: false,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              ExpertApplication.fromDocument,
            )
            .toList();
      },
    );
  }

  /// Başvuruyu atomik şekilde onaylar.
  ///
  /// İlk başvuruda yeni uzman profili oluşturulur.
  /// Profil güncellemesinde mevcut uzman profili
  /// yeni bilgilerle güncellenip tekrar aktif edilir.
  Future<void> approveApplication({
    required ExpertApplication application,
    required String adminUid,
  }) async {
    final String? applicationId =
        application.applicationId;

    if (applicationId == null ||
        applicationId.isEmpty) {
      throw const ExpertReviewException(
        'Başvuru kimliği bulunamadı.',
      );
    }

    final DocumentReference<Map<String, dynamic>>
        applicationReference =
        _applicationsCollection.doc(applicationId);

    final DocumentReference<Map<String, dynamic>>
        userReference =
        _usersCollection.doc(application.uid);

    final DocumentReference<Map<String, dynamic>>
        expertReference =
        _expertsCollection.doc(application.uid);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            applicationSnapshot =
            await transaction.get(
          applicationReference,
        );

        final DocumentSnapshot<Map<String, dynamic>>
            userSnapshot =
            await transaction.get(userReference);

        if (!applicationSnapshot.exists ||
            applicationSnapshot.data() == null) {
          throw const ExpertReviewException(
            'Başvuru bulunamadı.',
          );
        }

        if (!userSnapshot.exists ||
            userSnapshot.data() == null) {
          throw const ExpertReviewException(
            'Başvuru sahibinin kullanıcı profili bulunamadı.',
          );
        }

        final Map<String, dynamic> applicationData =
            applicationSnapshot.data()!;

        if (applicationData['status'] != 'pending') {
          throw const ExpertReviewException(
            'Bu başvuru daha önce sonuçlandırılmış.',
          );
        }

        final Map<String, dynamic> userData =
            userSnapshot.data()!;

        final List<String> currentRoles =
            List<String>.from(
          userData['roles'] as List<dynamic>? ??
              const ['user'],
        );

        final List<String> updatedRoles = {
          ...currentRoles,
          'expert',
        }.toList();

        final Map<String, dynamic> expertData = {
          'uid': application.uid,
          'firstName':
              userData['name'] as String? ?? '',
          'lastName':
              userData['surname'] as String? ?? '',
          'companyName':
              application.companyName.trim(),
          'branch': application.branch.trim(),
          'position': application.position.trim(),
          'corporateEmail': application
              .corporateEmail
              .trim()
              .toLowerCase(),
          'phone': application.phone.trim(),
          'status': 'active',
          'verificationStatus': 'approved',
          'acceptsNewRequests': true,
          'updatedAt':
              FieldValue.serverTimestamp(),
          'lastVerifiedAt':
              FieldValue.serverTimestamp(),
          'suspendedAt': null,
          'suspensionReason': null,
        };

        if (application.isInitialApplication) {
          expertData['createdAt'] =
              FieldValue.serverTimestamp();

          transaction.set(
            expertReference,
            expertData,
          );
        } else {
          transaction.set(
            expertReference,
            expertData,
            SetOptions(merge: true),
          );
        }

        transaction.update(
          applicationReference,
          {
            'status': 'approved',
            'reviewNote': null,
            'reviewedBy': adminUid,
            'reviewedAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          userReference,
          {
            'roles': updatedRoles,
            'expertStatus': 'approved',
            'phone': application.phone.trim(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  /// Başvuruyu atomik şekilde reddeder.
  ///
  /// Profil güncelleme başvurusu reddedilirse uzman
  /// doğrulanmamış eski bilgilerle aktif edilmez;
  /// askıda kalmaya devam eder.
  Future<void> rejectApplication({
    required ExpertApplication application,
    required String adminUid,
    required String reviewNote,
  }) async {
    final String? applicationId =
        application.applicationId;

    if (applicationId == null ||
        applicationId.isEmpty) {
      throw const ExpertReviewException(
        'Başvuru kimliği bulunamadı.',
      );
    }

    final String normalizedNote =
        reviewNote.trim();

    if (normalizedNote.length < 5) {
      throw const ExpertReviewException(
        'Lütfen kullanıcıya açıklayıcı bir red nedeni yazınız.',
      );
    }

    final DocumentReference<Map<String, dynamic>>
        applicationReference =
        _applicationsCollection.doc(applicationId);

    final DocumentReference<Map<String, dynamic>>
        userReference =
        _usersCollection.doc(application.uid);

    final DocumentReference<Map<String, dynamic>>
        expertReference =
        _expertsCollection.doc(application.uid);

    await _firestore.runTransaction<void>(
  (transaction) async {
    final DocumentSnapshot<Map<String, dynamic>>
        applicationSnapshot =
        await transaction.get(
      applicationReference,
    );

    DocumentSnapshot<Map<String, dynamic>>?
        expertSnapshot;

    if (application.isProfileUpdateApplication) {
      expertSnapshot = await transaction.get(
        expertReference,
      );
    }

    if (!applicationSnapshot.exists ||
        applicationSnapshot.data() == null) {
      throw const ExpertReviewException(
        'Başvuru bulunamadı.',
      );
    }

    if (applicationSnapshot.data()!['status'] !=
        'pending') {
      throw const ExpertReviewException(
        'Bu başvuru daha önce sonuçlandırılmış.',
      );
    }

    transaction.update(
      applicationReference,
      {
        'status': 'rejected',
        'reviewNote': normalizedNote,
        'reviewedBy': adminUid,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    transaction.update(
      userReference,
      {
        'expertStatus': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    if (application.isProfileUpdateApplication &&
        expertSnapshot != null &&
        expertSnapshot.exists) {
      transaction.update(
        expertReference,
        {
          'status': 'suspended',
          'verificationStatus': 'rejected',
          'acceptsNewRequests': false,
          'suspensionReason': normalizedNote,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }
  },
);
  }
}