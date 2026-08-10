import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

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

  CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection('users');
  }

  /// Kullanıcı profilini oluşturur.
  Future<void> createUserProfile(AppUser user) async {
    final DocumentReference<Map<String, dynamic>>
        userReference =
        _usersCollection.doc(user.uid);

    await userReference.set({
      ...user.toMap(),
      'uid': user.uid,
      'email': user.email.trim().toLowerCase(),
      'roles': const ['user'],
      'expertStatus': 'none',
      'phone': user.phone?.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser> getUserById(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _usersCollection.doc(uid).get();

    if (!document.exists || document.data() == null) {
      throw const UserNotFoundException();
    }

    return AppUser.fromDocument(document);
  }

  Stream<AppUser?> watchUserById(String uid) {
    return _usersCollection.doc(uid).snapshots().map((document) {
      if (!document.exists || document.data() == null) {
        return null;
      }

      return AppUser.fromDocument(document);
    });
  }

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
      'phone': normalizedPhone == null ||
              normalizedPhone.isEmpty
          ? null
          : normalizedPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

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

  Future<void> markExpertApplicationPending({
    required String uid,
  }) async {
    await _usersCollection.doc(uid).update({
      'expertStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUserProfile({
    required String uid,
  }) async {
    await _usersCollection.doc(uid).delete();
  }
}
