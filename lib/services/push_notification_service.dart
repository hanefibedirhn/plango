import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../repositories/device_token_repository.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance =
      PushNotificationService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceTokenRepository _tokenRepository =
      DeviceTokenRepository();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  String? _currentToken;
  bool _initialized = false;

  final StreamController<RemoteMessage>
      _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  final StreamController<RemoteMessage>
      _notificationTapController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get foregroundMessages =>
      _foregroundMessageController.stream;

  /// Bildirime dokunulduğunda main.dart / navigator katmanı
  /// bu stream'i dinleyerek doğru ekrana yönlendirecek.
  Stream<RemoteMessage> get notificationTaps =>
      _notificationTapController.stream;

  String? get currentToken => _currentToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) {
      // V1 mobil push kapsamı Android + iOS.
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    await _requestPermission();
    await _configureAppleForegroundPresentation();

    final bool tokenReady = await _waitUntilTokenCanBeRequested();
    if (tokenReady) {
      await _registerCurrentToken();
    }

    _tokenRefreshSubscription =
        _messaging.onTokenRefresh.listen(
      (newToken) async {
        await _handleTokenRefresh(newToken);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'FCM TOKEN REFRESH ERROR => $error',
        );
      },
    );

    _authSubscription = _auth.authStateChanges().listen(
      (user) async {
        await _syncTokenWithUser(user);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'FCM AUTH SYNC ERROR => $error',
        );
      },
    );

    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen(
      (message) {
        _foregroundMessageController.add(message);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'FCM FOREGROUND MESSAGE ERROR => $error',
        );
      },
    );

    _openedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        _notificationTapController.add(message);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'FCM OPENED APP ERROR => $error',
        );
      },
    );
  }

  /// Uygulama tamamen kapalıyken kullanıcı push bildirime
  /// dokunarak uygulamayı açtıysa ilk mesajı verir.
  /// main.dart bunu Splash/Disclaimer akışını bozmadan işleyecek.
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Future<NotificationSettings> _requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> _configureAppleForegroundPresentation() async {
    if (!Platform.isIOS) return;

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Apple tarafında Firebase'in güncel gereksinimine göre
  /// FCM API çağrısından önce APNs token'ın hazır olmasını bekler.
  Future<bool> _waitUntilTokenCanBeRequested() async {
    if (!Platform.isIOS) return true;

    for (int attempt = 0; attempt < 20; attempt++) {
      final String? apnsToken =
          await _messaging.getAPNSToken();

      if (apnsToken != null && apnsToken.isNotEmpty) {
        return true;
      }

      await Future<void>.delayed(
        const Duration(milliseconds: 250),
      );
    }

    debugPrint(
      'FCM => APNs token henüz hazır değil. '
      'Token refresh akışı bekleniyor.',
    );

    return false;
  }

  Future<void> _registerCurrentToken() async {
    try {
      final String? token = await _messaging.getToken();

      if (token == null || token.trim().isEmpty) {
        debugPrint('FCM => Device token alınamadı.');
        return;
      }

      _currentToken = token.trim();

      await _tokenRepository.saveToken(
        token: _currentToken!,
        platform: _platformName,
        userUid: _auth.currentUser?.uid,
      );

      debugPrint('FCM => Device token kaydedildi.');
    } catch (error, stackTrace) {
      debugPrint('FCM TOKEN REGISTER ERROR => $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _handleTokenRefresh(
    String newToken,
  ) async {
    final String normalizedNewToken = newToken.trim();
    if (normalizedNewToken.isEmpty) return;

    final String oldToken = _currentToken ?? '';

    try {
      await _tokenRepository.replaceToken(
        oldToken: oldToken,
        newToken: normalizedNewToken,
        platform: _platformName,
        userUid: _auth.currentUser?.uid,
      );

      _currentToken = normalizedNewToken;

      debugPrint('FCM => Device token yenilendi.');
    } catch (error, stackTrace) {
      debugPrint('FCM TOKEN REPLACE ERROR => $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _syncTokenWithUser(
    User? user,
  ) async {
    String? token = _currentToken;

    if (token == null || token.isEmpty) {
      final bool ready =
          await _waitUntilTokenCanBeRequested();

      if (!ready) return;

      try {
        token = await _messaging.getToken();
      } catch (error, stackTrace) {
        debugPrint('FCM TOKEN SYNC ERROR => $error');
        debugPrint('$stackTrace');
        return;
      }

      if (token == null || token.trim().isEmpty) {
        return;
      }

      token = token.trim();
      _currentToken = token;
    }

    try {
      if (user == null) {
        await _tokenRepository.detachTokenFromUser(
          token: token,
        );
      } else {
        await _tokenRepository.attachTokenToUser(
          token: token,
          userUid: user.uid,
          platform: _platformName,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('FCM USER TOKEN SYNC ERROR => $error');
      debugPrint('$stackTrace');
    }
  }

  String get _platformName {
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _authSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
    await _foregroundMessageController.close();
    await _notificationTapController.close();

    _initialized = false;
  }
}
