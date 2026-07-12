import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final String email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'E-posta adresinizi giriniz.';
    }

    final RegExp emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }

    return null;
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Firebase bağlandığında şifre sıfırlama e-postası
    // bu bölümden gönderilecek.
    await Future<void>.delayed(
      const Duration(milliseconds: 450),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                color: _green,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'E-postanızı Kontrol Edin',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '${_emailController.text.trim()} adresine şifre yenileme '
            'bağlantısı gönderilecektir.\n\n'
            'Bağlantı görünmüyorsa spam veya gereksiz klasörünü '
            'kontrol edebilirsiniz.',
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: Color(0xFF374151),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tamam',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
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
          'Şifremi Unuttum',
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
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PasswordResetHeader(),
                const SizedBox(height: 28),
                Container(
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
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            hintText: 'ornek@eposta.com',
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: _green,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: const TextStyle(
                              color: _textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                            hintStyle: TextStyle(
                              color: _textMuted.withValues(alpha: 0.75),
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
                                color: _green,
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
                          ),
                          validator: _validateEmail,
                          onFieldSubmitted: (_) {
                            if (!_isSubmitting) {
                              _sendResetLink();
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed:
                              _isSubmitting ? null : _sendResetLink,
                          style: FilledButton.styleFrom(
                            backgroundColor: _green,
                            disabledBackgroundColor:
                                _green.withValues(alpha: 0.55),
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
                              : const Text(
                                  'Şifre Yenileme Bağlantısı Gönder',
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _SecurityNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordResetHeader extends StatelessWidget {
  const _PasswordResetHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PasswordResetIcon(),
        SizedBox(height: 18),
        Text(
          'Şifrenizi Yenileyin',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ForgotPasswordScreenState._textDark,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Hesabınıza kayıtlı e-posta adresini girin. '
          'Şifrenizi yenileyebilmeniz için bağlantı gönderelim.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ForgotPasswordScreenState._textMuted,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PasswordResetIcon extends StatelessWidget {
  const _PasswordResetIcon();

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
        Icons.lock_reset_rounded,
        color: _ForgotPasswordScreenState._green,
        size: 40,
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: _ForgotPasswordScreenState._textMuted,
          size: 18,
        ),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'Güvenliğiniz için şifre yenileme bağlantısını yalnızca '
            'hesabınıza kayıtlı e-posta adresine göndereceğiz.',
            style: TextStyle(
              color: _ForgotPasswordScreenState._textMuted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}