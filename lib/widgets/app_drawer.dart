import 'package:flutter/material.dart';

import '../screens/about_screen.dart';
import '../screens/companies_screen.dart';
import '../screens/legal_info_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  void _openPage(
    BuildContext context,
    Widget page,
  ) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _background,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLANGO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: _green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bağımsız Tasarruf Finansmanı\nKarar Destek Platformu',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    title: 'Ana Sayfa',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.campaign_outlined,
                    title: 'Duyurular',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Doğrulanmış Uzmanlar',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.business_outlined,
                    title: 'Tasarruf Finansman Şirketleri',
                    onTap: () {
                      _openPage(
                        context,
                        const CompaniesScreen(),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_outlined,
                    title: 'Faizsiz Finansman Sistemi',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.gavel_outlined,
                    title: 'Yasal Bilgilendirme',
                    onTap: () {
                      _openPage(
                        context,
                        const LegalInfoScreen(),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Hakkımızda',
                    onTap: () {
                      _openPage(
                        context,
                        const AboutScreen(),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Ayarlar',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Plango v1.0.0',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Icon(
          icon,
          color: AppDrawer._green,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: AppDrawer._textDark,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF9CA3AF),
        ),
        onTap: onTap,
      ),
    );
  }
}