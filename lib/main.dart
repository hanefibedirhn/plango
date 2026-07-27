import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr_TR', null);

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
                  borderRadius: BorderRadius.circular(20),
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
              const SizedBox(height: 12),
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
                      borderRadius: BorderRadius.circular(13),
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
                      fontSize: 18,
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
              height: 42,
              child: ElevatedButton(
                onPressed: accepted ? _continue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
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
