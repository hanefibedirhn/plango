import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.targetScreen,
    required this.createdAt,
    this.targetId,
    this.actorId,
    this.readAt,
  });

  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String status;
  final String targetScreen;
  final DateTime createdAt;
  final String? targetId;
  final String? actorId;
  final DateTime? readAt;

  bool get isRead => status == 'read';

  factory AppNotification.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? readNullableDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return AppNotification(
      notificationId:
          data['notificationId'] as String? ?? document.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'system',
      status: data['status'] as String? ?? 'unread',
      targetScreen: data['targetScreen'] as String? ?? 'none',
      targetId: data['targetId'] as String?,
      actorId: data['actorId'] as String?,
      createdAt: readDate(data['createdAt']),
      readAt: readNullableDate(data['readAt']),
    );
  }
}
