import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/expert_model.dart';
import '../../repositories/expert_repository.dart';

class ExpertPanelScreen extends StatefulWidget {
  const ExpertPanelScreen({
    super.key,
  });

  @override
  State<ExpertPanelScreen> createState() =>
      _ExpertPanelScreenState();
}

class _ExpertPanelScreenState extends State<ExpertPanelScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);
  static const Color _warningBackground = Color(0xFFFFF4E5);
  static const Color _warningText = Color(0xFFB54708);

  final ExpertRepository _expertRepository =
      ExpertRepository();

  bool _isUpdatingAvailability = false;

  String? get _currentUid {
    return FirebaseAuth.instance.currentUser?.uid;
  }

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
    if (_isUpdatingAvailability) {
      return;
    }

    if (!expert.isActive) {
      _showMessage(
        'Uzman profiliniz aktif olmadığı için danışma durumunu değiştiremezsiniz.',
      );
      return;
    }

    setState(() {
      _isUpdatingAvailability = true;
    });

    try {
      await _expertRepository.setAcceptsNewRequests(
        uid: expert.uid,
        value: value,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        value
            ? 'Artık yeni danışma talepleri alabilirsiniz.'
            : 'Yeni danışma talebi alımı kapatıldı.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String message =
          error.toString().contains('permission-denied')
              ? 'Bu işlemi gerçekleştirmek için yetkiniz bulunmuyor.'
              : 'Danışma durumu güncellenemedi. Lütfen tekrar deneyin.';

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvailability = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = _currentUid;

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
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Uzman Paneli',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<Expert?>(
          stream: _expertRepository.watchExpert(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _green,
                ),
              );
            }

            if (snapshot.hasError) {
              return const _ExpertPanelMessageScreen(
                title: 'Uzman Profili Alınamadı',
                message:
                    'Uzman bilgileriniz yüklenirken bir sorun oluştu.',
                icon: Icons.error_outline_rounded,
              );
            }

            final Expert? expert = snapshot.data;

            if (expert == null) {
              return const _ExpertPanelMessageScreen(
                title: 'Uzman Profili Bulunamadı',
                message:
                    'Uzman profiliniz henüz oluşturulmamış veya erişime kapatılmış olabilir.',
                icon: Icons.person_search_outlined,
              );
            }

            return _buildPanel(expert);
          },
        ),
      ),
    );
  }

  Widget _buildPanel(Expert expert) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        34,
      ),
      children: [
        _ExpertHeader(expert: expert),
        const SizedBox(height: 18),

        if (!expert.isActive) ...[
          _SuspendedNotice(expert: expert),
          const SizedBox(height: 18),
        ],

        const _SectionTitle(
          title: 'Danışma Durumu',
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

        const SizedBox(height: 22),
        const _SectionTitle(
          title: 'Uzman İşlemleri',
        ),
        const SizedBox(height: 10),

        _ExpertActionCard(
          icon: Icons.inbox_outlined,
          title: 'Danışma Taleplerim',
          subtitle:
              'Yeni, devam eden ve tamamlanan danışma taleplerinizi yönetin.',
          onTap: () {
            _showComingSoon('Danışma Taleplerim');
          },
        ),

        _ExpertActionCard(
          icon: Icons.people_outline_rounded,
          title: 'Danışanlarım',
          subtitle:
              'Görüştüğünüz kullanıcıları ve gönderilen planları inceleyin.',
          onTap: () {
            _showComingSoon('Danışanlarım');
          },
        ),

        _ExpertActionCard(
          icon: Icons.badge_outlined,
          title: 'Uzman Profilim',
          subtitle:
              'Uygulamada gösterilen uzmanlık bilgilerinizi görüntüleyin.',
          onTap: () {
            _showComingSoon('Uzman Profilim');
          },
        ),

        _ExpertActionCard(
          icon: Icons.sync_alt_rounded,
          title: 'Şirket / Pozisyon Değişikliği',
          subtitle:
              'Yeni şirket veya görev bilgilerinizi yeniden doğrulamaya gönderin.',
          onTap: () {
            _showComingSoon(
              'Şirket ve pozisyon değişikliği',
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ExpertPanelScreenState._green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoş Geldiniz',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            expert.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _HeaderInformation(
            icon: Icons.apartment_rounded,
            text: expert.companyName,
          ),
          const SizedBox(height: 8),
          _HeaderInformation(
            icon: Icons.location_city_outlined,
            text: expert.branch,
          ),
          const SizedBox(height: 8),
          _HeaderInformation(
            icon: Icons.work_outline_rounded,
            text: expert.position,
          ),
        ],
      ),
    );
  }
}

class _HeaderInformation extends StatelessWidget {
  const _HeaderInformation({
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
          color: Colors.white70,
          size: 19,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
    final bool canChange = expert.isActive && !isUpdating;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _ExpertPanelScreenState._border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: expert.acceptsNewRequests
                  ? _ExpertPanelScreenState._softGreen
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              expert.acceptsNewRequests
                  ? Icons.mark_chat_unread_outlined
                  : Icons.do_not_disturb_alt_outlined,
              color: expert.acceptsNewRequests
                  ? _ExpertPanelScreenState._green
                  : _ExpertPanelScreenState._textMuted,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expert.acceptsNewRequests
                      ? 'Talep Alıyorum'
                      : 'Şu An Talep Almıyorum',
                  style: const TextStyle(
                    color: _ExpertPanelScreenState._textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expert.acceptsNewRequests
                      ? 'Kullanıcılar size yeni danışma talebi gönderebilir.'
                      : 'Profiliniz görünür ancak yeni danışma talebi gönderilemez.',
                  style: const TextStyle(
                    color: _ExpertPanelScreenState._textMuted,
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUpdating)
            const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: _ExpertPanelScreenState._green,
              ),
            )
          else
            Switch(
              value: expert.acceptsNewRequests,
              activeThumbColor:
                  _ExpertPanelScreenState._green,
              onChanged: canChange ? onChanged : null,
            ),
        ],
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
    final String message = expert.suspensionReason?.trim().isNotEmpty ==
            true
        ? expert.suspensionReason!
        : 'Uzman profiliniz şu anda inceleme veya doğrulama sürecindedir.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ExpertPanelScreenState._warningBackground,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: _ExpertPanelScreenState._warningText,
            size: 23,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uzman Profiliniz Aktif Değil',
                  style: TextStyle(
                    color: _ExpertPanelScreenState._warningText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _ExpertPanelScreenState._textDark,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ExpertActionCard extends StatelessWidget {
  const _ExpertActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _ExpertPanelScreenState._border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _ExpertPanelScreenState._softGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: _ExpertPanelScreenState._green,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color:
                              _ExpertPanelScreenState._textDark,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color:
                              _ExpertPanelScreenState._textMuted,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
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
      backgroundColor: const Color(0xFFF7F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F5),
        title: const Text(
          'Uzman Paneli',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color(0xFF0B5D3B),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}