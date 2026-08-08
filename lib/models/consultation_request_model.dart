import 'package:cloud_firestore/cloud_firestore.dart';

import 'calculation_plan.dart';

class ConsultationRequest {
  const ConsultationRequest({
    this.requestId,
    required this.userId,
    required this.isGuest,
    required this.userFullName,
    required this.companyName,
    required this.plan,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.expertId = '',
    this.userNote,
    this.assignmentType,
    this.assignedAt,
    this.assignedBy,
    this.expiresAt,
    this.acceptedAt,
    this.contactedAt,
    this.completedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.rejectionReason,
    this.adminQueueReason,
    this.waitingForAdminAt,
    this.reassignedFromExpertId,
  });

  final String? requestId;
  final String userId;
  final bool isGuest;
  final String userFullName;
  final String companyName;
  final CalculationPlan plan;
  final String? userNote;

  /// waiting_assignment, pending, accepted, contacted,
  /// completed, rejected, expired veya cancelled.
  final String status;

  /// Atanan uzmanın Firebase UID'si.
  /// Atama yapılmadan önce boş string olarak tutulur.
  final String expertId;

  /// auto veya admin.
  final String? assignmentType;
  final DateTime? assignedAt;
  final String? assignedBy;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Uzman atandıktan sonra cevap süresinin bittiği zaman.
  final DateTime? expiresAt;

  final DateTime? acceptedAt;
  final DateTime? contactedAt;
  final DateTime? completedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;

  final String? rejectionReason;
  final String? adminQueueReason;
  final DateTime? waitingForAdminAt;
  final String? reassignedFromExpertId;

  bool get isWaitingAssignment =>
      status == 'waiting_assignment';

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';
  bool get isContacted => status == 'contacted';
  bool get isCompleted => status == 'completed';

  bool get hasAssignedExpert => expertId.trim().isNotEmpty;

  bool get isOpen {
    return isWaitingAssignment ||
        isPending ||
        isAccepted ||
        isContacted;
  }

  bool get canExpertRespond {
    if (!isPending || expiresAt == null) {
      return false;
    }

    return DateTime.now().isBefore(expiresAt!);
  }

  double get financeAmount => plan.financeAmount;
  double get downPayment => plan.downPayment;
  double get monthlyInstallment => plan.monthlyInstallment;
  String get increaseModel => plan.increaseModel;
  int get estimatedDelivery => plan.estimatedDelivery;
  int get estimatedTerm => plan.estimatedTerm;

