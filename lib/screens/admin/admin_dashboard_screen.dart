import 'package:flutter/material.dart';

import 'admin_consultation_management_screen.dart';
import 'admin_experts_screen.dart';
import 'admin_featured_list_screen.dart';
import 'admin_feedback_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
  });

  // ============================================================
  // TASARRUF PLANIM DESIGN SYSTEM
  // ============================================================

  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);

  static const Color _background = Color(0xFFF7F9FB);
  static const Color _textMuted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openExpertManagement(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminExpertsScreen(),
      ),
    );
  }

  void _openConsultationManagement(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AdminConsultationManagementScreen(),
      ),
    );
  }

  void _openFeaturedManagement(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminFeaturedListScreen(),
      ),
    );
  }

  void _openFeedbackManagement(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminFeedbackScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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
        centerTitle: false,
        title: const Text(
          'Yönetici Paneli',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
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
            36,
          ),
          children: [
            const _AdminHeroCard(),

            const SizedBox(height: 24),

            const _SectionHeader(
              icon: Icons.dashboard_outlined,
              title: 'Yönetim Merkezleri',
              subtitle:
                  'Platform operasyonlarına hızlı erişim sağlayın.',
            ),

            const SizedBox(height: 13),

            // ==================================================
            // UZMANLAR
            // ==================================================

            _AdminModuleCard(
              icon: Icons.workspace_premium_outlined,
              title: 'Uzmanlar',
              subtitle:
                  'Uzman ağını, durumlarını ve talep süreçlerini yönetin.',
              onTap: () {
                _openExpertManagement(context);
              },
            ),

            const SizedBox(height: 9),

            // ==================================================
            // DANIŞMALAR
            // ==================================================

            _AdminModuleCard(
              icon: Icons.handshake_outlined,
              title: 'Danışmalar',
              subtitle:
                  'Danışma taleplerini ve operasyon süreçlerini yönetin.',
              onTap: () {
                _openConsultationManagement(context);
              },
            ),

            const SizedBox(height: 9),

            // ==================================================
            // İÇERİKLER
            // ==================================================

            _AdminModuleCard(
              icon: Icons.newspaper_rounded,
              title: 'İçerikler',
              subtitle:
                  'Ana sayfadaki Öne Çıkanlar içeriklerini yönetin.',
              onTap: () {
                _openFeaturedManagement(context);
              },
            ),

            const SizedBox(height: 9),

            // ==================================================
            // ŞİKAYET & ÖNERİ
            // ==================================================

            _AdminModuleCard(
              icon: Icons.forum_outlined,
              title: 'Şikayet & Öneri',
              subtitle:
                  'Kullanıcı taleplerini inceleyin ve yanıtlayın.',
              highlight: true,
              onTap: () {
                _openFeedbackManagement(context);
              },
            ),

            const SizedBox(height: 24),

            const _AdminFooter(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _AdminHeroCard extends StatelessWidget {
  const _AdminHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        16,
        18,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AdminDashboardScreen._navy,
            AdminDashboardScreen._petrol,
            Color(0xFF07535A),
            AdminDashboardScreen._teal,
          ],
          stops: [
            0.0,
            0.36,
            0.72,
            1.0,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240B2239),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.13,
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF55E2D0),
                        size: 13,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'TASARRUF PLANIM ADMIN',
                        style: TextStyle(
                          color: Color(0xFFDDF7F3),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 13),

                const Text(
                  'Yönetim Merkezi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Tasarruf Planım operasyonlarını ve platform '
                  'içeriklerini tek merkezden yönetin.',
                  style: TextStyle(
                    color: Color(0xFFD6E6E8),
                    fontSize: 12.2,
                    height: 1.48,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color:
                  AdminDashboardScreen._turquoise.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: const Color(0xFF55E2D0).withValues(
                  alpha: 0.22,
                ),
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Color(0xFF55E2D0),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
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
            color: const Color(0xFFE8F7F5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: AdminDashboardScreen._teal,
            size: 18,
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
                  color: AdminDashboardScreen._navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AdminDashboardScreen._textMuted,
                  fontSize: 10.8,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HORIZONTAL MANAGEMENT CARD
// ============================================================

class _AdminModuleCard extends StatelessWidget {
  const _AdminModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final Color iconBackground = highlight
        ? const Color(0xFFDDF7F3)
        : const Color(0xFFEAF5F4);

    final Color borderColor = highlight
        ? AdminDashboardScreen._turquoise.withValues(
            alpha: 0.32,
          )
        : AdminDashboardScreen._border;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            13,
            12,
            12,
            12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B2239).withValues(
                  alpha: highlight ? 0.045 : 0.025,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // ICON
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AdminDashboardScreen._teal,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AdminDashboardScreen._navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            AdminDashboardScreen._textMuted,
                        fontSize: 10.7,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F7F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8B98A5),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FOOTER
// ============================================================

class _AdminFooter extends StatelessWidget {
  const _AdminFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD8ECE9),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AdminDashboardScreen._teal,
            size: 19,
          ),

          SizedBox(width: 9),

          Expanded(
            child: Text(
              'Yönetim işlemleri yalnızca yetkili yönetici '
              'hesapları üzerinden gerçekleştirilmelidir.',
              style: TextStyle(
                color: Color(0xFF48636B),
                fontSize: 10.8,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}