import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceTokenRepository {
  DeviceTokenRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _collection =>
          _firestore.collection('deviceTokens');

  /// Android, iOS ve Flutter Web ile uyumlu
  /// sabit token document ID üretir.
  String _documentIdForToken(String token) {
    final BigInt offsetBasis =
        BigInt.parse(
      'cbf29ce484222325',
      radix: 16,
    );

    final BigInt prime =
        BigInt.parse(
      '100000001b3',
      radix: 16,
    );

    final BigInt mask =
        BigInt.parse(
      'ffffffffffffffff',
      radix: 16,
    );

    BigInt hash = offsetBasis;

    for (final int byte in token.codeUnits) {
      hash ^= BigInt.from(byte);
      hash = (hash * prime) & mask;
    }

    return hash
        .toRadixString(16)
        .padLeft(16, '0');
  }

  /// FCM tokenını kaydeder veya mevcut
  /// token kaydını günceller.
  ///
  /// Firestore'dan token belgesi okunmaz.
  Future<void> saveToken({
    required String token,
    required String platform,
    String? userUid,
  }) async {
    final String normalizedToken =
        token.trim();

    final String normalizedPlatform =
        platform.trim().toLowerCase();

    final String? normalizedUid =
        userUid == null ||
                userUid.trim().isEmpty
            ? null
            : userUid.trim();

    if (normalizedToken.isEmpty) {
      throw ArgumentError(
        'FCM token boş bırakılamaz.',
      );
    }

    if (!const {
      'android',
      'ios',
    }.contains(normalizedPlatform)) {
      throw ArgumentError(
        'Desteklenmeyen cihaz platformu.',
      );
    }

    final String documentId =
        _documentIdForToken(
      normalizedToken,
    );

    await _collection
        .doc(documentId)
        .set(
      {
        'tokenId': documentId,
        'token': normalizedToken,
        'platform': normalizedPlatform,
        'userUid': normalizedUid,
        'isActive': true,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  /// Mevcut cihaz tokenını giriş yapan
  /// kullanıcı hesabına bağlar.
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

  /// Mevcut cihazın kullanıcı bağlantısını
  /// kaldırır.
  Future<void> detachTokenFromUser({
    required String token,
  }) async {
    final String normalizedToken =
        token.trim();

    if (normalizedToken.isEmpty) {
      return;
    }

    final String documentId =
        _documentIdForToken(
      normalizedToken,
    );

    await _collection
        .doc(documentId)
        .set(
      {
        'userUid': null,
        'isActive': true,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  /// Firebase Messaging yeni token ürettiğinde
  /// eski tokenı pasif hale getirir ve yenisini
  /// kaydeder.
  Future<void> replaceToken({
    required String oldToken,
    required String newToken,
    required String platform,
    String? userUid,
  }) async {
    final String normalizedOld =
        oldToken.trim();

    final String normalizedNew =
        newToken.trim();

    if (normalizedNew.isEmpty) {
      throw ArgumentError(
        'Yeni FCM token boş bırakılamaz.',
      );
    }

    if (normalizedOld.isNotEmpty &&
        normalizedOld != normalizedNew) {
      final String oldDocumentId =
          _documentIdForToken(
        normalizedOld,
      );

      await _collection
          .doc(oldDocumentId)
          .set(
        {
          'userUid': null,
          'isActive': false,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );
    }

    await saveToken(
      token: normalizedNew,
      platform: platform,
      userUid: userUid,
    );
  }
}