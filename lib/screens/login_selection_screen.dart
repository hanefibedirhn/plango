import 'package:flutter/material.dart';

import 'register_screen.dart';
import 'user_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _softTeal = Color(0xFFEAF8F5);
  static const Color _border = Color(0xFFE4EAF0);
  static const Color _textMuted = Color(0xFF748193);

  void _openPage(
    BuildContext context,
    Widget page,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
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
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hesabım',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _WelcomeSection(),
              const SizedBox(height: 24),

              const _SectionLabel(
                title: 'Giriş Yap',
                subtitle: 'Plango hesabınıza giriş yaparak devam edin.',
              ),
              const SizedBox(height: 10),

              _LoginOptionCard(
                icon: Icons.login_rounded,
                title: 'Giriş Yap',
                subtitle:
                    'Planlarınıza, hesabınıza ve size özel özelliklere erişin.',
                onTap: () {
                  _openPage(
                    context,
                    const UserLoginScreen(),
                  );
                },
              ),
              const SizedBox(height: 25),
              const _DividerWithText(),
              const SizedBox(height: 25),

              const _SectionLabel(
                title: 'Plango’ya yeni misiniz?',
                subtitle:
                    'Ücretsiz hesabınızı oluşturarak planlarınızı kaydedebilirsiniz.',
              ),
              const SizedBox(height: 10),

              _CreateAccountCard(
                onTap: () {
                  _openPage(
                    context,
                    const RegisterScreen(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 19, 18, 19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LoginSelectionScreen._navy,
            LoginSelectionScreen._petrol,
            LoginSelectionScreen._teal,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: LoginSelectionScreen._petrol.withValues(
              alpha: 0.12,
            ),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProfileIcon(),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plango’ya Hoş Geldiniz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Planlarınızı kaydedin, danışma '
                  'taleplerinizi takip edin ve hesabınızı '
                  'yönetin.',
                  style: TextStyle(
                    color: Color(0xFFD3E4E8),
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.13),
        ),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: Color(0xFF5DE0D0),
        size: 27,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: LoginSelectionScreen._navy,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: LoginSelectionScreen._textMuted,
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginOptionCard extends StatelessWidget {
  const _LoginOptionCard({
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
    const iconBackground = LoginSelectionScreen._teal;
    const iconColor = Colors.white;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: LoginSelectionScreen._teal.withValues(
                alpha: 0.30,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: LoginSelectionScreen._navy.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
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
                        color: LoginSelectionScreen._navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color:
                            LoginSelectionScreen._textMuted,
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA8B7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: LoginSelectionScreen._border,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'veya',
            style: TextStyle(
              color: LoginSelectionScreen._textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: LoginSelectionScreen._border,
          ),
        ),
      ],
    );
  }
}

class _CreateAccountCard extends StatelessWidget {
  const _CreateAccountCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LoginSelectionScreen._softTeal,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: LoginSelectionScreen._teal.withValues(
                alpha: 0.20,
              ),
            ),
          ),
          child: const Row(
            children: [
              _CreateAccountIcon(),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hesap Oluştur',
                      style: TextStyle(
                        color: LoginSelectionScreen._navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Planlarınızı kaydetmek ve Plango '
                      'özelliklerinden daha fazla yararlanmak '
                      'için hesabınızı oluşturun.',
                      style: TextStyle(
                        color:
                            LoginSelectionScreen._textMuted,
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: LoginSelectionScreen._teal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateAccountIcon extends StatelessWidget {
  const _CreateAccountIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.person_add_alt_1_outlined,
        color: LoginSelectionScreen._teal,
        size: 23,
      ),
    );
  }
}
