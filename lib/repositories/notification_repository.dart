import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _collection {
    return _firestore.collection(
      'notifications',
    );
  }

  Stream<List<AppNotification>>
      watchUserNotifications(
    String userId,
  ) {
    return _collection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final List<AppNotification>
          notifications = snapshot.docs
              .map(
                AppNotification.fromDocument,
              )
              .toList();

      notifications.sort(
        (first, second) =>
            second.createdAt.compareTo(
          first.createdAt,
        ),
      );

      return notifications;
    });
  }

  Stream<int> watchUnreadCount(
    String userId,
  ) {
    return _collection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .where(
          'status',
          isEqualTo: 'unread',
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.length,
        );
  }

  Future<String> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String targetScreen,
    String? targetId,
    String? actorId,
  }) async {
    final DocumentReference<
        Map<String, dynamic>> reference =
        _collection.doc();

    await reference.set({
      'notificationId': reference.id,
      'userId': userId,
      'title': title.trim(),
      'message': message.trim(),
      'type': type,
      'status': 'unread',
      'targetScreen': targetScreen,
      'targetId': targetId,
      'actorId': actorId,
      'createdAt':
          FieldValue.serverTimestamp(),
      'readAt': null,
    });

    return reference.id;
  }

  Future<void> notify({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String targetScreen,
    String? targetId,
    String? actorId,
  }) async {
    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      targetScreen: targetScreen,
      targetId: targetId,
      actorId: actorId,
    );
  }

  Future<void> markAsRead(
    String notificationId,
  ) async {
    await _collection
        .doc(notificationId)
        .update({
      'status': 'read',
      'readAt':
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllAsRead(
    String userId,
  ) async {
    final QuerySnapshot<
        Map<String, dynamic>> snapshot =
        await _collection
            .where(
              'userId',
              isEqualTo: userId,
            )
            .where(
              'status',
              isEqualTo: 'unread',
            )
            .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final WriteBatch batch =
        _firestore.batch();

    for (final QueryDocumentSnapshot<
        Map<String, dynamic>>
        document in snapshot.docs) {
      batch.update(
        document.reference,
        {
          'status': 'read',
          'readAt':
              FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }
}