  ConsultationRequest copyWith({
    String? requestId,
    String? userId,
    bool? isGuest,
    String? userFullName,
    String? companyName,
    CalculationPlan? plan,
    String? userNote,
    String? status,
    String? expertId,
    String? assignmentType,
    DateTime? assignedAt,
    String? assignedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    DateTime? contactedAt,
    DateTime? completedAt,
    DateTime? rejectedAt,
    DateTime? cancelledAt,
    String? rejectionReason,
    String? adminQueueReason,
    DateTime? waitingForAdminAt,
    String? reassignedFromExpertId,
    bool clearRequestId = false,
    bool clearUserNote = false,
    bool clearExpertId = false,
    bool clearAssignmentType = false,
    bool clearAssignedAt = false,
    bool clearAssignedBy = false,
    bool clearExpiresAt = false,
    bool clearAcceptedAt = false,
    bool clearContactedAt = false,
    bool clearCompletedAt = false,
    bool clearRejectedAt = false,
    bool clearCancelledAt = false,
    bool clearRejectionReason = false,
    bool clearAdminQueueReason = false,
    bool clearWaitingForAdminAt = false,
    bool clearReassignedFromExpertId = false,
  }) {
    return ConsultationRequest(
      requestId:
          clearRequestId ? null : requestId ?? this.requestId,
      userId: userId ?? this.userId,
      isGuest: isGuest ?? this.isGuest,
      userFullName: userFullName ?? this.userFullName,
      companyName: companyName ?? this.companyName,
      plan: plan ?? this.plan,
      userNote: clearUserNote ? null : userNote ?? this.userNote,
      status: status ?? this.status,
      expertId: clearExpertId ? '' : expertId ?? this.expertId,
      assignmentType: clearAssignmentType
          ? null
          : assignmentType ?? this.assignmentType,
      assignedAt:
          clearAssignedAt ? null : assignedAt ?? this.assignedAt,
      assignedBy:
          clearAssignedBy ? null : assignedBy ?? this.assignedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt:
          clearExpiresAt ? null : expiresAt ?? this.expiresAt,
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
      adminQueueReason: clearAdminQueueReason
          ? null
          : adminQueueReason ?? this.adminQueueReason,
      waitingForAdminAt: clearWaitingForAdminAt
          ? null
          : waitingForAdminAt ?? this.waitingForAdminAt,
      reassignedFromExpertId: clearReassignedFromExpertId
          ? null
          : reassignedFromExpertId ?? this.reassignedFromExpertId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'isGuest': isGuest,
      'userFullName': userFullName.trim(),
      'companyName': companyName.trim(),
      'financeAmount': plan.financeAmount,
      'downPayment': plan.downPayment,
      'monthlyInstallment': plan.monthlyInstallment,
      'increaseModel': plan.increaseModel.trim(),
      'estimatedDelivery': plan.estimatedDelivery,
      'estimatedTerm': plan.estimatedTerm,
      'userNote': _nullableTrimmed(userNote),
      'status': status,
      'expertId': expertId.trim(),
      'assignmentType': _nullableTrimmed(assignmentType),
      'assignedAt': _timestampOrNull(assignedAt),
      'assignedBy': _nullableTrimmed(assignedBy),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'expiresAt': _timestampOrNull(expiresAt),
      'acceptedAt': _timestampOrNull(acceptedAt),
      'contactedAt': _timestampOrNull(contactedAt),
      'completedAt': _timestampOrNull(completedAt),
      'rejectedAt': _timestampOrNull(rejectedAt),
      'cancelledAt': _timestampOrNull(cancelledAt),
      'rejectionReason': _nullableTrimmed(rejectionReason),
      'adminQueueReason': _nullableTrimmed(adminQueueReason),
      'waitingForAdminAt': _timestampOrNull(waitingForAdminAt),
      'reassignedFromExpertId':
          _nullableTrimmed(reassignedFromExpertId),
    };
  }

  factory ConsultationRequest.fromMap(
    Map<String, dynamic> map, {
    String? requestId,
  }) {
    return ConsultationRequest(
      requestId: requestId ?? map['requestId'] as String?,
      userId: map['userId'] as String? ?? '',
      isGuest: map['isGuest'] as bool? ?? false,
      userFullName: map['userFullName'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      plan: CalculationPlan(
        financeAmount: _readDouble(map['financeAmount']),
        downPayment: _readDouble(map['downPayment']),
        monthlyInstallment:
            _readDouble(map['monthlyInstallment']),
        increaseModel: map['increaseModel'] as String? ?? '',
        estimatedDelivery:
            _readInt(map['estimatedDelivery']),
        estimatedTerm: _readInt(map['estimatedTerm']),
      ),
      userNote: map['userNote'] as String?,
      status: map['status'] as String? ?? 'waiting_assignment',
      expertId: map['expertId'] as String? ?? '',
      assignmentType: map['assignmentType'] as String?,
      assignedAt: _readNullableDate(map['assignedAt']),
      assignedBy: map['assignedBy'] as String?,
      createdAt: _readDate(
        map['createdAt'],
        fallback: DateTime.now(),
      ),
      updatedAt: _readDate(
        map['updatedAt'],
        fallback: DateTime.now(),
      ),
      expiresAt: _readNullableDate(map['expiresAt']),
      acceptedAt: _readNullableDate(map['acceptedAt']),
      contactedAt: _readNullableDate(map['contactedAt']),
      completedAt: _readNullableDate(map['completedAt']),
      rejectedAt: _readNullableDate(map['rejectedAt']),
      cancelledAt: _readNullableDate(map['cancelledAt']),
      rejectionReason: map['rejectionReason'] as String?,
      adminQueueReason: map['adminQueueReason'] as String?,
      waitingForAdminAt:
          _readNullableDate(map['waitingForAdminAt']),
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

  static String? _nullableTrimmed(String? value) {
    final String normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static Timestamp? _timestampOrNull(DateTime? value) {
    return value == null ? null : Timestamp.fromDate(value);
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  static int _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

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
