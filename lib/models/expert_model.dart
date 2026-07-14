import 'package:cloud_firestore/cloud_firestore.dart';

class Expert {
  const Expert({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.branch,
    required this.position,
    required this.corporateEmail,
    required this.phone,
    required this.status,
    required this.verificationStatus,
    required this.acceptsNewRequests,
    required this.createdAt,
    required this.updatedAt,
    this.lastVerifiedAt,
    this.suspendedAt,
    this.suspensionReason,
  });

  final String uid;

  final String firstName;
  final String lastName;

  final String companyName;
  final String branch;
  final String position;
  final String corporateEmail;
  final String phone;

  /// active, suspended veya inactive
  final String status;

  /// approved, pendingUpdate veya rejected
  final String verificationStatus;

  /// Uzmanın yeni danışma talebi kabul edip etmediğini belirtir.
  final bool acceptsNewRequests;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Uzman bilgilerinin yönetici tarafından en son onaylandığı zaman.
  final DateTime? lastVerifiedAt;

  /// Profilin geçici olarak pasife alındığı zaman.
  final DateTime? suspendedAt;

  /// Profilin neden pasife alındığına dair sistem veya yönetici açıklaması.
  final String? suspensionReason;

  String get fullName => '$firstName $lastName'.trim();

  bool get isActive {
    return status == 'active' &&
        verificationStatus == 'approved';
  }

  bool get isSuspended => status == 'suspended';

  bool get hasPendingUpdate {
    return verificationStatus == 'pendingUpdate';
  }

  bool get canReceiveNewRequests {
    return isActive && acceptsNewRequests;
  }

  Expert copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? companyName,
    String? branch,
    String? position,
    String? corporateEmail,
    String? phone,
    String? status,
    String? verificationStatus,
    bool? acceptsNewRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastVerifiedAt,
    DateTime? suspendedAt,
    String? suspensionReason,
    bool clearSuspendedAt = false,
    bool clearSuspensionReason = false,
  }) {
    return Expert(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      branch: branch ?? this.branch,
      position: position ?? this.position,
      corporateEmail: corporateEmail ?? this.corporateEmail,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      verificationStatus:
          verificationStatus ?? this.verificationStatus,
      acceptsNewRequests:
          acceptsNewRequests ?? this.acceptsNewRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      suspendedAt: clearSuspendedAt
          ? null
          : suspendedAt ?? this.suspendedAt,
      suspensionReason: clearSuspensionReason
          ? null
          : suspensionReason ?? this.suspensionReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'companyName': companyName.trim(),
      'branch': branch.trim(),
      'position': position.trim(),
      'corporateEmail':
          corporateEmail.trim().toLowerCase(),
      'phone': phone.trim(),
      'status': status,
      'verificationStatus': verificationStatus,
      'acceptsNewRequests': acceptsNewRequests,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastVerifiedAt': lastVerifiedAt == null
          ? null
          : Timestamp.fromDate(lastVerifiedAt!),
      'suspendedAt': suspendedAt == null
          ? null
          : Timestamp.fromDate(suspendedAt!),
      'suspensionReason': suspensionReason?.trim(),
    };
  }

  factory Expert.fromMap(
    Map<String, dynamic> map,
  ) {
    return Expert(
      uid: map['uid'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      branch: map['branch'] as String? ?? '',
      position: map['position'] as String? ?? '',
      corporateEmail:
          map['corporateEmail'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      status: map['status'] as String? ?? 'inactive',
      verificationStatus:
          map['verificationStatus'] as String? ??
              'rejected',
      acceptsNewRequests:
          map['acceptsNewRequests'] as bool? ?? false,
      createdAt: _readDate(
        map['createdAt'],
        fallback: DateTime.now(),
      ),
      updatedAt: _readDate(
        map['updatedAt'],
        fallback: DateTime.now(),
      ),
      lastVerifiedAt: _readNullableDate(
        map['lastVerifiedAt'],
      ),
      suspendedAt: _readNullableDate(
        map['suspendedAt'],
      ),
      suspensionReason:
          map['suspensionReason'] as String?,
    );
  }

  factory Expert.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic>? data = document.data();

    if (data == null) {
      throw StateError(
        'Uzman profili bulunamadı: ${document.id}',
      );
    }

    return Expert.fromMap({
      ...data,
      'uid': document.id,
    });
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