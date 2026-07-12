import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UsernameAlreadyInUseException implements Exception {
  const UsernameAlreadyInUseException();

  @override
  String toString() {
    return 'Bu kullanıcı adı daha önce alınmış.';
  }
}

class UserNotFoundException implements Exception {
  const UserNotFoundException();

  @override
  String toString() {
    return 'Kullanıcı profili bulunamadı.';
  }
}

class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }

  CollectionReference<Map<String, dynamic>> get _usernamesCollection {
    return _firestore.collection('usernames');
  }

  String normalizeUsername(String username) {
    return username.trim().toLowerCase();
  }

  /// Kullanıcı profilini ve kullanıcı adı rezervasyonunu
  /// tek bir transaction içinde oluşturur.
  ///
  /// Böylece aynı kullanıcı adını iki kişinin aynı anda
  /// alması engellenir.
Future<void> createUserProfile(AppUser user) async {
  final String normalizedUsername = normalizeUsername(
    user.usernameLowercase,
  );

  final DocumentReference<Map<String, dynamic>> userReference =
      _usersCollection.doc(user.uid);

  final DocumentReference<Map<String, dynamic>> usernameReference =
      _usernamesCollection.doc(normalizedUsername);

  final WriteBatch batch = _firestore.batch();

  batch.set(
    usernameReference,
    {
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    },
  );

  batch.set(
    userReference,
    {
      ...user.toMap(),
      'uid': user.uid,
      'username': user.username.trim(),
      'usernameLowercase': normalizedUsername,
      'email': user.email.trim().toLowerCase(),
      'roles': const ['user'],
      'expertStatus': 'none',
      'phone': user.phone?.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  );

  try {
    await batch.commit();
  } on FirebaseException catch (error) {
    if (error.code == 'permission-denied' ||
        error.code == 'already-exists') {
      throw const UsernameAlreadyInUseException();
    }

    rethrow;
  }
}

  /// Kullanıcının profilini UID üzerinden getirir.
  Future<AppUser> getUserById(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _usersCollection.doc(uid).get();

    if (!document.exists || document.data() == null) {
      throw const UserNotFoundException();
    }

    return AppUser.fromDocument(document);
  }

  /// Kullanıcının profilini gerçek zamanlı olarak takip eder.
  Stream<AppUser?> watchUserById(String uid) {
    return _usersCollection.doc(uid).snapshots().map((document) {
      if (!document.exists || document.data() == null) {
        return null;
      }

      return AppUser.fromDocument(document);
    });
  }

  /// Profil ekranından değiştirilebilen alanları günceller.
  ///
  /// Kullanıcı adı ve e-posta burada değiştirilmez.
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String surname,
    String? phone,
  }) async {
    final String normalizedName = name.trim();
    final String normalizedSurname = surname.trim();
    final String? normalizedPhone = phone?.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError(
        'Ad alanı boş bırakılamaz.',
      );
    }

    if (normalizedSurname.isEmpty) {
      throw ArgumentError(
        'Soyad alanı boş bırakılamaz.',
      );
    }

    await _usersCollection.doc(uid).update({
      'name': normalizedName,
      'surname': normalizedSurname,
      'phone': normalizedPhone == null || normalizedPhone.isEmpty
          ? null
          : normalizedPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Danışma talebi sırasında alınan telefon numarasını
  /// kullanıcının profiline kaydeder.
  Future<void> savePhoneNumber({
    required String uid,
    required String phone,
  }) async {
    final String normalizedPhone = phone.trim();

    if (normalizedPhone.isEmpty) {
      throw ArgumentError(
        'Telefon numarası boş bırakılamaz.',
      );
    }

    await _usersCollection.doc(uid).update({
      'phone': normalizedPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Uzman başvurusu yapıldığında kullanıcı profilindeki
  /// uzmanlık durumunu beklemede olarak günceller.
  Future<void> markExpertApplicationPending({
    required String uid,
  }) async {
    await _usersCollection.doc(uid).update({
      'expertStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kullanıcının Firestore profilini ve kullanıcı adı
  /// rezervasyonunu siler.
  ///
  /// Firebase Authentication hesabının silinmesi
  /// AuthService içinde ayrıca yapılacaktır.
  Future<void> deleteUserProfile({
    required String uid,
    required String username,
  }) async {
    final String normalizedUsername = normalizeUsername(username);

    final WriteBatch batch = _firestore.batch();

    batch.delete(
      _usersCollection.doc(uid),
    );

    batch.delete(
      _usernamesCollection.doc(normalizedUsername),
    );

    await batch.commit();
  }
}