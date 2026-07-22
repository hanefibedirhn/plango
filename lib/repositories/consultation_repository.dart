import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/consultation_request_model.dart';

class ConsultationRepositoryException
    implements Exception {
  const ConsultationRepositoryException(
    this.message,
  );

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
      : super(
          'Bu danışma talebi daha önce sonuçlandırılmış.',
        );
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
      : super(
          'Bu danışma talebinin yanıt süresi dolmuş.',
        );
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
      get _requestContactsCollection {
    return _firestore.collection(
      'consultationRequestContacts',
    );
  }

  CollectionReference<Map<String, dynamic>>
      get _expertsCollection {
    return _firestore.collection('experts');
  }

  CollectionReference<Map<String, dynamic>>
    get _expertProfilesCollection {
  return _firestore.collection(
    'expertProfiles',
  );
  }
  /// Yeni danışma talebi oluşturur.
  ///
  /// Kayıtlı veya anonim kullanıcının UID değeri
  /// request.userId alanında bulunmalıdır.
  ///
  /// Kullanıcının farklı bir uzmanla açık danışma
  /// süreci varsa yeni talep oluşturulmaz.
  Future<String> createConsultationRequest(
  ConsultationRequest request, {
  required String userPhone,
}) async {
  _validateRequest(request);

  final String normalizedPhone =
      userPhone.replaceAll(
    RegExp(r'[^0-9]'),
    '',
  );

  if (!_isValidPhone(normalizedPhone)) {
    throw const ConsultationRepositoryException(
      'Lütfen geçerli bir telefon numarası giriniz.',
    );
  }

  final DocumentSnapshot<Map<String, dynamic>>
    expertSnapshot =
    await _expertProfilesCollection
        .doc(request.expertId)
        .get();

  if (!expertSnapshot.exists ||
      expertSnapshot.data() == null) {
    throw const ConsultationExpertUnavailableException();
  }

  final Map<String, dynamic> expertData =
      expertSnapshot.data()!;

  final String expertStatus =
      expertData['status'] as String? ??
          'inactive';

  final bool acceptsNewRequests =
      expertData['acceptsNewRequests']
              as bool? ??
          false;

  final String expertCompanyName =
      expertData['companyName']
              as String? ??
          '';

  if (expertStatus != 'active' ||
      !acceptsNewRequests) {
    throw const ConsultationExpertUnavailableException();
  }

  if (_normalize(expertCompanyName) !=
      _normalize(request.companyName)) {
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

  final DocumentReference<Map<String, dynamic>>
      contactReference =
      _requestContactsCollection.doc(
    requestReference.id,
  );

  final DateTime now = DateTime.now();

  final DateTime expiresAt =
      now.add(responseDuration);

  final ConsultationRequest preparedRequest =
      request.copyWith(
    requestId: requestReference.id,
    status: 'pending',
    createdAt: now,
    updatedAt: now,
    expiresAt: expiresAt,
    clearAcceptedAt: true,
    clearContactedAt: true,
    clearCompletedAt: true,
    clearRejectedAt: true,
    clearCancelledAt: true,
    clearRejectionReason: true,
  );

  final WriteBatch batch =
      _firestore.batch();

  batch.set(
    requestReference,
    {
      ...preparedRequest.toMap(),
      'requestId': requestReference.id,
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
      'expiresAt':
          Timestamp.fromDate(expiresAt),
      'status': 'pending',
      'acceptedAt': null,
      'contactedAt': null,
      'completedAt': null,
      'rejectedAt': null,
      'cancelledAt': null,
      'rejectionReason': null,
    },
  );

  batch.set(
    contactReference,
    {
      'requestId': requestReference.id,
      'userId': request.userId,
      'expertId': request.expertId,
      'userPhone': normalizedPhone,
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    },
  );

  await batch.commit();

  return requestReference.id;
}

  void _validateRequest(
    ConsultationRequest request,
  ) {
    if (request.userId.trim().isEmpty) {
      throw const ConsultationRepositoryException(
        'Kullanıcı kimliği bulunamadı.',
      );
    }

    if (request.expertId.trim().isEmpty) {
      throw const ConsultationRepositoryException(
        'Uzman kimliği bulunamadı.',
      );
    }

    if (request.userId == request.expertId) {
      throw const ConsultationRepositoryException(
        'Kendinize danışma talebi gönderemezsiniz.',
      );
    }

    if (request.userFullName.trim().length < 3) {
      throw const ConsultationRepositoryException(
        'Lütfen geçerli bir ad soyad giriniz.',
      );
    }

    if (request.companyName.trim().isEmpty) {
      throw const ConsultationRepositoryException(
        'Şirket bilgisi bulunamadı.',
      );
    }

    if (request.plan.financeAmount <= 0) {
      throw const ConsultationRepositoryException(
        'Finansman tutarı geçerli değil.',
      );
    }

    if (request.plan.monthlyInstallment <= 0) {
      throw const ConsultationRepositoryException(
        'İlk taksit tutarı geçerli değil.',
      );
    }

    if (request.plan.estimatedDelivery <= 0 ||
        request.plan.estimatedTerm <= 0) {
      throw const ConsultationRepositoryException(
        'FP Engine plan bilgileri geçerli değil.',
      );
    }

    final String note =
        request.userNote?.trim() ?? '';

    if (note.length > 500) {
      throw const ConsultationRepositoryException(
        'Notunuz en fazla 500 karakter olabilir.',
      );
    }
  }

  bool _isValidPhone(
    String value,
  ) {
    final String digits =
        value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    return digits.length == 10 ||
        digits.length == 11;
  }

  /// Kullanıcının farklı bir uzmanla açık talebi var mı?
  Future<bool> _hasActiveRequestWithDifferentExpert({
    required String userId,
    required String expertId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>>
        snapshot =
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

    for (final QueryDocumentSnapshot<
        Map<String, dynamic>> document
        in snapshot.docs) {
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
        await _requestsCollection
            .doc(requestId)
            .get();

    if (!document.exists ||
        document.data() == null) {
      throw const ConsultationRequestNotFoundException();
    }

    return ConsultationRequest.fromDocument(
      document,
    );
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
  Stream<List<ConsultationRequest>>
      watchUserRequests(
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
  Stream<List<ConsultationRequest>>
      watchExpertRequests(
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
    final DateTime now = DateTime.now();

    return snapshot.docs
        .map(
          ConsultationRequest.fromDocument,
        )
        .where(
  (request) {
    const visibleStatuses = {
      'pending',
      'accepted',
      'contacted',
      'completed',
    };

    if (!visibleStatuses.contains(
      request.status,
    )) {
      return false;
    }

    if (request.status == 'pending' &&
        request.expiresAt != null &&
        !request.expiresAt!.isAfter(now)) {
      return false;
    }

    return true;
  },
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
    print("1- Transaction başladı");

    final requestSnapshot =
        await transaction.get(requestReference);

    print("2- Snapshot alındı");

    if (!requestSnapshot.exists ||
        requestSnapshot.data() == null) {
      print("3- Talep bulunamadı");
      throw const ConsultationRequestNotFoundException();
    }

    final data = requestSnapshot.data()!;
    print("4- Data okundu");

    if (data['expertId'] != expertId) {
      print("5- Expert uyuşmuyor");
      throw const ConsultationRepositoryException(
        'Bu danışma talebi size ait değil.',
      );
    }

    if (data['status'] != 'pending') {
      print("6- Status pending değil");
      throw const ConsultationRequestAlreadyProcessedException();
    }

    final expiresAt =
        _readNullableDate(data['expiresAt']);

    print("7- Expires okundu");

    if (expiresAt == null ||
        !DateTime.now().isBefore(expiresAt)) {
      print("8- Süresi dolmuş");
      throw const ConsultationRequestExpiredException();
    }

    print("9- Update başlıyor");

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

    print("10- Update tamam");
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
            await transaction.get(
          requestReference,
        );

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
    'status': 'waiting_for_admin',
    'rejectionReason': normalizedReason,
    'rejectedAt':
        FieldValue.serverTimestamp(),
    'waitingForAdminAt':
        FieldValue.serverTimestamp(),
    'adminQueueReason': 'expert_rejected',
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
            await transaction.get(
          requestReference,
        );

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

  /// Yönetici tarafından yeniden atanmayı bekleyen talepleri dinler.
Stream<List<ConsultationRequest>>
    watchWaitingForAdminRequests() {
  return _requestsCollection
      .where(
        'status',
        isEqualTo: 'waiting_for_admin',
      )
      .orderBy(
        'updatedAt',
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

  Future<String?> getRequestPhone({
  required String requestId,
  required String expertId,
}) async {
  final contactSnapshot =
      await _requestContactsCollection
          .doc(requestId)
          .get();

  if (!contactSnapshot.exists ||
      contactSnapshot.data() == null) {
    return null;
  }

  final data = contactSnapshot.data()!;

  if (data['expertId'] != expertId) {
    throw ConsultationRepositoryException(
      'Bu iletişim bilgisine erişim yetkiniz yok.',
    );
  }

  final String phone =
      data['userPhone'] as String? ?? '';

  return phone.isEmpty ? null : phone;
}

  Future<void> _updateExpertOwnedStatus({
    required String requestId,
    required String expertId,
    required List<String>
        requiredCurrentStatuses,
    required Map<String, dynamic> values,
  }) async {
    final DocumentReference<Map<String, dynamic>>
        requestReference =
        _requestsCollection.doc(requestId);

    await _firestore.runTransaction<void>(
      (transaction) async {
        final DocumentSnapshot<Map<String, dynamic>>
            requestSnapshot =
            await transaction.get(
          requestReference,
        );

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

  /// Süresi geçen pending talebi expired yapar.
  ///
  /// Tam otomatik süre kontrolü daha sonra güvenli
  /// backend göreviyle çalıştırılacaktır.
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
            await transaction.get(
          requestReference,
        );

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
            _readNullableDate(
          data['expiresAt'],
        );

        if (expiresAt == null ||
            DateTime.now()
                .isBefore(expiresAt)) {
          return false;
        }

        transaction.update(
  requestReference,
  {
    'status': 'waiting_for_admin',
    'waitingForAdminAt':
        FieldValue.serverTimestamp(),
    'adminQueueReason': 'response_expired',
    'updatedAt':
        FieldValue.serverTimestamp(),
  },
);

        return true;
      },
    );
  }
  
  /// Reddedilen veya yanıt süresi dolan talebi
  /// yönetici tarafından başka bir uzmana atar.
  ///
  /// Eski talep reassigned durumuna geçirilir.
  /// Yeni uzman için yeni bir pending talep oluşturulur.
  /// Kullanıcının iletişim bilgisi yeni talebe kopyalanır.
  Future<String> reassignRequest({
    required ConsultationRequest previousRequest,
    required String newExpertId,
  }) async {
    final String? previousRequestId =
        previousRequest.requestId;

    final String normalizedNewExpertId =
        newExpertId.trim();

    if (previousRequestId == null ||
        previousRequestId.trim().isEmpty) {
      throw const ConsultationRequestNotFoundException();
    }

    if (normalizedNewExpertId.isEmpty) {
      throw const ConsultationRepositoryException(
        'Yeni uzman kimliği bulunamadı.',
      );
    }

    if (normalizedNewExpertId ==
        previousRequest.expertId) {
      throw const ConsultationRepositoryException(
        'Talep aynı uzmana yeniden yönlendirilemez.',
      );
    }

    final DocumentReference<Map<String, dynamic>>
        previousRequestReference =
        _requestsCollection.doc(previousRequestId);

    final DocumentReference<Map<String, dynamic>>
        previousContactReference =
        _requestContactsCollection.doc(
      previousRequestId,
    );

    final DocumentReference<Map<String, dynamic>>
        newExpertReference =
        _expertProfilesCollection.doc(
      normalizedNewExpertId,
    );

    final DocumentReference<Map<String, dynamic>>
        newRequestReference =
        _requestsCollection.doc();

    final DocumentReference<Map<String, dynamic>>
        newContactReference =
        _requestContactsCollection.doc(
      newRequestReference.id,
    );

    final DateTime expiresAt =
        DateTime.now().add(responseDuration);

    await _firestore.runTransaction<void>(
      (transaction) async {
        // Transaction içinde önce bütün okumalar yapılır.
        final DocumentSnapshot<Map<String, dynamic>>
            previousRequestSnapshot =
            await transaction.get(
          previousRequestReference,
        );

        final DocumentSnapshot<Map<String, dynamic>>
            previousContactSnapshot =
            await transaction.get(
          previousContactReference,
        );

        final DocumentSnapshot<Map<String, dynamic>>
            newExpertSnapshot =
            await transaction.get(
          newExpertReference,
        );

        if (!previousRequestSnapshot.exists ||
            previousRequestSnapshot.data() == null) {
          throw const ConsultationRequestNotFoundException();
        }

        if (!previousContactSnapshot.exists ||
            previousContactSnapshot.data() == null) {
          throw const ConsultationRepositoryException(
            'Danışma talebinin iletişim bilgisi bulunamadı.',
          );
        }

        if (!newExpertSnapshot.exists ||
            newExpertSnapshot.data() == null) {
          throw const ConsultationExpertUnavailableException();
        }

        final Map<String, dynamic> previousRequestData =
            previousRequestSnapshot.data()!;

        final Map<String, dynamic> previousContactData =
            previousContactSnapshot.data()!;

        final Map<String, dynamic> newExpertData =
            newExpertSnapshot.data()!;

        final String previousStatus =
            previousRequestData['status']
                    as String? ??
                '';

        if (previousStatus != 'waiting_for_admin') {
          throw const ConsultationRequestAlreadyProcessedException();
        }

        final String currentExpertId =
            previousRequestData['expertId']
                    as String? ??
                '';

        if (currentExpertId.isEmpty) {
          throw const ConsultationRepositoryException(
            'Talebin önceki uzman bilgisi bulunamadı.',
          );
        }

        if (currentExpertId ==
            normalizedNewExpertId) {
          throw const ConsultationRepositoryException(
            'Talep aynı uzmana yeniden yönlendirilemez.',
          );
        }

        final String newExpertStatus =
            newExpertData['status'] as String? ??
                'inactive';

        final bool acceptsNewRequests =
            newExpertData['acceptsNewRequests']
                    as bool? ??
                false;

        final String newExpertCompanyName =
            newExpertData['companyName']
                    as String? ??
                '';

        final String requestCompanyName =
            previousRequestData['companyName']
                    as String? ??
                previousRequest.companyName;

        if (newExpertStatus != 'active' ||
            !acceptsNewRequests) {
          throw const ConsultationExpertUnavailableException();
        }

        if (_normalize(newExpertCompanyName) !=
            _normalize(requestCompanyName)) {
          throw const ConsultationRepositoryException(
            'Seçilen uzman ile şirket bilgisi eşleşmiyor.',
          );
        }

        final String userPhone =
            previousContactData['userPhone']
                    as String? ??
                '';

        if (!_isValidPhone(userPhone)) {
          throw const ConsultationRepositoryException(
            'Danışma talebinin telefon bilgisi geçerli değil.',
          );
        }

        final Map<String, dynamic> newRequestData = {
          ...previousRequestData,
          'requestId': newRequestReference.id,
          'expertId': normalizedNewExpertId,
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
          'waitingForAdminAt': null,
          'adminQueueReason': null,
          'reassignedFromExpertId':
              currentExpertId,
        };

        final Map<String, dynamic> newContactData = {
          ...previousContactData,
          'requestId': newRequestReference.id,
          'expertId': normalizedNewExpertId,
          'userPhone': userPhone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Bütün kontroller tamamlandıktan sonra
        // yazma işlemleri gerçekleştirilir.
        transaction.update(
          previousRequestReference,
          {
            'status': 'reassigned',
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        transaction.set(
          newRequestReference,
          newRequestData,
        );

        transaction.set(
          newContactReference,
          newContactData,
        );
      },
    );

    return newRequestReference.id;
  }

  static String _normalize(
    String value,
  ) {
    return value.trim().toLowerCase();
  }

  static DateTime? _readNullableDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}