import 'package:shared_preferences/shared_preferences.dart';

class NotificationSeenStore {
  static const String _lastSeenKey =
      'global_notifications_last_seen_millis';

  Future<DateTime?> getLastSeenAt() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    final int? millis = preferences.getInt(_lastSeenKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> markSeenNow() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    await preferences.setInt(
      _lastSeenKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
