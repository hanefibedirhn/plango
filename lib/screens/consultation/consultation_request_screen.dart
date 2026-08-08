import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/calculation_plan.dart';
import '../../models/company.dart';
import '../../models/consultation_request_model.dart';
import '../../repositories/consultation_repository.dart';
import '../my_consultation_requests_screen.dart';
import '../register_screen.dart';

class ConsultationRequestScreen extends StatefulWidget {
  const ConsultationRequestScreen({
    super.key,
    required this.company,
    required this.plan,
  });

  final Company company;
  final CalculationPlan plan;

  @override
  State<ConsultationRequestScreen> createState() =>
      _ConsultationRequestScreenState();
}

class _ConsultationRequestScreenState
    extends State<ConsultationRequestScreen> {
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EAF0);
  static const Color _softTeal = Color(0xFFEAF8F5);
  static const Color _error = Color(0xFFB42318);

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
  bool _consentAccepted = false;
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
    setState(() {
      _isLoadingRequester = true;
      _requesterError = null;
    });

    try {
      final User user =
          await _ensureAuthenticatedUser();

      if (user.isAnonymous) {
        if (!mounted) return;

        setState(() {
          _isGuest = true;
          _isLoadingRequester = false;
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

      if (!mounted) return;

      setState(() {
        _isGuest = false;
        _isLoadingRequester = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingRequester = false;
        _requesterError =
            'İletişim bilgileriniz yüklenemedi. '
            'Lütfen tekrar deneyin.';
      });
    }
  }

  String _formatCurrency(double value) {
    return _currencyFormatter.format(value);
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

    if (!_consentAccepted) {
      _showMessage(
        'Danışma talebini göndermek için '
        'iletişim paylaşım onayını vermelisiniz.',
      );
      return false;
    }

    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_isSubmitting || _isLoadingRequester) {
      return;
    }

    FocusScope.of(context).unfocus();

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
        companyName: widget.company.name,
        plan: widget.plan,
        userNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        status: 'waiting_assignment',
        createdAt: now,
        updatedAt: now,
      );

      final String requestId =
          await _repository
              .createConsultationRequest(
        request,
        userPhone: _normalizedPhone(),
      );

      if (!mounted) return;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ConsultationRequestSuccessScreen(
            requestId: requestId,
            companyName: widget.company.name,
            isGuest: user.isAnonymous,
            initialFullName:
                _fullNameController.text.trim(),
            initialPhone: _normalizedPhone(),
          ),
        ),
      );
    } on ConsultationRepositoryException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.code == 'operation-not-allowed'
            ? 'Firebase anonim giriş özelliği etkin değil.'
            : 'Oturum başlatılamadı. Lütfen tekrar deneyin.',
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.code == 'permission-denied'
            ? 'Danışma talebi için Firestore erişim '
                'kurallarının güncellenmesi gerekiyor.'
            : 'Danışma talebi kaydedilemedi. '
                'Lütfen tekrar deneyin.',
      );
    } catch (_) {
      if (!mounted) return;

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
        foregroundColor: _navy,
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
                  color: _teal,
                ),
              )
            : _requesterError != null
                ? _RequesterErrorView(
                    message: _requesterError!,
                    onRetry: _loadRequester,
                  )
                : GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior
                              .onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        8,
                        18,
                        36,
                      ),
                      children: [
                        const _ConsultationProgress(
                          currentStep: 2,
                        ),
                        const SizedBox(height: 18),
                        _CompanyAssignmentCard(
                          companyName:
                              widget.company.name,
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
                          optional: true,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteController,
                          minLines: 4,
                          maxLines: 6,
                          maxLength: 500,
                          textCapitalization:
                              TextCapitalization
                                  .sentences,
                          decoration: _inputDecoration(
                            hint:
                                'Aranmak istediğiniz saat, '
                                'düşündüğünüz sistem veya '
                                'özellikle konuşmak istediğiniz '
                                'konuları yazabilirsiniz.',
                            icon: Icons
                                .chat_bubble_outline_rounded,
                            alignIconTop: true,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _ConsentCard(
                          value: _consentAccepted,
                          onChanged: (value) {
                            setState(() {
                              _consentAccepted =
                                  value ?? false;
                            });
                          },
                        ),
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
                                    Icons
                                        .arrow_forward_rounded,
                                  ),
                            label: Text(
                              _isSubmitting
                                  ? 'Talep Gönderiliyor'
                                  : 'Danışma Talebini Gönder',
                            ),
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor: _teal,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  _teal.withOpacity(0.55),
                              disabledForegroundColor:
                                  Colors.white,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  17,
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
      ),
    );
  }

  static InputDecoration _inputDecoration({
    String? label,
    required String hint,
    required IconData icon,
    bool alignIconTop = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 13.5,
        height: 1.4,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          top: alignIconTop ? 14 : 0,
        ),
        child: Icon(
          icon,
          color: _teal,
        ),
      ),
      prefixIconConstraints:
          const BoxConstraints(
        minWidth: 48,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: _teal,
          width: 1.5,
        ),
      ),
    );
  }
}

