import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/calculation_plan.dart';
import '../../models/company.dart';
import '../../models/consultation_request_model.dart';
import '../../models/expert_profile_model.dart';
import '../../repositories/consultation_repository.dart';

class ConsultationRequestScreen extends StatefulWidget {
  const ConsultationRequestScreen({
    super.key,
    required this.company,
    required this.expert,
    required this.plan,
  });

  final Company company;
  final ExpertProfile expert;
  final CalculationPlan plan;

  @override
  State<ConsultationRequestScreen> createState() =>
      _ConsultationRequestScreenState();
}

class _ConsultationRequestScreenState
    extends State<ConsultationRequestScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);

  final ConsultationRepository _repository =
      ConsultationRepository();

  final TextEditingController _fullNameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _noteController =
      TextEditingController();

  final NumberFormat _currencyFormatter =
      NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  bool _isLoadingRequester = true;
  bool _isSubmitting = false;
  bool _isGuest = true;
  String? _requesterError;

  @override
  void initState() {
    super.initState();
    _loadRequester();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }

  Future<User> _ensureAuthenticatedUser() async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      return currentUser;
    }

    final UserCredential credential =
        await FirebaseAuth.instance.signInAnonymously();

    final User? anonymousUser = credential.user;

    if (anonymousUser == null) {
      throw StateError(
        'Misafir oturumu oluşturulamadı.',
      );
    }

    return anonymousUser;
  }

  Future<void> _loadRequester() async {
    try {
      final User user =
          await _ensureAuthenticatedUser();

      if (user.isAnonymous) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isGuest = true;
          _isLoadingRequester = false;
          _requesterError = null;
        });

        return;
      }

      final DocumentSnapshot<Map<String, dynamic>>
          userDocument =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final Map<String, dynamic>? userData =
          userDocument.data();

      final String name =
          userData?['name'] as String? ?? '';

      final String surname =
          userData?['surname'] as String? ?? '';

      final String phone =
          userData?['phone'] as String? ?? '';

      _fullNameController.text =
          '$name $surname'.trim();

      _phoneController.text = phone.trim();

      if (!mounted) {
        return;
      }

      setState(() {
        _isGuest = false;
        _isLoadingRequester = false;
        _requesterError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingRequester = false;
        _requesterError =
            'İletişim bilgileriniz yüklenemedi. '
            'Lütfen tekrar deneyin.';
      });
    }
  }

  String _normalizedPhone() {
    return _phoneController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
  }

  bool _validateForm() {
    final String fullName =
        _fullNameController.text.trim();

    final String phone = _normalizedPhone();

    if (fullName.length < 3) {
      _showMessage(
        'Lütfen adınızı ve soyadınızı yazınız.',
      );
      return false;
    }

    if (phone.length != 10 &&
        phone.length != 11) {
      _showMessage(
        'Lütfen geçerli bir telefon numarası yazınız.',
      );
      return false;
    }

    return true;
  }

  void _showMessage(
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFF991B1B) : _green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_isSubmitting ||
        _isLoadingRequester) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final User user =
          await _ensureAuthenticatedUser();

      final DateTime now = DateTime.now();

      final ConsultationRequest request =
          ConsultationRequest(
        userId: user.uid,
        isGuest: user.isAnonymous,
        userFullName:
            _fullNameController.text.trim(),
        userPhone: _normalizedPhone(),
        expertId: widget.expert.uid,
        companyName: widget.company.name,
        plan: widget.plan,
        userNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        status: 'pending',
        createdAt: now,
        updatedAt: now,
        expiresAt: now.add(
          ConsultationRepository.responseDuration,
        ),
      );

      final String requestId =
          await _repository
              .createConsultationRequest(
        request,
      );

      if (!mounted) {
        return;
      }

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ConsultationRequestSuccessScreen(
            requestId: requestId,
            isGuest: user.isAnonymous,
          ),
        ),
      );
    } on ConsultationRepositoryException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.message);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      final String message =
          error.code == 'operation-not-allowed'
              ? 'Firebase anonim giriş özelliği etkin değil.'
              : 'Oturum başlatılamadı. Lütfen tekrar deneyin.';

      _showMessage(message);
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      final String message =
          error.code == 'permission-denied'
              ? 'Danışma talebi için Firestore erişim '
                  'kurallarının güncellenmesi gerekiyor.'
              : 'Danışma talebi kaydedilemedi. '
                  'Lütfen tekrar deneyin.';

      _showMessage(message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Danışma talebi gönderilemedi. '
        'Lütfen tekrar deneyin.',
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
          'Danışma Talebi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingRequester
            ? const Center(
                child: CircularProgressIndicator(
                  color: _green,
                ),
              )
            : _requesterError != null
                ? _RequesterErrorView(
                    message: _requesterError!,
                    onRetry: _loadRequester,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      10,
                      18,
                      34,
                    ),
                    children: [
                      const _ConsultationProgress(
                        currentStep: 2,
                      ),
                      const SizedBox(height: 20),
                      _ExpertSummaryCard(
                        company: widget.company,
                        expert: widget.expert,
                      ),
                      const SizedBox(height: 22),
                      const _SectionTitle(
                        title: 'Plan Özeti',
                      ),
                      const SizedBox(height: 10),
                      _PlanSummaryCard(
                        plan: widget.plan,
                        formatCurrency:
                            _formatCurrency,
                      ),
                      const SizedBox(height: 22),
                      const _SectionTitle(
                        title: 'İletişim Bilgileri',
                      ),
                      const SizedBox(height: 10),
                      if (_isGuest)
                        _GuestContactForm(
                          fullNameController:
                              _fullNameController,
                          phoneController:
                              _phoneController,
                        )
                      else
                        _RegisteredContactCard(
                          fullName:
                              _fullNameController.text,
                          phone:
                              _phoneController.text,
                        ),
                      const SizedBox(height: 22),
                      const _SectionTitle(
                        title: 'Notunuz',
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noteController,
                        minLines: 5,
                        maxLines: 7,
                        maxLength: 500,
                        textCapitalization:
                            TextCapitalization
                                .sentences,
                        decoration: InputDecoration(
                          hintText:
                              'Uzmanınıza iletmek istediğiniz '
                              'notu yazabilirsiniz.\n\n'
                              'Örneğin;\n'
                              '• Akşam saatlerinde aranmak istiyorum.\n'
                              '• Çekilişsiz sistem düşünüyorum.\n'
                              '• Teslim sürem benim için önemli.',
                          hintStyle: const TextStyle(
                            color: _textMuted,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.all(17),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                            borderSide:
                                const BorderSide(
                              color: _border,
                            ),
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                            borderSide:
                                const BorderSide(
                              color: _border,
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                            borderSide:
                                const BorderSide(
                              color: _green,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _PrivacyNotice(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 57,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : _submitRequest,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  size: 21,
                                ),
                          label: Text(
                            _isSubmitting
                                ? 'Gönderiliyor'
                                : 'Danışma Talebi Gönder',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor:
                                Colors.white,
                            disabledBackgroundColor:
                                _green.withValues(
                              alpha: 0.65,
                            ),
                            disabledForegroundColor:
                                Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                            textStyle:
                                const TextStyle(
                              fontSize: 15.5,
                              fontWeight:
                                  FontWeight.w900,
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

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({
    required this.plan,
    required this.formatCurrency,
  });

  final CalculationPlan plan;
  final String Function(double value)
      formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              _ConsultationRequestScreenState._border,
        ),
      ),
      child: Column(
        children: [
          _PlanRow(
            label: 'Finansman',
            value: formatCurrency(
              plan.financeAmount,
            ),
          ),
          const Divider(
            height: 1,
            color:
                _ConsultationRequestScreenState._border,
          ),
          _PlanRow(
            label: 'Peşinat',
            value: formatCurrency(
              plan.downPayment,
            ),
          ),
          const Divider(
            height: 1,
            color:
                _ConsultationRequestScreenState._border,
          ),
          _PlanRow(
            label: 'İlk Taksit',
            value: formatCurrency(
              plan.monthlyInstallment,
            ),
          ),
          const Divider(
            height: 1,
            color:
                _ConsultationRequestScreenState._border,
          ),
          _PlanRow(
            label: 'Ödeme Modeli',
            value: plan.increaseModel,
          ),
          const Divider(
            height: 1,
            color:
                _ConsultationRequestScreenState._border,
          ),
          _PlanRow(
            label: 'Tahmini Teslim',
            value: '${plan.estimatedDelivery} Ay',
            isHighlighted: true,
          ),
          const Divider(
            height: 1,
            color:
                _ConsultationRequestScreenState._border,
          ),
          _PlanRow(
            label: 'Tahmini Vade',
            value: '${plan.estimatedTerm} Ay',
          ),
        ],
      ),
    );
  }
}

class _GuestContactForm extends StatelessWidget {
  const _GuestContactForm({
    required this.fullNameController,
    required this.phoneController,
  });

  final TextEditingController fullNameController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: fullNameController,
          textCapitalization:
              TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Ad Soyad',
            hint: 'Adınızı ve soyadınızı yazınız',
            icon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Telefon Numarası',
            hint: '05XX XXX XX XX',
            icon: Icons.phone_outlined,
          ),
        ),
      ],
    );
  }

  static InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color:
            _ConsultationRequestScreenState._green,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color:
              _ConsultationRequestScreenState._border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color:
              _ConsultationRequestScreenState._border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color:
              _ConsultationRequestScreenState._green,
          width: 1.5,
        ),
      ),
    );
  }
}

