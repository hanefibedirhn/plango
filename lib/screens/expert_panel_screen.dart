import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/consultation_request_model.dart';
import '../../models/expert_model.dart';
import '../../repositories/consultation_repository.dart';
import '../../repositories/expert_repository.dart';
import '../../repositories/notification_repository.dart';
import 'expert_consultation_requests_screen.dart';
import 'expert_profile_update_screen.dart';
import 'expert_notifications_screen.dart';

class ExpertPanelScreen extends StatefulWidget {
  const ExpertPanelScreen({super.key});

  @override
  State<ExpertPanelScreen> createState() => _ExpertPanelScreenState();
}

class _ExpertPanelScreenState extends State<ExpertPanelScreen> {
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EAF0);
  static const Color _softTeal = Color(0xFFEAF8F5);
  static const Color _warningBackground = Color(0xFFFFF4E5);
  static const Color _warningText = Color(0xFFB54708);

  final ExpertRepository _expertRepository = ExpertRepository();
  final ConsultationRepository _consultationRepository =
      ConsultationRepository();
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  bool _isUpdatingAvailability = false;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String feature) {
    _showMessage('$feature sonraki aşamada bağlanacak.');
  }

  Future<void> _updateAvailability({
    required Expert expert,
    required bool value,
  }) async {
    if (_isUpdatingAvailability) return;

    if (!expert.isActive) {
      _showMessage(
        'Uzman profiliniz aktif olmadığı için danışma durumunu değiştiremezsiniz.',
      );
      return;
    }

    setState(() => _isUpdatingAvailability = true);

    try {
      await _expertRepository.setAcceptsNewRequests(
        uid: expert.uid,
        value: value,
      );

      if (!mounted) return;

      _showMessage(
        value
            ? 'Artık yeni danışma talepleri alabilirsiniz.'
            : 'Yeni danışma talebi alımı kapatıldı.',
      );
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().contains('permission-denied')
          ? 'Bu işlemi gerçekleştirmek için yetkiniz bulunmuyor.'
          : 'Danışma durumu güncellenemedi. Lütfen tekrar deneyin.';

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _isUpdatingAvailability = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUid;

    if (uid == null) {
      return const _ExpertPanelMessageScreen(
        title: 'Oturum Bulunamadı',
        message:
            'Uzman panelini kullanabilmek için hesabınıza giriş yapmanız gerekiyor.',
        icon: Icons.login_rounded,
      );
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Uzman Paneli',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          StreamBuilder<int>(
            stream: _notificationRepository.watchExpertUnreadCount(uid),
            builder: (context, snapshot) {
              final int unreadCount = snapshot.data ?? 0;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Uzman Bildirimleri',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ExpertNotificationsScreen(),
                      ),
                    );
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 26,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -7,
                          top: -7,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _teal,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _background,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<Expert?>(
          stream: _expertRepository.watchExpert(uid),
          builder: (context, expertSnapshot) {
            if (expertSnapshot.connectionState == ConnectionState.waiting &&
                !expertSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _teal),
              );
            }

            if (expertSnapshot.hasError) {
              return const _ExpertPanelMessageScreen(
                title: 'Uzman Profili Alınamadı',
                message:
                    'Uzman bilgileriniz yüklenirken bir sorun oluştu.',
                icon: Icons.error_outline_rounded,
              );
            }

            final expert = expertSnapshot.data;

            if (expert == null) {
              return const _ExpertPanelMessageScreen(
                title: 'Uzman Profili Bulunamadı',
                message:
                    'Uzman profiliniz henüz oluşturulmamış veya erişime kapatılmış olabilir.',
                icon: Icons.person_search_outlined,
              );
            }

            return StreamBuilder<List<ConsultationRequest>>(
              stream: _consultationRepository.watchExpertRequests(expert.uid),
              builder: (context, requestSnapshot) {
                final requests =
                    requestSnapshot.data ?? <ConsultationRequest>[];

                final now = DateTime.now();

                final newCount = requests.where((request) {
                  if (request.status != 'pending') return false;

                  final deadline = request.expiresAt;
                  return deadline == null || deadline.isAfter(now);
                }).length;

                final ongoingCount = requests.where((request) {
                  return request.status == 'accepted' ||
                      request.status == 'contacted';
                }).length;

                final completedCount = requests
                    .where((request) => request.status == 'completed')
                    .length;

                return _buildPanel(
                  expert: expert,
                  newCount: newCount,
                  ongoingCount: ongoingCount,
                  completedCount: completedCount,
                  requestError: requestSnapshot.hasError,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPanel({
    required Expert expert,
    required int newCount,
    required int ongoingCount,
    required int completedCount,
    required bool requestError,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
      children: [
        _ExpertHeader(expert: expert),
        const SizedBox(height: 14),

        if (!expert.isActive) ...[
          _SuspendedNotice(expert: expert),
          const SizedBox(height: 14),
        ],

        _ConsultationSummary(
          newCount: newCount,
          ongoingCount: ongoingCount,
          completedCount: completedCount,
          hasError: requestError,
        ),

        const SizedBox(height: 14),

        _PrimaryActionCard(
          icon: Icons.inbox_outlined,
          title: 'Danışma Taleplerim',
          subtitle: null,
          badgeText: newCount > 0 ? '$newCount YENİ' : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpertConsultationRequestsScreen(
                  expertId: expert.uid,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 10),

        _AvailabilityCard(
          expert: expert,
          isUpdating: _isUpdatingAvailability,
          onChanged: (value) {
            _updateAvailability(
              expert: expert,
              value: value,
            );
          },
        ),

        const SizedBox(height: 10),

        _SecondaryActionCard(
          icon: Icons.sync_alt_rounded,
          title: 'Şirket / Pozisyon Değişikliği',
          subtitle: null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpertProfileUpdateScreen(
                  expert: expert,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ExpertHeader extends StatelessWidget {
  const _ExpertHeader({
    required this.expert,
  });

  final Expert expert;

  @override
  Widget build(BuildContext context) {
    final active = expert.isActive;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _ExpertPanelScreenState._navy,
            _ExpertPanelScreenState._petrol,
            _ExpertPanelScreenState._teal,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _ExpertPanelScreenState._petrol.withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.13),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: Color(0xFF5DE0D0),
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hoş geldiniz',
                      style: TextStyle(
                        color: Color(0xFFC9DCE2),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      expert.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF5DE0D0).withOpacity(0.15)
                      : Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active
                        ? const Color(0xFF5DE0D0).withOpacity(0.35)
                        : Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  active ? 'AKTİF' : 'ASKIDA',
                  style: TextStyle(
                    color: active
                        ? const Color(0xFF9BF2E7)
                        : const Color(0xFFFFD7A8),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _HeaderInfoLine(
            icon: Icons.apartment_rounded,
            text: expert.companyName,
          ),
          const SizedBox(height: 8),
          _HeaderInfoLine(
            icon: Icons.location_city_outlined,
            text: expert.branch,
          ),
          const SizedBox(height: 8),
          _HeaderInfoLine(
            icon: Icons.work_outline_rounded,
            text: expert.position,
          ),
        ],
      ),
    );
  }
}

class _HeaderInfoLine extends StatelessWidget {
  const _HeaderInfoLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFFBFE9E3),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsultationSummary extends StatelessWidget {
  const _ConsultationSummary({
    required this.newCount,
    required this.ongoingCount,
    required this.completedCount,
    required this.hasError,
  });

  final int newCount;
  final int ongoingCount;
  final int completedCount;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _ExpertPanelScreenState._border),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: _ExpertPanelScreenState._muted,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Danışma özeti şu anda yüklenemiyor.',
                style: TextStyle(
                  color: _ExpertPanelScreenState._muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.mark_unread_chat_alt_outlined,
            value: newCount,
            label: 'Yeni',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _SummaryCard(
            icon: Icons.forum_outlined,
            value: ongoingCount,
            label: 'Devam',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _SummaryCard(
            icon: Icons.task_alt_rounded,
            value: completedCount,
            label: 'Biten',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.fromLTRB(11, 10, 9, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ExpertPanelScreenState._border),
        boxShadow: [
          BoxShadow(
            color: _ExpertPanelScreenState._navy.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _ExpertPanelScreenState._softTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: _ExpertPanelScreenState._teal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: _ExpertPanelScreenState._navy,
              fontSize: 21,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ExpertPanelScreenState._muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _ExpertPanelScreenState._softTeal,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 18,
            color: _ExpertPanelScreenState._teal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ExpertPanelScreenState._navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _ExpertPanelScreenState._muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.badgeText,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _ExpertPanelScreenState._border),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _ExpertPanelScreenState._softTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: _ExpertPanelScreenState._teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: _ExpertPanelScreenState._navy,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF4FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeText!,
                              style: const TextStyle(
                                color: Color(0xFF175CD3),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: _ExpertPanelScreenState._muted,
                          fontSize: 11.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA8B7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.expert,
    required this.isUpdating,
    required this.onChanged,
  });

  final Expert expert;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = expert.isActive && !isUpdating;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 13, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ExpertPanelScreenState._border),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: expert.acceptsNewRequests
                  ? _ExpertPanelScreenState._softTeal
                  : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              expert.acceptsNewRequests
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.chat_bubble_outline_rounded,
              color: expert.acceptsNewRequests
                  ? _ExpertPanelScreenState._teal
                  : _ExpertPanelScreenState._muted,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni Talep Bildirimleri',
                  style: TextStyle(
                    color: _ExpertPanelScreenState._navy,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUpdating)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: _ExpertPanelScreenState._teal,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  expert.acceptsNewRequests ? 'AÇIK' : 'KAPALI',
                  style: TextStyle(
                    color: expert.acceptsNewRequests
                        ? _ExpertPanelScreenState._teal
                        : _ExpertPanelScreenState._muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Switch(
                  value: expert.acceptsNewRequests,
                  onChanged: enabled ? onChanged : null,
                  activeColor: Colors.white,
                  activeTrackColor: _ExpertPanelScreenState._teal,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD8E0E7),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _ExpertPanelScreenState._border),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: _ExpertPanelScreenState._softTeal,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _ExpertPanelScreenState._teal,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ExpertPanelScreenState._navy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: _ExpertPanelScreenState._muted,
                          fontSize: 11.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA8B7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuspendedNotice extends StatelessWidget {
  const _SuspendedNotice({
    required this.expert,
  });

  final Expert expert;

  @override
  Widget build(BuildContext context) {
    final reason = expert.suspensionReason?.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ExpertPanelScreenState._warningBackground,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFF7D7AD),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: _ExpertPanelScreenState._warningText,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uzman hesabınız askıda',
                  style: TextStyle(
                    color: _ExpertPanelScreenState._warningText,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason != null && reason.isNotEmpty
                      ? 'Neden: $reason'
                      : 'Yeni danışma talebi alamazsınız. Hesabınız yönetici tarafından yeniden aktifleştirilebilir.',
                  style: const TextStyle(
                    color: _ExpertPanelScreenState._warningText,
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertPanelMessageScreen extends StatelessWidget {
  const _ExpertPanelMessageScreen({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ExpertPanelScreenState._background,
      appBar: AppBar(
        backgroundColor: _ExpertPanelScreenState._background,
        surfaceTintColor: _ExpertPanelScreenState._background,
        foregroundColor: _ExpertPanelScreenState._navy,
        elevation: 0,
        title: const Text(
          'Uzman Paneli',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: _ExpertPanelScreenState._softTeal,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Icon(
                  icon,
                  color: _ExpertPanelScreenState._teal,
                  size: 31,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ExpertPanelScreenState._navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ExpertPanelScreenState._muted,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
