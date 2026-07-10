import 'package:flutter/material.dart';

import '../models/company.dart';

class CompanyDetailScreen extends StatelessWidget {
  final Company company;

  const CompanyDetailScreen({
    super.key,
    required this.company,
  });

  static const Color _pageBg = Color(0xFFF6F7F8);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _plangoGreen = Color(0xFF0F7A4F);
  static const Color _softGreen = Color(0xFFEAF7F1);
  static const Color _divider = Color(0xFFE5E7EB);
  static const Color _linkBlue = Color(0xFF2563EB);

  String get _displayWebsite {
    return company.website
        .replaceFirst('https://', '')
        .replaceFirst('http://', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
  backgroundColor: _pageBg,
  foregroundColor: _textDark,
  elevation: 0,
),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          _buildInfoCard(),
          const SizedBox(height: 14),
          _buildActionCard(),
          const SizedBox(height: 16),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: _plangoGreen,
                ),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'BDDK Lisanslı Tasarruf Finansman Şirketi',
                    style: TextStyle(
                      color: _plangoGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _divider),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Kuruluş',
            value: company.foundedYear.toString(),
          ),
          const Divider(height: 1, color: _divider),
          _InfoRow(
            label: 'Şube Sayısı',
            value: company.branchCount,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _divider),
    ),
    child: Column(
      children: [
        _ActionRow(
          icon: Icons.language_rounded,
          title: 'Resmî Web Sitesi',
          subtitle: _displayWebsite,
          subtitleColor: _linkBlue,
          onTap: () {},
        ),
        const Divider(height: 1, color: _divider),
        _ActionRow(
          icon: Icons.star_outline_rounded,
          title: 'Şikayetvar Sayfasını Aç',
          onTap: () {},
        ),
        const Divider(height: 1, color: _divider),
        _ActionRow(
          icon: Icons.verified_user_outlined,
          title: 'Doğrulanmış Uzmanları Gör',
          onTap: () {},
        ),
        const Divider(height: 1, color: _divider),
        _ActionRow(
          icon: Icons.calculate_outlined,
          title: 'FP Engine\'e Git',
          onTap: () {},
        ),
      ],
    ),
  );
}

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: _textMuted,
              ),
              SizedBox(width: 8),
              Text(
                'Bilgilendirme',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Bu sayfada yer alan bilgiler yalnızca genel bilgilendirme amacıyla sunulmaktadır. '
            'Plango herhangi bir tasarruf finansman şirketini tavsiye etmez, sıralamaz veya diğer şirketlere üstün göstermez.\n\n'
            'Şirketlere ilişkin güncel ve bağlayıcı bilgiler için ilgili şirketlerin resmî internet siteleri, '
            'resmî kurum açıklamaları ve ilgili platformlarda yayımlanan güncel bilgiler esas alınmalıdır.',
            style: TextStyle(
              color: _textMuted,
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0F7A4F),
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color:
                            subtitleColor ?? const Color(0xFF6B7280),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
    );
  }
}