import 'package:cloud_firestore/cloud_firestore.dart';

import 'calculation_plan.dart';

class ConsultationRequest {
  const ConsultationRequest({
    this.requestId,
    required this.userId,
    required this.isGuest,
    required this.userFullName,
    required this.userPhone,
    required this.expertId,
    required this.companyName,
    required this.plan,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    this.userNote,
    this.acceptedAt,
    this.contactedAt,
    this.completedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.rejectionReason,
    this.reassignedFromExpertId,
  });

  /// Firestore danışma talebi belge kimliği.
  final String? requestId;

  /// Kayıtlı kullanıcı UID'si veya anonim Firebase UID'si.
  final String userId;

  /// Talebin anonim/misafir kullanıcı tarafından oluşturulup
  /// oluşturulmadığını belirtir.
  final bool isGuest;

  /// Uzmanın talep detayında göreceği kullanıcı adı.
  final String userFullName;

  /// Uzman talebi kabul edene kadar gizli tutulacak telefon.
  final String userPhone;

  /// Talebin gönderildiği uzmanın Firebase UID'si.
  final String expertId;

  /// Seçilen tasarruf finansman şirketi.
  final String companyName;

  /// FP Engine tarafından oluşturulan plan.
  final CalculationPlan plan;

  /// Kullanıcının uzmana iletmek istediği isteğe bağlı not.
  final String? userNote;

  /// pending, accepted, rejected, expired, reassigned,
  /// cancelled, contacted veya completed
  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Uzmanın talebe cevap vermesi gereken son zaman.
  final DateTime expiresAt;

  final DateTime? acceptedAt;
  final DateTime? contactedAt;
  final DateTime? completedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;

  final String? rejectionReason;

  /// Talep başka uzmana yönlendirildiyse önceki uzman UID'si.
  final String? reassignedFromExpertId;

  bool get isPending => status == 'pending';

  bool get isAccepted => status == 'accepted';

  bool get isRejected => status == 'rejected';

  bool get isExpired => status == 'expired';

  bool get isReassigned => status == 'reassigned';

  bool get isCancelled => status == 'cancelled';

  bool get isContacted => status == 'contacted';

  bool get isCompleted => status == 'completed';

  bool get isOpen {
    return isPending || isAccepted || isContacted;
  }

  bool get canExpertRespond {
    return isPending &&
        DateTime.now().isBefore(expiresAt);
  }

  /// Mevcut repository ve Firestore yapısıyla uyumlu
  /// kolay erişim alanları.
  double get financeAmount => plan.financeAmount;

  double get downPayment => plan.downPayment;

  double get monthlyInstallment =>
      plan.monthlyInstallment;

  String get increaseModel => plan.increaseModel;

  int get estimatedDelivery =>
      plan.estimatedDelivery;

  int get estimatedTerm => plan.estimatedTerm;

  ConsultationRequest copyWith({
    String? requestId,
    String? userId,
    bool? isGuest,
    String? userFullName,
    String? userPhone,
    String? expertId,
    String? companyName,
    CalculationPlan? plan,
    String? userNote,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    DateTime? contactedAt,
    DateTime? completedAt,
    DateTime? rejectedAt,
    DateTime? cancelledAt,
    String? rejectionReason,
    String? reassignedFromExpertId,
    bool clearRequestId = false,
    bool clearUserNote = false,
    bool clearAcceptedAt = false,
    bool clearContactedAt = false,
    bool clearCompletedAt = false,
    bool clearRejectedAt = false,
    bool clearCancelledAt = false,
    bool clearRejectionReason = false,
    bool clearReassignedFromExpertId = false,
  }) {
    return ConsultationRequest(
      requestId: clearRequestId
          ? null
          : requestId ?? this.requestId,
      userId: userId ?? this.userId,
      isGuest: isGuest ?? this.isGuest,
      userFullName:
          userFullName ?? this.userFullName,
      userPhone: userPhone ?? this.userPhone,
      expertId: expertId ?? this.expertId,
      companyName:
          companyName ?? this.companyName,
      plan: plan ?? this.plan,
      userNote: clearUserNote
          ? null
          : userNote ?? this.userNote,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: clearAcceptedAt
          ? null
          : acceptedAt ?? this.acceptedAt,
      contactedAt: clearContactedAt
          ? null
          : contactedAt ?? this.contactedAt,
      completedAt: clearCompletedAt
          ? null
          : completedAt ?? this.completedAt,
      rejectedAt: clearRejectedAt
          ? null
          : rejectedAt ?? this.rejectedAt,
      cancelledAt: clearCancelledAt
          ? null
          : cancelledAt ?? this.cancelledAt,
      rejectionReason: clearRejectionReason
          ? null
          : rejectionReason ??
              this.rejectionReason,
      reassignedFromExpertId:
          clearReassignedFromExpertId
              ? null
              : reassignedFromExpertId ??
                  this.reassignedFromExpertId,
    );
  }

