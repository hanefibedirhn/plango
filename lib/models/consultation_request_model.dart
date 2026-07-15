import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationRequest {
  const ConsultationRequest({
    this.requestId,
    required this.userId,
    required this.expertId,
    required this.userFullName,
    required this.companyName,
    required this.financeAmount,
    required this.downPayment,
    required this.monthlyInstallment,
    required this.increaseModel,
    required this.estimatedDelivery,
    required this.estimatedTerm,
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

  /// Firestore tarafından otomatik oluşturulan talep kimliği.
  final String? requestId;

  /// Talebi oluşturan kullanıcının Firebase UID değeri.
  final String userId;

  /// Talebin yönlendirildiği uzmanın Firebase UID değeri.
  final String expertId;

  /// Uzmanın talep listesinde gösterilecek kullanıcı adı.
  final String userFullName;

  /// Talebin gönderildiği tasarruf finansman şirketi.
  final String companyName;

  /// Kullanıcının gönderdiği FP Engine plan özeti.
  final double financeAmount;
  final double downPayment;
  final double monthlyInstallment;
  final String increaseModel;
  final String estimatedDelivery;
  final int estimatedTerm;

  /// Kullanıcının uzmana iletmek istediği isteğe bağlı not.
  final String? userNote;

  /// pending, accepted, rejected, expired, reassigned,
  /// cancelled, contacted veya completed
  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Uzmanın cevap vermesi gereken son zaman.
  final DateTime expiresAt;

  final DateTime? acceptedAt;
  final DateTime? contactedAt;
  final DateTime? completedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;

  final String? rejectionReason;

  /// Talep başka uzmana yönlendirildiyse önceki uzman UID değeri.
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
    return status == 'pending' ||
        status == 'accepted' ||
        status == 'contacted';
  }

  bool get canExpertRespond {
    return isPending && DateTime.now().isBefore(expiresAt);
  }

  ConsultationRequest copyWith({
    String? requestId,
    String? userId,
    String? expertId,
    String? userFullName,
    String? companyName,
    double? financeAmount,
    double? downPayment,
    double? monthlyInstallment,
    String? increaseModel,
    String? estimatedDelivery,
    int? estimatedTerm,
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
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      expertId: expertId ?? this.expertId,
      userFullName: userFullName ?? this.userFullName,
      companyName: companyName ?? this.companyName,
      financeAmount: financeAmount ?? this.financeAmount,
      downPayment: downPayment ?? this.downPayment,
      monthlyInstallment:
          monthlyInstallment ?? this.monthlyInstallment,
      increaseModel: increaseModel ?? this.increaseModel,
      estimatedDelivery:
          estimatedDelivery ?? this.estimatedDelivery,
      estimatedTerm: estimatedTerm ?? this.estimatedTerm,
      userNote: clearUserNote ? null : userNote ?? this.userNote,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt:
          clearAcceptedAt ? null : acceptedAt ?? this.acceptedAt,
      contactedAt:
          clearContactedAt ? null : contactedAt ?? this.contactedAt,
      completedAt:
          clearCompletedAt ? null : completedAt ?? this.completedAt,
      rejectedAt:
          clearRejectedAt ? null : rejectedAt ?? this.rejectedAt,
      cancelledAt:
          clearCancelledAt ? null : cancelledAt ?? this.cancelledAt,
      rejectionReason: clearRejectionReason
          ? null
          : rejectionReason ?? this.rejectionReason,
      reassignedFromExpertId: clearReassignedFromExpertId
          ? null
          : reassignedFromExpertId ?? this.reassignedFromExpertId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'expertId': expertId,
      'userFullName': userFullName.trim(),
      'companyName': companyName.trim(),
      'financeAmount': financeAmount,
      'downPayment': downPayment,
      'monthlyInstallment': monthlyInstallment,
      'increaseModel': increaseModel.trim(),
      'estimatedDelivery': estimatedDelivery.trim(),
      'estimatedTerm': estimatedTerm,
      'userNote': userNote?.trim(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
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
      'rejectionReason': rejectionReason?.trim(),
      'reassignedFromExpertId': reassignedFromExpertId,
    };
  }

  factory ConsultationRequest.fromMap(
    Map<String, dynamic> map, {
    String? requestId,
  }) {
    return ConsultationRequest(
      requestId: requestId ?? map['requestId'] as String?,
      userId: map['userId'] as String? ?? '',
      expertId: map['expertId'] as String? ?? '',
      userFullName: map['userFullName'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      financeAmount: _readDouble(map['financeAmount']),
      downPayment: _readDouble(map['downPayment']),
      monthlyInstallment: _readDouble(map['monthlyInstallment']),
      increaseModel: map['increaseModel'] as String? ?? '',
      estimatedDelivery: map['estimatedDelivery'] as String? ?? '',
      estimatedTerm: _readInt(map['estimatedTerm']),
      userNote: map['userNote'] as String?,
      status: map['status'] as String? ?? 'pending',
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
      acceptedAt: _readNullableDate(map['acceptedAt']),
      contactedAt: _readNullableDate(map['contactedAt']),
      completedAt: _readNullableDate(map['completedAt']),
      rejectedAt: _readNullableDate(map['rejectedAt']),
      cancelledAt: _readNullableDate(map['cancelledAt']),
      rejectionReason: map['rejectionReason'] as String?,
      reassignedFromExpertId:
          map['reassignedFromExpertId'] as String?,
    );
  }

  factory ConsultationRequest.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic>? data = document.data();

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

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  static int _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
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