class _RegisteredContactCard
    extends StatelessWidget {
  const _RegisteredContactCard({
    required this.fullName,
    required this.phone,
  });

  final String fullName;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              _ConsultationRequestScreenState._border,
        ),
      ),
      child: Column(
        children: [
          _ContactRow(
            icon: Icons.person_outline_rounded,
            label: 'Ad Soyad',
            value: fullName.isEmpty
                ? 'Profil bilgisi bulunamadı'
                : fullName,
          ),
          const SizedBox(height: 14),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: 'Telefon',
            value: phone.isEmpty
                ? 'Telefon bilgisi bulunamadı'
                : phone,
          ),
          const SizedBox(height: 12),
          const Text(
            'Bu bilgiler profilinizden alınmıştır.',
            style: TextStyle(
              color:
                  _ConsultationRequestScreenState
                      ._textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              _ConsultationRequestScreenState._green,
          size: 21,
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
                      _ConsultationRequestScreenState
                          ._textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color:
                      _ConsultationRequestScreenState
                          ._textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          color:
              _ConsultationRequestScreenState
                  ._textMuted,
          size: 18,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Telefon numaranız yalnızca seçtiğiniz uzman '
            'talebinizi kabul ettiğinde paylaşılır.',
            style: TextStyle(
              color:
                  _ConsultationRequestScreenState
                      ._textMuted,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _RequesterErrorView extends StatelessWidget {
  const _RequesterErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB42318),
              size: 45,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    _ConsultationRequestScreenState
                        ._textDark,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _ConsultationRequestScreenState
                        ._green,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Tekrar Dene',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpertSummaryCard extends StatelessWidget {
  const _ExpertSummaryCard({
    required this.company,
    required this.expert,
  });

  final Company company;
  final ExpertProfile expert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ConsultationRequestScreenState
            ._softGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(17),
            ),
            child: Text(
              _initials(expert),
              style: const TextStyle(
                color:
                    _ConsultationRequestScreenState
                        ._green,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  expert.fullName,
                  style: const TextStyle(
                    color:
                        _ConsultationRequestScreenState
                            ._textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  company.name,
                  style: const TextStyle(
                    color:
                        _ConsultationRequestScreenState
                            ._green,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expert.position,
                  style: const TextStyle(
                    color:
                        _ConsultationRequestScreenState
                            ._textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expert.branch,
                  style: const TextStyle(
                    color:
                        _ConsultationRequestScreenState
                            ._textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(
    ExpertProfile expert,
  ) {
    final String first =
        expert.firstName.trim().isEmpty
            ? ''
            : expert.firstName
                .trim()
                .characters
                .first
                .toUpperCase();

    final String last =
        expert.lastName.trim().isEmpty
            ? ''
            : expert.lastName
                .trim()
                .characters
                .first
                .toUpperCase();

    final String result = '$first$last';

    return result.isEmpty ? 'U' : result;
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color:
                    _ConsultationRequestScreenState
                        ._textMuted,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isHighlighted
                    ? _ConsultationRequestScreenState
                        ._green
                    : _ConsultationRequestScreenState
                        ._textDark,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
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
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color:
            _ConsultationRequestScreenState._textDark,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ConsultationProgress
    extends StatelessWidget {
  const _ConsultationProgress({
    required this.currentStep,
  });

  final int currentStep;

  static const List<String> _steps = [
    'Şirket',
    'Uzman',
    'Görüş Talebi',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              _ConsultationRequestScreenState
                  ._border,
        ),
      ),
      child: Row(
        children: List.generate(
          _steps.length,
          (index) {
            final bool isCompleted =
                index < currentStep;

            final bool isCurrent =
                index == currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment:
                              Alignment.center,
                          decoration: BoxDecoration(
                            color: isCompleted ||
                                    isCurrent
                                ? _ConsultationRequestScreenState
                                    ._green
                                : const Color(
                                    0xFFF3F4F6,
                                  ),
                            shape: BoxShape.circle,
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 19,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.white
                                        : _ConsultationRequestScreenState
                                            ._textMuted,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _steps[index],
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCompleted ||
                                    isCurrent
                                ? _ConsultationRequestScreenState
                                    ._green
                                : _ConsultationRequestScreenState
                                    ._textMuted,
                            fontSize: 11.5,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index <
                      _steps.length - 1)
                    Container(
                      width: 20,
                      height: 2,
                      margin:
                          const EdgeInsets.only(
                        left: 3,
                        right: 3,
                        bottom: 22,
                      ),
                      color: isCompleted
                          ? _ConsultationRequestScreenState
                              ._green
                          : _ConsultationRequestScreenState
                              ._border,
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

class ConsultationRequestSuccessScreen
    extends StatelessWidget {
  const ConsultationRequestSuccessScreen({
    super.key,
    required this.requestId,
    required this.isGuest,
  });

  final String requestId;
  final bool isGuest;

  static const Color _green =
      Color(0xFF0B5D3B);

  static const Color _background =
      Color(0xFFF7F8F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: _green,
                  size: 45,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Danışma Talebiniz Gönderildi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                isGuest
                    ? 'Uzman talebinizi inceleyecektir. '
                        'Talebinizi uygulama üzerinden takip '
                        'etmek için daha sonra hesabınızı '
                        'oluşturabilirsiniz.'
                    : 'Uzman talebinizi inceleyecektir. '
                        'Talebinizin durumunu Danışmalarım '
                        'bölümünden takip edebilirsiniz.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Talep No: $requestId',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _green,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Tamam',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight:
                          FontWeight.w900,
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
