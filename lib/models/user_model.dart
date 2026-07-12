import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.username,
    required this.usernameLowercase,
    required this.roles,
    required this.expertStatus,
    required this.createdAt,
    this.phone,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String surname;
  final String email;
  final String username;

  /// Kullanıcı adıyla arama ve giriş işlemlerinde kullanılır.
  /// Örneğin "Hanefi_34" değeri "hanefi_34" olarak saklanır.
  final String usernameLowercase;

  /// Aynı hesap birden fazla yetkiye sahip olabilir.
  /// Örnek: ['user', 'expert', 'admin']
  final List<String> roles;

  /// none, pending, approved veya rejected
  final String expertStatus;

  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isUser => roles.contains('user');

  bool get isExpert =>
      roles.contains('expert') && expertStatus == 'approved';

  bool get isAdmin => roles.contains('admin');

  String get fullName => '$name $surname'.trim();

  AppUser copyWith({
    String? uid,
    String? name,
    String? surname,
    String? email,
    String? username,
    String? usernameLowercase,
    List<String>? roles,
    String? expertStatus,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearPhone = false,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      username: username ?? this.username,
      usernameLowercase:
          usernameLowercase ?? this.usernameLowercase,
      roles: roles ?? this.roles,
      expertStatus: expertStatus ?? this.expertStatus,
      phone: clearPhone ? null : phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name.trim(),
      'surname': surname.trim(),
      'email': email.trim().toLowerCase(),
      'username': username.trim(),
      'usernameLowercase': usernameLowercase.trim().toLowerCase(),
      'roles': roles,
      'expertStatus': expertStatus,
      'phone': phone?.trim(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null
          ? null
          : Timestamp.fromDate(updatedAt!),
    };
  }

  factory AppUser.fromMap(
    Map<String, dynamic> map,
  ) {
    final dynamic createdAtValue = map['createdAt'];
    final dynamic updatedAtValue = map['updatedAt'];

    return AppUser(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      surname: map['surname'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      usernameLowercase:
          map['usernameLowercase'] as String? ??
              (map['username'] as String? ?? '').toLowerCase(),
      roles: List<String>.from(
        map['roles'] as List<dynamic>? ?? const ['user'],
      ),
      expertStatus:
          map['expertStatus'] as String? ?? 'none',
      phone: map['phone'] as String?,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      updatedAt: updatedAtValue is Timestamp
          ? updatedAtValue.toDate()
          : null,
    );
  }

  factory AppUser.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Kullanıcı belgesi bulunamadı: ${document.id}',
      );
    }

    return AppUser.fromMap({
      ...data,
      'uid': document.id,
    });
  }
}