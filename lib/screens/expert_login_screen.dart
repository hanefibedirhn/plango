import 'package:flutter/material.dart';

import 'forgot_password_screen.dart';
import 'register_screen.dart';

class ExpertLoginScreen extends StatefulWidget {
  const ExpertLoginScreen({super.key});

  @override
  State<ExpertLoginScreen> createState() => _ExpertLoginScreenState();
}

class _ExpertLoginScreenState extends State<ExpertLoginScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _loginFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  String? _validateLogin(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Kullanıcı adınızı veya e-posta adresinizi giriniz.';
    }

    if (text.length < 3) {
      return 'Girdiğiniz bilgi en az 3 karakter olmalıdır.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final String text = value ?? '';

    if (text.isEmpty) {
      return 'Şifrenizi giriniz.';
    }

    if (text.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }

    return null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Firebase bağlandığında burada:
    // 1. Hesap doğrulanacak.
    // 2. Uzman rolü kontrol edilecek.
    // 3. Uzman hesabının aktif/onaylı durumu kontrol edilecek.
    await Future<void>.delayed(
      const Duration(milliseconds: 450),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Uzman giriş altyapısı Firebase bağlantısıyla etkinleştirilecek.',
        ),
        behavior: SnackBarBehavior.floating,
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
        scrolledUnderElevation: 0,
        title: const Text(
          'Uzman Girişi',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ExpertLoginHeader(),
                const SizedBox(height: 24),
                _ExpertLoginCard(
                  formKey: _formKey,
                  loginController: _loginController,
                  passwordController: _passwordController,
                  loginFocusNode: _loginFocusNode,
                  passwordFocusNode: _passwordFocusNode,
                  isPasswordVisible: _isPasswordVisible,
                  isSubmitting: _isSubmitting,
                  validateLogin: _validateLogin,
                  validatePassword: _validatePassword,
                  onPasswordVisibilityChanged: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  onForgotPassword: () {
                    _openPage(
                    ForgotPasswordScreen(),
                    );
                  },
                  onLogin: _login,
                ),
                const SizedBox(height: 22),
                _ExpertRegisterSection(
                  onRegister: () {
                    _openPage(
                      const RegisterScreen(),
                    );
                  },
                ),
                const SizedBox(height: 22),
                const _ExpertAccessNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpertLoginHeader extends StatelessWidget {
  const _ExpertLoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ExpertLoginIcon(),
        SizedBox(height: 18),
        Text(
          'Uzman Hesabınıza Giriş Yapın',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ExpertLoginScreenState._textDark,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Danışma taleplerinizi görüntülemek ve uzman panelinizi '
          'yönetmek için giriş yapabilirsiniz.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ExpertLoginScreenState._textMuted,
            fontSize: 14.5,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ExpertLoginIcon extends StatelessWidget {
  const _ExpertLoginIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Icon(
        Icons.work_outline_rounded,
        color: _ExpertLoginScreenState._green,
        size: 38,
      ),
    );
  }
}

class _ExpertLoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController loginController;
  final TextEditingController passwordController;
  final FocusNode loginFocusNode;
  final FocusNode passwordFocusNode;
  final bool isPasswordVisible;
  final bool isSubmitting;
  final String? Function(String?) validateLogin;
  final String? Function(String?) validatePassword;
  final VoidCallback onPasswordVisibilityChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;

  const _ExpertLoginCard({
    required this.formKey,
    required this.loginController,
    required this.passwordController,
    required this.loginFocusNode,
    required this.passwordFocusNode,
    required this.isPasswordVisible,
    required this.isSubmitting,
    required this.validateLogin,
    required this.validatePassword,
    required this.onPasswordVisibilityChanged,
    required this.onForgotPassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.055),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: loginController,
              focusNode: loginFocusNode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: _inputDecoration(
                label: 'Kullanıcı Adı veya E-posta',
                hint: 'Kullanıcı adınızı veya e-postanızı girin',
                icon: Icons.alternate_email_rounded,
              ),
              validator: validateLogin,
              onFieldSubmitted: (_) {
                passwordFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              enabled: !isSubmitting,
              obscureText: !isPasswordVisible,
              textInputAction: TextInputAction.done,
              autofillHints: const [
                AutofillHints.password,
              ],
              decoration: _inputDecoration(
                label: 'Şifre',
                hint: 'Şifrenizi girin',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  tooltip: isPasswordVisible
                      ? 'Şifreyi gizle'
                      : 'Şifreyi göster',
                  onPressed: onPasswordVisibilityChanged,
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _ExpertLoginScreenState._textMuted,
                  ),
                ),
              ),
              validator: validatePassword,
              onFieldSubmitted: (_) {
                if (!isSubmitting) {
                  onLogin();
                }
              },
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isSubmitting ? null : onForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: _ExpertLoginScreenState._green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Şifremi Unuttum'),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: isSubmitting ? null : onLogin,
              style: FilledButton.styleFrom(
                backgroundColor: _ExpertLoginScreenState._green,
                disabledBackgroundColor:
                    _ExpertLoginScreenState._green.withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isSubmitting
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        key: ValueKey('button'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Uzman Girişi Yap'),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: _ExpertLoginScreenState._green,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(
        color: _ExpertLoginScreenState._textMuted,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: _ExpertLoginScreenState._textMuted.withValues(alpha: 0.75),
        fontSize: 13.5,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _ExpertLoginScreenState._green,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFB42318),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFB42318),
          width: 1.6,
        ),
      ),
    );
  }
}

class _ExpertRegisterSection extends StatelessWidget {
  final VoidCallback onRegister;

  const _ExpertRegisterSection({
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Henüz hesabınız yok mu?',
              style: TextStyle(
                color: _ExpertLoginScreenState._textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onRegister,
            style: TextButton.styleFrom(
              foregroundColor: _ExpertLoginScreenState._green,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Text('Hesap Oluştur'),
          ),
        ],
      ),
    );
  }
}

class _ExpertAccessNotice extends StatelessWidget {
  const _ExpertAccessNotice();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 17,
          color: _ExpertLoginScreenState._textMuted,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Uzman paneline erişim, uzman başvurunuzun yönetici tarafından '
            'onaylanmasının ardından aktif hâle gelir.',
            style: TextStyle(
              color: _ExpertLoginScreenState._textMuted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}