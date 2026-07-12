import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordAgainController =
      TextEditingController();

  bool _currentVisible = false;
  bool _newVisible = false;
  bool _newAgainVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _newPasswordAgainController.dispose();
    super.dispose();
  }

  String? _validatePassword(
    String? value,
    String emptyMessage,
  ) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return emptyMessage;
    }

    if (password.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }

    return null;
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).unfocus();

    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    if (_newPasswordController.text !=
        _newPasswordAgainController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Yeni şifreler birbiriyle eşleşmiyor.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_currentPasswordController.text ==
        _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Yeni şifreniz mevcut şifrenizden farklı olmalıdır.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Firebase bağlandığında yeniden kimlik doğrulama
    // ve şifre güncelleme işlemi burada yapılacak.
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
          'Şifreniz güncellendi.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
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
          'Şifremi Değiştir',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          children: [
            const _PasswordHeader(),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _PasswordField(
                      controller: _currentPasswordController,
                      label: 'Mevcut Şifre',
                      visible: _currentVisible,
                      enabled: !_isSubmitting,
                      onVisibilityChanged: () {
                        setState(() {
                          _currentVisible = !_currentVisible;
                        });
                      },
                      validator: (value) {
                        return _validatePassword(
                          value,
                          'Mevcut şifrenizi giriniz.',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: _newPasswordController,
                      label: 'Yeni Şifre',
                      visible: _newVisible,
                      enabled: !_isSubmitting,
                      onVisibilityChanged: () {
                        setState(() {
                          _newVisible = !_newVisible;
                        });
                      },
                      validator: (value) {
                        return _validatePassword(
                          value,
                          'Yeni şifrenizi giriniz.',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: _newPasswordAgainController,
                      label: 'Yeni Şifre Tekrar',
                      visible: _newAgainVisible,
                      enabled: !_isSubmitting,
                      onVisibilityChanged: () {
                        setState(() {
                          _newAgainVisible = !_newAgainVisible;
                        });
                      },
                      validator: (value) {
                        return _validatePassword(
                          value,
                          'Yeni şifrenizi tekrar giriniz.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed:
                  _isSubmitting ? null : _updatePassword,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
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
              child: _isSubmitting
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Şifreyi Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordHeader extends StatelessWidget {
  const _PasswordHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.security_rounded,
            color: _ChangePasswordScreenState._green,
            size: 30,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Güvenliğiniz için yeni şifrenizin mevcut '
              'şifrenizden farklı olması gerekir.',
              style: TextStyle(
                color: _ChangePasswordScreenState._textDark,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.enabled,
    required this.onVisibilityChanged,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool visible;
  final bool enabled;
  final VoidCallback onVisibilityChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: !visible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: _ChangePasswordScreenState._green,
        ),
        suffixIcon: IconButton(
          tooltip: visible
              ? 'Şifreyi gizle'
              : 'Şifreyi göster',
          onPressed: onVisibilityChanged,
          icon: Icon(
            visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _ChangePasswordScreenState._textMuted,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
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
            color: _ChangePasswordScreenState._green,
            width: 1.7,
          ),
        ),
      ),
    );
  }
}