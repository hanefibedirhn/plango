import 'package:flutter/material.dart';

import '../models/expert_application_model.dart';
import '../models/expert_model.dart';
import '../repositories/expert_application_repository.dart';

class ExpertProfileUpdateScreen extends StatefulWidget {
  const ExpertProfileUpdateScreen({
    super.key,
    required this.expert,
  });

  final Expert expert;

  @override
  State<ExpertProfileUpdateScreen> createState() =>
      _ExpertProfileUpdateScreenState();
}

class _ExpertProfileUpdateScreenState
    extends State<ExpertProfileUpdateScreen> {
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF123B4A);
  static const Color _teal = Color(0xFF087C72);
  static const Color _softTeal = Color(0xFFE9F5F3);
  static const Color _text = Color(0xFF172B35);
  static const Color _muted = Color(0xFF667982);
  static const Color _border = Color(0xFFE3ECEF);
  static const Color _warningBackground = Color(0xFFFFF7E8);
  static const Color _warningBorder = Color(0xFFF2D59B);
  static const Color _warningText = Color(0xFF755316);

  final _formKey = GlobalKey<FormState>();
  final _repository = ExpertApplicationRepository();

  late final TextEditingController _companyController;
  late final TextEditingController _branchController;
  late final TextEditingController _positionController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _submitting = false;

  Expert get _expert => widget.expert;

  @override
  void initState() {
    super.initState();

    _companyController =
        TextEditingController(text: _expert.companyName);
    _branchController =
        TextEditingController(text: _expert.branch);
    _positionController =
        TextEditingController(text: _expert.position);
    _emailController =
        TextEditingController(text: _expert.corporateEmail);
    _phoneController =
        TextEditingController(text: _expert.phone);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _branchController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _normalize(String value) => value.trim();

  String _normalizeEmail(String value) =>
      value.trim().toLowerCase();

  bool get _hasChanges {
    return _normalize(_companyController.text) !=
            _normalize(_expert.companyName) ||
        _normalize(_branchController.text) !=
            _normalize(_expert.branch) ||
        _normalize(_positionController.text) !=
            _normalize(_expert.position) ||
        _normalizeEmail(_emailController.text) !=
            _normalizeEmail(_expert.corporateEmail) ||
        _normalize(_phoneController.text) !=
            _normalize(_expert.phone);
  }

  String? _requiredValidator(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredError =
        _requiredValidator(value, 'Kurumsal e-posta');
    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();
    final emailPattern =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Geçerli bir e-posta adresi girin.';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final requiredError =
        _requiredValidator(value, 'Telefon numarası');
    if (requiredError != null) {
      return requiredError;
    }

    final digits =
        value!.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length < 10 || digits.length > 12) {
      return 'Geçerli bir telefon numarası girin.';
    }

    return null;
  }

  Future<bool> _confirmSubmission() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: _teal,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Yeniden doğrulama',
                  style: TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Değişiklik talebini gönderdiğinizde uzman '
            'profiliniz inceleme süresince pasife alınır ve '
            'yeni danışma talebi alamazsınız. Yönetici '
            'onayından sonra yeni bilgilerinizle tekrar '
            'aktif olursunuz.',
            style: TextStyle(
              color: _text,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _submit() async {
    if (_submitting) return;

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_hasChanges) {
      _showMessage(
        'Başvuru göndermek için en az bir bilgiyi değiştirin.',
      );
      return;
    }

    final confirmed = await _confirmSubmission();
    if (!confirmed || !mounted) return;

    setState(() => _submitting = true);

    try {
      final application = ExpertApplication(
        uid: _expert.uid,
        type: 'profileUpdate',
        companyName: _companyController.text.trim(),
        branch: _branchController.text.trim(),
        position: _positionController.text.trim(),
        corporateEmail:
            _emailController.text.trim().toLowerCase(),
        phone: _phoneController.text.trim(),
        status: 'pending',
        createdAt: DateTime.now(),
        previousCompanyName: _expert.companyName,
        previousBranch: _expert.branch,
        previousPosition: _expert.position,
        previousCorporateEmail:
            _expert.corporateEmail,
      );

      await _repository.submitProfileUpdateApplication(
        application: application,
        currentExpert: _expert,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            icon: const Icon(
              Icons.check_circle_rounded,
              color: _teal,
              size: 44,
            ),
            title: const Text(
              'Talebiniz gönderildi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: const Text(
              'Yeni bilgileriniz yönetici incelemesine '
              'gönderildi. İnceleme tamamlanana kadar '
              'uzman profiliniz pasif kalacaktır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                height: 1.45,
              ),
            ),
            actionsAlignment:
                MainAxisAlignment.center,
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Tamam'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ExpertApplicationAlreadyPendingException {
      _showMessage(
        'İncelenmekte olan bir uzman başvurunuz bulunuyor.',
      );
    } on ExpertProfileNotFoundException {
      _showMessage(
        'Aktif uzman profiliniz bulunamadı.',
      );
    } catch (error) {
      _showMessage(
        'Değişiklik talebi gönderilemedi: $error',
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
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
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Şirket / Pozisyon Değişikliği',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              30,
            ),
            children: [
              const _VerificationNotice(),
              const SizedBox(height: 18),
              const _SectionTitle(
                title: 'Mevcut Bilgiler',
                subtitle:
                    'Son doğrulanan uzmanlık bilgileriniz',
              ),
              const SizedBox(height: 10),
              _CurrentInfoCard(expert: _expert),
              const SizedBox(height: 22),
              const _SectionTitle(
                title: 'Yeni Bilgiler',
                subtitle:
                    'Yalnızca değiştirmek istediğiniz alanları düzenleyin',
              ),
              const SizedBox(height: 10),
              _FormCard(
                children: [
                  _InputField(
                    controller: _companyController,
                    label: 'Şirket',
                    icon: Icons.business_outlined,
                    textInputAction:
                        TextInputAction.next,
                    validator: (value) =>
                        _requiredValidator(
                      value,
                      'Şirket',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _branchController,
                    label: 'Şube',
                    icon:
                        Icons.location_on_outlined,
                    textInputAction:
                        TextInputAction.next,
                    validator: (value) =>
                        _requiredValidator(
                      value,
                      'Şube',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _positionController,
                    label: 'Pozisyon',
                    icon:
                        Icons.badge_outlined,
                    textInputAction:
                        TextInputAction.next,
                    validator: (value) =>
                        _requiredValidator(
                      value,
                      'Pozisyon',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _emailController,
                    label: 'Kurumsal E-posta',
                    icon: Icons.alternate_email,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _phoneController,
                    label: 'Telefon Numarası',
                    icon: Icons.phone_outlined,
                    keyboardType:
                        TextInputType.phone,
                    textInputAction:
                        TextInputAction.done,
                    validator: _phoneValidator,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _SmallInfoCard(),
              const SizedBox(height: 22),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _teal.withValues(alpha: 0.55),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                  ),
                  onPressed:
                      _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                        ),
                  label: Text(
                    _submitting
                        ? 'Gönderiliyor...'
                        : 'Değişiklik Talebini Gönder',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
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

class _VerificationNotice extends StatelessWidget {
  const _VerificationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            _ExpertProfileUpdateScreenState._warningBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              _ExpertProfileUpdateScreenState._warningBorder,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color:
                _ExpertProfileUpdateScreenState._warningText,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeniden doğrulama gerekir',
                  style: TextStyle(
                    color:
                        _ExpertProfileUpdateScreenState._warningText,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Değişiklik talebiniz gönderildiğinde '
                  'uzman profiliniz inceleme süresince '
                  'pasife alınır ve yeni danışma talebi '
                  'alamazsınız.',
                  style: TextStyle(
                    color:
                        _ExpertProfileUpdateScreenState._warningText,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ExpertProfileUpdateScreenState._navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: _ExpertProfileUpdateScreenState._muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CurrentInfoCard extends StatelessWidget {
  const _CurrentInfoCard({
    required this.expert,
  });

  final Expert expert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _ExpertProfileUpdateScreenState._border,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.business_outlined,
            label: 'Şirket',
            value: expert.companyName,
          ),
          const _InfoDivider(),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Şube',
            value: expert.branch,
          ),
          const _InfoDivider(),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Pozisyon',
            value: expert.position,
          ),
          const _InfoDivider(),
          _InfoRow(
            icon: Icons.alternate_email,
            label: 'Kurumsal E-posta',
            value: expert.corporateEmail,
          ),
          const _InfoDivider(),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Telefon',
            value: expert.phone,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color:
                  _ExpertProfileUpdateScreenState._softTeal,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 18,
              color:
                  _ExpertProfileUpdateScreenState._teal,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color:
                        _ExpertProfileUpdateScreenState._muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isEmpty ? '—' : value,
                  style: const TextStyle(
                    color:
                        _ExpertProfileUpdateScreenState._text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
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

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Divider(
        height: 1,
        color: _ExpertProfileUpdateScreenState._border,
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _ExpertProfileUpdateScreenState._border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    required this.textInputAction,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        color: _ExpertProfileUpdateScreenState._text,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: _ExpertProfileUpdateScreenState._muted,
        ),
        prefixIcon: Icon(
          icon,
          color: _ExpertProfileUpdateScreenState._teal,
          size: 20,
        ),
        filled: true,
        fillColor:
            _ExpertProfileUpdateScreenState._background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: _ExpertProfileUpdateScreenState._border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: _ExpertProfileUpdateScreenState._teal,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  const _SmallInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ExpertProfileUpdateScreenState._softTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: _ExpertProfileUpdateScreenState._teal,
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mevcut doğrulanmış bilgileriniz, yeni '
              'başvurunuz sonuçlanana kadar geçmiş kayıt '
              'olarak korunur. Onay sonrasında yeni '
              'bilgileriniz uzman profilinize aktarılır.',
              style: TextStyle(
                color: _ExpertProfileUpdateScreenState._navy,
                fontSize: 11.5,
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
