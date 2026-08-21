import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceTokenRepository {
  DeviceTokenRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('deviceTokens');

  String _documentIdForToken(String token) {
    int hash = 0xcbf29ce484222325;
    for (final int byte in token.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  Future<void> saveToken({
    required String token,
    required String platform,
    String? userUid,
  }) async {
    final String normalizedToken = token.trim();
    final String normalizedPlatform = platform.trim().toLowerCase();
    final String? normalizedUid =
        (userUid == null || userUid.trim().isEmpty) ? null : userUid.trim();

    if (normalizedToken.isEmpty) {
      throw ArgumentError('FCM token boş bırakılamaz.');
    }
    if (!const {'android', 'ios'}.contains(normalizedPlatform)) {
      throw ArgumentError('Desteklenmeyen cihaz platformu.');
    }

    final String documentId = _documentIdForToken(normalizedToken);
    final reference = _collection.doc(documentId);
    final snapshot = await reference.get();

    final Map<String, dynamic> data = {
      'tokenId': documentId,
      'token': normalizedToken,
      'platform': normalizedPlatform,
      'userUid': normalizedUid,
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await reference.set(data, SetOptions(merge: true));
  }

  Future<void> attachTokenToUser({
    required String token,
    required String userUid,
    required String platform,
  }) {
    return saveToken(
      token: token,
      platform: platform,
      userUid: userUid,
    );
  }

  Future<void> detachTokenFromUser({required String token}) async {
    final String normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;

    await _collection.doc(_documentIdForToken(normalizedToken)).set({
      'userUid': null,
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> replaceToken({
    required String oldToken,
    required String newToken,
    required String platform,
    String? userUid,
  }) async {
    final String normalizedOld = oldToken.trim();
    final String normalizedNew = newToken.trim();

    if (normalizedNew.isEmpty) {
      throw ArgumentError('Yeni FCM token boş bırakılamaz.');
    }

    if (normalizedOld.isNotEmpty && normalizedOld != normalizedNew) {
      await _collection.doc(_documentIdForToken(normalizedOld)).set({
        'isActive': false,
        'userUid': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await saveToken(
      token: normalizedNew,
      platform: platform,
      userUid: userUid,
    );
  }

  Future<void> detachAllTokensForUser(String userUid) async {
    final String normalizedUid = userUid.trim();
    if (normalizedUid.isEmpty) return;

    final snapshot =
        await _collection.where('userUid', isEqualTo: normalizedUid).get();

    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (final document in snapshot.docs) {
      batch.set(document.reference, {
        'userUid': null,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      count++;
      if (count == 400) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }

    if (count > 0) await batch.commit();
  }
}
