import '../repositories/notification_repository.dart';

class NotificationService {
  NotificationService._();

  static final NotificationRepository _repository =
      NotificationRepository();

  // ==================================================
  // ÖNE ÇIKANLAR
  // ==================================================

  /// Yeni Öne Çıkanlar içeriği yayınlandığında tek bir global
  /// bildirim oluşturur. Giriş yapmayan kullanıcıların cihazları da
  /// push izni verdiyse sunucu tarafında bu bildirimi alabilir.
  static Future<String> featuredPublished({
    required String contentId,
    required String title,
  }) {
    return _repository.createGlobalNotification(
      title: 'Yeni Öne Çıkan İçerik',
      message: title.trim(),
      type: 'featured',
      targetScreen: 'featured',
      targetId: contentId.trim(),
    );
  }

  // ==================================================
  // KAMPANYALAR
  // ==================================================

  /// Mevcut uygulamada kampanya akışı tekrar kullanılacaksa,
  /// global Bildirim Merkezi ile aynı omurgadan yayınlanır.
  ///
  /// Global notification type kümesinde ayrı "campaign" türü
  /// kullanmıyoruz; genel içerik/duyuru olarak "announcement"
  /// altında tutulur. targetScreen değeri yönlendirmeyi korur.
  static Future<String> campaignPublished({
    required String contentId,
    required String title,
  }) {
    return _repository.createGlobalNotification(
      title: 'Yeni Kampanya',
      message: title.trim(),
      type: 'announcement',
      targetScreen: 'campaign',
      targetId: contentId.trim(),
    );
  }

  // ==================================================
  // SİSTEM DUYURUSU
  // ==================================================

  static Future<String> systemAnnouncement({
    required String title,
    required String message,
    String? contentId,
  }) {
    final String? normalizedContentId =
        _normalizeOptional(contentId);

    return _repository.createGlobalNotification(
      title: title.trim(),
      message: message.trim(),
      type: 'announcement',
      targetScreen: 'announcement',
      targetId: normalizedContentId,
    );
  }

  // ==================================================
  // UYGULAMA GÜNCELLEMESİ
  // ==================================================

  static Future<String> appUpdate({
    required String version,
    required String message,
  }) {
    return _repository.createGlobalNotification(
      title: 'Tasarruf Planım Güncellendi',
      message: message.trim(),
      type: 'system',
      targetScreen: 'system',
      targetId: version.trim(),
    );
  }

  static String? _normalizeOptional(String? value) {
    final String normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
