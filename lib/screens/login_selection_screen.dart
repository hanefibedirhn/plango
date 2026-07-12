import 'package:flutter/material.dart';

import 'expert_login_screen.dart';
import 'register_screen.dart';
import 'user_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

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
        foregroundColor: _textDark,
        elevation: 0,
        title: const Text(
          'Hesabım',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _WelcomeCard(),
              const SizedBox(height: 28),

              _PrimaryButton(
                icon: Icons.person_outline_rounded,
                title: 'Kullanıcı Girişi',
                onPressed: () {
                  _openPage(
                    context,
                    const UserLoginScreen(),
                  );
                },
              ),
              const SizedBox(height: 12),

              _SecondaryButton(
                icon: Icons.work_outline_rounded,
                title: 'Uzman Girişi',
                onPressed: () {
                  _openPage(
                    context,
                    const ExpertLoginScreen(),
                  );
                },
              ),
              const SizedBox(height: 28),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'veya',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 28),

              OutlinedButton.icon(
                onPressed: () {
                  _openPage(
                    context,
                    const RegisterScreen(),
                  );
                },
                icon: const Icon(
                  Icons.person_add_alt_1_outlined,
                ),
                label: const Text(
                  'Hesap Oluştur',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(
                    color: _green,
                    width: 1.4,
                  ),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: const Column(
        children: [
          _ProfileIcon(),
          SizedBox(height: 18),
          Text(
            'Hoş Geldiniz',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LoginSelectionScreen._textDark,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Plango’yu giriş yapmadan kullanabilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LoginSelectionScreen._textMuted,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Planlarınızı kaydetmek, danışma taleplerinizi takip etmek '
            've hesabınızı yönetmek için giriş yapabilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LoginSelectionScreen._textMuted,
              fontSize: 14,
              height: 1.5,
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
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: LoginSelectionScreen._green,
        size: 38,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: FilledButton.styleFrom(
        backgroundColor: LoginSelectionScreen._green,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFE8F1EC),
        foregroundColor: LoginSelectionScreen._green,
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}