  /// Plan alanları Firestore'da düz tutulur.
  /// Böylece sorgular, Rules ve mevcut repository yapısı
  /// sade kalır; uygulama içinde CalculationPlan kullanılır.
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'isGuest': isGuest,
      'userFullName': userFullName.trim(),
      'userPhone': userPhone.trim(),
      'expertId': expertId,
      'companyName': companyName.trim(),
      'financeAmount': plan.financeAmount,
      'downPayment': plan.downPayment,
      'monthlyInstallment':
          plan.monthlyInstallment,
      'increaseModel':
          plan.increaseModel.trim(),
      'estimatedDelivery':
          plan.estimatedDelivery,
      'estimatedTerm': plan.estimatedTerm,
      'userNote': _nullableTrimmed(userNote),
      'status': status,
      'createdAt':
          Timestamp.fromDate(createdAt),
      'updatedAt':
          Timestamp.fromDate(updatedAt),
      'expiresAt':
          Timestamp.fromDate(expiresAt),
      'acceptedAt': acceptedAt == null
          ? null
          : Timestamp.fromDate(acceptedAt!),
      'contactedAt': contactedAt == null
          ? null
          : Timestamp.fromDate(contactedAt!),
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),
      'rejectedAt': rejectedAt == null
          ? null
          : Timestamp.fromDate(rejectedAt!),
      'cancelledAt': cancelledAt == null
          ? null
          : Timestamp.fromDate(cancelledAt!),
      'rejectionReason':
          _nullableTrimmed(rejectionReason),
      'reassignedFromExpertId':
          reassignedFromExpertId,
    };
  }

  factory ConsultationRequest.fromMap(
    Map<String, dynamic> map, {
    String? requestId,
  }) {
    return ConsultationRequest(
      requestId:
          requestId ?? map['requestId'] as String?,
      userId: map['userId'] as String? ?? '',
      isGuest: map['isGuest'] as bool? ?? false,
      userFullName:
          map['userFullName'] as String? ?? '',
      userPhone:
          map['userPhone'] as String? ?? '',
      expertId:
          map['expertId'] as String? ?? '',
      companyName:
          map['companyName'] as String? ?? '',
      plan: CalculationPlan(
        financeAmount:
            _readDouble(map['financeAmount']),
        downPayment:
            _readDouble(map['downPayment']),
        monthlyInstallment:
            _readDouble(
          map['monthlyInstallment'],
        ),
        increaseModel:
            map['increaseModel'] as String? ?? '',
        estimatedDelivery:
            _readInt(map['estimatedDelivery']),
        estimatedTerm:
            _readInt(map['estimatedTerm']),
      ),
      userNote: map['userNote'] as String?,
      status:
          map['status'] as String? ?? 'pending',
      createdAt: _readDate(
        map['createdAt'],
        fallback: DateTime.now(),
      ),
      updatedAt: _readDate(
        map['updatedAt'],
        fallback: DateTime.now(),
      ),
      expiresAt: _readDate(
        map['expiresAt'],
        fallback: DateTime.now(),
      ),
      acceptedAt:
          _readNullableDate(map['acceptedAt']),
      contactedAt:
          _readNullableDate(map['contactedAt']),
      completedAt:
          _readNullableDate(map['completedAt']),
      rejectedAt:
          _readNullableDate(map['rejectedAt']),
      cancelledAt:
          _readNullableDate(map['cancelledAt']),
      rejectionReason:
          map['rejectionReason'] as String?,
      reassignedFromExpertId:
          map['reassignedFromExpertId']
              as String?,
    );
  }

  factory ConsultationRequest.fromDocument(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) {
    final Map<String, dynamic>? data =
        document.data();

    if (data == null) {
      throw StateError(
        'Danışma talebi bulunamadı: ${document.id}',
      );
    }

    return ConsultationRequest.fromMap(
      data,
      requestId: document.id,
    );
  }

  static String? _nullableTrimmed(
    String? value,
  ) {
    final String normalized =
        value?.trim() ?? '';

    return normalized.isEmpty
        ? null
        : normalized;
  }

  static double _readDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  static int _readInt(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    // Eski kayıtlarda estimatedDelivery String olabilir.
    if (value is String) {
      return int.tryParse(
            value.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;
    }

    return 0;
  }

  static DateTime _readDate(
    dynamic value, {
    required DateTime fallback,
  }) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return fallback;
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