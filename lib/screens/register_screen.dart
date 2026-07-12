import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();
      final AuthService _authService = AuthService();
final UserRepository _userRepository = UserRepository();

  bool _passwordVisible = false;
  bool _passwordAgainVisible = false;
  bool _membershipAccepted = false;
  bool _clarificationAcknowledged = false;
  bool _privacyAccepted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if ((value ?? '').trim().isEmpty) {
      return '$fieldName alanını doldurunuz.';
    }

    return null;
  }

  String? _emailValidator(String? value) {
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

  String? _usernameValidator(String? value) {
  final String username = (value ?? '').trim();
  final String normalizedUsername = username.toLowerCase();

  const Set<String> reservedUsernames = {
    'admin',
    'administrator',
    'support',
    'plango',
    'official',
    'system',
    'moderator',
    'root',
  };

  if (username.isEmpty) {
    return 'Kullanıcı adınızı giriniz.';
  }

  if (username.length < 3) {
    return 'Kullanıcı adı en az 3 karakter olmalıdır.';
  }

  if (username.length > 20) {
    return 'Kullanıcı adı en fazla 20 karakter olabilir.';
  }

  final RegExp usernamePattern =
      RegExp(r'^[a-zA-Z0-9._]+$');

  if (!usernamePattern.hasMatch(username)) {
    return 'Yalnızca harf, rakam, nokta ve alt çizgi kullanabilirsiniz.';
  }

  if (username == '.' ||
    username == '..' ||
    username.replaceAll('.', '').isEmpty) {
  return 'Geçerli bir kullanıcı adı belirleyiniz.';
}

  if (reservedUsernames.contains(normalizedUsername)) {
    return 'Bu kullanıcı adı kullanılamaz.';
  }

  return null;
}

  String? _passwordValidator(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Şifrenizi giriniz.';
    }

    if (password.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }

    return null;
  }

  String? _passwordAgainValidator(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Şifrenizi tekrar giriniz.';
    }

    if (value != _passwordController.text) {
      return 'Girdiğiniz şifreler eşleşmiyor.';
    }

    return null;
  }

  Future<void> _openLegalDocument({
    required String title,
    required String confirmationText,
    required void Function() onConfirmed,
  }) async {
    final bool? confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _LegalDocumentPlaceholderScreen(
          title: title,
          confirmationText: confirmationText,
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(onConfirmed);
    }
  }

  Future<void> _createAccount() async {
  FocusScope.of(context).unfocus();

  final bool isFormValid =
      _formKey.currentState?.validate() ?? false;

  if (!isFormValid) {
    return;
  }

  if (!_membershipAccepted ||
      !_clarificationAcknowledged ||
      !_privacyAccepted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Devam etmek için gerekli metinleri inceleyiniz.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  final String name = _nameController.text.trim();
  final String surname = _surnameController.text.trim();
  final String email =
      _emailController.text.trim().toLowerCase();
  final String username = _usernameController.text.trim();
  final String normalizedUsername =
      username.toLowerCase();
  final String password = _passwordController.text;

  bool authenticationAccountCreated = false;

  try {
    final credential =
        await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw const AuthServiceException(
        code: 'user-not-created',
        message: 'Kullanıcı hesabı oluşturulamadı.',
      );
    }

    authenticationAccountCreated = true;

    final AppUser appUser = AppUser(
      uid: firebaseUser.uid,
      name: name,
      surname: surname,
      email: email,
      username: username,
      usernameLowercase: normalizedUsername,
      roles: const ['user'],
      expertStatus: 'none',
      phone: null,
      createdAt: DateTime.now(),
    );

    await _userRepository.createUserProfile(appUser);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Plango hesabınız başarıyla oluşturuldu.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  } on UsernameAlreadyInUseException catch (error) {
    if (authenticationAccountCreated) {
      await _authService.rollbackNewlyCreatedUser();
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } on AuthServiceException catch (error) {
    if (authenticationAccountCreated) {
      await _authService.rollbackNewlyCreatedUser();
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (error) {
    if (authenticationAccountCreated) {
      await _authService.rollbackNewlyCreatedUser();
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Hesap oluşturulurken beklenmeyen bir hata oluştu.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
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
          'Hesap Oluştur',
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _RegisterHeader(),
                const SizedBox(height: 24),
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
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                enabled: !_isSubmitting,
                                textCapitalization:
                                    TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.givenName,
                                ],
                                decoration: _inputDecoration(
                                  label: 'Ad',
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (value) {
                                  return _requiredValidator(value, 'Ad');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _surnameController,
                                enabled: !_isSubmitting,
                                textCapitalization:
                                    TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.familyName,
                                ],
                                decoration: _inputDecoration(
                                  label: 'Soyad',
                                  icon: Icons.badge_outlined,
                                ),
                                validator: (value) {
                                  return _requiredValidator(
                                    value,
                                    'Soyad',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                          decoration: _inputDecoration(
                            label: 'E-posta',
                            hint: 'ornek@eposta.com',
                            icon: Icons.mail_outline_rounded,
                          ),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          enabled: !_isSubmitting,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: _inputDecoration(
                            label: 'Kullanıcı Adı',
                            hint: 'Kullanıcı adınızı belirleyin',
                            icon: Icons.alternate_email_rounded,
                          ),
                          validator: _usernameValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isSubmitting,
                          obscureText: !_passwordVisible,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          decoration: _inputDecoration(
                            label: 'Şifre',
                            hint: 'En az 8 karakter',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              tooltip: _passwordVisible
                                  ? 'Şifreyi gizle'
                                  : 'Şifreyi göster',
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _textMuted,
                              ),
                            ),
                          ),
                          validator: _passwordValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordAgainController,
                          enabled: !_isSubmitting,
                          obscureText: !_passwordAgainVisible,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          decoration: _inputDecoration(
                            label: 'Şifre Tekrar',
                            hint: 'Şifrenizi tekrar girin',
                            icon: Icons.lock_reset_rounded,
                            suffixIcon: IconButton(
                              tooltip: _passwordAgainVisible
                                  ? 'Şifreyi gizle'
                                  : 'Şifreyi göster',
                              onPressed: () {
                                setState(() {
                                  _passwordAgainVisible =
                                      !_passwordAgainVisible;
                                });
                              },
                              icon: Icon(
                                _passwordAgainVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _textMuted,
                              ),
                            ),
                          ),
                          validator: _passwordAgainValidator,
                          onFieldSubmitted: (_) {
                            if (!_isSubmitting) {
                              _createAccount();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _LegalConfirmationTile(
                  isChecked: _membershipAccepted,
                  textBeforeLink: '',
                  linkText: 'Üyelik Sözleşmesi',
                  textAfterLink: '\'ni kabul ediyorum.',
                  onTapLink: () {
                    _openLegalDocument(
                      title: 'Üyelik Sözleşmesi',
                      confirmationText:
                          'Okudum, anladım ve kabul ediyorum',
                      onConfirmed: () {
                        _membershipAccepted = true;
                      },
                    );
                  },
                  onChanged: (_) {
                    if (!_membershipAccepted) {
                      _openLegalDocument(
                        title: 'Üyelik Sözleşmesi',
                        confirmationText:
                            'Okudum, anladım ve kabul ediyorum',
                        onConfirmed: () {
                          _membershipAccepted = true;
                        },
                      );
                    } else {
                      setState(() {
                        _membershipAccepted = false;
                      });
                    }
                  },
                ),
                _LegalConfirmationTile(
                  isChecked: _clarificationAcknowledged,
                  textBeforeLink: '',
                  linkText: 'Aydınlatma Metni',
                  textAfterLink: ' hakkında bilgilendirildim.',
                  onTapLink: () {
                    _openLegalDocument(
                      title: 'Aydınlatma Metni',
                      confirmationText: 'Bilgilendirildim',
                      onConfirmed: () {
                        _clarificationAcknowledged = true;
                      },
                    );
                  },
                  onChanged: (_) {
                    if (!_clarificationAcknowledged) {
                      _openLegalDocument(
                        title: 'Aydınlatma Metni',
                        confirmationText: 'Bilgilendirildim',
                        onConfirmed: () {
                          _clarificationAcknowledged = true;
                        },
                      );
                    } else {
                      setState(() {
                        _clarificationAcknowledged = false;
                      });
                    }
                  },
                ),
                _LegalConfirmationTile(
                  isChecked: _privacyAccepted,
                  textBeforeLink: '',
                  linkText: 'Gizlilik Politikası',
                  textAfterLink: '\'nı okudum ve anladım.',
                  onTapLink: () {
                    _openLegalDocument(
                      title: 'Gizlilik Politikası',
                      confirmationText: 'Okudum ve anladım',
                      onConfirmed: () {
                        _privacyAccepted = true;
                      },
                    );
                  },
                  onChanged: (_) {
                    if (!_privacyAccepted) {
                      _openLegalDocument(
                        title: 'Gizlilik Politikası',
                        confirmationText: 'Okudum ve anladım',
                        onConfirmed: () {
                          _privacyAccepted = true;
                        },
                      );
                    } else {
                      setState(() {
                        _privacyAccepted = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed:
                      _isSubmitting ? null : _createAccount,
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
                      : const Text('Hesap Oluştur'),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Zaten hesabınız var mı?',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _green,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: const Text('Giriş Yap'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: _green,
      ),
      suffixIcon: suffixIcon,
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
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _RegisterIcon(),
        SizedBox(height: 16),
        Text(
          'Plango Hesabınızı Oluşturun',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _RegisterScreenState._textDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Planlarınızı kaydedin ve danışma taleplerinizi kolayca takip edin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _RegisterScreenState._textMuted,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _RegisterIcon extends StatelessWidget {
  const _RegisterIcon();

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
        Icons.person_add_alt_1_outlined,
        color: _RegisterScreenState._green,
        size: 37,
      ),
    );
  }
}

class _LegalConfirmationTile extends StatelessWidget {
  final bool isChecked;
  final String textBeforeLink;
  final String linkText;
  final String textAfterLink;
  final VoidCallback onTapLink;
  final ValueChanged<bool?> onChanged;

  const _LegalConfirmationTile({
    required this.isChecked,
    required this.textBeforeLink,
    required this.linkText,
    required this.textAfterLink,
    required this.onTapLink,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: _RegisterScreenState._green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: _RegisterScreenState._textDark,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(text: textBeforeLink),
                      TextSpan(
                        text: linkText,
                        style: const TextStyle(
                          color: _RegisterScreenState._green,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = onTapLink,
                      ),
                      TextSpan(text: textAfterLink),
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

class _LegalDocumentPlaceholderScreen extends StatefulWidget {
  final String title;
  final String confirmationText;

  const _LegalDocumentPlaceholderScreen({
    required this.title,
    required this.confirmationText,
  });

  @override
  State<_LegalDocumentPlaceholderScreen> createState() =>
      _LegalDocumentPlaceholderScreenState();
}

class _LegalDocumentPlaceholderScreenState
    extends State<_LegalDocumentPlaceholderScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _reachedBottom = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_checkScrollPosition);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollPosition();
    });
  }

  void _checkScrollPosition() {
    if (!_scrollController.hasClients) return;

    final ScrollPosition position = _scrollController.position;

    final bool reachedBottom =
        position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent - 12;

    if (reachedBottom != _reachedBottom && mounted) {
      setState(() {
        _reachedBottom = reachedBottom;
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_checkScrollPosition)
      ..dispose();

    super.dispose();
  }

  void _showScrollWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Lütfen metni sonuna kadar inceleyiniz.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RegisterScreenState._background,
      appBar: AppBar(
        backgroundColor: _RegisterScreenState._background,
        foregroundColor: _RegisterScreenState._textDark,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Taslak Metin',
                      style: TextStyle(
                        color: _RegisterScreenState._green,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: _RegisterScreenState._textDark,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Bu ekranın teknik yapısı hazırlanmıştır. Nihai hukuki '
                      'metin, uygulamanın özellikleri tamamlandıktan sonra '
                      'eklenecek ve yayın öncesinde profesyonel hukuki '
                      'incelemeden geçirilecektir.\n\n'
                      'Metinler PDF olarak açılmayacak; uygulama içinde '
                      'okunabilir ayrı sayfalar halinde gösterilecektir.\n\n'
                      'Kullanıcı, işlem düğmesine ulaşmadan önce metni sonuna '
                      'kadar incelemek zorunda olacaktır. Metnin görüntülenen '
                      'sürümü, işlem tarihi ve hesap bilgisi sistemde kayıt '
                      'altına alınacaktır.\n\n'
                      'Bu bölüm daha sonra gerçek sözleşme maddeleriyle '
                      'değiştirilecektir.\n\n'
                      'Plango, kullanıcı verilerinin yalnızca gerekli amaçlar '
                      'doğrultusunda işlenmesi ve yetkisiz kişilerle '
                      'paylaşılmaması prensibiyle geliştirilmektedir.\n\n'
                      'Danışma talebi sırasında girilen iletişim bilgileri, '
                      'talebin iletilebilmesi amacıyla yalnızca kullanıcının '
                      'seçtiği uzmanla paylaşılacaktır.\n\n'
                      'Uzman başvurularında halka açık gösterilecek bilgiler '
                      'ayrıca ve açık biçimde belirtilecektir.\n\n'
                      'Nihai metin eklendiğinde bu taslak ifade tamamen '
                      'kaldırılacaktır.',
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 15,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: FilledButton(
                onPressed: _reachedBottom
                    ? () {
                        Navigator.pop(context, true);
                      }
                    : _showScrollWarning,
                style: FilledButton.styleFrom(
                  backgroundColor: _reachedBottom
                      ? _RegisterScreenState._green
                      : const Color(0xFF9CA3AF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: Text(widget.confirmationText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}