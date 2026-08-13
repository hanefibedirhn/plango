import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/company.dart';
import 'calculator_screen.dart';

class CompanyDetailScreen extends StatefulWidget {
  const CompanyDetailScreen({
    super.key,
    required this.company,
  });

  final Company company;

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4E9EE);

  bool _isAboutExpanded = false;

  Company get company => widget.company;

  String get _displayWebsite {
    return company.website
        .replaceFirst('https://', '')
        .replaceFirst('http://', '')
        .replaceFirst(RegExp(r'/$'), '');
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Bağlantı açılamadı. Lütfen tekrar deneyin.'),
          ),
        );
    }
  }

  void _openCalculator({bool forConsultation = false}) {
    if (forConsultation) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${company.name} için danışma talebi oluşturmadan önce planınızı hesaplayın.',
            ),
          ),
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CalculatorScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _navy,
        title: const Text(
          'Şirket Detayı',
          style: TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 38),
        children: [
          _buildHero(),
          const SizedBox(height: 14),
          _buildCompanyFacts(),
          const SizedBox(height: 22),
          _buildAboutSection(),
          const SizedBox(height: 22),
          _buildLinksCard(),
          const SizedBox(height: 14),
          _buildActions(),
          const SizedBox(height: 18),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0FAF8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.055),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 118,
            height: 88,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: _navy.withOpacity(0.055),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Image.asset(
              company.logoAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    company.name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: _teal,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 17),
          Text(
            company.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navy,
              fontSize: 25,
              height: 1.1,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            company.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _turquoise.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _turquoise.withOpacity(0.28)),
            ),
            child: const Text(
              'BDDK LİSANSLI',
              style: TextStyle(
                color: _teal,
                fontSize: 10.5,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyFacts() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _factRow('Kuruluş', company.foundedYear.toString()),
          const Divider(height: 1, indent: 17, endIndent: 17, color: _border),
          _factRow('Genel Merkez', company.headquarters),
          const Divider(height: 1, indent: 17, endIndent: 17, color: _border),
          _factRow('Şube Sayısı', company.branchCount),
        ],
      ),
    );
  }

  Widget _factRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _navy,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Şirket Hakkında',
          style: TextStyle(
            color: _navy,
            fontSize: 19,
            letterSpacing: -0.25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.035),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Text(
                  company.about,
                  maxLines: _isAboutExpanded ? null : 7,
                  overflow: _isAboutExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF465567),
                    fontSize: 13.5,
                    height: 1.68,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 9),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isAboutExpanded = !_isAboutExpanded;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: _teal,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isAboutExpanded ? 'Daha Az Göster' : 'Devamını Oku',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _isAboutExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 260),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Bu içerik, ilgili şirketin resmî kurumsal kaynaklarında yer alan bilgiler esas alınarak Tasarruf Planım tarafından özetlenmiştir.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10.8,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinksCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.03),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _linkRow(
            title: 'Resmî Web Sitesi',
            subtitle: _displayWebsite,
            onTap: () => _openUrl(company.website),
          ),
          const Divider(height: 1, indent: 17, endIndent: 17, color: _border),
          _linkRow(
            title: 'Şikayetvar',
            subtitle: 'Kullanıcı değerlendirmelerini görüntüle',
            onTap: () => _openUrl(company.complaintUrl),
          ),
        ],
      ),
    );
  }

  Widget _linkRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 15, 14, 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, color: _teal, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _openCalculator,
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Text('Plan Oluştur'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: () => _openCalculator(forConsultation: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              backgroundColor: Colors.white,
              side: const BorderSide(color: _teal, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Text('Uzmana Danış'),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _petrol.withOpacity(0.045),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _petrol.withOpacity(0.08)),
      ),
      child: const Text(
        'Tasarruf Planım herhangi bir tasarruf finansman şirketini tavsiye etmez, sıralamaz veya diğer şirketlere üstün göstermez. Güncel ve bağlayıcı bilgiler için şirketin resmî teklifleri ile sözleşme hükümleri esas alınmalıdır.',
        style: TextStyle(
          color: Color(0xFF5E6D7E),
          fontSize: 11.5,
          height: 1.55,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
