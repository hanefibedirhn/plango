import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expert_application_model.dart';

class ExpertApplicationAlreadyExistsException implements Exception {
  const ExpertApplicationAlreadyExistsException();

  @override
  String toString() {
    return 'Daha önce oluşturulmuş bir uzman başvurunuz bulunuyor.';
  }
}

class ExpertApplicationNotFoundException implements Exception {
  const ExpertApplicationNotFoundException();

  @override
  String toString() {
    return 'Uzman başvurusu bulunamadı.';
  }
}

class ExpertApplicationRepository {
  ExpertApplicationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _applicationsCollection {
    return _firestore.collection('expertApplications');
  }

  CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection('users');
  }

  /// Uzman başvurusunu oluşturur.
  ///
  /// Başvuru belgesi, telefon bilgisi ve kullanıcının
  /// uzmanlık durumu tek transaction içinde kaydedilir.
  Future<void> submitApplication(
    ExpertApplication application,
  ) async {
    final DocumentReference<Map<String, dynamic>>
        applicationReference =
        _applicationsCollection.doc(application.uid);

    final DocumentReference<Map<String, dynamic>>
        userReference =
        _usersCollection.doc(application.uid);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            applicationSnapshot =
            await transaction.get(applicationReference);

        if (applicationSnapshot.exists) {
          throw const ExpertApplicationAlreadyExistsException();
        }

        transaction.set(
          applicationReference,
          {
            ...application.toMap(),
            'uid': application.uid,
            'companyName': application.companyName.trim(),
            'branch': application.branch.trim(),
            'position': application.position.trim(),
            'corporateEmail':
                application.corporateEmail.trim().toLowerCase(),
            'phone': application.phone.trim(),
            'status': 'pending',
            'reviewNote': null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          userReference,
          {
            'phone': application.phone.trim(),
            'expertStatus': 'pending',
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  /// Kullanıcının uzman başvurusunu UID ile getirir.
  Future<ExpertApplication> getApplicationByUserId(
    String uid,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _applicationsCollection.doc(uid).get();

    if (!document.exists || document.data() == null) {
      throw const ExpertApplicationNotFoundException();
    }

    return ExpertApplication.fromDocument(document);
  }

  /// Başvurunun durumunu gerçek zamanlı takip eder.
  Stream<ExpertApplication?> watchApplicationByUserId(
    String uid,
  ) {
    return _applicationsCollection.doc(uid).snapshots().map(
      (document) {
        if (!document.exists || document.data() == null) {
          return null;
        }

        return ExpertApplication.fromDocument(document);
      },
    );
  }
}