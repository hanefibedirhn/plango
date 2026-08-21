import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/consultation_request_contact_model.dart';
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
      : super('Uygun uzman şu anda yeni danışma talebi almıyor.');
}

class ConsultationRequestExpiredException
    extends ConsultationRepositoryException {
  const ConsultationRequestExpiredException()
      : super('Bu danışma talebinin yanıt süresi dolmuş.');
}

class ConsultationRepository {
  ConsultationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration responseDuration = Duration(hours: 24);

  CollectionReference<Map<String, dynamic>> get _requestsCollection =>
      _firestore.collection('consultationRequests');

  CollectionReference<Map<String, dynamic>> get _requestContactsCollection =>
      _firestore.collection('consultationRequestContacts');

  CollectionReference<Map<String, dynamic>> get _expertsCollection =>
      _firestore.collection('experts');

  CollectionReference<Map<String, dynamic>> get _expertProfilesCollection =>
      _firestore.collection('expertProfiles');

  /// Talebi önce şirket kuyruğunda oluşturur.
  ///
  /// Ardından aynı şirkette aktif ve yeni talep kabul eden bir uzmanı
  /// otomatik olarak atamayı dener. Uygun uzman bulunamazsa talep
  /// waiting_assignment durumunda kalır ve yönetici panelinde görünür.
  Future<String> createConsultationRequest(
    ConsultationRequest request, {
    required String userPhone,
  }) async {
    _validateRequest(request);

    final String normalizedPhone =
        userPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (!_isValidPhone(normalizedPhone)) {
      throw const ConsultationRepositoryException(
        'Lütfen geçerli bir telefon numarası giriniz.',
      );
    }

    final bool hasDuplicateOpenRequest =
        await _hasDuplicateOpenRequest(
      request: request,
    );

    if (hasDuplicateOpenRequest) {
      throw const ConsultationRepositoryException(
        'Bu plan için seçtiğiniz şirkete ait devam eden bir danışma talebiniz bulunuyor.',
      );
    }

    final DocumentReference<Map<String, dynamic>> requestReference =
        _requestsCollection.doc();

    final DocumentReference<Map<String, dynamic>> contactReference =
        _requestContactsCollection.doc(requestReference.id);

    final DateTime now = DateTime.now();

    final ConsultationRequest preparedRequest = request.copyWith(
      requestId: requestReference.id,
      status: 'waiting_assignment',
      createdAt: now,
      updatedAt: now,
      clearExpertId: true,
      clearAssignmentType: true,
      clearAssignedAt: true,
      clearAssignedBy: true,
      clearExpiresAt: true,
      clearAcceptedAt: true,
      clearContactedAt: true,
      clearCompletedAt: true,
      clearRejectedAt: true,
      clearCancelledAt: true,
      clearRejectionReason: true,
      clearAdminQueueReason: true,
      clearWaitingForAdminAt: true,
      clearReassignedFromExpertId: true,
    );

    final WriteBatch batch = _firestore.batch();

    batch.set(
      requestReference,
      {
        ...preparedRequest.toMap(),
        'requestId': requestReference.id,
        'expertId': '',
        'status': 'waiting_assignment',
        'assignmentType': null,
        'assignedAt': null,
        'assignedBy': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
      },
    );

    batch.set(
      contactReference,
      {
        'requestId': requestReference.id,
        'userId': request.userId,
        'expertId': '',
        'userPhone': normalizedPhone,
        'expertPhone': null,
        'expertCorporateEmail': null,
        'contactSharedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
    // Talebin kaydedilmesi uzman bulunamamasına bağlı değildir.
    // Otomatik atama başarısız olursa yönetici kuyruğunda kalır.
    try {
      await tryAutomaticAssignment(
        requestId: requestReference.id,
        companyName: request.companyName,
      );
    } on FirebaseException {
      // Rules veya index henüz güncellenmediyse kullanıcı talebi kaybolmaz.
    } on ConsultationRepositoryException {
      // Uygun uzman bulunamaması normal bir kuyruk senaryosudur.
    }

    return requestReference.id;
  }

  void _validateRequest(ConsultationRequest request) {
    if (request.userId.trim().isEmpty) {
      throw const ConsultationRepositoryException(
        'Kullanıcı kimliği bulunamadı.',
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

    if (request.plan.downPayment < 0) {
      throw const ConsultationRepositoryException(
        'Peşinat tutarı geçerli değil.',
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

    final String note = request.userNote?.trim() ?? '';

    if (note.length > 500) {
      throw const ConsultationRepositoryException(
        'Notunuz en fazla 500 karakter olabilir.',
      );
    }
  }

  Future<bool> _hasDuplicateOpenRequest({
    required ConsultationRequest request,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _requestsCollection
            .where(
              'userId',
              isEqualTo: request.userId,
            )
            .where(
              'status',
              whereIn: const [
                'waiting_assignment',
                'pending',
                'accepted',
                'contacted',
                'waiting_for_admin',
              ],
            )
            .get();

    final String company = _normalize(request.companyName);
    final String increaseModel =
        _normalize(request.plan.increaseModel);

    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      final Map<String, dynamic> data = document.data();

      final String existingCompany = _normalize(
        data['companyName'] as String? ?? '',
      );

      final String existingIncreaseModel = _normalize(
        data['increaseModel'] as String? ?? '',
      );

      final double existingFinanceAmount =
          (data['financeAmount'] as num?)?.toDouble() ?? 0;

      final double existingDownPayment =
          (data['downPayment'] as num?)?.toDouble() ?? 0;

      final double existingMonthlyInstallment =
          (data['monthlyInstallment'] as num?)?.toDouble() ?? 0;

      final int existingEstimatedDelivery =
          (data['estimatedDelivery'] as num?)?.toInt() ?? 0;

      final int existingEstimatedTerm =
          (data['estimatedTerm'] as num?)?.toInt() ?? 0;

      final bool samePlan =
          existingCompany == company &&
          existingFinanceAmount == request.plan.financeAmount &&
          existingDownPayment == request.plan.downPayment &&
          existingMonthlyInstallment ==
              request.plan.monthlyInstallment &&
          existingIncreaseModel == increaseModel &&
          existingEstimatedDelivery ==
              request.plan.estimatedDelivery &&
          existingEstimatedTerm == request.plan.estimatedTerm;

      if (samePlan) {
        return true;
      }
    }

    return false;
  }

  /// Aynı şirketteki uygun uzmanlar arasından en düşük iş yüküne sahip
  /// uzmanı seçer. İş yükü eşitse en uzun süredir atama almayan uzman
  /// önceliklendirilir.
  Future<bool> tryAutomaticAssignment({
    required String requestId,
    required String companyName,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _expertProfilesCollection
            .where('companyName', isEqualTo: companyName.trim())
            .where('status', isEqualTo: 'active')
            .where('acceptsNewRequests', isEqualTo: true)
            .get();

    if (snapshot.docs.isEmpty) {
      return false;
    }

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> candidates =
        snapshot.docs.toList()
          ..sort((a, b) {
            final Map<String, dynamic> aData = a.data();
            final Map<String, dynamic> bData = b.data();

            final int aCount =
                (aData['activeRequestCount'] as num?)?.toInt() ?? 0;
            final int bCount =
                (bData['activeRequestCount'] as num?)?.toInt() ?? 0;

            final int countComparison = aCount.compareTo(bCount);
            if (countComparison != 0) {
              return countComparison;
            }

            final DateTime? aLast = _readNullableDate(
              aData['lastAssignedAt'],
            );
            final DateTime? bLast = _readNullableDate(
              bData['lastAssignedAt'],
            );

            if (aLast == null && bLast == null) {
              return a.id.compareTo(b.id);
            }
            if (aLast == null) return -1;
            if (bLast == null) return 1;

            return aLast.compareTo(bLast);
          });

    await assignExpert(
      requestId: requestId,
      expertId: candidates.first.id,
      assignmentType: 'auto',
      assignedBy: 'system',
    );

    return true;
  }

  /// Yönetici veya otomatik atama sistemi tarafından mevcut talebe
  /// uzman atar. Yeni talep belgesi oluşturulmaz; süreç tek belge
  /// üzerinden devam eder.
  Future<void> assignExpert({
    required String requestId,
    required String expertId,
    required String assignmentType,
    required String assignedBy,
  }) async {
    final String normalizedExpertId = expertId.trim();

    if (normalizedExpertId.isEmpty) {
      throw const ConsultationRepositoryException(
        'Uzman kimliği bulunamadı.',
      );
    }

    if (assignmentType != 'auto' && assignmentType != 'admin') {
      throw const ConsultationRepositoryException(
        'Atama türü geçerli değil.',
      );
    }

    final DocumentReference<Map<String, dynamic>> requestReference =
        _requestsCollection.doc(requestId);

    final DocumentReference<Map<String, dynamic>> contactReference =
        _requestContactsCollection.doc(requestId);

    final DocumentReference<Map<String, dynamic>> expertReference =
        _expertProfilesCollection.doc(normalizedExpertId);

    final DateTime expiresAt = DateTime.now().add(responseDuration);

    await _firestore.runTransaction<void>((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> requestSnapshot =
          await transaction.get(requestReference);
      final DocumentSnapshot<Map<String, dynamic>> contactSnapshot =
          await transaction.get(contactReference);
      final DocumentSnapshot<Map<String, dynamic>> expertSnapshot =
          await transaction.get(expertReference);

      if (!requestSnapshot.exists || requestSnapshot.data() == null) {
        throw const ConsultationRequestNotFoundException();
      }

      if (!contactSnapshot.exists || contactSnapshot.data() == null) {
        throw const ConsultationRepositoryException(
          'Danışma talebinin iletişim kaydı bulunamadı.',
        );
      }

      if (!expertSnapshot.exists || expertSnapshot.data() == null) {
        throw const ConsultationExpertUnavailableException();
      }

      final Map<String, dynamic> requestData = requestSnapshot.data()!;
      final Map<String, dynamic> expertData = expertSnapshot.data()!;

      final String currentStatus =
          requestData['status'] as String? ?? '';

      if (currentStatus != 'waiting_assignment' &&
          currentStatus != 'waiting_for_admin') {
        throw const ConsultationRequestAlreadyProcessedException();
      }

      final String expertStatus =
          expertData['status'] as String? ?? 'inactive';
      final bool acceptsNewRequests =
          expertData['acceptsNewRequests'] as bool? ?? false;
      final String expertCompanyName =
          expertData['companyName'] as String? ?? '';
      final String requestCompanyName =
          requestData['companyName'] as String? ?? '';

      if (expertStatus != 'active' || !acceptsNewRequests) {
        throw const ConsultationExpertUnavailableException();
      }

      if (_normalize(expertCompanyName) !=
          _normalize(requestCompanyName)) {
        throw const ConsultationRepositoryException(
          'Seçilen uzman ile şirket bilgisi eşleşmiyor.',
        );
      }

      final String previousExpertId =
          requestData['expertId'] as String? ?? '';

      transaction.update(
        requestReference,
        {
          'expertId': normalizedExpertId,
          'status': 'pending',
          'assignmentType': assignmentType,
          'assignedAt': FieldValue.serverTimestamp(),
          'assignedBy': assignedBy.trim(),
          'expiresAt': Timestamp.fromDate(expiresAt),
          'updatedAt': FieldValue.serverTimestamp(),
          'acceptedAt': null,
          'contactedAt': null,
          'completedAt': null,
          'rejectedAt': null,
          'cancelledAt': null,
          'rejectionReason': null,
          'adminQueueReason': null,
          'waitingForAdminAt': null,
          'reassignedFromExpertId': previousExpertId.isNotEmpty
              ? previousExpertId
              : requestData['reassignedFromExpertId'],
        },
      );

      transaction.update(
        contactReference,
        {
          'expertId': normalizedExpertId,
          'expertPhone': null,
          'expertCorporateEmail': null,
          'contactSharedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    });
  }

  Future<ConsultationRequest> getRequestById(
    String requestId,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _requestsCollection.doc(requestId).get();

    if (!document.exists || document.data() == null) {
      throw const ConsultationRequestNotFoundException();
    }

    return ConsultationRequest.fromDocument(document);
  }

  Stream<ConsultationRequest?> watchRequestById(
    String requestId,
  ) {
    return _requestsCollection.doc(requestId).snapshots().map(
      (document) {
        if (!document.exists || document.data() == null) {
          return null;
        }

        return ConsultationRequest.fromDocument(document);
      },
    );
  }

  Stream<List<ConsultationRequest>> watchUserRequests(
    String userId,
  ) {
    return _requestsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConsultationRequest.fromDocument)
              .toList(),
        );
  }

  Stream<List<ConsultationRequest>> watchExpertRequests(
    String expertId,
  ) {
    return _requestsCollection
        .where('expertId', isEqualTo: expertId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConsultationRequest.fromDocument)
              .where(
                (request) => const {
                  'pending',
                  'accepted',
                  'contacted',
                  'completed',
                  'rejected',
                  'expired',
                }.contains(request.status),
              )
              .toList(),
        );
  }

  Stream<List<ConsultationRequest>> watchPendingExpertRequests(
    String expertId,
  ) {
    return _requestsCollection
        .where('expertId', isEqualTo: expertId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConsultationRequest.fromDocument)
              .toList(),
        );
  }

  Stream<List<ConsultationRequest>> watchAllRequests() {
    return _requestsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConsultationRequest.fromDocument)
              .toList(),
        );
  }

  Stream<List<ConsultationRequest>>
      watchWaitingForAdminRequests() {
    return _requestsCollection
        .where(
          'status',
          whereIn: const [
            'waiting_assignment',
            'waiting_for_admin',
          ],
        )
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConsultationRequest.fromDocument)
              .toList(),
        );
  }

  Future<void> acceptRequest({
    required String requestId,
    required String expertId,
  }) async {
    final DocumentReference<Map<String, dynamic>> requestReference =
        _requestsCollection.doc(requestId);


    await _firestore.runTransaction<void>((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get(requestReference);

      if (!snapshot.exists || snapshot.data() == null) {
        throw const ConsultationRequestNotFoundException();
      }

      final Map<String, dynamic> data = snapshot.data()!;

      _validateExpertOwnership(data, expertId);

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
          'acceptedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'rejectedAt': null,
          'rejectionReason': null,
        },
      );
    });
  }

  Future<void> rejectRequest({
    required String requestId,
    required String expertId,
    required String rejectionReason,
  }) async {
    final String normalizedReason = rejectionReason.trim();

    if (normalizedReason.length < 3) {
      throw const ConsultationRepositoryException(
        'Lütfen geçerli bir red nedeni seçiniz.',
      );
    }

    final DocumentReference<Map<String, dynamic>> requestReference =
        _requestsCollection.doc(requestId);


    await _firestore.runTransaction<void>((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get(requestReference);

      if (!snapshot.exists || snapshot.data() == null) {
        throw const ConsultationRequestNotFoundException();
      }

      final Map<String, dynamic> data = snapshot.data()!;

      _validateExpertOwnership(data, expertId);

      if (data['status'] != 'pending') {
        throw const ConsultationRequestAlreadyProcessedException();
      }

      transaction.update(
        requestReference,
        {
          'status': 'waiting_for_admin',
          'rejectedAt': FieldValue.serverTimestamp(),
          'rejectionReason': normalizedReason,
          'waitingForAdminAt': FieldValue.serverTimestamp(),
          'adminQueueReason': 'expert_rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    });
  }

  Future<void> cancelRequest({
    required String requestId,
    required String userId,
  }) async {
    final DocumentReference<Map<String, dynamic>> requestReference =
        _requestsCollection.doc(requestId);

    await _firestore.runTransaction<void>((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get(requestReference);

      if (!snapshot.exists || snapshot.data() == null) {
        throw const ConsultationRequestNotFoundException();
      }

      final Map<String, dynamic> data = snapshot.data()!;

      if (data['userId'] != userId) {
        throw const ConsultationRepositoryException(
          'Bu danışma talebini iptal etme yetkiniz bulunmuyor.',
        );
      }

      final String status = data['status'] as String? ?? '';

      if (!const {
        'waiting_assignment',
        'pending',
        'accepted',
      }.contains(status)) {
        throw const ConsultationRequestAlreadyProcessedException();
      }

      transaction.update(
        requestReference,
        {
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    });
  }

  Future<void> markAsContacted({
    required String requestId,
    required String expertId,
  }) async {
    final DocumentReference<Map<String, dynamic>> requestReference =
        _requestsCollection.doc(requestId);
    final DocumentReference<Map<String, dynamic>> contactReference =
        _requestContactsCollection.doc(requestId);
    final DocumentReference<Map<String, dynamic>> expertReference =
        _expertsCollection.doc(expertId);


    await _firestore.runTransaction<void>((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> requestSnapshot =
          await transaction.get(requestReference);
      final DocumentSnapshot<Map<String, dynamic>> contactSnapshot =
          await transaction.get(contactReference);
      final DocumentSnapshot<Map<String, dynamic>> expertSnapshot =
        await transaction.get(expertReference);

      if (!requestSnapshot.exists ||
          requestSnapshot.data() == null) {
        throw const ConsultationRequestNotFoundException();
      }

      if (!contactSnapshot.exists ||
          contactSnapshot.data() == null) {
        throw const ConsultationRepositoryException(
          'Danışma talebinin iletişim kaydı bulunamadı.',
        );
      }

      if (!expertSnapshot.exists || expertSnapshot.data() == null) {
        throw const ConsultationRepositoryException(
          'Uzman iletişim bilgileri bulunamadı.',
        );
      }

      final Map<String, dynamic> requestData =
          requestSnapshot.data()!;

      final Map<String, dynamic> contactData =
          contactSnapshot.data()!;
      final Map<String, dynamic> expertData =
          expertSnapshot.data()!;

      _validateExpertOwnership(requestData, expertId);

      if (contactData['expertId'] != expertId) {
        throw const ConsultationRepositoryException(
          'Bu danışma talebinin iletişim bilgisi size ait değil.',
        );
      }

      if (requestData['status'] != 'accepted') {
        throw const ConsultationRequestAlreadyProcessedException();
      }

      final String expertPhone =
          (expertData['phone'] as String? ?? '').trim();
      final String expertCorporateEmail =
          (expertData['corporateEmail'] as String? ?? '')
              .trim()
              .toLowerCase();

      if (!_isValidPhone(expertPhone)) {
        throw const ConsultationRepositoryException(
          'Uzman telefon bilgisi geçerli değil.',
        );
      }

      if (!_isValidEmail(expertCorporateEmail)) {
        throw const ConsultationRepositoryException(
          'Uzman kurumsal e-posta bilgisi geçerli değil.',
        );
      }

      transaction.update(
        requestReference,
        {
          'status': 'contacted',
          'contactedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      transaction.update(
        contactReference,
        {
          'expertPhone': expertPhone,
          'expertCorporateEmail': expertCorporateEmail,
          'contactSharedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    });
  }

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
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      decreaseActiveCount: false,
    );
  }

  Stream<ConsultationRequestContact?>
      watchRequestContactForUser({
    required String requestId,
    required String userId,
  }) {
    return _requestContactsCollection
        .doc(requestId)
        .snapshots()
        .map((document) {
      if (!document.exists || document.data() == null) {
        return null;
      }

      final ConsultationRequestContact contact =
          ConsultationRequestContact.fromDocument(document);

      if (contact.userId != userId) {
        throw const ConsultationRepositoryException(
          'Bu iletişim bilgisine erişim yetkiniz yok.',
        );
      }

      return contact;
    });
  }

  Future<String?> getRequestPhone({
    required String requestId,
    required String expertId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> contactSnapshot =
        await _requestContactsCollection.doc(requestId).get();

    if (!contactSnapshot.exists || contactSnapshot.data() == null) {
      return null;
    }

    final Map<String, dynamic> data = contactSnapshot.data()!;

    if (data['expertId'] != expertId) {
      throw const ConsultationRepositoryException(
        'Bu iletişim bilgisine erişim yetkiniz yok.',
      );
    }

    final String phone =
        data['userPhone'] as String? ?? '';

    return phone.trim().isEmpty ? null : phone.trim();
  }

  /// Yönetici talep detayında telefon numarasını güvenli koleksiyondan okur.
  Future<String?> getRequestPhoneForAdmin({
    required String requestId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _requestContactsCollection.doc(requestId).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    final String phone =
        snapshot.data()!['userPhone'] as String? ?? '';

    return phone.trim().isEmpty ? null : phone.trim();
  }

  Future<bool> expireRequestIfNeeded(
    String requestId,
  ) async {
    final DocumentReference<Map<String, dynamic>> requestReference =
        _requestsCollection.doc(requestId);

    return _firestore.runTransaction<bool>((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get(requestReference);

      if (!snapshot.exists || snapshot.data() == null) {
        throw const ConsultationRequestNotFoundException();
      }

      final Map<String, dynamic> data = snapshot.data()!;

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
          'status': 'waiting_for_admin',
          'waitingForAdminAt': FieldValue.serverTimestamp(),
          'adminQueueReason': 'response_expired',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      return true;
    });
  }

  /// Eski ekranlarla geçici uyumluluk için aynı talep belgesini
  /// yeni uzmana geçirir. Yeni belge oluşturulmaz.
  Future<String> reassignRequest({
    required ConsultationRequest previousRequest,
    required String newExpertId,
    String assignedBy = 'admin',
  }) async {
    final String? requestId = previousRequest.requestId;

    if (requestId == null || requestId.trim().isEmpty) {
      throw const ConsultationRequestNotFoundException();
    }

    await assignExpert(
      requestId: requestId,
      expertId: newExpertId,
      assignmentType: 'admin',
      assignedBy: assignedBy,
    );

    return requestId;
  }

  /// Uzman kendi kullanıcı hesabını sildiğinde, o uzmana bağlı açık
  /// danışma taleplerini sahipsiz bırakmaz. Talepler yönetici kuyruğuna
  /// alınır ve daha sonra başka bir uzmana yeniden atanabilir.
  Future<int> handleExpertAccountDeleted({
    required String expertId,
  }) async {
    final String normalizedExpertId = expertId.trim();

    if (normalizedExpertId.isEmpty) {
      return 0;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _requestsCollection
            .where('expertId', isEqualTo: normalizedExpertId)
            .get();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> openRequests =
        snapshot.docs.where((document) {
      final String status =
          document.data()['status'] as String? ?? '';

      return const {
        'pending',
        'accepted',
        'contacted',
      }.contains(status);
    }).toList();

    if (openRequests.isEmpty) {
      return 0;
    }

    const int requestsPerBatch = 200;

    for (int start = 0;
        start < openRequests.length;
        start += requestsPerBatch) {
      final int end =
          (start + requestsPerBatch < openRequests.length)
              ? start + requestsPerBatch
              : openRequests.length;

      final WriteBatch batch = _firestore.batch();

      for (final document in openRequests.sublist(start, end)) {
        final DocumentReference<Map<String, dynamic>> requestReference =
            _requestsCollection.doc(document.id);
        final DocumentReference<Map<String, dynamic>> contactReference =
            _requestContactsCollection.doc(document.id);

        batch.update(
          requestReference,
          {
            'expertId': '',
            'status': 'waiting_for_admin',
            'expiresAt': null,
            'waitingForAdminAt': FieldValue.serverTimestamp(),
            'adminQueueReason': 'expert_account_deleted',
            'reassignedFromExpertId': normalizedExpertId,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        batch.update(
          contactReference,
          {
            'expertId': '',
            'expertPhone': null,
            'expertCorporateEmail': null,
            'contactSharedAt': null,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();
    }

    return openRequests.length;
  }

  Future<void> _updateExpertOwnedStatus({
    required String requestId,
    required String expertId,
    required List<String> requiredCurrentStatuses,
    required Map<String, dynamic> values,
    bool decreaseActiveCount = false,
  }) async {
    final DocumentReference<Map<String, dynamic>> requestReference =
        _requestsCollection.doc(requestId);
    final DocumentReference<Map<String, dynamic>> expertReference =
        _expertProfilesCollection.doc(expertId);

    await _firestore.runTransaction<void>((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get(requestReference);

      if (!snapshot.exists || snapshot.data() == null) {
        throw const ConsultationRequestNotFoundException();
      }

      final Map<String, dynamic> data = snapshot.data()!;

      _validateExpertOwnership(data, expertId);

      final String currentStatus =
          data['status'] as String? ?? '';

      if (!requiredCurrentStatuses.contains(currentStatus)) {
        throw const ConsultationRequestAlreadyProcessedException();
      }

      transaction.update(requestReference, values);

      if (decreaseActiveCount) {
        transaction.update(
          expertReference,
          {
            'activeRequestCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
    });
  }

  void _validateExpertOwnership(
    Map<String, dynamic> data,
    String expertId,
  ) {
    if ((data['expertId'] as String? ?? '') != expertId) {
      throw const ConsultationRepositoryException(
        'Bu danışma talebi size ait değil.',
      );
    }
  }

  bool _isValidPhone(String value) {
    final String digits =
        value.replaceAll(RegExp(r'[^0-9]'), '');

    return digits.length == 10 || digits.length == 11;
  }

  bool _isValidEmail(String value) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(value.trim());
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase();

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
