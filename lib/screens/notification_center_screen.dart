import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import 'user_login_screen.dart';
import 'register_screen.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends State<NotificationCenterScreen> {
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EAF0);

  final NotificationRepository _repository =
      NotificationRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Bildirim Merkezi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          initialData: FirebaseAuth.instance.currentUser,
          builder: (context, authSnapshot) {
            final User? user = authSnapshot.data;

            if (user == null) {
              return _SignedOutNotificationView(
                onLogin: _openLogin,
                onRegister: _openRegister,
              );
            }

            return _buildNotificationContent(user);
          },
        ),
      ),
    );
  }

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserLoginScreen(),
      ),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  Widget _buildNotificationContent(User user) {
    return StreamBuilder<List<AppNotification>>(
      stream: _repository.watchUserNotifications(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: _teal,
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint(
            'NOTIFICATION ERROR: ${snapshot.error}',
          );

          return const _MessageView(
            icon: Icons.error_outline_rounded,
            title: 'Bildirimler yüklenemedi',
            message:
                'Bildirimleriniz yüklenirken bir sorun oluştu. '
                'Lütfen tekrar deneyin.',
          );
        }

        final List<AppNotification> notifications =
            snapshot.data ?? const [];

        if (notifications.isEmpty) {
          return const _MessageView(
            icon: Icons.notifications_none_rounded,
            title: 'Henüz bildiriminiz yok',
            message:
                'Plango’daki yeni içerikler ve önemli '
                'gelişmeler burada görünecek.',
          );
        }

        final List<_NotificationGroup> groups =
            _groupNotifications(notifications);

        return RefreshIndicator(
          color: _teal,
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              32,
            ),
            itemCount: groups.length,
            itemBuilder: (context, groupIndex) {
              final _NotificationGroup group =
                  groups[groupIndex];

              return _NotificationGroupSection(
                title: group.title,
                notifications: group.notifications,
                onTap: _openNotification,
              );
            },
          ),
        );
      },
    );
  }

  List<_NotificationGroup> _groupNotifications(
    List<AppNotification> notifications,
  ) {
    final DateTime now = DateTime.now();
    final DateTime today =
        DateTime(now.year, now.month, now.day);
    final DateTime yesterday =
        today.subtract(const Duration(days: 1));
    final DateTime weekStart =
        today.subtract(Duration(days: today.weekday - 1));
    final DateTime monthStart =
        DateTime(now.year, now.month, 1);

    final Map<String, List<AppNotification>> grouped = {
      'Bugün': [],
      'Dün': [],
      'Bu Hafta': [],
      'Bu Ay': [],
      'Daha Eski': [],
    };

    for (final AppNotification notification
        in notifications) {
      final DateTime created =
          notification.createdAt;
      final DateTime dateOnly = DateTime(
        created.year,
        created.month,
        created.day,
      );

      if (dateOnly == today) {
        grouped['Bugün']!.add(notification);
      } else if (dateOnly == yesterday) {
        grouped['Dün']!.add(notification);
      } else if (!dateOnly.isBefore(weekStart)) {
        grouped['Bu Hafta']!.add(notification);
      } else if (!dateOnly.isBefore(monthStart)) {
        grouped['Bu Ay']!.add(notification);
      } else {
        grouped['Daha Eski']!.add(notification);
      }
    }

    return grouped.entries
        .where((entry) => entry.value.isNotEmpty)
        .map(
          (entry) => _NotificationGroup(
            title: entry.key,
            notifications: entry.value,
          ),
        )
        .toList();
  }

  Future<void> _openNotification(
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      try {
        await _repository.markAsRead(
          notification.notificationId,
        );
      } catch (_) {
        // Okundu işaretleme hatası ekranı bozmaz.
      }
    }
  }
}

class _SignedOutNotificationView extends StatelessWidget {
  const _SignedOutNotificationView({
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  static const Color _navy = Color(0xFF0B2239);
  static const Color _teal = Color(0xFF087C72);
  static const Color _muted = Color(0xFF748193);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: _teal,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Bildirimlerinizi Takip Edin',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plango’daki yeni içerikleri ve önemli gelişmeleri '
              'görüntülemek için hesabınıza giriş yapın.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                TextButton(
                  onPressed: onLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: _teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Text(
                  '•',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: onRegister,
                  style: TextButton.styleFrom(
                    foregroundColor: _teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationGroup {
  const _NotificationGroup({
    required this.title,
    required this.notifications,
  });

  final String title;
  final List<AppNotification> notifications;
}

class _NotificationGroupSection extends StatelessWidget {
  const _NotificationGroupSection({
    required this.title,
    required this.notifications,
    required this.onTap,
  });

  final String title;
  final List<AppNotification> notifications;
  final Future<void> Function(
    AppNotification notification,
  ) onTap;

  static const Color _navy = Color(0xFF0B2239);
  static const Color _border = Color(0xFFE4EAF0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              2,
              4,
              2,
              10,
            ),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: _navy,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _border,
              ),
            ),
            child: Column(
              children: [
                for (int index = 0;
                    index < notifications.length;
                    index++) ...[
                  _NotificationRow(
                    notification:
                        notifications[index],
                    onTap: () =>
                        onTap(notifications[index]),
                  ),
                  if (index !=
                      notifications.length - 1)
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 62),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: _border,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF0B2239);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _muted = Color(0xFF748193);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            15,
            15,
            14,
            14,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F5),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: _teal,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: _navy,
                              fontSize: 14,
                              height: 1.25,
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.w700
                                      : FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin:
                                const EdgeInsets.only(
                              top: 4,
                            ),
                            decoration:
                                const BoxDecoration(
                              color: _turquoise,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (notification.message
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Text(
                      DateFormat(
                        'HH:mm',
                        'tr_TR',
                      ).format(
                        notification.createdAt,
                      ),
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F5),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF087C72),
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0B2239),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF748193),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
