import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/legal_info_screen.dart';
import 'engine/fp_engine.dart';
import 'screens/about_screen.dart';
import 'screens/companies_screen.dart';
import 'screens/calculator_screen.dart';
import 'widgets/app_drawer.dart';
import 'screens/account_router_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/content_model.dart';
import 'repositories/content_repository.dart';
import 'screens/featured_screen.dart';
import 'screens/saved_plans_screen.dart';
import 'models/saved_plan_model.dart';
import 'repositories/saved_plan_repository.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

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


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);

  final SavedPlanRepository _savedPlanRepository = SavedPlanRepository();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );
  final PageController _featuredController = PageController();

  int _selectedNavigationIndex = 0;
  int _featuredIndex = 0;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  void _openCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalculatorScreen()),
    );
  }

  void _openAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AccountRouterScreen()),
    );
  }

  void _openSavedPlans() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedPlansScreen()),
    );
  }

  void _openCompanies() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompaniesScreen()),
    );
  }

  void _openFeatured() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FeaturedScreen()),
    );
  }

  void _handleBottomNavigation(int index) {
    if (index == 0) {
      setState(() => _selectedNavigationIndex = 0);
      return;
    }

    switch (index) {
      case 1:
        _openCompanies();
        break;
      case 2:
        _openCalculator();
        break;
      case 3:
        _openSavedPlans();
        break;
      case 4:
        _openAccount();
        break;
    }
  }

  String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 6) return 'İyi geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  String get _displayName {
    final String? rawName = _currentUser?.displayName?.trim();
    if (rawName == null || rawName.isEmpty) return '';
    return rawName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final String name = _displayName;

    return Scaffold(
      backgroundColor: _background,
      drawer: const AppDrawer(),
      appBar: _buildPremiumAppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 108),
          children: [
            Text(
              name.isEmpty ? '$_greeting 👋' : '$_greeting, $name 👋',
              style: const TextStyle(
                color: _navy,
                fontSize: 20,
                height: 1.10,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Bugün ne planlamak istiyorsun?',
              style: TextStyle(
                color: Color(0xFF7A8797),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 13),
            _buildHeroCard(),
            const SizedBox(height: 16),
            _buildLastPlanSection(),
            const SizedBox(height: 20),
            _buildHighlightsSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 66,
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: _navy, size: 25),
      titleSpacing: 3,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlangoRoadLogo(size: 36),
          SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PLANGO',
                style: TextStyle(
                  color: _navy,
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Planla • Karşılaştır • Karar Ver',
                style: TextStyle(
                  color: _teal,
                  fontSize: 8.5,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.35,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            Positioned(
              right: 4,
              top: 5,
              child: Container(
                width: 15,
                height: 15,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5A4F),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 7),
      ],
    );
  }

  Widget _buildHeroCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = (width * 0.54).clamp(190.0, 204.0);

        return Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _petrol,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _petrol.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/home_hero_house_car.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.55, 0.12),
                errorBuilder: (_, __, ___) => const _HeroFallbackArtwork(),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0, 0.48, 0.76, 1],
                    colors: [
                      Color(0xFF031D2E),
                      Color(0xED053040),
                      Color(0x52055255),
                      Color(0x0808706A),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _turquoise.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _turquoise.withOpacity(0.34),
                        ),
                      ),
                      child: const Text(
                        'FP ENGINE',
                        style: TextStyle(
                          color: Color(0xFF39E2CC),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: width * 0.58,
                      child: const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.5,
                            height: 1.10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                          children: [
                            TextSpan(text: 'Ev veya aracın için\n'),
                            TextSpan(
                              text: 'en doğru ',
                              style: TextStyle(color: _turquoise),
                            ),
                            TextSpan(text: 'planı oluştur.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: width * 0.56,
                      child: const Text(
                        '30 saniyede tahmini teslim tarihini, ödeme planını ve vade süreni öğren.',
                        style: TextStyle(
                          color: Color(0xFFE4EFF1),
                          fontSize: 10.3,
                          height: 1.24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 142,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: _openCalculator,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          backgroundColor: _turquoise,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plan Oluştur',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded, size: 17),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrustStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE5EBEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_user_outlined,
              title: 'Bağımsız',
              subtitle: 'Tarafsız karar desteği',
            ),
          ),
          _TrustDivider(),
          Expanded(
            child: _TrustItem(
              icon: Icons.fact_check_outlined,
              title: 'Güvenilir',
              subtitle: 'Tutarlı hesaplama',
            ),
          ),
          _TrustDivider(),
          Expanded(
            child: _TrustItem(
              icon: Icons.info_outline_rounded,
              title: 'Bilgilendirici',
              subtitle: 'Sektörel bilgilendirme',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPlanSection() {
    final User? user = _currentUser;
    if (user == null) return _buildSignedOutPlanCard();

    return StreamBuilder<List<SavedPlan>>(
      stream: _savedPlanRepository.watchSavedPlans(userId: user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoadingPlanCard();
        }
        if (snapshot.hasError) {
          return _buildPlanMessageCard(
            icon: Icons.cloud_off_outlined,
            title: 'Son planın yüklenemedi',
            subtitle: 'Bağlantını kontrol edip tekrar deneyebilirsin.',
          );
        }

        final List<SavedPlan> plans = snapshot.data ?? <SavedPlan>[];
        if (plans.isEmpty) {
          return _buildPlanMessageCard(
            icon: Icons.add_chart_rounded,
            title: 'Henüz kayıtlı planın yok',
            subtitle: 'İlk planını oluşturarak teslim ve vade tahminini görüntüle.',
            actionLabel: 'Plan Oluştur',
            onAction: _openCalculator,
          );
        }

        final List<SavedPlan> sortedPlans = List<SavedPlan>.from(plans)
          ..sort((a, b) {
            final DateTime aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final DateTime bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

        return _buildLastPlanCard(sortedPlans.first);
      },
    );
  }

  Widget _buildLastPlanCard(SavedPlan plan) {
    final DateTime? deliveryDate = _findDeliveryDate(plan);
    final String deliveryText = deliveryDate == null
        ? '${plan.estimatedDelivery}. ay'
        : DateFormat('MMMM yyyy', 'tr_TR').format(deliveryDate);

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4EBEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: _teal,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Son Planın',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openSavedPlans,
                style: TextButton.styleFrom(
                  foregroundColor: _teal,
                  backgroundColor: const Color(0xFFEAF7F5),
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tüm Planlarım',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.chevron_right_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FBF9), Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EFED)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Finansman Tutarı',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _currencyFormat.format(plan.financeAmount),
                      maxLines: 1,
                      style: const TextStyle(
                        color: _teal,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _PlanMetric(
                  label: 'Peşinat',
                  value: _currencyFormat.format(plan.downPayment),
                ),
              ),
              const _PlanMetricDivider(),
              Expanded(
                child: _PlanMetric(
                  label: 'Aylık Taksit',
                  value: _currencyFormat.format(plan.monthlyInstallment),
                ),
              ),
              const _PlanMetricDivider(),
              Expanded(
                child: _PlanMetric(
                  label: 'Tahmini Teslim',
                  value: deliveryText,
                ),
              ),
              const _PlanMetricDivider(),
              Expanded(
                child: _PlanMetric(
                  label: 'Toplam Vade',
                  value: '${plan.estimatedTerm} Ay',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(
                  Icons.history_rounded,
                  color: _muted,
                  size: 17,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'En son kaydettiğin plan',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openSavedPlans,
                  style: TextButton.styleFrom(
                    foregroundColor: _teal,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Devam Et',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.chevron_right_rounded, size: 17),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _findDeliveryDate(SavedPlan plan) {
    for (final SavedPaymentPlanItem item in plan.paymentPlan) {
      if (item.isDeliveryMonth) return item.paymentDate;
    }
    return null;
  }

  Widget _buildSignedOutPlanCard() {
    return _buildPlanMessageCard(
      icon: Icons.lock_outline_rounded,
      title: 'Planlarına ulaşmak için giriş yap',
      subtitle: 'Kaydettiğin planları ana sayfadan hızlıca görüntüleyebilirsin.',
      actionLabel: 'Hesabım',
      onAction: _openAccount,
    );
  }

  Widget _buildLoadingPlanCard() {
    return Container(
      height: 165,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPlanMessageCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EBEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _teal, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10.5,
                    height: 1.24,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: _teal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Öne Çıkanlar',
                style: TextStyle(
                  color: _navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
            ),
            TextButton(
              onPressed: _openFeatured,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: _teal,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, color: _teal, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        StreamBuilder<List<ContentModel>>(
          stream: ContentRepository().watchPublishedFeatured(limit: 5),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const SizedBox(
                height: 190,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _buildHighlightMessage(
                icon: Icons.error_outline,
                message: 'Öne çıkan içerikler yüklenemedi.',
              );
            }

            final List<ContentModel> contents = snapshot.data ?? <ContentModel>[];
            if (contents.isEmpty) {
              return _buildHighlightMessage(
                icon: Icons.article_outlined,
                message: 'Şu anda yayınlanmış içerik bulunmuyor.',
              );
            }

            final int safeIndex = _featuredIndex.clamp(0, contents.length - 1);

            return Column(
              children: [
                SizedBox(
                  height: 190,
                  child: PageView.builder(
                    controller: _featuredController,
                    itemCount: contents.length,
                    onPageChanged: (index) {
                      if (mounted) setState(() => _featuredIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildHighlightCard(
                        content: contents[index],
                        index: index,
                        itemCount: contents.length,
                      );
                    },
                  ),
                ),
                if (contents.length > 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(contents.length, (index) {
                      final bool selected = index == safeIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: selected ? 22 : 8,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: selected
                              ? _teal
                              : const Color(0xFFD5DDE2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required ContentModel content,
    required int index,
    required int itemCount,
  }) {
    const List<List<Color>> gradients = [
      [Color(0xFF062538), Color(0xFF075B5A)],
      [Color(0xFF083C48), Color(0xFF119A88)],
      [Color(0xFF12344B), Color(0xFF0A746E)],
    ];
    final List<Color> colors = gradients[index % gradients.length];

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeaturedDetailScreen(content: content),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.18),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                top: -16,
                bottom: -12,
                width: 150,
                child: Opacity(
                  opacity: 0.18,
                  child: const _HeroFallbackArtwork(),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xF8062538),
                        Color(0xD8063542),
                        Color(0x40075B5A),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 14, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _turquoise,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Text(
                        'GÜNCEL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 230,
                      child: Text(
                        content.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 230,
                      child: Text(
                        content.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD8E7E8),
                          fontSize: 11.5,
                          height: 1.26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white70,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '2 dk okuma',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: itemCount <= 1
                              ? null
                              : () {
                                  final int next = (_featuredIndex + 1) % itemCount;
                                  _featuredController.animateToPage(
                                    next,
                                    duration: const Duration(milliseconds: 330),
                                    curve: Curves.easeOutCubic,
                                  );
                                },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF0B4E53),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightMessage({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EBEE)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _teal, size: 27),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE7ECEF)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Row(
              children: [
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.home_rounded,
                    label: 'Ana Sayfa',
                    selected: _selectedNavigationIndex == 0,
                    onTap: () => _handleBottomNavigation(0),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.apartment_rounded,
                    label: 'Firmalar',
                    selected: false,
                    onTap: () => _handleBottomNavigation(1),
                  ),
                ),
                const SizedBox(width: 88),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.bookmark_rounded,
                    label: 'Planlarım',
                    selected: false,
                    onTap: () => _handleBottomNavigation(3),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profil',
                    selected: false,
                    onTap: () => _handleBottomNavigation(4),
                  ),
                ),
              ],
            ),
            Positioned(
              top: -22,
              child: Semantics(
                button: true,
                label: 'Plan Oluştur',
                child: InkWell(
                  onTap: _openCalculator,
                  customBorder: const CircleBorder(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_turquoise, _teal],
                          ),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: _teal.withOpacity(0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.calculate_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const SizedBox(
                        width: 92,
                        child: Text(
                          'Plan Oluştur',
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _teal,
                            fontSize: 9.5,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
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


class PlangoRoadLogo extends StatelessWidget {
  const PlangoRoadLogo({
    super.key,
    this.size = 48,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlangoLogoPainter(),
      ),
    );
  }
}

class _PlangoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF17C9B0),
          Color(0xFF087C72),
          Color(0xFF0A3451),
        ],
      ).createShader(rect);

    final RRect body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.06,
        size.width * 0.72,
        size.height * 0.88,
      ),
      Radius.circular(size.width * 0.22),
    );

    canvas.drawRRect(body, gradientPaint);

    final Paint cutPaint = Paint()
      ..color = const Color(0xFFF7F9FB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round;

    final Path road = Path()
      ..moveTo(
        size.width * 0.30,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.68,
        size.width * 0.67,
        size.height * 0.69,
        size.width * 0.67,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.67,
        size.height * 0.24,
        size.width * 0.49,
        size.height * 0.23,
        size.width * 0.31,
        size.height * 0.34,
      );

    canvas.drawPath(road, cutPaint);

    final Paint centerLinePaint = Paint()
      ..color = const Color(0xFF26D6BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round;

    final Path centerLine = Path()
      ..moveTo(
        size.width * 0.31,
        size.height * 0.86,
      )
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.68,
        size.width * 0.60,
        size.height * 0.65,
        size.width * 0.60,
        size.height * 0.43,
      );

    canvas.drawPath(centerLine, centerLinePaint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}


class _HeroFallbackArtwork extends StatelessWidget {
  const _HeroFallbackArtwork();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF062538),
                Color(0xFF075252),
                Color(0xFF07806F),
              ],
            ),
          ),
        ),
        Positioned(
          right: -8,
          top: 24,
          child: Icon(
            Icons.show_chart_rounded,
            size: 145,
            color: const Color(0xFF59E6D2)
                .withOpacity(0.35),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 10,
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.home_work_rounded,
                size: 116,
                color: Colors.white.withOpacity(0.28),
              ),
              Transform.translate(
                offset: const Offset(-18, 9),
                child: Icon(
                  Icons
                      .directions_car_filled_rounded,
                  size: 75,
                  color: const Color(0xFF57E6D0)
                      .withOpacity(0.45),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CustomPaint(
            size: const Size(
              double.infinity,
              76,
            ),
            painter: _HeroRoadPainter(),
          ),
        ),
      ],
    );
  }
}

class _HeroRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint glow = Paint()
      ..color = const Color(0xFF2DE0C6)
          .withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 18);

    final Paint road = Paint()
      ..color = const Color(0xFF3BE5CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      ..moveTo(size.width * 0.40, size.height)
      ..cubicTo(
        size.width * 0.50,
        size.height * 0.65,
        size.width * 0.63,
        size.height * 0.58,
        size.width * 0.72,
        size.height * 0.24,
      )
      ..cubicTo(
        size.width * 0.79,
        size.height * 0.08,
        size.width * 0.90,
        size.height * 0.24,
        size.width,
        0,
      );

    canvas.drawPath(path, glow);
    canvas.drawPath(path, road);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF087C72),
          size: 21,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF10243A),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF7A8797),
            fontSize: 10,
            height: 1.18,
          ),
        ),
      ],
    );
  }
}

class _TrustDivider extends StatelessWidget {
  const _TrustDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      color: const Color(0xFFE4E9EC),
    );
  }
}

class _PlanMetric extends StatelessWidget {
  const _PlanMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF7A8797),
                fontSize: 9.5,
                height: 1.1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF10243A),
                fontSize: 12,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanMetricDivider extends StatelessWidget {
  const _PlanMetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE4E9EC),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color teal = Color(0xFF087C72);
    const Color muted = Color(0xFF687480);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 42 : 34,
              height: 29,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFDFF6F2) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: selected ? teal : muted,
                size: 21,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: selected ? teal : muted,
                fontSize: 10,
                height: 1,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTypePill extends StatelessWidget {
  const _PlanTypePill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDCE9E7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF10BFA7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3D4A59),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
