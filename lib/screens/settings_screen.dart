import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _calculationNotificationsEnabled = true;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature daha sonra bağlanacak.'),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
            'Plango hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Çıkış sistemi sonraki adımda mevcut Firebase yapısına bağlanacak.',
                    ),
                  ),
                );
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Hesap'),
          const SizedBox(height: 8),

          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Profil Bilgileri',
                subtitle: 'Ad, soyad ve telefon bilgilerinizi düzenleyin.',
                onTap: () {
                  _showComingSoon('Profil bilgileri');
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Şifre Değiştir',
                subtitle: 'Hesap şifrenizi güvenli şekilde güncelleyin.',
                onTap: () {
                  _showComingSoon('Şifre değiştirme ekranı');
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Uzman Başvurusu',
                subtitle:
                    'Uzman başvurusu oluşturun veya başvuru durumunuzu görüntüleyin.',
                onTap: () {
                  _showComingSoon('Uzman başvuru sistemi');
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Bildirimler'),
          const SizedBox(height: 8),

          _buildSettingsCard(
            children: [
              SwitchListTile(
                secondary: const Icon(
                  Icons.notifications_outlined,
                ),
                title: const Text(
                  'Uygulama Bildirimleri',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Plango ile ilgili önemli bilgilendirmeleri alın.',
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;

                    if (!value) {
                      _calculationNotificationsEnabled = false;
                    }
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(
                  Icons.calculate_outlined,
                ),
                title: const Text(
                  'Plan Hatırlatmaları',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Kayıtlı planlarınızla ilgili hatırlatmaları alın.',
                ),
                value: _calculationNotificationsEnabled,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _calculationNotificationsEnabled = value;
                        });
                      }
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Uygulama'),
          const SizedBox(height: 8),

          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.language_outlined,
                title: 'Dil',
                subtitle: 'Türkçe',
                onTap: () {
                  _showComingSoon('Dil seçimi');
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Görünüm',
                subtitle: 'Sistem ayarını kullan',
                onTap: () {
                  _showComingSoon('Tema seçimi');
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Bilgilendirme'),
          const SizedBox(height: 8),

          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'Hakkımızda',
                subtitle: 'Plango hakkında bilgi edinin.',
                onTap: () {
                  _showComingSoon('Hakkımızda ekranı');
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.gavel_outlined,
                title: 'Yasal Bilgilendirme',
                subtitle:
                    'Kullanım koşulları ve yasal açıklamaları görüntüleyin.',
                onTap: () {
                  _showComingSoon('Yasal bilgilendirme ekranı');
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Gizlilik Politikası',
                subtitle:
                    'Kişisel verilerin nasıl kullanıldığını inceleyin.',
                onTap: () {
                  _showComingSoon('Gizlilik politikası');
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Sıkça Sorulan Sorular',
                subtitle: 'Merak ettiğiniz soruların cevaplarını inceleyin.',
                onTap: () {
                  _showComingSoon('SSS ekranı');
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Oturum'),
          const SizedBox(height: 8),

          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Çıkış Yap',
                titleColor: Colors.red,
                showArrow: false,
                onTap: _showLogoutDialog,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'Plango V1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingsCard({
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
            ),
      trailing: showArrow
          ? const Icon(
              Icons.chevron_right,
            )
          : null,
      onTap: onTap,
    );
  }
}