import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../repositories/consultation_repository.dart';
import '../repositories/notification_repository.dart';
import 'expert_request_detail_screen.dart';

class ExpertNotificationsScreen extends StatefulWidget {
  const ExpertNotificationsScreen({super.key});

  @override
  State<ExpertNotificationsScreen> createState() =>
      _ExpertNotificationsScreenState();
}

class _ExpertNotificationsScreenState
    extends State<ExpertNotificationsScreen> {
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  final ConsultationRepository _consultationRepository =
      ConsultationRepository();

  bool _markingAll = false;

  String? get _expertUid =>
      FirebaseAuth.instance.currentUser?.uid;

  Future<void> _markAllAsRead() async {
    final String uid = _expertUid?.trim() ?? '';

    if (uid.isEmpty || _markingAll) return;

    setState(() => _markingAll = true);

    try {
      await _notificationRepository.markAllExpertAsRead(uid);
    } on Exception {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bildirimler güncellenemedi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _markingAll = false);
      }
    }
  }

  Future<void> _openNotification(
    AppNotification notification,
  ) async {
    try {
      if (!notification.isRead) {
        await _notificationRepository.markAsRead(
          notification.notificationId,
        );
      }
    } on Exception {
      // Okundu işlemi yönlendirmeyi engellemez.
    }

    if (!mounted) return;

    final String targetId =
        notification.targetId?.trim() ?? '';

    if (notification.targetScreen !=
            'expert_consultation_request' ||
        targetId.isEmpty) {
      _showUnavailable();
      return;
    }

    try {
      final request =
          await _consultationRepository.getRequestById(
        targetId,
      );

      final String currentUid =
          _expertUid?.trim() ?? '';

      if (currentUid.isEmpty ||
          request.expertId != currentUid) {
        _showUnavailable();
        return;
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ExpertRequestDetailScreen(
            request: request,
          ),
        ),
      );
    } on ConsultationRequestNotFoundException {
      _showUnavailable();
    } on Exception {
      _showUnavailable();
    }
  }

  void _showUnavailable() {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'İlgili danışma talebi artık görüntülenemiyor.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final String uid = _expertUid?.trim() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF0B2239),
        ),
        title: const Text(
          'Uzman Bildirimleri',
          style: TextStyle(
            color: Color(0xFF0B2239),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (uid.isNotEmpty)
            StreamBuilder<int>(
              stream: _notificationRepository
                  .watchExpertUnreadCount(uid),
              builder: (context, snapshot) {
                final int unreadCount =
                    snapshot.data ?? 0;

                if (unreadCount == 0) {
                  return const SizedBox.shrink();
                }

                return TextButton(
                  onPressed:
                      _markingAll ? null : _markAllAsRead,
                  child: _markingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Tümünü okundu yap',
                          style: TextStyle(
                            color: Color(0xFF087C72),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: uid.isEmpty
          ? const _MessageState(
              icon: Icons.lock_outline_rounded,
              title: 'Oturum bulunamadı',
              message:
                  'Uzman bildirimlerini görüntülemek için giriş yapmanız gerekiyor.',
            )
          : StreamBuilder<List<AppNotification>>(
              stream: _notificationRepository
                  .watchExpertNotifications(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _MessageState(
                    icon: Icons.error_outline_rounded,
                    title: 'Bildirimler yüklenemedi',
                    message:
                        'Uzman bildirimleri alınırken bir sorun oluştu.',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final notifications = snapshot.data!;

                if (notifications.isEmpty) {
                  return const _MessageState(
                    icon:
                        Icons.notifications_none_rounded,
                    title: 'Henüz bildirim yok',
                    message:
                        'Size atanan yeni danışma talepleri burada görünecek.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    28,
                  ),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notification =
                        notifications[index];

                    return _NotificationCard(
                      notification: notification,
                      onTap: () =>
                          _openNotification(notification),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool unread = notification.isUnread;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: unread
                  ? const Color(0xFF087C72)
                      .withValues(alpha: 0.24)
                  : const Color(0xFFE3E8ED),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: unread
                        ? const Color(0xFFE8F7F5)
                        : const Color(0xFFF1F4F6),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: unread
                        ? const Color(0xFF087C72)
                        : const Color(0xFF667783),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
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
                                color: const Color(
                                  0xFF0B2239,
                                ),
                                fontSize: 15,
                                fontWeight: unread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 8),
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 5),
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor:
                                    Color(0xFF087C72),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          color: Color(0xFF52616D),
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatDate(
                          notification.createdAt,
                        ),
                        style: const TextStyle(
                          color: Color(0xFF8A98A5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime local = date.toLocal();

    final bool today = now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;

    if (today) {
      return 'Bugün ${_two(local.hour)}:${_two(local.minute)}';
    }

    final DateTime yesterday =
        DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));

    final bool isYesterday =
        yesterday.year == local.year &&
            yesterday.month == local.month &&
            yesterday.day == local.day;

    if (isYesterday) {
      return 'Dün ${_two(local.hour)}:${_two(local.minute)}';
    }

    return '${_two(local.day)}.${_two(local.month)}.${local.year} '
        '${_two(local.hour)}:${_two(local.minute)}';
  }

  static String _two(int value) =>
      value.toString().padLeft(2, '0');
}

class _MessageState extends StatelessWidget {
  const _MessageState({
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF087C72),
                size: 31,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0B2239),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667783),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
