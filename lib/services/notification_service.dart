import '../repositories/notification_repository.dart';

class NotificationService {
  NotificationService._();

  static final NotificationRepository _repository =
      NotificationRepository();

  // ==================================================
  // ÖNE ÇIKANLAR
  // ==================================================

  static Future<void> featuredPublished({
    required String userId,
    required String contentId,
    required String title,
  }) async {
    await _repository.createNotification(
      userId: userId,
      title: 'Yeni Öne Çıkan İçerik',
      message: title,
      type: 'featured',
      targetScreen: 'featured',
      targetId: contentId,
    );
  }

  // ==================================================
  // KAMPANYALAR
  // ==================================================

  static Future<void> campaignPublished({
    required String userId,
    required String contentId,
    required String title,
  }) async {
    await _repository.createNotification(
      userId: userId,
      title: 'Yeni Kampanya',
      message: title,
      type: 'campaign',
      targetScreen: 'campaign',
      targetId: contentId,
    );
  }

  // ==================================================
  // SİSTEM DUYURUSU
  // ==================================================

  static Future<void> systemAnnouncement({
    required String userId,
    required String title,
    required String message,
    String? contentId,
  }) async {
    await _repository.createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'announcement',
      targetScreen: 'announcement',
      targetId: contentId,
    );
  }

  // ==================================================
  // UYGULAMA GÜNCELLEMESİ
  // ==================================================

  static Future<void> appUpdate({
    required String userId,
    required String version,
    required String message,
  }) async {
    await _repository.createNotification(
      userId: userId,
      title: 'Tasarruf Planım Güncellendi',
      message: message,
      type: 'system',
      targetScreen: 'system',
      targetId: version,
    );
  }
}