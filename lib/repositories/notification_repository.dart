import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';
import 'notification_seen_store.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFirestore? firestore,
    NotificationSeenStore? seenStore,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _seenStore =
            seenStore ?? NotificationSeenStore();

  final FirebaseFirestore _firestore;
  final NotificationSeenStore _seenStore;

  CollectionReference<Map<String, dynamic>>
      get _collection {
    return _firestore.collection('notifications');
  }

  Stream<List<AppNotification>> watchGlobalNotifications({
    int limit = 100,
  }) {
    return _collection
        .where('audience', isEqualTo: 'all')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map(AppNotification.fromDocument)
          .toList();

      notifications.sort(
        (first, second) =>
            second.createdAt.compareTo(first.createdAt),
      );

      return notifications;
    });
  }

  Stream<List<AppNotification>> watchUserNotifications(
    String userId,
  ) {
    return watchGlobalNotifications();
  }

  /// Global bildirimlerde cihazın son görülme zamanından
  /// sonra oluşturulan bildirimleri sayar.
  /// userId sadece eski çağrılarla uyumluluk için tutulur.
  Stream<int> watchUnreadCount([
    String? userId,
  ]) {
    return watchGlobalNotifications().asyncMap(
      (notifications) async {
        final DateTime? lastSeenAt =
            await _seenStore.getLastSeenAt();

        if (lastSeenAt == null) {
          return notifications.length;
        }

        return notifications
            .where(
              (notification) =>
                  notification.createdAt.isAfter(lastSeenAt),
            )
            .length;
      },
    );
  }

  Future<void> markGlobalNotificationsSeen() async {
    await _seenStore.markSeenNow();
  }

  Future<String> createGlobalNotification({
    required String title,
    required String message,
    required String type,
    required String targetScreen,
    String? targetId,
  }) async {
    final reference = _collection.doc();

    await reference.set({
      'notificationId': reference.id,
      'audience': 'all',
      'title': title.trim(),
      'message': message.trim(),
      'type': type,
      'targetScreen': targetScreen,
      'targetId': targetId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }

  /// LEGACY: Mevcut kişisel bildirim çağrılarını kırmamak için korunur.
  /// Bu belgeler global Bildirim Merkezi akışında gösterilmez.
  Future<String> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String targetScreen,
    String? targetId,
    String? actorId,
  }) async {
    final reference = _collection.doc();

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
      'createdAt': FieldValue.serverTimestamp(),
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
  ) async {}

  Future<void> markAllAsRead(
    String userId,
  ) async {}
}
