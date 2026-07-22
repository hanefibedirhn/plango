import 'package:flutter/material.dart';

import 'admin_expert_applications_screen.dart';
import 'admin_consultation_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
  });

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);

  void _showComingSoon(
    BuildContext context,
    String moduleName,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$moduleName modülü sonraki geliştirme aşamasında bağlanacak.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          'Yönetici Paneli',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            36,
          ),
          children: [
            const _AdminHeader(),
            const SizedBox(height: 22),

            const _SectionTitle(
              title: 'Yönetim Merkezleri',
            ),
            const SizedBox(height: 10),

            _AdminModuleCard(
              icon: Icons.badge_outlined,
              title: 'Uzman Yönetimi',
              subtitle:
                  'Başvuruları inceleyin, uzmanları onaylayın ve durumlarını yönetin.',
              badgeText: 'Aktif',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminExpertApplicationsScreen(),
                  ),
                );
              },
            ),

            _AdminModuleCard(
              icon: Icons.handshake_outlined,
              title: 'Danışma Yönetimi',
              subtitle:
                  'Kullanıcı ve uzman arasındaki danışma taleplerini takip edin.',
              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const AdminConsultationManagementScreen(),
    ),
  );
},
            ),

            _AdminModuleCard(
              icon: Icons.people_outline_rounded,
              title: 'Kullanıcı Yönetimi',
              subtitle:
                  'Kullanıcı hesaplarını, hareketlerini ve uzmanlık durumlarını görüntüleyin.',
              onTap: () {
                _showComingSoon(
                  context,
                  'Kullanıcı Yönetimi',
                );
              },
            ),

            _AdminModuleCard(
              icon: Icons.dashboard_customize_outlined,
              title: 'İçerik Yönetimi',
              subtitle:
                  'Öne Çıkanlar, şirket bilgileri, duyurular ve uygulama içeriklerini yönetin.',
              onTap: () {
                _showComingSoon(
                  context,
                  'İçerik Yönetimi',
                );
              },
            ),

            _AdminModuleCard(
              icon: Icons.security_outlined,
              title: 'Sistem ve Denetim',
              subtitle:
                  'Şikâyetleri, yönetici işlemlerini ve sistem kayıtlarını inceleyin.',
              onTap: () {
                _showComingSoon(
                  context,
                  'Sistem ve Denetim',
                );
              },
            ),

            const SizedBox(height: 18),

            const _SecurityNotice(),
          ],
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminDashboardScreen._green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 38,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plango Yönetim Merkezi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Başvuruları, kullanıcı süreçlerini ve uygulama operasyonlarını tek merkezden yönetin.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
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
        color: AdminDashboardScreen._textDark,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AdminModuleCard extends StatelessWidget {
  const _AdminModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: AdminDashboardScreen._border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AdminDashboardScreen._softGreen,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: AdminDashboardScreen._green,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color:
                                    AdminDashboardScreen._textDark,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AdminDashboardScreen._softGreen,
                                borderRadius:
                                    BorderRadius.circular(999),
                              ),
                              child: Text(
                                badgeText!,
                                style: const TextStyle(
                                  color:
                                      AdminDashboardScreen._green,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color:
                              AdminDashboardScreen._textMuted,
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
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

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF92400E),
            size: 22,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Yönetici panelinde gerçekleştirilen kritik işlemler ileride işlem kayıtları ve yetki denetimiyle takip edilecektir.',
              style: TextStyle(
                color: Color(0xFF78350F),
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}