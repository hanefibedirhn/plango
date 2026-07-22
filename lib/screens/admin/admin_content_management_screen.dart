import 'package:flutter/material.dart';

import 'admin_featured_list_screen.dart';

class AdminContentManagementScreen extends StatelessWidget {
  const AdminContentManagementScreen({super.key});

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);

  void _comingSoon(
    BuildContext context,
    String title,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title ekranı birazdan oluşturulacak."),
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
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _textDark,
        title: const Text(
          "İçerik Yönetimi",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.dashboard_customize,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(height: 10),
                Text(
                  "İçerik Merkezi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Öne Çıkanlar ve Kampanyalar içeriklerini buradan yönetin.",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          _MenuCard(
            icon: Icons.newspaper,
            title: "Öne Çıkanlar",
            subtitle:
                "Sektör haberleri, duyurular ve uygulama içerikleri",
            onTap: () {
              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdminFeaturedListScreen(),
  ),
);
            },
          ),

          _MenuCard(
            icon: Icons.local_offer_outlined,
            title: "Kampanyalar",
            subtitle:
                "Firmaların kampanyalarını yönetin",
            onTap: () {
              _comingSoon(context, "Kampanyalar");
            },
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AdminContentManagementScreen._border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AdminContentManagementScreen._softGreen,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: AdminContentManagementScreen._green,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              AdminContentManagementScreen._textDark,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color:
                              AdminContentManagementScreen._textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}