import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';
import 'notification_seen_store.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFirestore? firestore,
    NotificationSeenStore? seenStore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _seenStore = seenStore ?? NotificationSeenStore();

  final FirebaseFirestore _firestore;
  final NotificationSeenStore _seenStore;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('notifications');
  }

  // ---------------------------------------------------------------------------
  // GLOBAL BİLDİRİMLER
  // ---------------------------------------------------------------------------

  Stream<List<AppNotification>> watchGlobalNotifications({
    int limit = 100,
  }) {
    return _collection
        .where('audience', isEqualTo: 'all')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final notifications =
          snapshot.docs.map(AppNotification.fromDocument).toList();

      notifications.sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );

      return notifications;
    });
  }

  /// Eski ekran/widget çağrılarıyla uyumluluk için korunur.
  /// Normal kullanıcı Bildirim Merkezi yalnızca global bildirimleri gösterir.
  Stream<List<AppNotification>> watchUserNotifications(
    String userId,
  ) {
    return watchGlobalNotifications();
  }

  /// Global bildirimlerde cihazın son görülme zamanından sonra oluşturulan
  /// bildirimleri sayar.
  ///
  /// userId sadece eski çağrılarla uyumluluk için tutulur.
  Stream<int> watchUnreadCount([
    String? userId,
  ]) {
    return watchGlobalNotifications().asyncMap(
      (notifications) async {
        final DateTime? lastSeenAt = await _seenStore.getLastSeenAt();

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
      'type': type.trim(),
      'targetScreen': targetScreen.trim(),
      'targetId': _cleanNullableString(targetId),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }

  // ---------------------------------------------------------------------------
  // UZMAN BİLDİRİMLERİ
  // ---------------------------------------------------------------------------

  Stream<List<AppNotification>> watchExpertNotifications(
    String expertUid, {
    int limit = 100,
  }) {
    final String normalizedUid = expertUid.trim();

    if (normalizedUid.isEmpty) {
      return Stream<List<AppNotification>>.value(
        const <AppNotification>[],
      );
    }

    return _collection
        .where('audience', isEqualTo: 'expert')
        .where('recipientUid', isEqualTo: normalizedUid)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final notifications =
          snapshot.docs.map(AppNotification.fromDocument).toList();

      notifications.sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );

      return notifications;
    });
  }

  Stream<int> watchExpertUnreadCount(
    String expertUid,
  ) {
    final String normalizedUid = expertUid.trim();

    if (normalizedUid.isEmpty) {
      return Stream<int>.value(0);
    }

    return _collection
        .where('audience', isEqualTo: 'expert')
        .where('recipientUid', isEqualTo: normalizedUid)
        .where('status', isEqualTo: 'unread')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<String> createExpertNotification({
    required String expertUid,
    required String title,
    required String message,
    required String type,
    required String targetScreen,
    String? targetId,
    String? actorId,
  }) {
    return _createPersonalNotification(
      audience: 'expert',
      recipientUid: expertUid,
      title: title,
      message: message,
      type: type,
      targetScreen: targetScreen,
      targetId: targetId,
      actorId: actorId,
    );
  }

  Future<String> notifyExpertAboutConsultationRequest({
    required String expertUid,
    required String requestId,
  }) {
    return createExpertNotification(
      expertUid: expertUid,
      title: 'Yeni danışma talebi',
      message:
          'Yeni bir danışma talebiniz var. Yanıtlamak için 24 saatiniz bulunuyor.',
      type: 'consultation_request_assigned',
      targetScreen: 'expert_consultation_request',
      targetId: requestId,
    );
  }

  // ---------------------------------------------------------------------------
  // ADMİN BİLDİRİMLERİ
  // ---------------------------------------------------------------------------

  Stream<List<AppNotification>> watchAdminNotifications({
    int limit = 100,
  }) {
    return _collection
        .where('audience', isEqualTo: 'admin')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final notifications =
          snapshot.docs.map(AppNotification.fromDocument).toList();

      notifications.sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );

      return notifications;
    });
  }

  Stream<int> watchAdminUnreadCount() {
    return _collection
        .where('audience', isEqualTo: 'admin')
        .where('status', isEqualTo: 'unread')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<String> createAdminNotification({
    required String title,
    required String message,
    required String type,
    required String targetScreen,
    String? targetId,
    String? actorId,
  }) {
    return _createPersonalNotification(
      audience: 'admin',
      title: title,
      message: message,
      type: type,
      targetScreen: targetScreen,
      targetId: targetId,
      actorId: actorId,
    );
  }

  Future<String> notifyAdminExpertAccountDeleted({
    required String expertUid,
    required int affectedRequestCount,
  }) {
    final String requestText = affectedRequestCount == 1
        ? '1 açık danışma talebi'
        : '$affectedRequestCount açık danışma talebi';

    return createAdminNotification(
      title: 'Uzman hesabını sildi',
      message: affectedRequestCount > 0
          ? 'Bir uzman hesabını sildi. $requestText yönetici kuyruğuna alındı.'
          : 'Bir uzman hesabını sildi.',
      type: 'expert_account_deleted',
      targetScreen: 'admin_experts',
      targetId: expertUid,
      actorId: expertUid,
    );
  }

  Future<String> notifyAdminResponseExpired({
    required String requestId,
    required String expertUid,
  }) {
    return createAdminNotification(
      title: 'Danışma talebinin yanıt süresi doldu',
      message:
          'Uzman danışma talebine 24 saat içinde yanıt vermedi. Talep yeniden atama bekliyor.',
      type: 'consultation_response_expired',
      targetScreen: 'admin_consultation_request',
      targetId: requestId,
      actorId: expertUid,
    );
  }

  Future<String> notifyAdminExpertApplication({
    required String applicationId,
    String? applicantUid,
  }) {
    return createAdminNotification(
      title: 'Yeni uzman başvurusu',
      message: 'Yeni bir uzman başvurusu inceleme bekliyor.',
      type: 'expert_application_created',
      targetScreen: 'admin_expert_application',
      targetId: applicationId,
      actorId: applicantUid,
    );
  }

  Future<String> notifyAdminExpertCompanyChange({
    required String expertUid,
    required String expertName,
  }) {
    final String normalizedName = expertName.trim();

    return createAdminNotification(
      title: 'Uzman şirket değişikliği',
      message: normalizedName.isEmpty
          ? 'Bir uzman şirket bilgilerinin güncellenmesini talep etti.'
          : '$normalizedName şirket bilgilerinin güncellenmesini talep etti.',
      type: 'expert_company_change_requested',
      targetScreen: 'admin_expert_update_request',
      targetId: expertUid,
      actorId: expertUid,
    );
  }

  Future<String> notifyAdminFeedback({
    required String feedbackId,
    required String feedbackType,
    String? actorUid,
  }) {
    final String normalizedType = feedbackType.trim().toLowerCase();

    final bool isComplaint =
        normalizedType == 'complaint' || normalizedType == 'şikayet';

    return createAdminNotification(
      title: isComplaint ? 'Yeni şikayet' : 'Yeni öneri',
      message: isComplaint
          ? 'Yeni bir kullanıcı şikayeti inceleme bekliyor.'
          : 'Yeni bir kullanıcı önerisi inceleme bekliyor.',
      type: isComplaint ? 'feedback_complaint' : 'feedback_suggestion',
      targetScreen: 'admin_feedback',
      targetId: feedbackId,
      actorId: actorUid,
    );
  }

  // ---------------------------------------------------------------------------
  // KİŞİSEL BİLDİRİM OKUNMA DURUMU
  // ---------------------------------------------------------------------------

  Future<void> markAsRead(
    String notificationId,
  ) async {
    final String normalizedId = notificationId.trim();

    if (normalizedId.isEmpty) {
      return;
    }

    final DocumentReference<Map<String, dynamic>> reference =
        _collection.doc(normalizedId);

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await reference.get();

    if (!snapshot.exists || snapshot.data() == null) {
      return;
    }

    final Map<String, dynamic> data = snapshot.data()!;

    // Global bildirimlerin okunma durumu NotificationSeenStore ile tutulur.
    if ((data['audience'] as String? ?? '') == 'all') {
      return;
    }

    if ((data['status'] as String? ?? '') == 'read') {
      return;
    }

    await reference.update({
      'status': 'read',
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllExpertAsRead(
    String expertUid,
  ) {
    return _markAllPersonalAsRead(
      audience: 'expert',
      recipientUid: expertUid,
    );
  }

  Future<void> markAllAdminAsRead() {
    return _markAllPersonalAsRead(
      audience: 'admin',
    );
  }

  /// LEGACY: Eski kişisel bildirim çağrılarını kırmamak için korunur.
  Future<String> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String targetScreen,
    String? targetId,
    String? actorId,
  }) {
    return _createPersonalNotification(
      audience: 'user',
      recipientUid: userId,
      legacyUserId: userId,
      title: title,
      message: message,
      type: type,
      targetScreen: targetScreen,
      targetId: targetId,
      actorId: actorId,
    );
  }

  /// LEGACY
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

  /// LEGACY
  Future<void> markAllAsRead(
    String userId,
  ) {
    return _markAllPersonalAsRead(
      audience: 'user',
      recipientUid: userId,
    );
  }

  // ---------------------------------------------------------------------------
  // ORTAK YARDIMCILAR
  // ---------------------------------------------------------------------------

  Future<String> _createPersonalNotification({
    required String audience,
    required String title,
    required String message,
    required String type,
    required String targetScreen,
    String? recipientUid,
    String? legacyUserId,
    String? targetId,
    String? actorId,
  }) async {
    final String normalizedAudience = audience.trim();
    final String? normalizedRecipientUid =
        _cleanNullableString(recipientUid);

    if (normalizedAudience.isEmpty) {
      throw ArgumentError('Bildirim hedef kitlesi bulunamadı.');
    }

    if (normalizedAudience == 'expert' &&
        normalizedRecipientUid == null) {
      throw ArgumentError('Uzman bildirim alıcısı bulunamadı.');
    }

    final reference = _collection.doc();

    await reference.set({
      'notificationId': reference.id,
      'audience': normalizedAudience,
      'recipientUid': normalizedRecipientUid,
      'userId': _cleanNullableString(legacyUserId),
      'title': title.trim(),
      'message': message.trim(),
      'type': type.trim(),
      'status': 'unread',
      'targetScreen': targetScreen.trim(),
      'targetId': _cleanNullableString(targetId),
      'actorId': _cleanNullableString(actorId),
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
    });

    return reference.id;
  }

  Future<void> _markAllPersonalAsRead({
    required String audience,
    String? recipientUid,
  }) async {
    final String normalizedAudience = audience.trim();
    final String? normalizedRecipientUid =
        _cleanNullableString(recipientUid);

    Query<Map<String, dynamic>> query = _collection
        .where('audience', isEqualTo: normalizedAudience)
        .where('status', isEqualTo: 'unread');

    if (normalizedRecipientUid != null) {
      query = query.where(
        'recipientUid',
        isEqualTo: normalizedRecipientUid,
      );
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await query.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    const int maxWritesPerBatch = 450;

    for (int start = 0;
        start < snapshot.docs.length;
        start += maxWritesPerBatch) {
      final int end =
          (start + maxWritesPerBatch < snapshot.docs.length)
              ? start + maxWritesPerBatch
              : snapshot.docs.length;

      final WriteBatch batch = _firestore.batch();

      for (final document in snapshot.docs.sublist(start, end)) {
        batch.update(
          document.reference,
          {
            'status': 'read',
            'readAt': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();
    }
  }

  static String? _cleanNullableString(
    String? value,
  ) {
    final String? cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }
}