class _ConsultationProgress extends StatelessWidget {
  const _ConsultationProgress({
    required this.currentStep,
  });

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = [
      'Şirket',
      'Talep',
      'Onay',
    ];

    return Row(
      children: List.generate(
        labels.length,
        (index) {
          final int step = index + 1;
          final bool isCompleted =
              step < currentStep;
          final bool isCurrent =
              step == currentStep;
          final bool isActive =
              step <= currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 31,
                        height: 31,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _ConsultationRequestScreenState
                                  ._teal
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? _ConsultationRequestScreenState
                                    ._teal
                                : _ConsultationRequestScreenState
                                    ._border,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                '$step',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : _ConsultationRequestScreenState
                                          ._muted,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isCurrent
                              ? _ConsultationRequestScreenState
                                  ._navy
                              : _ConsultationRequestScreenState
                                  ._muted,
                          fontSize: 12,
                          fontWeight: isCurrent
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < labels.length - 1)
                  Container(
                    width: 24,
                    height: 2,
                    margin:
                        const EdgeInsets.only(
                      bottom: 25,
                    ),
                    color: step < currentStep
                        ? _ConsultationRequestScreenState
                            ._teal
                        : _ConsultationRequestScreenState
                            ._border,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompanyAssignmentCard extends StatelessWidget {
  const _CompanyAssignmentCard({
    required this.companyName,
  });

  final String companyName;

  @override
  Widget build(BuildContext context) {
    final String initial = companyName.trim().isEmpty
        ? 'P'
        : companyName.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF052F3D),
            Color(0xFF087C72),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF052F3D)
                .withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
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
                  companyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Talebiniz bu şirkette görev yapan '
                  'uygun bir uzmana yönlendirilecektir.',
                  style: TextStyle(
                    color: Color(0xFFD9F7F1),
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Uzman seçmeniz gerekmez',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
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
    this.optional = false,
  });

  final String title;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color:
                _ConsultationRequestScreenState
                    ._navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 7),
          const Text(
            'İsteğe bağlı',
            style: TextStyle(
              color:
                  _ConsultationRequestScreenState
                      ._muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
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
              _ConsultationRequestScreenState
                  ._border,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2239)
                .withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _PlanRow(
            label: 'Finansman',
            value: formatCurrency(
              plan.financeAmount,
            ),
          ),
          const _CardDivider(),
          _PlanRow(
            label: 'Peşinat',
            value: formatCurrency(
              plan.downPayment,
            ),
          ),
          const _CardDivider(),
          _PlanRow(
            label: 'İlk Taksit',
            value: formatCurrency(
              plan.monthlyInstallment,
            ),
          ),
          const _CardDivider(),
          _PlanRow(
            label: 'Ödeme Modeli',
            value: plan.increaseModel,
          ),
          const _CardDivider(),
          _PlanRow(
            label: 'Tahmini Teslim',
            value: '${plan.estimatedDelivery} Ay',
            highlighted: true,
          ),
          const _CardDivider(),
          _PlanRow(
            label: 'Tahmini Vade',
            value: '${plan.estimatedTerm} Ay',
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 15,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color:
                    _ConsultationRequestScreenState
                        ._muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: highlighted
                  ? _ConsultationRequestScreenState
                      ._teal
                  : _ConsultationRequestScreenState
                      ._navy,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color:
          _ConsultationRequestScreenState
              ._border,
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
          decoration:
              _ConsultationRequestScreenState
                  ._inputDecoration(
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
          decoration:
              _ConsultationRequestScreenState
                  ._inputDecoration(
            label: 'Telefon Numarası',
            hint: '05XX XXX XX XX',
            icon: Icons.phone_outlined,
          ),
        ),
      ],
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
              _ConsultationRequestScreenState
                  ._border,
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
                      ._muted,
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
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                _ConsultationRequestScreenState
                    ._softTeal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color:
                _ConsultationRequestScreenState
                    ._teal,
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
                label,
                style: const TextStyle(
                  color:
                      _ConsultationRequestScreenState
                          ._muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color:
                      _ConsultationRequestScreenState
                          ._navy,
                  fontSize: 13.5,
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

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        8,
        10,
        14,
        10,
      ),
      decoration: BoxDecoration(
        color:
            _ConsultationRequestScreenState
                ._softTeal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              _ConsultationRequestScreenState
                  ._turquoise
                  .withOpacity(0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor:
                _ConsultationRequestScreenState
                    ._teal,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(5),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 7),
              child: Text(
                'İletişim bilgilerimin, danışma '
                'talebimin yürütülmesi amacıyla '
                'atanacak doğrulanmış uzmanla '
                'paylaşılmasını kabul ediyorum.',
                style: TextStyle(
                  color:
                      _ConsultationRequestScreenState
                          ._petrol,
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
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
              color:
                  _ConsultationRequestScreenState
                      ._error,
              size: 48,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    _ConsultationRequestScreenState
                        ._navy,
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
                        ._teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
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
    required this.companyName,
    required this.isGuest,
    required this.initialFullName,
    required this.initialPhone,
  });

  final String requestId;
  final String companyName;
  final bool isGuest;
  final String initialFullName;
  final String initialPhone;

  static const Color _background =
      Color(0xFFF7F9FB);
  static const Color _navy =
      Color(0xFF0B2239);
  static const Color _petrol =
      Color(0xFF052F3D);
  static const Color _teal =
      Color(0xFF087C72);
  static const Color _turquoise =
      Color(0xFF16C7B0);
  static const Color _muted =
      Color(0xFF748193);
  static const Color _border =
      Color(0xFFE4EAF0);

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  void _openRequests(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            const MyConsultationRequestsScreen(),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            22,
            34,
            22,
            28,
          ),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _turquoise,
                      _teal,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _teal.withOpacity(0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Talebiniz Alındı',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _navy,
                  fontSize: 25,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5E8),
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: const Text(
                  'Uzman Ataması Bekleniyor',
                  style: TextStyle(
                    color: Color(0xFFB54708),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Text(
                isGuest
                    ? 'Talebiniz $companyName bünyesinde '
                        'görev yapan uygun bir uzmana '
                        'yönlendirilecektir. Talebinizin '
                        'durumunu takip etmek ve '
                        'gelişmelerden haberdar olmak için '
                        'hesabınızı tamamlayabilirsiniz.'
                    : 'Talebiniz $companyName bünyesinde '
                        'görev yapan uygun bir uzmana '
                        'yönlendirilecektir. Talebinizin '
                        'durumunu Danışmalarım bölümünden '
                        'takip edebilirsiniz.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                  border: Border.all(
                    color: _border,
                  ),
                ),
                child: const Column(
                  children: [
                    _SuccessStep(
                      icon: Icons.check_circle_rounded,
                      title: 'Talep oluşturuldu',
                      completed: true,
                    ),
                    _SuccessConnector(
                      active: true,
                    ),
                    _SuccessStep(
                      icon: Icons.hourglass_top_rounded,
                      title: 'Uygun uzman aranıyor',
                      active: true,
                    ),
                    _SuccessConnector(),
                    _SuccessStep(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Uzman ataması',
                    ),
                    _SuccessConnector(),
                    _SuccessStep(
                      icon: Icons.phone_in_talk_rounded,
                      title: 'Uzman sizinle iletişime geçecek',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Talep No: $requestId',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              if (isGuest) ...[
                SizedBox(
                  width: double.infinity,
                  height: 57,
                  child: ElevatedButton(
                    onPressed: () async {
                      final bool? completed =
                          await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterScreen(
                            initialFullName:
                                initialFullName,
                            initialPhone:
                                initialPhone,
                            completeAnonymousAccount:
                                true,
                          ),
                        ),
                      );

                      if (completed == true &&
                          context.mounted) {
                        _openRequests(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                      ),
                      textStyle:
                          const TextStyle(
                        fontSize: 15.5,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    child: const Text(
                      'Hesabını Tamamla ve Takip Et',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _goHome(context),
                  style: TextButton.styleFrom(
                    foregroundColor: _muted,
                  ),
                  child: const Text(
                    'Şimdilik Geç',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  height: 57,
                  child: ElevatedButton(
                    onPressed: () =>
                        _openRequests(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                      ),
                      textStyle:
                          const TextStyle(
                        fontSize: 15.5,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    child: const Text(
                      'Danışmalarımı Gör',
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

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({
    required this.icon,
    required this.title,
    this.completed = false,
    this.active = false,
  });

  final IconData icon;
  final String title;
  final bool completed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color color = completed || active
        ? ConsultationRequestSuccessScreen
            ._teal
        : ConsultationRequestSuccessScreen
            ._muted;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: completed || active
                ? const Color(0xFFEAF8F5)
                : const Color(0xFFF2F5F8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: completed || active
                  ? ConsultationRequestSuccessScreen
                      ._petrol
                  : ConsultationRequestSuccessScreen
                      ._muted,
              fontSize: 13.5,
              fontWeight: completed || active
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessConnector extends StatelessWidget {
  const _SuccessConnector({
    this.active = false,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 2,
        height: 18,
        margin: const EdgeInsets.only(
          left: 18,
        ),
        color: active
            ? ConsultationRequestSuccessScreen
                ._turquoise
            : ConsultationRequestSuccessScreen
                ._border,
      ),
    );
  }
}
