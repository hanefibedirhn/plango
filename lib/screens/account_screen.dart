import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'admin/admin_dashboard_screen.dart';
import 'expert_application_screen.dart';
import 'expert_panel_screen.dart';
import 'profile_information_screen.dart';
import 'legal_info_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'user_agreement_screen.dart';
import 'expert_agreement_screen.dart';
import 'feedback_screen.dart';
import 'my_consultation_requests_screen.dart';

enum ExpertApplicationStatus {
  none,
  pending,
  rejected,
  approved,
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    this.userName = '',
    this.expertStatus = ExpertApplicationStatus.none,
    this.isAdmin = false,
  });

  final String userName;
  final ExpertApplicationStatus expertStatus;
  final bool isAdmin;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();

  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  bool _darkMode = false;

  Color get _pageBackground =>
      _darkMode ? const Color(0xFF07141D) : _background;

  Color get _cardBackground =>
      _darkMode ? const Color(0xFF10232E) : Colors.white;

  Color get _primaryText =>
      _darkMode ? const Color(0xFFF2F7F8) : _navy;

  Color get _secondaryText =>
      _darkMode ? const Color(0xFF9FB0BB) : _muted;

  Color get _divider =>
      _darkMode ? const Color(0xFF263B46) : _border;

  Color get _softTeal =>
      _darkMode ? const Color(0xFF123C3B) : const Color(0xFFE8F7F5);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExpertAction() {
    switch (widget.expertStatus) {
      case ExpertApplicationStatus.none:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpertApplicationScreen(),
          ),
        );
        break;

      case ExpertApplicationStatus.pending:
        _showMessage('Uzman başvurunuz incelenmektedir.');
        break;

      case ExpertApplicationStatus.rejected:
        _showMessage(
          'Uzman başvurunuz reddedildi. Yeni başvuru süreci daha sonra açılabilir.',
        );
        break;

      case ExpertApplicationStatus.approved:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpertPanelScreen(),
          ),
        );
        break;
    }
  }

  String get _expertTitle {
    switch (widget.expertStatus) {
      case ExpertApplicationStatus.none:
        return 'Uzman Başvurusu';
      case ExpertApplicationStatus.pending:
        return 'Uzman Başvurusu İnceleniyor';
      case ExpertApplicationStatus.rejected:
        return 'Uzman Başvuru Sonucu';
      case ExpertApplicationStatus.approved:
        return 'Uzman Paneli';
    }
  }

  String get _expertSubtitle {
    switch (widget.expertStatus) {
      case ExpertApplicationStatus.none:
        return 'Tasarruf Planım uzmanlık başvurunu oluştur.';
      case ExpertApplicationStatus.pending:
        return 'Başvurun yönetici değerlendirmesinde.';
      case ExpertApplicationStatus.rejected:
        return 'Başvuru durumunu görüntüle.';
      case ExpertApplicationStatus.approved:
        return 'Danışma taleplerini ve uzman işlemlerini yönet.';
    }
  }

  IconData get _expertIcon {
    switch (widget.expertStatus) {
      case ExpertApplicationStatus.none:
        return Icons.person_add_alt_1_rounded;
      case ExpertApplicationStatus.pending:
        return Icons.hourglass_top_rounded;
      case ExpertApplicationStatus.rejected:
        return Icons.info_outline_rounded;
      case ExpertApplicationStatus.approved:
        return Icons.workspace_premium_outlined;
    }
  }

  Future<void> _logout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Çıkış Yap',
            style: TextStyle(
              color: _primaryText,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Hesabından çıkış yapmak istediğine emin misin?',
            style: TextStyle(
              color: _secondaryText,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hesabından çıkış yapıldı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openInformationPage({
    required String title,
    required IconData icon,
    required List<_InformationSectionData> sections,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _InformationScreen(
          title: title,
          icon: icon,
          sections: sections,
        ),
      ),
    );
  }

  void _openLegalInformation() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LegalInformationScreen(),
    ),
  );
}

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutScreen(),
      ),
    );
  }

  void _openFeedback() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const FeedbackScreen(),
    ),
  );
}

  void _openPrivacyPolicy() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PrivacyPolicyScreen(),
    ),
  );
}

  void _openUserAgreement() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const UserAgreementScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pageBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _primaryText,
        centerTitle: false,
        title: Text(
          'Profil',
          style: TextStyle(
            color: _primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            38,
          ),
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 20),

            _buildSectionLabel('Hesabım'),

            const SizedBox(height: 8),

            _buildMenuGroup(
              children: [
                _ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Profil Bilgilerim',
                  subtitle: 'Kişisel bilgilerini ve şifreni yönet.',
                  iconBackground: _softTeal,
                  iconColor: _teal,
                  titleColor: _primaryText,
                  subtitleColor: _secondaryText,
                  dividerColor: _divider,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ProfileInformationScreen(),
                      ),
                    );
                  },
                ),

                _ProfileMenuTile(
  icon: Icons.support_agent_outlined,
  title: 'Danışma Taleplerim',
  subtitle: 'Danışma taleplerini ve durumlarını takip et.',
  iconBackground: _softTeal,
  iconColor: _teal,
  titleColor: _primaryText,
  subtitleColor: _secondaryText,
  dividerColor: _divider,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MyConsultationRequestsScreen(),
      ),
    );
  },
),

                _ProfileMenuTile(
                  icon: _expertIcon,
                  title: _expertTitle,
                  subtitle: _expertSubtitle,
                  iconBackground: _softTeal,
                  iconColor: _teal,
                  titleColor: _primaryText,
                  subtitleColor: _secondaryText,
                  dividerColor: _divider,
                  onTap: _handleExpertAction,
                ),

                if (widget.isAdmin)
                  _ProfileMenuTile(
                    icon:
                        Icons.admin_panel_settings_outlined,
                    title: 'Yönetici Paneli',
                    subtitle:
                        'Tasarruf Planım içeriklerini ve yönetim işlemlerini yönet.',
                    iconBackground:
                        _darkMode
                            ? const Color(0xFF2C2940)
                            : const Color(0xFFF0ECFF),
                    iconColor: const Color(0xFF6750A4),
                    titleColor: _primaryText,
                    subtitleColor: _secondaryText,
                    dividerColor: _divider,
                    showDivider: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminDashboardScreen(),
                        ),
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 22),

            _buildSectionLabel('Görünüm'),

            const SizedBox(height: 8),

            _buildThemeCard(),

            const SizedBox(height: 22),

            _buildSectionLabel('Tasarruf Planım Hakkında'),

            const SizedBox(height: 8),

            _buildMenuGroup(
              children: [
                _ProfileMenuTile(
                  icon: Icons.gavel_rounded,
                  title: 'Yasal Bilgilendirme',
                  iconBackground: _softTeal,
                  iconColor: _teal,
                  titleColor: _primaryText,
                  subtitleColor: _secondaryText,
                  dividerColor: _divider,
                  onTap: _openLegalInformation,
                ),
                _ProfileMenuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Hakkımızda',
                  iconBackground: _softTeal,
                  iconColor: _teal,
                  titleColor: _primaryText,
                  subtitleColor: _secondaryText,
                  dividerColor: _divider,
                  onTap: _openAbout,
                ),
                _ProfileMenuTile(
  icon: Icons.chat_bubble_outline_rounded,
  title: 'Şikayet ve Öneri',
  iconBackground: _softTeal,
  iconColor: _teal,
  titleColor: _primaryText,
  subtitleColor: _secondaryText,
  dividerColor: _divider,
  onTap: _openFeedback,
),
                _ProfileMenuTile(
                  icon: Icons.shield_outlined,
                  title: 'Gizlilik Politikası',
                  iconBackground: _softTeal,
                  iconColor: _teal,
                  titleColor: _primaryText,
                  subtitleColor: _secondaryText,
                  dividerColor: _divider,
                  onTap: _openPrivacyPolicy,
                ),
                _ProfileMenuTile(
  icon: Icons.description_outlined,
  title: 'Kullanıcı Sözleşmesi',
  iconBackground: _softTeal,
  iconColor: _teal,
  titleColor: _primaryText,
  subtitleColor: _secondaryText,
  dividerColor: _divider,
  onTap: _openUserAgreement,
),
_ProfileMenuTile(
  icon: Icons.workspace_premium_outlined,
  title: 'Uzman Sözleşmesi',
  subtitle: 'Uzmanlık şartlarını ve yükümlülüklerini inceleyin.',
  iconBackground: _softTeal,
  iconColor: _teal,
  titleColor: _primaryText,
  subtitleColor: _secondaryText,
  dividerColor: _divider,
  showDivider: false,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExpertAgreementScreen(),
      ),
    );
  },
),
              ],
            ),

            const SizedBox(height: 24),

            _buildLogoutButton(),

            const SizedBox(height: 18),

            Center(
              child: Text(
                'Tasarruf Planım',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final String cleanName = widget.userName.trim();
    final String visibleName =
        cleanName.isEmpty ? 'Tasarruf Planım Kullanıcısı' : cleanName;

    String initials = 'P';

    if (cleanName.isNotEmpty) {
      final List<String> parts = cleanName
          .split(' ')
          .where((element) => element.trim().isNotEmpty)
          .toList();

      if (parts.length >= 2) {
        initials =
            '${parts.first.characters.first}${parts.last.characters.first}'
                .toUpperCase();
      } else if (parts.isNotEmpty) {
        initials = parts.first.characters.first.toUpperCase();
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        17,
        16,
        17,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _petrol,
            Color(0xFF07585A),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _petrol.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.white.withOpacity(0.13),
              ),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hesabın',
                  style: TextStyle(
                    color: Color(0xFFB9D8D8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  visibleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _turquoise.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF50E1CF),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: TextStyle(
        color: _primaryText,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.1,
      ),
    );
  }

  Widget _buildMenuGroup({
    required List<Widget> children,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _divider,
        ),
        boxShadow: _darkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildThemeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _softTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _darkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_outlined,
              color: _teal,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Karanlık Mod',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _darkMode ? 'Karanlık tema açık' : 'Açık tema kullanılıyor',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: _darkMode,
            activeColor: _teal,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(
          Icons.logout_rounded,
          size: 19,
        ),
        label: const Text(
          'Çıkış Yap',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFB42318),
          backgroundColor: _cardBackground,
          side: BorderSide(
            color: _darkMode
                ? const Color(0xFF653733)
                : const Color(0xFFF0CAC7),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.iconBackground,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.dividerColor,
    required this.onTap,
    this.subtitle,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color dividerColor;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null &&
                            subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 10.5,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: subtitleColor.withOpacity(0.65),
                    size: 20,
                  ),
                ],
              ),
            ),

            if (showDivider)
              Padding(
                padding: const EdgeInsets.only(
                  left: 65,
                ),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: dividerColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InformationSectionData {
  const _InformationSectionData({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class _InformationScreen extends StatelessWidget {
  const _InformationScreen({
    required this.title,
    required this.icon,
    required this.sections,
  });

  final String title;
  final IconData icon;
  final List<_InformationSectionData> sections;

  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          36,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _petrol,
                  Color(0xFF075B5A),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF53E3D0),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ...sections.map(
            (section) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4EBEE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    section.body,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
