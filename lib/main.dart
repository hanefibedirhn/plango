import 'package:flutter/material.dart';
import 'screens/legal_info_screen.dart';
import 'engine/fp_engine.dart';
import 'screens/about_screen.dart';
import 'screens/companies_screen.dart';
import 'screens/calculator_screen.dart';
import 'widgets/app_drawer.dart';
import 'screens/login_selection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    drawer: const AppDrawer(),
    appBar: AppBar(
      backgroundColor: AppColors.bg,
      title: const Text(
        'PLANGO',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.green,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginSelectionScreen(),
              ),
            );
          },
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
    const Row(
      children: [
        Expanded(
          child: MarketCard(
            title: 'Altın',
            value: 'Demo',
            icon: Icons.monetization_on,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: MarketCard(
            title: 'Dolar',
            value: 'Demo',
            icon: Icons.attach_money,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: MarketCard(
            title: 'Euro',
            value: 'Demo',
            icon: Icons.euro,
          ),
        ),
      ],
    ),
    const SizedBox(height: 22),
    _highlightsSection(context),
  ],
),
);
}
Widget _highlightsSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Öne Çıkanlar',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // İleride tüm duyurular sayfasına bağlanacak.
            },
            child: const Text('Tümünü Gör'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _highlightRow(
              icon: Icons.account_balance_outlined,
              title: 'Sektörel gelişmeleri takip edin',
              subtitle: 'Mevzuat ve sektör duyuruları',
              onTap: () {},
            ),
            const Divider(
              height: 1,
              indent: 68,
              color: Color(0xFFE5E7EB),
            ),
            _highlightRow(
              icon: Icons.campaign_outlined,
              title: 'Plango duyuruları',
              subtitle: 'Yeni özellikler ve güncellemeler',
              onTap: () {},
            ),
            const Divider(
              height: 1,
              indent: 68,
              color: Color(0xFFE5E7EB),
            ),
            _highlightRow(
              icon: Icons.auto_awesome_outlined,
              title: 'Yeni içerikleri keşfedin',
              subtitle: 'Hesaplama, şirketler ve bilgilendirmeler',
              onTap: () {},
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _highlightRow({
  required IconData icon,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: AppColors.green,
                size: 21,
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
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
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
            'Tasarruf planını oluştur.',
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

