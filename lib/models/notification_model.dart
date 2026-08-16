import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.targetScreen,
    required this.createdAt,
    this.targetId,
    this.audience = 'all',
  });

  final String notificationId;
  final String title;
  final String message;
  final String type;
  final String targetScreen;
  final DateTime createdAt;
  final String? targetId;
  final String audience;

  // Eski ekran/widget kodlarıyla uyumluluk için.
  // Genel bildirimlerde Firestore üzerinde kullanıcı bazlı read tutulmaz.
  bool get isRead => false;

  factory AppNotification.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return AppNotification(
      notificationId:
          data['notificationId'] as String? ?? document.id,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'announcement',
      targetScreen: data['targetScreen'] as String? ?? 'none',
      targetId: data['targetId'] as String?,
      createdAt: readDate(data['createdAt']),
      audience: data['audience'] as String? ?? '',
    );
  }
}
