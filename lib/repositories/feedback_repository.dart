import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackRepository {
  FeedbackRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _feedbackCollection {
    return _firestore.collection('feedbackRequests');
  }

  /// Kullanıcının yeni şikayet, öneri veya
  /// teknik sorun talebini oluşturur.
  Future<String> createFeedback({
    required String userId,
    required String userEmail,
    required String type,
    required String subject,
    required String message,
  }) async {
    final String normalizedUserId = userId.trim();
    final String normalizedEmail =
        userEmail.trim().toLowerCase();
    final String normalizedType = type.trim();
    final String normalizedSubject = subject.trim();
    final String normalizedMessage = message.trim();

    if (normalizedUserId.isEmpty) {
      throw ArgumentError(
        'Kullanıcı kimliği boş bırakılamaz.',
      );
    }

    if (normalizedSubject.isEmpty) {
      throw ArgumentError(
        'Konu başlığı boş bırakılamaz.',
      );
    }

    if (normalizedMessage.length < 10) {
      throw ArgumentError(
        'Mesaj en az 10 karakter olmalıdır.',
      );
    }

    final DocumentReference<Map<String, dynamic>>
        reference =
        await _feedbackCollection.add({
      'userId': normalizedUserId,
      'userEmail': normalizedEmail,
      'type': normalizedType,
      'subject': normalizedSubject,
      'message': normalizedMessage,
      'status': 'pending',
      'adminReply': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }

  /// Kullanıcının oluşturduğu talepleri izler.
  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchUserFeedback({
    required String userId,
  }) {
    return _feedbackCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .snapshots();
  }

  /// Kullanıcı hesabı silinirken kullanıcıya ait
  /// şikayet, öneri ve teknik destek kayıtlarını
  /// Firestore'dan temizler.
  ///
  /// Kayıtlar feedbackRequests ana koleksiyonunda
  /// tutulduğu için users/{uid} profil belgesinin
  /// silinmesi bu kayıtları otomatik olarak silmez.
  Future<void> deleteAllUserFeedback({
    required String userId,
  }) async {
    final String normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      return;
    }

    const int batchSize = 400;

    while (true) {
      final QuerySnapshot<Map<String, dynamic>>
          snapshot =
          await _feedbackCollection
              .where(
                'userId',
                isEqualTo: normalizedUserId,
              )
              .limit(batchSize)
              .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final WriteBatch batch = _firestore.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();

      if (snapshot.docs.length < batchSize) {
        return;
      }
    }
  }
}