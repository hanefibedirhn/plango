import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertProfile {
  const ExpertProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.branch,
    required this.position,
    required this.status,
    required this.acceptsNewRequests,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Uzmanın Firebase kullanıcı kimliği.
  final String uid;

  final String firstName;
  final String lastName;

  final String companyName;
  final String branch;
  final String position;

  /// active, suspended veya inactive
  final String status;

  /// Uzmanın şu anda yeni danışma talebi alıp almadığı.
  final bool acceptsNewRequests;

  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName {
    return '$firstName $lastName'.trim();
  }

  /// Yalnızca aktif uzman profilleri kullanıcı listesinde gösterilir.
  bool get isVisible {
    return status == 'active';
  }

  /// Talep gönderme butonunun aktif olup olmayacağını belirler.
  bool get canReceiveRequests {
    return isVisible && acceptsNewRequests;
  }

  ExpertProfile copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? companyName,
    String? branch,
    String? position,
    String? status,
    bool? acceptsNewRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpertProfile(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      branch: branch ?? this.branch,
      position: position ?? this.position,
      status: status ?? this.status,
      acceptsNewRequests:
          acceptsNewRequests ?? this.acceptsNewRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      'status': status,
      'acceptsNewRequests': acceptsNewRequests,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ExpertProfile.fromMap(
    Map<String, dynamic> map,
  ) {
    return ExpertProfile(
      uid: map['uid'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      branch: map['branch'] as String? ?? '',
      position: map['position'] as String? ?? '',
      status: map['status'] as String? ?? 'inactive',
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
    );
  }

  factory ExpertProfile.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic>? data = document.data();

    if (data == null) {
      throw StateError(
        'Uzman profili bulunamadı: ${document.id}',
      );
    }

    return ExpertProfile.fromMap({
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
}