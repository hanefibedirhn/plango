import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/consultation_request_model.dart';

class ConsultationRepositoryException implements Exception {
  const ConsultationRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ConsultationRequestNotFoundException
    extends ConsultationRepositoryException {
  const ConsultationRequestNotFoundException()
      : super('Danışma talebi bulunamadı.');
}

class ConsultationRequestAlreadyProcessedException
    extends ConsultationRepositoryException {
  const ConsultationRequestAlreadyProcessedException()
      : super('Bu danışma talebi daha önce sonuçlandırılmış.');
}

class ConsultationExpertUnavailableException
    extends ConsultationRepositoryException {
  const ConsultationExpertUnavailableException()
      : super(
          'Seçtiğiniz uzman şu anda yeni danışma talebi almıyor.',
        );
}

class ConsultationDifferentExpertActiveException
    extends ConsultationRepositoryException {
  const ConsultationDifferentExpertActiveException()
      : super(
          'Devam eden danışma süreciniz tamamlanmadan farklı bir uzmana talep gönderemezsiniz.',
        );
}

class ConsultationRequestExpiredException
    extends ConsultationRepositoryException {
  const ConsultationRequestExpiredException()
      : super('Bu danışma talebinin yanıt süresi dolmuş.');
}

class ConsultationRepository {
  ConsultationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration responseDuration =
      Duration(hours: 3);

  CollectionReference<Map<String, dynamic>>
      get _requestsCollection {
    return _firestore.collection(
      'consultationRequests',
    );
  }

  CollectionReference<Map<String, dynamic>>
      get _expertsCollection {
    return _firestore.collection('experts');
  }

  CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection('users');
  }

  /// Yeni danışma talebi oluşturur.
  ///
  /// Kullanıcının başka bir uzmanla devam eden süreci varsa
  /// yeni talep oluşturulmaz. Aynı uzmana farklı planlar
  /// gönderilmesine izin verilir.
  Future<String> createConsultationRequest(
    ConsultationRequest request,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>>
        expertSnapshot =
        await _expertsCollection.doc(request.expertId).get();

    if (!expertSnapshot.exists ||
        expertSnapshot.data() == null) {
      throw const ConsultationExpertUnavailableException();
    }

    final Map<String, dynamic> expertData =
        expertSnapshot.data()!;

    final String expertStatus =
        expertData['status'] as String? ?? 'inactive';

    final String verificationStatus =
        expertData['verificationStatus']
                as String? ??
            'rejected';

    final bool acceptsNewRequests =
        expertData['acceptsNewRequests']
                as bool? ??
            false;

    final String expertCompanyName =
        expertData['companyName'] as String? ?? '';

    if (expertStatus != 'active' ||
        verificationStatus != 'approved' ||
        !acceptsNewRequests) {
      throw const ConsultationExpertUnavailableException();
    }

    if (expertCompanyName.trim().toLowerCase() !=
        request.companyName.trim().toLowerCase()) {
      throw const ConsultationRepositoryException(
        'Seçilen uzman ile şirket bilgisi eşleşmiyor.',
      );
    }

    final bool hasDifferentExpertRequest =
        await _hasActiveRequestWithDifferentExpert(
      userId: request.userId,
      expertId: request.expertId,
    );

    if (hasDifferentExpertRequest) {
      throw const ConsultationDifferentExpertActiveException();
    }

    final DocumentReference<Map<String, dynamic>>
        requestReference =
        _requestsCollection.doc();

    final DateTime now = DateTime.now();
    final DateTime expiresAt =
        now.add(responseDuration);

    await requestReference.set({
      ...request.toMap(),
      'requestId': requestReference.id,
      'userId': request.userId,
      'expertId': request.expertId,
      'userFullName': request.userFullName.trim(),
      'companyName': request.companyName.trim(),
      'financeAmount': request.financeAmount,
      'downPayment': request.downPayment,
      'monthlyInstallment':
          request.monthlyInstallment,
      'increaseModel': request.increaseModel.trim(),
      'estimatedDelivery':
          request.estimatedDelivery.trim(),
      'estimatedTerm': request.estimatedTerm,
      'userNote': _nullableTrimmed(request.userNote),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'acceptedAt': null,
      'contactedAt': null,
      'completedAt': null,
      'rejectedAt': null,
      'cancelledAt': null,
      'rejectionReason': null,
      'reassignedFromExpertId':
          request.reassignedFromExpertId,
    });

    return requestReference.id;
  }

