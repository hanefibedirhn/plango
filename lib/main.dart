import 'package:flutter/material.dart';
import 'screens/legal_info_screen.dart';
import 'engine/fp_engine.dart';
import 'screens/about_screen.dart';
import 'screens/companies_screen.dart';
import 'screens/calculator_screen.dart';

import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PlangoApp());
}

class PlangoApp extends StatelessWidget {
  const PlangoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plango',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B5D3B),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class AppColors {
  static const green = Color(0xFF0B5D3B);
  static const dark = Color(0xFF10231B);
  static const gold = Color(0xFFD6A84F);
  static const bg = Color(0xFFF7F8F5);
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goToDisclaimer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DisclaimerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text(
                    'P',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'PLANGO',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Türkiye’nin ilk bağımsız tasarruf finansmanı karar destek platformu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.4,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Planla. Karşılaştır. Karar Ver.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _goToDisclaimer(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Girişimi Başlat',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'v0.1.0 • Founder: Hanefi Bedirhan Turanoğlu',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool accepted = false;

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Önemli Bilgilendirme'),
        backgroundColor: AppColors.bg,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  Text(
                    'Plango bağımsız bir karar destek platformudur.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'FP Engine tarafından oluşturulan sonuçlar; kullanıcı tarafından girilen verilere göre üretilen bağımsız ve bilgilendirme amaçlı tahmini analizlerdir.',
                    style: TextStyle(fontSize: 16, height: 1.45),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Plango sözleşme oluşturmaz, ödeme kabul etmez, teslimat taahhüdünde bulunmaz ve hiçbir tasarruf finansman kuruluşu adına işlem yapmaz.',
                    style: TextStyle(fontSize: 16, height: 1.45),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Nihai planlama, sözleşme şartları ve teslim bilgileri ilgili tasarruf finansman kuruluşu tarafından belirlenir.',
                    style: TextStyle(fontSize: 16, height: 1.45),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Resmî karar vermeden önce ilgili tasarruf finansman kuruluşundan güncel bilgi almanız tavsiye edilir.',
                    style: TextStyle(fontSize: 16, height: 1.45),
                  ),
                ],
              ),
            ),
            CheckboxListTile(
              value: accepted,
              onChanged: (v) => setState(() => accepted = v ?? false),
              title: const Text('Okudum, anladım ve kabul ediyorum.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: accepted ? _continue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Devam Et'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalculatorScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'PLANGO',
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.green),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _heroCard(context),
          const SizedBox(height: 18),
          _sectionTitle('Piyasalar'),
          Row(
            children: const [
              Expanded(child: MarketCard(title: 'Altın', value: 'Demo', icon: Icons.monetization_on)),
              SizedBox(width: 10),
              Expanded(child: MarketCard(title: 'Dolar', value: 'Demo', icon: Icons.attach_money)),
              SizedBox(width: 10),
              Expanded(child: MarketCard(title: 'Euro', value: 'Demo', icon: Icons.euro)),
            ],
          ),
          const SizedBox(height: 22),
          _sectionTitle('V1 Bölümleri'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              const FeatureCard(title: 'Duyurular', icon: Icons.campaign),
              const FeatureCard(title: 'Rehber', icon: Icons.menu_book),
FeatureCard(
  title: 'Tasarruf Finansman\nŞirketleri',
  icon: Icons.business,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CompaniesScreen(),
      ),
    );
  },
),
              const FeatureCard(title: 'Uzmanlar', icon: Icons.verified_user),
              FeatureCard(
  title: 'Hakkımızda',
  icon: Icons.info_outline,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  },
),

FeatureCard(
  title: 'Yasal Bilgi',
  icon: Icons.gavel,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LegalInfoScreen()),
    );
  },
),
               ],
          ),
        ],
      ),
    );
  }        

  Widget _heroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tasarruf finansman planını oluştur.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ne zaman teslim alabileceğini ve tahmini vadeni görüntüle.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => _openCalculator(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.dark,
            ),
            child: const Text('Hesaplamaya Başla'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class MarketCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const MarketCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.green),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.green, size: 30),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

