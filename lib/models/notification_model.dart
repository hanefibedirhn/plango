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
    this.recipientUid,
    this.actorId,
    this.status = 'unread',
    this.readAt,
  });

  final String notificationId;
  final String title;
  final String message;
  final String type;
  final String targetScreen;
  final DateTime createdAt;
  final String? targetId;
  final String audience;

  /// Kişisel uzman/kullanıcı bildirimlerinde alıcı UID'si.
  /// Global ve admin bildirimlerinde null olabilir.
  final String? recipientUid;

  /// Bildirimi oluşturan kullanıcı/uzman varsa UID'si.
  final String? actorId;

  /// Kişisel ve admin bildirimlerinde unread/read olarak tutulur.
  /// Global bildirimlerin okunma durumu NotificationSeenStore tarafından
  /// cihaz bazlı yönetildiği için bu alan global akışta kullanılmaz.
  final String status;

  final DateTime? readAt;

  bool get isGlobal => audience == 'all';

  bool get isExpert => audience == 'expert';

  bool get isAdmin => audience == 'admin';

  bool get isPersonalUser => audience == 'user';

  bool get isRead {
    if (isGlobal) {
      return false;
    }

    return status == 'read' || readAt != null;
  }

  bool get isUnread => !isRead;

  factory AppNotification.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return AppNotification(
      notificationId:
          _readString(data['notificationId']) ?? document.id,
      title: _readString(data['title']) ?? '',
      message: _readString(data['message']) ?? '',
      type: _readString(data['type']) ?? 'announcement',
      targetScreen: _readString(data['targetScreen']) ?? 'none',
      targetId: _readString(data['targetId']),
      createdAt: _readDate(data['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      audience: _readString(data['audience']) ?? 'all',
      recipientUid: _readString(data['recipientUid']) ??
          _readString(data['userId']),
      actorId: _readString(data['actorId']),
      status: _readString(data['status']) ?? 'unread',
      readAt: _readDate(data['readAt']),
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static String? _readString(dynamic value) {
    if (value is! String) {
      return null;
    }

    final String cleaned = value.trim();

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }
}
