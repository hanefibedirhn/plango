import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/theme_controller.dart';

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PlangoThemeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Tasarruf Planım',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            fontFamily: 'Arial',
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.teal,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'Arial',
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0B141B),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.teal,
              brightness: Brightness.dark,
              surface: const Color(0xFF111D25),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0B141B),
              foregroundColor: Color(0xFFEAF4F5),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            cardColor: const Color(0xFF111D25),
            dividerColor: const Color(0xFF24323B),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class AppColors {
  static const navy = Color(0xFF0B2239);
  static const petrol = Color(0xFF052F3D);
  static const teal = Color(0xFF087C72);
  static const turquoise = Color(0xFF16C7B0);
  static const background = Color(0xFFF7F9FB);
  static const muted = Color(0xFF748193);
  static const border = Color(0xFFE4EBEE);
  static const softTeal = Color(0xFFE8F7F5);
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _symbolReveal;
  late final Animation<double> _nameReveal;
  late final Animation<double> _sloganReveal;
  late final Animation<double> _finalScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Ev + araç artık tek kesintisiz reveal içinde açılır.
    // Böylece ev bittikten sonra araç başlarken oluşan görsel duraklama kalkar.
    _symbolReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.52, curve: Curves.easeOutCubic),
    );

    _nameReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 0.74, curve: Curves.easeOutCubic),
    );

    _sloganReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.66, 0.92, curve: Curves.easeOutCubic),
    );

    _finalScale = Tween<double>(
      begin: 0.985,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _startSplash();
  }

  Future<void> _startSplash() async {
    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 850));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 460),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const DisclaimerScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String logoAsset =
        'assets/images/tasarruf_planim_splash_slogan.png';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: AspectRatio(
                aspectRatio: 920 / 640,
                child: ScaleTransition(
                  scale: _finalScale,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1) SEMBOL: Ev + araç tek ve kesintisiz hareketle açılır.
                      AnimatedBuilder(
                        animation: _symbolReveal,
                        builder: (context, child) {
                          return ClipPath(
                            clipper: _LogoBandRevealClipper(
                              progress: _symbolReveal.value,
                              left: 0.24,
                              top: 0.08,
                              right: 0.86,
                              bottom: 0.54,
                            ),
                            child: child,
                          );
                        },
                        child: Image.asset(
                          logoAsset,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // 3) MARKA ADI: PNG içindeki seçilmiş yuvarlak wordmark.
                      AnimatedBuilder(
                        animation: _nameReveal,
                        builder: (context, child) {
                          final double p = _nameReveal.value;
                          return Opacity(
                            opacity: p,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - p)),
                              child: ClipPath(
                                clipper: _LogoBandRevealClipper(
                                  progress: p,
                                  left: 0.07,
                                  top: 0.54,
                                  right: 0.94,
                                  bottom: 0.79,
                                ),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          logoAsset,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // 4) SLOGAN.
                      AnimatedBuilder(
                        animation: _sloganReveal,
                        builder: (context, child) {
                          final double p = _sloganReveal.value;
                          return Opacity(
                            opacity: p,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - p)),
                              child: ClipPath(
                                clipper: _LogoBandRevealClipper(
                                  progress: p,
                                  left: 0.16,
                                  top: 0.77,
                                  right: 0.90,
                                  bottom: 0.94,
                                ),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          logoAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoBandRevealClipper extends CustomClipper<Path> {
  const _LogoBandRevealClipper({
    required this.progress,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double progress;
  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Path getClip(Size size) {
    final double p = progress.clamp(0.0, 1.0);
    final double x1 = size.width * left;
    final double x2 = size.width * right;
    final double y1 = size.height * top;
    final double y2 = size.height * bottom;

    final Rect rect = Rect.fromLTRB(
      x1,
      y1,
      x1 + ((x2 - x1) * p),
      y2,
    );

    return Path()..addRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
    );
  }

  @override
  bool shouldReclip(covariant _LogoBandRevealClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.left != left ||
        oldClipper.top != top ||
        oldClipper.right != right ||
        oldClipper.bottom != bottom;
  }
}

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() =>
      _DisclaimerScreenState();
}

class _DisclaimerScreenState
    extends State<DisclaimerScreen> {
  bool accepted = false;

  void _continue() {
    if (!accepted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(
          milliseconds: 360,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const HomeScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final Animation<Offset> slide =
              Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -90,
              right: -85,
              child: _BackgroundGlow(
                size: 250,
                color: Color(0x1816C7B0),
              ),
            ),
            const Positioned(
              bottom: -120,
              left: -110,
              child: _BackgroundGlow(
                size: 300,
                color: Color(0x12052F3D),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  24,
                  18,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      18,
                      18,
                      17,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        28,
                      ),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.petrol
                              .withOpacity(0.10),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.softTeal,
                                borderRadius:
                                    BorderRadius.circular(
                                  15,
                                ),
                              ),
                              child: const Icon(
                                Icons
                                    .verified_user_outlined,
                                color: AppColors.teal,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Önemli Bilgilendirme',
                                    style: TextStyle(
                                      color:
                                          AppColors.navy,
                                      fontSize: 19,
                                      height: 1.1,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                      letterSpacing:
                                          -0.35,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Tasarruf Planım’ı kullanmadan önce aşağıdaki bilgileri okumanı rica ediyoruz.',
                                    style: TextStyle(
                                      color:
                                          AppColors.muted,
                                      fontSize: 11.5,
                                      height: 1.42,
                                      fontWeight:
                                          FontWeight
                                              .w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _InfoItem(
                          icon: Icons
                              .shield_outlined,
                          title: 'Bağımsız Platform',
                          description:
                              'Tasarruf Planım, bağımsız bir tasarruf finansmanı karar destek platformudur.',
                        ),
                        const _InfoItem(
                          icon:
                              Icons.calculate_outlined,
                          title: 'FP Engine',
                          description:
                              'FP Engine sonuçları, kullanıcı tarafından girilen verilere göre oluşturulan bilgilendirme amaçlı tahmini analizlerdir.',
                        ),
                        const _InfoItem(
                          icon:
                              Icons.description_outlined,
                          title: 'Resmî Plan ve Sözleşme',
                          description:
                              'Tasarruf Planım sözleşme oluşturmaz, ödeme kabul etmez ve hiçbir tasarruf finansman kuruluşu adına işlem yapmaz.',
                        ),
                        const _InfoItem(
                          icon: Icons
                              .calendar_month_outlined,
                          title: 'Teslim ve Planlama',
                          description:
                              'Nihai ödeme planı, sözleşme şartları ve teslim bilgileri ilgili tasarruf finansman kuruluşu tarafından belirlenir.',
                        ),
                        const _InfoItem(
                          icon: Icons
                              .info_outline_rounded,
                          title: 'Güncel Bilgi',
                          description:
                              'Resmî karar vermeden önce ilgili tasarruf finansman kuruluşundan güncel bilgi alman tavsiye edilir.',
                          showDivider: false,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                const Color(
                              0xFFF5F9FA,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                            border: Border.all(
                              color:
                                  const Color(
                                0xFFE6EEF0,
                              ),
                            ),
                          ),
                          child: CheckboxListTile(
                            value: accepted,
                            onChanged: (value) {
                              setState(() {
                                accepted =
                                    value ?? false;
                              });
                            },
                            activeColor:
                                AppColors.teal,
                            checkColor: Colors.white,
                            controlAffinity:
                                ListTileControlAffinity
                                    .leading,
                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 1,
                            ),
                            title: const Text(
                              'Okudum, anladım ve kabul ediyorum.',
                              style: TextStyle(
                                color:
                                    AppColors.navy,
                                fontSize: 11.5,
                                height: 1.3,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed:
                                accepted
                                    ? _continue
                                    : null,
                            style:
                                FilledButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  AppColors.teal,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  const Color(
                                0xFFDCE4E7,
                              ),
                              disabledForegroundColor:
                                  const Color(
                                0xFF93A1AA,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                              ),
                              textStyle:
                                  const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text('Devam Et'),
                                SizedBox(width: 7),
                                Icon(
                                  Icons
                                      .arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Center(
                          child: Column(
                            children: [
                              Text(
                                'Kurucu & Geliştirici',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 9,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.35,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hanefi Bedirhan Turanoğlu',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 10.5,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 9,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.teal,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 12.5,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.42,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding:
                EdgeInsets.only(left: 47),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFEDF1F3),
            ),
          ),
      ],
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.turquoise,
                AppColors.teal,
                AppColors.navy,
              ],
            ),
            borderRadius: BorderRadius.circular(
              26,
            ),
          ),
          child: const Text(
            'P',
            style: TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'TASARRUF PLANIM',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
