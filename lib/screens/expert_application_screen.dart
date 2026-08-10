import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/companies.dart';
import '../models/company.dart';
import '../models/expert_application_model.dart';
import '../models/user_model.dart';
import '../repositories/expert_application_repository.dart';
import '../repositories/user_repository.dart';
import 'expert_application_success_screen.dart';

class ExpertApplicationScreen extends StatefulWidget {
  const ExpertApplicationScreen({
    super.key,
  });

  @override
  State<ExpertApplicationScreen> createState() =>
      _ExpertApplicationScreenState();
}

class _ExpertApplicationScreenState
    extends State<ExpertApplicationScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _textDark = _navy;
  static const Color _textMuted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);
  static const Color _softTeal = Color(0xFFE8F7F5);
  static const Color _danger = Color(0xFFB42318);

  final GlobalKey<FormState> _companyFormKey =
      GlobalKey<FormState>();

  final GlobalKey<FormState> _contactFormKey =
      GlobalKey<FormState>();

  final UserRepository _userRepository = UserRepository();

  final ExpertApplicationRepository
      _expertApplicationRepository =
      ExpertApplicationRepository();

  final TextEditingController _branchController =
      TextEditingController();

  final TextEditingController _positionController =
      TextEditingController();

  final TextEditingController _corporateEmailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  Company? _selectedCompany;
  AppUser? _currentUser;

  int _currentStep = 0;

  bool _isLoadingProfile = true;
  bool _isSubmitting = false;
  bool _informationConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _branchController.dispose();
    _positionController.dispose();
    _corporateEmailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final User? firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      return;
    }

    try {
      final AppUser user =
          await _userRepository.getUserById(
        firebaseUser.uid,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = user;
        _phoneController.text = user.phone ?? '';
        _isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingProfile = false;
      });

      _showMessage(
        'Kullanıcı bilgileriniz alınamadı.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _requiredValidator(
    String? value,
    String fieldName,
  ) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return '$fieldName alanını doldurunuz.';
    }

    if (text.length < 2) {
      return '$fieldName en az 2 karakter olmalıdır.';
    }

    return null;
  }

  String? _corporateEmailValidator(
    String? value,
  ) {
    final String email =
        (value ?? '').trim().toLowerCase();

    if (email.isEmpty) {
      return 'Kurumsal e-posta adresinizi giriniz.';
    }

    final RegExp emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }

    const Set<String> personalDomains = {
      'gmail.com',
      'hotmail.com',
      'hotmail.com.tr',
      'outlook.com',
      'outlook.com.tr',
      'yahoo.com',
      'yandex.com',
      'yandex.com.tr',
      'icloud.com',
      'live.com',
      'msn.com',
    };

    final String domain =
        email.split('@').last;

    if (personalDomains.contains(domain)) {
      return 'Lütfen çalıştığınız şirkete ait kurumsal e-posta adresini giriniz.';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    String phone = (value ?? '').replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    if (phone.isEmpty) {
      return 'Telefon numaranızı giriniz.';
    }

    if (phone.length != 10 ||
        !phone.startsWith('5')) {
      return 'Telefonu 5XX XXX XX XX biçiminde giriniz.';
    }

    return null;
  }

  String _normalizedPhone() {
    String phone = _phoneController.text.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    return phone;
  }

  void _goToNextStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      final bool isValid =
          _companyFormKey.currentState?.validate() ??
              false;

      if (_selectedCompany == null) {
        _showMessage(
          'Çalıştığınız şirketi seçiniz.',
        );
        return;
      }

      if (!isValid) {
        return;
      }
    }

    if (_currentStep == 1) {
      final bool isValid =
          _contactFormKey.currentState?.validate() ??
              false;

      if (!isValid) {
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  Future<void> _submitApplication() async {
    FocusScope.of(context).unfocus();

    if (!_informationConfirmed) {
      _showMessage(
        'Başvuruyu göndermek için bilgilerin doğruluğunu onaylayınız.',
      );
      return;
    }

    final User? firebaseUser =
        FirebaseAuth.instance.currentUser;

    final AppUser? appUser = _currentUser;
    final Company? selectedCompany =
        _selectedCompany;

    if (firebaseUser == null ||
        appUser == null) {
      _showMessage(
        'Aktif kullanıcı bilgileri bulunamadı.',
      );
      return;
    }

    if (selectedCompany == null) {
      _showMessage(
        'Çalıştığınız şirketi seçiniz.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ExpertApplication application =
          ExpertApplication(
        uid: firebaseUser.uid,
        type: 'initial',
        companyName: selectedCompany.name,
        branch: _branchController.text.trim(),
        position: _positionController.text.trim(),
        corporateEmail:
            _corporateEmailController.text
                .trim()
                .toLowerCase(),
        phone: _normalizedPhone(),
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _expertApplicationRepository
          .submitInitialApplication(
        application,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ExpertApplicationSuccessScreen(),
        ),
      );
    } on ExpertApplicationAlreadyPendingException
        catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.toString());
    } on ArgumentError catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        error.message?.toString() ??
            'Başvuru bilgileri geçerli değil.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Uzman başvurusu gönderilemedi. Lütfen tekrar deneyiniz.',
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
    if (_isLoadingProfile) {
      return const _ApplicationLoadingScreen();
    }

    if (_currentUser == null) {
      return const _ApplicationErrorScreen(
        message:
            'Uzman başvurusu oluşturmak için hesabınıza giriş yapmanız gerekiyor.',
      );
    }

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (
        bool didPop,
        Object? result,
      ) {
        if (!didPop && _currentStep > 0) {
          _goToPreviousStep();
        }
      },
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          foregroundColor: _textDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: 'Geri',
            onPressed: _isSubmitting
                ? null
                : _goToPreviousStep,
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),
          title: const Text(
            'Uzman Başvurusu',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _ApplicationProgress(
                currentStep: _currentStep,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 220),
                  child: _buildCurrentStep(),
                ),
              ),
              _BottomActions(
                currentStep: _currentStep,
                isSubmitting: _isSubmitting,
                onBack: _goToPreviousStep,
                onNext: _goToNextStep,
                onSubmit: _submitApplication,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildCompanyStep();

      case 1:
        return _buildContactStep();

      case 2:
        return _buildConfirmationStep();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCompanyStep() {
    return SingleChildScrollView(
      key: const ValueKey('companyStep'),
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        28,
      ),
      child: Form(
        key: _companyFormKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              icon: Icons.business_outlined,
              title: 'Şirket Bilgileri',
              description:
                  'Çalıştığınız şirketi ve görev bilgilerinizi giriniz.',
            ),
            const SizedBox(height: 18),
            _ApplicationCard(
              children: [
                DropdownButtonFormField<Company>(
                  initialValue: _selectedCompany,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    label: 'Çalıştığınız Şirket',
                    icon: Icons.apartment_rounded,
                  ),
                  hint: const Text(
                    'Şirket seçiniz',
                  ),
                  items: companies.map(
                    (company) {
                      return DropdownMenuItem<Company>(
                        value: company,
                        child: Text(
                          company.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (Company? company) {
                          setState(() {
                            _selectedCompany = company;
                          });
                        },
                  validator: (Company? company) {
                    if (company == null) {
                      return 'Çalıştığınız şirketi seçiniz.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _branchController,
                  enabled: !_isSubmitting,
                  textCapitalization:
                      TextCapitalization.words,
                  textInputAction:
                      TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Şube',
                    hint: 'Örneğin Pendik Şubesi',
                    icon:
                        Icons.location_city_outlined,
                  ),
                  validator: (value) {
                    return _requiredValidator(
                      value,
                      'Şube',
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _positionController,
                  enabled: !_isSubmitting,
                  textCapitalization:
                      TextCapitalization.words,
                  textInputAction:
                      TextInputAction.done,
                  decoration: _inputDecoration(
                    label: 'Pozisyon / Ünvan',
                    hint:
                        'Örneğin Portföy Yöneticisi',
                    icon: Icons.work_outline_rounded,
                  ),
                  validator: (value) {
                    return _requiredValidator(
                      value,
                      'Pozisyon',
                    );
                  },
                  onFieldSubmitted: (_) {
                    _goToNextStep();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactStep() {
    return SingleChildScrollView(
      key: const ValueKey('contactStep'),
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        28,
      ),
      child: Form(
        key: _contactFormKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              icon: Icons.contact_mail_outlined,
              title: 'İletişim ve Doğrulama',
              description:
                  'Başvurunuzun incelenebilmesi için kurumsal iletişim bilgilerinizi giriniz.',
            ),
            const SizedBox(height: 18),
            _ApplicationCard(
              children: [
                TextFormField(
                  controller:
                      _corporateEmailController,
                  enabled: !_isSubmitting,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [
                    AutofillHints.email,
                  ],
                  decoration: _inputDecoration(
                    label: 'Kurumsal E-posta',
                    hint: 'ad.soyad@firma.com',
                    icon: Icons.mail_outline_rounded,
                  ),
                  validator:
                      _corporateEmailValidator,
                ),
                const SizedBox(height: 10),
                const _InformationNotice(
                  icon: Icons.verified_user_outlined,
                  text:
                      'Gmail, Hotmail veya benzeri kişisel e-posta adresleri kabul edilmez. Başvurular Plango yönetimi tarafından manuel olarak incelenir.',
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _phoneController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.phone,
                  textInputAction:
                      TextInputAction.done,
                  decoration: _inputDecoration(
                    label: 'Telefon Numarası',
                    hint: '5XX XXX XX XX',
                    icon: Icons.phone_outlined,
                  ),
                  validator: _phoneValidator,
                  onFieldSubmitted: (_) {
                    _goToNextStep();
                  },
                ),
                const SizedBox(height: 10),
                const _InformationNotice(
                  icon: Icons.info_outline_rounded,
                  text:
                      'Telefon numaranız uzman başvurunuzun değerlendirilmesi ve gerekli durumlarda sizinle iletişim kurulması amacıyla kullanılacaktır.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    final AppUser user = _currentUser!;

    return SingleChildScrollView(
      key: const ValueKey('confirmationStep'),
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        28,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const _StepHeader(
            icon: Icons.fact_check_outlined,
            title: 'Kontrol ve Gönder',
            description:
                'Başvurunuzu göndermeden önce bilgilerinizi kontrol ediniz.',
          ),
          const SizedBox(height: 18),
          _ApplicationCard(
            children: [
              _SummaryRow(
                label: 'Ad Soyad',
                value: user.fullName,
              ),
              const Divider(height: 25),
              _SummaryRow(
                label: 'Şirket',
                value:
                    _selectedCompany?.name ?? '-',
              ),
              const Divider(height: 25),
              _SummaryRow(
                label: 'Şube',
                value:
                    _branchController.text.trim(),
              ),
              const Divider(height: 25),
              _SummaryRow(
                label: 'Pozisyon',
                value:
                    _positionController.text.trim(),
              ),
              const Divider(height: 25),
              _SummaryRow(
                label: 'Kurumsal E-posta',
                value:
                    _corporateEmailController.text
                        .trim()
                        .toLowerCase(),
              ),
              const Divider(height: 25),
              _SummaryRow(
                label: 'Telefon',
                value: _normalizedPhone(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: _informationConfirmed
                    ? _teal
                    : _border,
              ),
            ),
            child: CheckboxListTile(
              value: _informationConfirmed,
              activeColor: _teal,
              controlAffinity:
                  ListTileControlAffinity.leading,
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              title: const Text(
                'Başvuru bilgilerimin doğru olduğunu ve Plango tarafından incelenebileceğini kabul ediyorum.',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onChanged: _isSubmitting
                  ? null
                  : (bool? value) {
                      setState(() {
                        _informationConfirmed =
                            value ?? false;
                      });
                    },
            ),
          ),
          const SizedBox(height: 14),
          const _InformationNotice(
            icon: Icons.lock_outline_rounded,
            text:
                'Başvuru gönderildikten sonra bilgileriniz değiştirilemez. Gerekli durumlarda Plango yönetimi sizden ek bilgi isteyebilir.',
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: _teal,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _teal,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _danger,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _danger,
          width: 1.6,
        ),
      ),
    );
  }
}

class _ApplicationProgress extends StatelessWidget {
  const _ApplicationProgress({
    required this.currentStep,
  });

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const List<String> titles = [
      'Şirket',
      'İletişim',
      'Kontrol',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        12,
        22,
        18,
      ),
      child: Row(
        children: List.generate(
          titles.length,
          (index) {
            final bool completed =
                index <= currentStep;

            return Expanded(
              child: Row(
                children: [
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 180,
                        ),
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: completed
                              ? _ExpertApplicationScreenState
                                  ._teal
                              : const Color(
                                  0xFFE4EBEE,
                                ),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: completed
                                ? Colors.white
                                : _ExpertApplicationScreenState
                                    ._textMuted,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        titles[index],
                        style: TextStyle(
                          color: completed
                              ? _ExpertApplicationScreenState
                                  ._teal
                              : _ExpertApplicationScreenState
                                  ._textMuted,
                          fontSize: 11.5,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (index <
                      titles.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin:
                            const EdgeInsets.only(
                          left: 7,
                          right: 7,
                          bottom: 20,
                        ),
                        color: index < currentStep
                            ? _ExpertApplicationScreenState
                                ._teal
                            : const Color(
                                0xFFE4EBEE,
                              ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            _ExpertApplicationScreenState._softTeal,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                _ExpertApplicationScreenState._teal,
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color:
                        _ExpertApplicationScreenState
                            ._textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color:
                        _ExpertApplicationScreenState
                            ._textMuted,
                    fontSize: 13.5,
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

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              _ExpertApplicationScreenState._border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InformationNotice extends StatelessWidget {
  const _InformationNotice({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color:
              _ExpertApplicationScreenState._textMuted,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color:
                  _ExpertApplicationScreenState
                      ._textMuted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 125,
          child: Text(
            label,
            style: const TextStyle(
              color:
                  _ExpertApplicationScreenState
                      ._textMuted,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color:
                  _ExpertApplicationScreenState
                      ._textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.currentStep,
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentStep;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE4EBEE),
          ),
        ),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed:
                    isSubmitting ? null : onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      _ExpertApplicationScreenState
                          ._textDark,
                  minimumSize:
                      const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Geri'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: currentStep > 0 ? 1 : 2,
            child: FilledButton(
              onPressed: isSubmitting
                  ? null
                  : currentStep == 2
                      ? onSubmit
                      : onNext,
              style: FilledButton.styleFrom(
                backgroundColor:
                    _ExpertApplicationScreenState
                        ._teal,
                foregroundColor: Colors.white,
                minimumSize:
                    const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      currentStep == 2
                          ? 'Başvuruyu Gönder'
                          : 'Devam Et',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationLoadingScreen
    extends StatelessWidget {
  const _ApplicationLoadingScreen();

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

class _ApplicationErrorScreen
    extends StatelessWidget {
  const _ApplicationErrorScreen({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _ExpertApplicationScreenState._background,
      appBar: AppBar(
        backgroundColor:
            _ExpertApplicationScreenState._background,
        title: const Text(
          'Uzman Başvurusu',
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
              color:
                  _ExpertApplicationScreenState
                      ._textDark,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}