  /// Kullanıcının başka bir uzmanla açık talebi var mı?
  Future<bool> _hasActiveRequestWithDifferentExpert({
    required String userId,
    required String expertId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _requestsCollection
            .where(
              'userId',
              isEqualTo: userId,
            )
            .where(
              'status',
              whereIn: const [
                'pending',
                'accepted',
                'contacted',
              ],
            )
            .get();

    for (final document in snapshot.docs) {
      final String existingExpertId =
          document.data()['expertId']
                  as String? ??
              '';

      if (existingExpertId.isNotEmpty &&
          existingExpertId != expertId) {
        return true;
      }
    }

    return false;
  }

  /// Belge kimliğiyle danışma talebini getirir.
  Future<ConsultationRequest> getRequestById(
    String requestId,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>>
        document =
        await _requestsCollection.doc(requestId).get();

    if (!document.exists ||
        document.data() == null) {
      throw const ConsultationRequestNotFoundException();
    }

    return ConsultationRequest.fromDocument(document);
  }

  /// Tek bir talebi gerçek zamanlı takip eder.
  Stream<ConsultationRequest?> watchRequestById(
    String requestId,
  ) {
    return _requestsCollection
        .doc(requestId)
        .snapshots()
        .map(
      (document) {
        if (!document.exists ||
            document.data() == null) {
          return null;
        }

        return ConsultationRequest.fromDocument(
          document,
        );
      },
    );
  }

  /// Kullanıcının bütün danışma taleplerini dinler.
  Stream<List<ConsultationRequest>> watchUserRequests(
    String userId,
  ) {
    return _requestsCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              ConsultationRequest.fromDocument,
            )
            .toList();
      },
    );
  }

  /// Uzmanın bütün danışma taleplerini dinler.
  Stream<List<ConsultationRequest>> watchExpertRequests(
    String expertId,
  ) {
    return _requestsCollection
        .where(
          'expertId',
          isEqualTo: expertId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              ConsultationRequest.fromDocument,
            )
            .toList();
      },
    );
  }

  /// Uzmanın yalnızca yanıt bekleyen taleplerini dinler.
  Stream<List<ConsultationRequest>>
      watchPendingExpertRequests(
    String expertId,
  ) {
    return _requestsCollection
        .where(
          'expertId',
          isEqualTo: expertId,
        )
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
              ConsultationRequest.fromDocument,
            )
            .toList();
      },
    );
  }

  /// Uzman danışma talebini kabul eder.
  Future<void> acceptRequest({
    required String requestId,
    required String expertId,
  }) async {
    final DocumentReference<Map<String, dynamic>>
        requestReference =
        _requestsCollection.doc(requestId);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            requestSnapshot =
            await transaction.get(requestReference);

        if (!requestSnapshot.exists ||
            requestSnapshot.data() == null) {
          throw const ConsultationRequestNotFoundException();
        }

        final Map<String, dynamic> data =
            requestSnapshot.data()!;

        if (data['expertId'] != expertId) {
          throw const ConsultationRepositoryException(
            'Bu danışma talebi size ait değil.',
          );
        }

        if (data['status'] != 'pending') {
          throw const ConsultationRequestAlreadyProcessedException();
        }

        final DateTime? expiresAt =
            _readNullableDate(data['expiresAt']);

        if (expiresAt == null ||
            !DateTime.now().isBefore(expiresAt)) {
          throw const ConsultationRequestExpiredException();
        }

        transaction.update(
          requestReference,
          {
            'status': 'accepted',
            'acceptedAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
            'rejectedAt': null,
            'rejectionReason': null,
          },
        );
      },
    );
  }

  /// Uzman danışma talebini reddeder.
  Future<void> rejectRequest({
    required String requestId,
    required String expertId,
    required String rejectionReason,
  }) async {
    final String normalizedReason =
        rejectionReason.trim();

    if (normalizedReason.length < 3) {
      throw const ConsultationRepositoryException(
        'Lütfen geçerli bir red nedeni seçiniz.',
      );
    }

    final DocumentReference<Map<String, dynamic>>
        requestReference =
        _requestsCollection.doc(requestId);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            requestSnapshot =
            await transaction.get(requestReference);

        if (!requestSnapshot.exists ||
            requestSnapshot.data() == null) {
          throw const ConsultationRequestNotFoundException();
        }

        final Map<String, dynamic> data =
            requestSnapshot.data()!;

        if (data['expertId'] != expertId) {
          throw const ConsultationRepositoryException(
            'Bu danışma talebi size ait değil.',
          );
        }

        if (data['status'] != 'pending') {
          throw const ConsultationRequestAlreadyProcessedException();
        }

        transaction.update(
          requestReference,
          {
            'status': 'rejected',
            'rejectionReason': normalizedReason,
            'rejectedAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  /// Kullanıcı kendi açık talebini iptal eder.
  Future<void> cancelRequest({
    required String requestId,
    required String userId,
  }) async {
    final DocumentReference<Map<String, dynamic>>
        requestReference =
        _requestsCollection.doc(requestId);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            requestSnapshot =
            await transaction.get(requestReference);

        if (!requestSnapshot.exists ||
            requestSnapshot.data() == null) {
          throw const ConsultationRequestNotFoundException();
        }

        final Map<String, dynamic> data =
            requestSnapshot.data()!;

        if (data['userId'] != userId) {
          throw const ConsultationRepositoryException(
            'Bu danışma talebini iptal etme yetkiniz bulunmuyor.',
          );
        }

        final String status =
            data['status'] as String? ?? '';

        if (status != 'pending' &&
            status != 'accepted') {
          throw const ConsultationRequestAlreadyProcessedException();
        }

        transaction.update(
          requestReference,
          {
            'status': 'cancelled',
            'cancelledAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  /// Uzman kullanıcıyla iletişime geçtiğini işaretler.
  Future<void> markAsContacted({
    required String requestId,
    required String expertId,
  }) async {
    await _updateExpertOwnedStatus(
      requestId: requestId,
      expertId: expertId,
      requiredCurrentStatuses: const [
        'accepted',
      ],
      values: {
        'status': 'contacted',
        'contactedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  /// Uzman danışma sürecini tamamlar.
  Future<void> completeRequest({
    required String requestId,
    required String expertId,
  }) async {
    await _updateExpertOwnedStatus(
      requestId: requestId,
      expertId: expertId,
      requiredCurrentStatuses: const [
        'accepted',
        'contacted',
      ],
      values: {
        'status': 'completed',
        'completedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> _updateExpertOwnedStatus({
    required String requestId,
    required String expertId,
    required List<String> requiredCurrentStatuses,
    required Map<String, dynamic> values,
  }) async {
    final DocumentReference<Map<String, dynamic>>
        requestReference =
        _requestsCollection.doc(requestId);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            requestSnapshot =
            await transaction.get(requestReference);

        if (!requestSnapshot.exists ||
            requestSnapshot.data() == null) {
          throw const ConsultationRequestNotFoundException();
        }

        final Map<String, dynamic> data =
            requestSnapshot.data()!;

        if (data['expertId'] != expertId) {
          throw const ConsultationRepositoryException(
            'Bu danışma talebi size ait değil.',
          );
        }

        final String currentStatus =
            data['status'] as String? ?? '';

        if (!requiredCurrentStatuses.contains(
          currentStatus,
        )) {
          throw const ConsultationRequestAlreadyProcessedException();
        }

        transaction.update(
          requestReference,
          values,
        );
      },
    );
  }

  /// Süresi geçen pending talebi expired olarak işaretler.
  ///
  /// Bu metot istemci tarafındaki kontroller için hazırlanmıştır.
  /// Tam otomatik üç saat kontrolü ileride güvenli bir backend
  /// göreviyle çalıştırılacaktır.
  Future<bool> expireRequestIfNeeded(
    String requestId,
  ) async {
    final DocumentReference<Map<String, dynamic>>
        requestReference =
        _requestsCollection.doc(requestId);

    return _firestore.runTransaction<bool>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            requestSnapshot =
            await transaction.get(requestReference);

        if (!requestSnapshot.exists ||
            requestSnapshot.data() == null) {
          throw const ConsultationRequestNotFoundException();
        }

        final Map<String, dynamic> data =
            requestSnapshot.data()!;

        if (data['status'] != 'pending') {
          return false;
        }

        final DateTime? expiresAt =
            _readNullableDate(data['expiresAt']);

        if (expiresAt == null ||
            DateTime.now().isBefore(expiresAt)) {
          return false;
        }

        transaction.update(
          requestReference,
          {
            'status': 'expired',
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        return true;
      },
    );
  }

  /// Süresi dolmuş veya reddedilmiş talebin başka uzmana
  /// yönlendirilmesi için yeni talep oluşturur.
  Future<String> reassignRequest({
    required ConsultationRequest previousRequest,
    required String newExpertId,
  }) async {
    final String? previousRequestId =
        previousRequest.requestId;

    if (previousRequestId == null ||
        previousRequestId.isEmpty) {
      throw const ConsultationRequestNotFoundException();
    }

    if (newExpertId == previousRequest.expertId) {
      throw const ConsultationRepositoryException(
        'Talep aynı uzmana yeniden yönlendirilemez.',
      );
    }

    final ConsultationRequest reassignedRequest =
        previousRequest.copyWith(
      requestId: null,
      expertId: newExpertId,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expiresAt:
          DateTime.now().add(responseDuration),
      reassignedFromExpertId:
          previousRequest.expertId,
      clearAcceptedAt: true,
      clearContactedAt: true,
      clearCompletedAt: true,
      clearRejectedAt: true,
      clearCancelledAt: true,
      clearRejectionReason: true,
    );

    final String newRequestId =
        await createConsultationRequest(
      reassignedRequest,
    );

    await _requestsCollection
        .doc(previousRequestId)
        .update({
      'status': 'reassigned',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return newRequestId;
  }

  static String? _nullableTrimmed(String? value) {
    final String normalized = value?.trim() ?? '';

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static DateTime? _readNullableDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}