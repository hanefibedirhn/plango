import 'package:flutter/material.dart';
import 'screens/legal_info_screen.dart';
import 'engine/fp_engine.dart';

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
              FeatureCard(title: 'FP Engine', icon: Icons.calculate, onTap: () => _openCalculator(context)),
              const FeatureCard(title: 'Gündem', icon: Icons.campaign),
              const FeatureCard(title: 'Rehber', icon: Icons.menu_book),
              const FeatureCard(title: 'Firmalar', icon: Icons.business),
              const FeatureCard(title: 'Uzmanlar', icon: Icons.verified_user),
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
            'Karar vermeden önce planını oluştur.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tahmini teslim süreni ve vade analizini FP Engine ile gör.',
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

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final financeController = TextEditingController(text: '0');
  final downPaymentController = TextEditingController(text: '0');
  final installmentController = TextEditingController(text: '0');

  String? model;
  FpResult? result;

  void calculate() {
  if (model == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Lütfen ödeme modelini seçiniz."),
      ),
    );
    return;
  }

  final finance = double.tryParse(
        financeController.text.replaceAll('.', ''),
      ) ??
      0;

  final downPayment = double.tryParse(
        downPaymentController.text.replaceAll('.', ''),
      ) ??
      0;

  final installment = double.tryParse(
        installmentController.text.replaceAll('.', ''),
      ) ??
      0;

  setState(() {
    result = FpEngine.calculate(
      finance: finance,
      downPayment: downPayment,
      installment: installment,
      model: model!,
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('FP Engine'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Planını oluştur',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _input('Finansman Tutarı', financeController),
          _input('Peşinat', downPaymentController),
          _input('İlk Taksit', installmentController),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: model,
            hint: const Text("Seçiniz"),
            decoration: _decor('Ödeme Modeli'),
            items: const [
  DropdownMenuItem(value: 'Sabit', child: Text('Sabit')),

  DropdownMenuItem(value: 'Aylık %1 Artış', child: Text('Aylık %1 Artış')),
  DropdownMenuItem(value: 'Aylık %2 Artış', child: Text('Aylık %2 Artış')),
  DropdownMenuItem(value: 'Aylık %3 Artış', child: Text('Aylık %3 Artış')),

  DropdownMenuItem(value: '3 Ayda Bir %5 Artış', child: Text('3 Ayda Bir %5 Artış')),
  DropdownMenuItem(value: '3 Ayda Bir %10 Artış', child: Text('3 Ayda Bir %10 Artış')),
  DropdownMenuItem(value: '3 Ayda Bir %15 Artış', child: Text('3 Ayda Bir %15 Artış')),
  DropdownMenuItem(value: '3 Ayda Bir %20 Artış', child: Text('3 Ayda Bir %20 Artış')),

  DropdownMenuItem(value: '6 Ayda Bir %10 Artış', child: Text('6 Ayda Bir %10 Artış')),
  DropdownMenuItem(value: '6 Ayda Bir %15 Artış', child: Text('6 Ayda Bir %15 Artış')),
  DropdownMenuItem(value: '6 Ayda Bir %20 Artış', child: Text('6 Ayda Bir %20 Artış')),

  DropdownMenuItem(value: '12 Ayda Bir %10 Artış', child: Text('12 Ayda Bir %10 Artış')),
  DropdownMenuItem(value: '12 Ayda Bir %15 Artış', child: Text('12 Ayda Bir %15 Artış')),
  DropdownMenuItem(value: '12 Ayda Bir %20 Artış', child: Text('12 Ayda Bir %20 Artış')),
  DropdownMenuItem(value: '12 Ayda Bir %30 Artış', child: Text('12 Ayda Bir %30 Artış')),
],
            onChanged: (v) => setState(() => model = v ?? 'Sabit'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hesapla')
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 22),
            ResultCard(result: result!),
          ],
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
  controller: controller,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    CurrencyInputFormatter(),
  ],
  decoration: _decor(label).copyWith(
    suffixText: "₺",
  ),
),
    );
  }

  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}


class ResultCard extends StatelessWidget {
  final FpResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          const Text(
            'FP Engine Analizi',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Text(
            '${result.estimatedDelivery} Ay',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'Tahmini Teslim Süresi',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Text(
            '${result.estimatedTerm} Ay Tahmini Vade',
            style: const TextStyle(color: AppColors.gold, fontSize: 18),
          ),
          const SizedBox(height: 18),
          const Text(
            'Bu sonuçlar FP Engine tarafından oluşturulan bağımsız tahmini analizlerdir. Resmî plan, sözleşme ve teslim bilgileri ilgili tasarruf finansman kuruluşu tarafından belirlenir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat('#,##0', 'tr_TR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('.', '');

    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.parse(text);
    final newText = formatter.format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}