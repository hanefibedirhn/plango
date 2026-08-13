import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'change_password_screen.dart';
import '../services/auth_service.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState
    extends State<ProfileInformationScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _textDark = _navy;
  static const Color _textMuted = Color(0xFF748193);
  static const Color _danger = Color(0xFFB42318);
  static const Color _border = Color(0xFFE4EBEE);
  static const Color _softTeal = Color(0xFFE8F7F5);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final UserRepository _userRepository = UserRepository();

  final AuthService _authService = AuthService();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _surnameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  bool _isEditing = false;
bool _isSaving = false;
bool _isDeletingAccount = false;

String? _loadedUserId;
AppUser? _currentProfile;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadControllers(AppUser user) {
    if (_loadedUserId == user.uid) {
      return;
    }

    _loadedUserId = user.uid;
    _currentProfile = user;

    _nameController.text = user.name;
    _surnameController.text = user.surname;
    _phoneController.text = user.phone ?? '';
  }

  String? _requiredValidator(
    String? value,
    String fieldName,
  ) {
    if ((value ?? '').trim().isEmpty) {
      return '$fieldName alanını doldurunuz.';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final String phone = (value ?? '').replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (phone.isEmpty) {
      return null;
    }

    if (phone.length != 10 || !phone.startsWith('5')) {
      return 'Telefonu 5XX XXX XX XX biçiminde giriniz.';
    }

    return null;
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final User? firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      _showMessage(
        'Aktif kullanıcı oturumu bulunamadı.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _userRepository.updateProfile(
        uid: firebaseUser.uid,
        name: _nameController.text,
        surname: _surnameController.text,
        phone: _phoneController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isEditing = false;
      });

      _showMessage(
        'Profil bilgileriniz güncellendi.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        error is ArgumentError
            ? error.message.toString()
            : 'Profil bilgileri güncellenemedi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _cancelEditing() {
    final AppUser? user = _currentProfile;

    if (user == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _nameController.text = user.name;
      _surnameController.text = user.surname;
      _phoneController.text = user.phone ?? '';
      _isEditing = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
  final TextEditingController passwordController =
      TextEditingController();

  bool passwordVisible = false;

  final String? password = await showDialog<String>(
    context: context,
    barrierDismissible: !_isDeletingAccount,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: _danger,
              size: 38,
            ),
            title: const Text(
              'Hesabı Kalıcı Olarak Sil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hesabınız ve profil bilgileriniz kalıcı olarak '
                  'silinecektir. Bu işlem geri alınamaz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Mevcut Şifre',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                    ),
                    suffixIcon: IconButton(
                      tooltip: passwordVisible
                          ? 'Şifreyi gizle'
                          : 'Şifreyi göster',
                      onPressed: () {
                        setDialogState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () {
                  final String password =
                      passwordController.text;

                  if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Devam etmek için mevcut şifrenizi giriniz.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    password,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hesabı Sil'),
              ),
            ],
          );
        },
      );
    },
  );

  passwordController.dispose();

  if (password == null || password.isEmpty || !mounted) {
    return;
  }

  final User? firebaseUser =
      FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    _showMessage(
      'Aktif kullanıcı bilgileri bulunamadı.',
    );
    return;
  }

  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Son Onay',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'Hesabınızı kalıcı olarak silmek istediğinizden '
          'emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Evet, Hesabımı Sil'),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !mounted) {
    return;
  }

  setState(() {
    _isDeletingAccount = true;
  });

  try {
    // Önce şifre kontrol edilir.
    await _authService.reauthenticateCurrentUser(
      currentPassword: password,
    );

    // Kullanıcı hâlâ oturum açmışken Firestore kayıtları silinir.
    await _userRepository.deleteUserProfile(
      uid: firebaseUser.uid,
    );

    // Son olarak Authentication hesabı silinir.
    await _authService.deleteAuthenticatedUser();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tasarruf Planım hesabınız kalıcı olarak silindi.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  } on AuthServiceException catch (error) {
    if (!mounted) {
      return;
    }

    _showMessage(error.message);
  } catch (_) {
    if (!mounted) {
      return;
    }

    _showMessage(
      'Hesap silinirken beklenmeyen bir hata oluştu.',
    );
  } finally {
    if (mounted) {
      setState(() {
        _isDeletingAccount = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final User? firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return const _ProfileErrorScreen(
        message: 'Aktif kullanıcı oturumu bulunamadı.',
      );
    }

    return StreamBuilder<AppUser?>(
      stream: _userRepository.watchUserById(
        firebaseUser.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _ProfileLoadingScreen();
        }

        if (snapshot.hasError) {
          return const _ProfileErrorScreen(
            message:
                'Profil bilgileriniz alınırken bir sorun oluştu.',
          );
        }

        final AppUser? user = snapshot.data;

        if (user == null) {
          return const _ProfileErrorScreen(
            message: 'Kullanıcı profili bulunamadı.',
          );
        }

        _currentProfile = user;

        if (!_isEditing) {
          _loadControllers(user);
        }

        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            foregroundColor: _textDark,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Profil Bilgilerim',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  tooltip: 'Bilgileri düzenle',
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(18, 10, 18, 36),
              children: [
                _ProfileHeader(
                  fullName: user.fullName,
                  email: user.email,
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(22),
                      border: Border.all(
                        color: _border,
                      ),
                    ),
                    child: Column(
                      children: [
                        _EditableProfileField(
                          controller: _nameController,
                          label: 'Ad',
                          icon:
                              Icons.person_outline_rounded,
                          enabled: _isEditing,
                          validator: (value) {
                            return _requiredValidator(
                              value,
                              'Ad',
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        _EditableProfileField(
                          controller: _surnameController,
                          label: 'Soyad',
                          icon: Icons.badge_outlined,
                          enabled: _isEditing,
                          validator: (value) {
                            return _requiredValidator(
                              value,
                              'Soyad',
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        _EditableProfileField(
                          controller: _phoneController,
                          label: 'Telefon',
                          hint: 'Henüz eklenmedi',
                          icon: Icons.phone_outlined,
                          enabled: _isEditing,
                          keyboardType:
                              TextInputType.phone,
                          validator: _phoneValidator,
                        ),
                        const SizedBox(height: 15),
                        _ReadOnlyProfileField(
                          label: 'E-posta',
                          value: user.email,
                          icon:
                              Icons.mail_outline_rounded,
                        ),

                      ],
                    ),
                  ),
                ),

                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving
                              ? null
                              : _cancelEditing,
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor: _textDark,
                            minimumSize:
                                const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Vazgeç',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isSaving
                              ? null
                              : _saveProfile,
                          style: FilledButton.styleFrom(
                            backgroundColor: _teal,
                            foregroundColor:
                                Colors.white,
                            minimumSize:
                                const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Kaydet',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                const _SectionTitle(
                  title: 'Güvenlik',
                ),
                const SizedBox(height: 10),

                _SettingsCard(
                  icon: Icons.lock_reset_rounded,
                  title: 'Şifremi Değiştir',
                  subtitle:
                      'Hesap şifrenizi güvenli şekilde güncelleyin.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 26),
                const _SectionTitle(
                  title: 'Hesap İşlemleri',
                ),
                const SizedBox(height: 10),

                _SettingsCard(
  icon: Icons.delete_outline_rounded,
  title: 'Hesabı Sil',
  subtitle: _isDeletingAccount
      ? 'Hesabınız siliniyor...'
      : 'Tasarruf Planım hesabınızı kalıcı olarak silin.',
  iconColor: _danger,
  titleColor: _danger,
  backgroundColor: const Color(0xFFFFF4F3),
  onTap: _isDeletingAccount
      ? () {}
      : _showDeleteAccountDialog,
),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.email,
  });

  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _ProfileInformationScreenState._petrol,
            Color(0xFF07585A),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _ProfileInformationScreenState._petrol.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
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

class _EditableProfileField extends StatelessWidget {
  const _EditableProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization:
          keyboardType == TextInputType.phone
              ? TextCapitalization.none
              : TextCapitalization.words,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: _ProfileInformationScreenState._teal,
        ),
        filled: true,
        fillColor: enabled
            ? Colors.white
            : const Color(0xFFF3F7F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE4EBEE),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE4EBEE),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color:
                _ProfileInformationScreenState._teal,
            width: 1.7,
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyProfileField extends StatelessWidget {
  const _ReadOnlyProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: _ProfileInformationScreenState._teal,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F7F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE4EBEE),
          ),
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: _ProfileInformationScreenState._textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _ProfileInformationScreenState._textDark,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor =
        _ProfileInformationScreenState._teal,
    this.titleColor =
        _ProfileInformationScreenState._textDark,
    this.backgroundColor = Colors.white,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4EBEE),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor == _ProfileInformationScreenState._danger
                      ? const Color(0xFFFFECEA)
                      : _ProfileInformationScreenState._softTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color:
                            _ProfileInformationScreenState
                                ._textMuted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLoadingScreen extends StatelessWidget {
  const _ProfileLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F9FB),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF087C72),
        ),
      ),
    );
  }
}

class _ProfileErrorScreen extends StatelessWidget {
  const _ProfileErrorScreen({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        title: const Text(
          'Profil Bilgilerim',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}