import 'package:flutter/material.dart';

import '../screens/register_screen.dart';
import '../screens/user_login_screen.dart';

class AuthRequiredView extends StatelessWidget {
  const AuthRequiredView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lock_outline_rounded,
    this.onAuthenticationCompleted,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAuthenticationCompleted;

  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EAF0);

  Future<void> _openLogin(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserLoginScreen(),
      ),
    );

    onAuthenticationCompleted?.call();
  }

  Future<void> _openRegister(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );

    onAuthenticationCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 34),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.055),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F5),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: _turquoise.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: _teal,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13.5,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => _openLogin(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('Giriş Yap'),
                  ),
                ),
                const SizedBox(height: 11),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => _openRegister(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _petrol,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: _turquoise,
                        width: 1.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('Hesap Oluştur'),
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'Giriş yaptıktan sonra kaldığınız ekrandan devam edebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
