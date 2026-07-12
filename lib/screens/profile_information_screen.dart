import 'package:flutter/material.dart';

import 'change_password_screen.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({
    super.key,
    this.initialName = 'Hanefi',
    this.initialSurname = 'Turanoğlu',
    this.initialEmail = 'hanoturan@gmail.com',
    this.initialUsername = 'hanoturan',
    this.initialPhone,
  });

  final String initialName;
  final String initialSurname;
  final String initialEmail;
  final String initialUsername;
  final String? initialPhone;

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState
    extends State<ProfileInformationScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _danger = Color(0xFFB42318);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName,
    );

    _surnameController = TextEditingController(
      text: widget.initialSurname,
    );

    _phoneController = TextEditingController(
      text: widget.initialPhone ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
      return 'Telefon numarasını 5XX XXX XX XX biçiminde giriniz.';
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

    setState(() {
      _isSaving = true;
    });

    // Firebase bağlandığında bilgiler burada güncellenecek.
    await Future<void>.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profil bilgileriniz güncellendi.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();

    setState(() {
      _nameController.text = widget.initialName;
      _surnameController.text = widget.initialSurname;
      _phoneController.text = widget.initialPhone ?? '';
      _isEditing = false;
    });
  }

  Future<void> _showDeleteAccountDialog() async {
    final bool? shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: _danger,
            size: 34,
          ),
          title: const Text(
            'Hesabı Sil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Hesabınızı silmek istediğinizden emin misiniz? '
            'Bu işlem hesabınıza erişiminizi sona erdirecektir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
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
              child: const Text('Devam Et'),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Hesap silme işlemi Firebase bağlantısı sırasında etkinleştirilecek.',
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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 36),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  children: [
                    _EditableProfileField(
                      controller: _nameController,
                      label: 'Ad',
                      icon: Icons.person_outline_rounded,
                      enabled: _isEditing,
                      validator: (value) {
                        return _requiredValidator(value, 'Ad');
                      },
                    ),
                    const SizedBox(height: 15),
                    _EditableProfileField(
                      controller: _surnameController,
                      label: 'Soyad',
                      icon: Icons.badge_outlined,
                      enabled: _isEditing,
                      validator: (value) {
                        return _requiredValidator(value, 'Soyad');
                      },
                    ),
                    const SizedBox(height: 15),
                    _EditableProfileField(
                      controller: _phoneController,
                      label: 'Telefon',
                      hint: 'Henüz eklenmedi',
                      icon: Icons.phone_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 15),
                    _ReadOnlyProfileField(
                      label: 'E-posta',
                      value: widget.initialEmail,
                      icon: Icons.mail_outline_rounded,
                    ),
                    const SizedBox(height: 15),
                    _ReadOnlyProfileField(
                      label: 'Kullanıcı Adı',
                      value: widget.initialUsername,
                      icon: Icons.alternate_email_rounded,
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
                      onPressed:
                          _isSaving ? null : _cancelEditing,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Vazgeç',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          _isSaving ? null : _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kaydet',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
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
              subtitle: 'Hesap şifrenizi güvenli şekilde güncelleyin.',
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
              subtitle: 'Plango hesabınızın silinmesini talep edin.',
              iconColor: _danger,
              titleColor: _danger,
              backgroundColor: const Color(0xFFFFF4F3),
              onTap: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
            Icons.manage_accounts_outlined,
            color: _ProfileInformationScreenState._green,
            size: 30,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Profil bilgilerinizi buradan görüntüleyebilir ve '
              'izin verilen alanları güncelleyebilirsiniz.',
              style: TextStyle(
                color: _ProfileInformationScreenState._textDark,
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
      textCapitalization: TextCapitalization.words,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: _ProfileInformationScreenState._green,
        ),
        filled: true,
        fillColor: enabled
            ? Colors.white
            : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: _ProfileInformationScreenState._green,
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
          color: _ProfileInformationScreenState._green,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
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
    this.iconColor = _ProfileInformationScreenState._green,
    this.titleColor = _ProfileInformationScreenState._textDark,
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
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            _ProfileInformationScreenState._textMuted,
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