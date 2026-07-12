import 'package:flutter/material.dart';
import 'profile_information_screen.dart';
import '../services/auth_service.dart';

enum ExpertApplicationStatus {
  none,
  pending,
  rejected,
  approved,
}

class AccountScreen extends StatelessWidget {
 AccountScreen({
    super.key,
    this.userName = 'Hanefi Bedirhan',
    this.expertStatus = ExpertApplicationStatus.none,
    this.isAdmin = false,
  });

  final AuthService _authService = AuthService();
  final String userName;
  final ExpertApplicationStatus expertStatus;
  final bool isAdmin;

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  void _showComingSoon(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExpertAction(BuildContext context) {
    switch (expertStatus) {
      case ExpertApplicationStatus.none:
        _showComingSoon(
          context,
          'Uzman başvuru ekranı bir sonraki adımda bağlanacak.',
        );
        break;

      case ExpertApplicationStatus.pending:
        _showComingSoon(
          context,
          'Uzman başvurunuz yönetici tarafından inceleniyor.',
        );
        break;

      case ExpertApplicationStatus.rejected:
        _showComingSoon(
          context,
          'Uzman başvuru sonucu ekranı bir sonraki adımda bağlanacak.',
        );
        break;

      case ExpertApplicationStatus.approved:
        _showComingSoon(
          context,
          'Uzman paneli bir sonraki adımda bağlanacak.',
        );
        break;
    }
  }

  String get _expertTitle {
    switch (expertStatus) {
      case ExpertApplicationStatus.none:
        return 'Uzman Başvurusu Yap';

      case ExpertApplicationStatus.pending:
        return 'Uzman Başvurunuz İnceleniyor';

      case ExpertApplicationStatus.rejected:
        return 'Başvuru Sonucunu Gör';

      case ExpertApplicationStatus.approved:
        return 'Uzman Paneline Git';
    }
  }

  String get _expertSubtitle {
    switch (expertStatus) {
      case ExpertApplicationStatus.none:
        return 'Plango uzmanlık başvurunuzu oluşturun.';

      case ExpertApplicationStatus.pending:
        return 'Başvurunuz yönetici değerlendirmesindedir.';

      case ExpertApplicationStatus.rejected:
        return 'Başvurunuzla ilgili sonucu inceleyin.';

      case ExpertApplicationStatus.approved:
        return 'Danışma taleplerinizi ve uzman profilinizi yönetin.';
    }
  }

  IconData get _expertIcon {
    switch (expertStatus) {
      case ExpertApplicationStatus.none:
        return Icons.person_add_alt_1_outlined;

      case ExpertApplicationStatus.pending:
        return Icons.hourglass_top_rounded;

      case ExpertApplicationStatus.rejected:
        return Icons.info_outline_rounded;

      case ExpertApplicationStatus.approved:
        return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hesabım',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
          children: [
            _AccountHeader(
              userName: userName,
            ),
            const SizedBox(height: 20),

            const _SectionTitle(
              title: 'Hesap İşlemleri',
            ),
            const SizedBox(height: 10),

            _AccountCard(
  icon: Icons.person_outline_rounded,
  title: 'Profil Bilgilerim',
  subtitle: 'Kişisel bilgilerinizi ve şifrenizi yönetin.',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileInformationScreen(),
      ),
    );
  },
),

            _AccountCard(
              icon: Icons.bookmark_border_rounded,
              title: 'Kayıtlı Planlarım',
              subtitle: 'Kaydettiğiniz hesaplama planlarını görüntüleyin.',
              onTap: () {
                _showComingSoon(
                  context,
                  'Kayıtlı Planlarım ekranı daha sonra bağlanacak.',
                );
              },
            ),

            _AccountCard(
              icon: Icons.handshake_outlined,
              title: 'Danışma Taleplerim',
              subtitle: 'Uzmanlara gönderdiğiniz talepleri takip edin.',
              onTap: () {
                _showComingSoon(
                  context,
                  'Danışma Taleplerim ekranı daha sonra bağlanacak.',
                );
              },
            ),

            const SizedBox(height: 22),
            const _SectionTitle(
              title: 'Panel ve Yetkiler',
            ),
            const SizedBox(height: 10),

            _AccountCard(
              icon: _expertIcon,
              title: _expertTitle,
              subtitle: _expertSubtitle,
              onTap: () {
                _handleExpertAction(context);
              },
            ),

            if (isAdmin)
              _AccountCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Yönetici Paneline Git',
                subtitle: 'Plango yönetim işlemlerine erişin.',
                onTap: () {
                  _showComingSoon(
                    context,
                    'Yönetici paneli bir sonraki adımda bağlanacak.',
                  );
                },
              ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
  onPressed: () {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Çıkış Yap',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
            style: TextStyle(
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _authService.logout();

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Hesabınızdan çıkış yapıldı.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } on AuthServiceException catch (error) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.message),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  },
  icon: const Icon(
    Icons.logout_rounded,
  ),
  label: const Text(
    'Çıkış Yap',
  ),
  style: OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFB42318),
    side: const BorderSide(
      color: Color(0xFFF2B8B5),
    ),
    minimumSize: const Size.fromHeight(56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: const TextStyle(
      fontSize: 15.5,
      fontWeight: FontWeight.w900,
    ),
    ),
),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AccountScreen._green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 33,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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
        color: AccountScreen._textDark,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
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
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AccountScreen._border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1EC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: AccountScreen._green,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AccountScreen._textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AccountScreen._textMuted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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