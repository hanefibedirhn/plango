import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expert_application_model.dart';
import '../models/expert_model.dart';

class ExpertApplicationAlreadyPendingException
    implements Exception {
  const ExpertApplicationAlreadyPendingException();

  @override
  String toString() {
    return 'İncelenmekte olan bir uzman başvurunuz bulunuyor.';
  }
}

class ExpertApplicationNotFoundException
    implements Exception {
  const ExpertApplicationNotFoundException();

  @override
  String toString() {
    return 'Uzman başvurusu bulunamadı.';
  }
}

class ExpertProfileNotFoundException
    implements Exception {
  const ExpertProfileNotFoundException();

  @override
  String toString() {
    return 'Aktif uzman profiliniz bulunamadı.';
  }
}

class ExpertApplicationRepository {
  ExpertApplicationRepository({
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

  /// Kullanıcının incelenmekte olan başvurusu var mı?
  Future<bool> hasPendingApplication(
    String uid,
  ) async {
    final QuerySnapshot<Map<String, dynamic>>
        snapshot = await _applicationsCollection
            .where('uid', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  /// İlk uzmanlık başvurusunu oluşturur.
  ///
  /// Başvuru autoId ile kaydedilir.
  /// Kullanıcının telefon bilgisi profile eklenir.
  /// users/{uid}.expertStatus değeri pending olur.
  Future<String> submitInitialApplication(
    ExpertApplication application,
  ) async {
    if (application.type != 'initial') {
      throw ArgumentError(
        'İlk başvuru türü initial olmalıdır.',
      );
    }

    final bool alreadyPending =
        await hasPendingApplication(
      application.uid,
    );

    if (alreadyPending) {
      throw const ExpertApplicationAlreadyPendingException();
    }

    final DocumentReference<Map<String, dynamic>>
        applicationReference =
        _applicationsCollection.doc();

    final DocumentReference<Map<String, dynamic>>
        userReference =
        _usersCollection.doc(application.uid);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            userSnapshot =
            await transaction.get(userReference);

        if (!userSnapshot.exists ||
            userSnapshot.data() == null) {
          throw StateError(
            'Kullanıcı profili bulunamadı.',
          );
        }

        final Map<String, dynamic> userData =
            userSnapshot.data()!;

        final String currentExpertStatus =
            userData['expertStatus']
                    as String? ??
                'none';

        if (currentExpertStatus == 'pending' ||
            currentExpertStatus == 'approved') {
          throw const ExpertApplicationAlreadyPendingException();
        }

        transaction.set(
          applicationReference,
          {
            ...application.toMap(),
            'applicationId':
                applicationReference.id,
            'uid': application.uid,
            'type': 'initial',
            'companyName':
                application.companyName.trim(),
            'branch': application.branch.trim(),
            'position': application.position.trim(),
            'corporateEmail': application
                .corporateEmail
                .trim()
                .toLowerCase(),
            'phone': application.phone.trim(),
            'status': 'pending',
            'reviewNote': null,
            'reviewedAt': null,
            'reviewedBy': null,
            'createdAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          userReference,
          {
            'phone': application.phone.trim(),
            'expertStatus': 'pending',
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );

    return applicationReference.id;
  }

  /// Onaylı uzmanın şirket, şube, pozisyon veya
  /// kurumsal e-posta değişikliği başvurusunu oluşturur.
  ///
  /// Başvuru gönderildiği anda uzman profili askıya alınır.
  Future<String> submitProfileUpdateApplication({
    required ExpertApplication application,
    required Expert currentExpert,
  }) async {
    if (application.type != 'profileUpdate') {
      throw ArgumentError(
        'Profil güncelleme başvuru türü '
        'profileUpdate olmalıdır.',
      );
    }

    if (application.uid != currentExpert.uid) {
      throw ArgumentError(
        'Başvuru ve uzman UID değerleri eşleşmiyor.',
      );
    }

    final bool alreadyPending =
        await hasPendingApplication(
      application.uid,
    );

    if (alreadyPending) {
      throw const ExpertApplicationAlreadyPendingException();
    }

    final DocumentReference<Map<String, dynamic>>
        applicationReference =
        _applicationsCollection.doc();

    final DocumentReference<Map<String, dynamic>>
        expertReference =
        _expertsCollection.doc(application.uid);

    final DocumentReference<Map<String, dynamic>>
        userReference =
        _usersCollection.doc(application.uid);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            expertSnapshot =
            await transaction.get(expertReference);

        if (!expertSnapshot.exists ||
            expertSnapshot.data() == null) {
          throw const ExpertProfileNotFoundException();
        }

        transaction.set(
          applicationReference,
          {
            ...application.toMap(),
            'applicationId':
                applicationReference.id,
            'uid': application.uid,
            'type': 'profileUpdate',
            'companyName':
                application.companyName.trim(),
            'branch': application.branch.trim(),
            'position': application.position.trim(),
            'corporateEmail': application
                .corporateEmail
                .trim()
                .toLowerCase(),
            'phone': application.phone.trim(),
            'status': 'pending',
            'reviewNote': null,
            'reviewedAt': null,
            'reviewedBy': null,
            'previousCompanyName':
                currentExpert.companyName,
            'previousBranch':
                currentExpert.branch,
            'previousPosition':
                currentExpert.position,
            'previousCorporateEmail':
                currentExpert.corporateEmail,
            'createdAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          expertReference,
          {
            'status': 'suspended',
            'verificationStatus':
                'pendingUpdate',
            'acceptsNewRequests': false,
            'suspendedAt':
                FieldValue.serverTimestamp(),
            'suspensionReason':
                'Şirket veya uzmanlık bilgisi '
                'değişikliği inceleniyor.',
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          userReference,
          {
            'phone': application.phone.trim(),
            'expertStatus': 'pending',
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );

    return applicationReference.id;
  }

  /// Belge kimliğiyle tek bir başvuruyu getirir.
  Future<ExpertApplication> getApplicationById(
    String applicationId,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>>
        document = await _applicationsCollection
            .doc(applicationId)
            .get();

    if (!document.exists ||
        document.data() == null) {
      throw const ExpertApplicationNotFoundException();
    }

    return ExpertApplication.fromDocument(
      document,
    );
  }

  /// Belge kimliğiyle başvuruyu gerçek zamanlı takip eder.
  Stream<ExpertApplication?> watchApplicationById(
    String applicationId,
  ) {
    return _applicationsCollection
        .doc(applicationId)
        .snapshots()
        .map(
      (document) {
        if (!document.exists ||
            document.data() == null) {
          return null;
        }

        return ExpertApplication.fromDocument(
          document,
        );
      },
    );
  }

  /// Kullanıcının tüm başvurularını getirir.
  ///
  /// En yeni başvuru en üstte olur.
  Stream<List<ExpertApplication>>
      watchApplicationsByUserId(
    String uid,
  ) {
    return _applicationsCollection
        .where('uid', isEqualTo: uid)
        .orderBy(
          'createdAt',
          descending: true,
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

  /// Kullanıcının son başvurusunu getirir.
  Future<ExpertApplication?>
      getLatestApplicationByUserId(
    String uid,
  ) async {
    final QuerySnapshot<Map<String, dynamic>>
        snapshot = await _applicationsCollection
            .where('uid', isEqualTo: uid)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return ExpertApplication.fromDocument(
      snapshot.docs.first,
    );
  }

  /// Yönetici panelinde bekleyen başvuruları dinler.
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

  /// Yönetici başvuruyu onayladığında başvuru kaydını
  /// günceller.
  ///
  /// Aktif uzman profilini oluşturma veya güncelleme işlemi
  /// admin servisinde / repository akışında ayrıca yapılır.
  Future<void> markApplicationApproved({
    required String applicationId,
    required String reviewedBy,
    String? reviewNote,
  }) async {
    await _applicationsCollection
        .doc(applicationId)
        .update({
      'status': 'approved',
      'reviewNote': reviewNote?.trim(),
      'reviewedBy': reviewedBy,
      'reviewedAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  /// Yönetici başvuruyu reddettiğinde başvuruyu ve
  /// kullanıcının uzmanlık durumunu günceller.
  Future<void> markApplicationRejected({
    required ExpertApplication application,
    required String reviewedBy,
    required String reviewNote,
  }) async {
    final String? applicationId =
        application.applicationId;

    if (applicationId == null ||
        applicationId.isEmpty) {
      throw const ExpertApplicationNotFoundException();
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
        transaction.update(
          applicationReference,
          {
            'status': 'rejected',
            'reviewNote': reviewNote.trim(),
            'reviewedBy': reviewedBy,
            'reviewedAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          userReference,
          {
            'expertStatus': 'rejected',
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        if (application.isProfileUpdateApplication) {
          final DocumentSnapshot<Map<String, dynamic>>
              expertSnapshot =
              await transaction.get(
            expertReference,
          );

          if (expertSnapshot.exists) {
            transaction.update(
              expertReference,
              {
                'status': 'suspended',
                'verificationStatus':
                    'rejected',
                'acceptsNewRequests': false,
                'suspensionReason':
                    reviewNote.trim(),
                'updatedAt':
                    FieldValue.serverTimestamp(),
              },
            );
          }
        }
      },
    );
  }
}