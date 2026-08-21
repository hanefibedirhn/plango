import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'push_notification_service.dart';

class PushNotificationRouter {
  PushNotificationRouter._();

  static final PushNotificationRouter instance =
      PushNotificationRouter._();

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  StreamSubscription<RemoteMessage>? _tapSubscription;
  RemoteMessage? _pendingMessage;
  bool _appReady = false;
  bool _initialized = false;

  RemoteMessage? get pendingMessage => _pendingMessage;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final RemoteMessage? initialMessage =
        await PushNotificationService.instance.getInitialMessage();

    if (initialMessage != null) {
      _pendingMessage = initialMessage;
    }

    _tapSubscription =
        PushNotificationService.instance.notificationTaps.listen(
      (message) {
        _pendingMessage = message;
        _tryOpenPendingMessage();
      },
    );
  }

  /// Splash + zorunlu bilgilendirme akışı tamamlanıp Home açıldığında
  /// bir kez çağrılır. Böylece terminated push, açılış akışını atlamaz.
  void markAppReady() {
    _appReady = true;
    _tryOpenPendingMessage();
  }

  void markAppNotReady() {
    _appReady = false;
  }

  /// Hedef ekran eşleştirmesini ayrı router dosyasında tutuyoruz.
  /// Cloud Function data payload'ındaki targetScreen/targetId burada
  /// değerlendirilecek. Main.dart bundan sonra değişmeyecek.
  void _tryOpenPendingMessage() {
    if (!_appReady || _pendingMessage == null) return;

    // Hedef ekranların gerçek constructor'ları bağlandığında
    // yalnızca bu router dosyası genişletilecek.
    // Mesajı şimdilik kaybetmiyoruz.
  }

  Map<String, String> pendingData() {
    return Map<String, String>.from(
      _pendingMessage?.data ?? const <String, String>{},
    );
  }

  void clearPendingMessage() {
    _pendingMessage = null;
  }

  Future<void> dispose() async {
    await _tapSubscription?.cancel();
    _initialized = false;
  }
}
