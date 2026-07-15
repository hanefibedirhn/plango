import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/company.dart';
import '../../models/expert_profile_model.dart';

class ConsultationRequestScreen extends StatefulWidget {
  const ConsultationRequestScreen({
    super.key,
    required this.company,
    required this.expert,
    required this.financeAmount,
    required this.downPayment,
    required this.monthlyInstallment,
    required this.increaseModel,
    required this.estimatedDelivery,
    required this.estimatedTerm,
  });

  final Company company;
  final ExpertProfile expert;

  final double financeAmount;
  final double downPayment;
  final double monthlyInstallment;

  final String increaseModel;
  final int estimatedDelivery;
  final int estimatedTerm;

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

  final TextEditingController _noteController =
      TextEditingController();

  final NumberFormat _currencyFormatter =
      NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }

  Future<void> _submitRequest() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Bir sonraki adımda ConsultationRepository
      // üzerinden gerçek Firestore kaydı oluşturulacak.
      await Future<void>.delayed(
        const Duration(milliseconds: 450),
      );

      if (!mounted) {
        return;
      }

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ConsultationRequestSuccessScreen(),
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
          'Danışma Talebi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
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

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _border,
                ),
              ),
              child: Column(
                children: [
                  _PlanRow(
                    label: 'Finansman',
                    value: _formatCurrency(
                      widget.financeAmount,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: _border,
                  ),
                  _PlanRow(
                    label: 'Peşinat',
                    value: _formatCurrency(
                      widget.downPayment,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: _border,
                  ),
                  _PlanRow(
                    label: 'İlk Taksit',
                    value: _formatCurrency(
                      widget.monthlyInstallment,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: _border,
                  ),
                  _PlanRow(
                    label: 'Ödeme Modeli',
                    value: widget.increaseModel,
                  ),
                  const Divider(
                    height: 1,
                    color: _border,
                  ),
                  _PlanRow(
                    label: 'Tahmini Teslim',
                    value:
                        '${widget.estimatedDelivery} Ay',
                    isHighlighted: true,
                  ),
                  const Divider(
                    height: 1,
                    color: _border,
                  ),
                  _PlanRow(
                    label: 'Tahmini Vade',
                    value:
                        '${widget.estimatedTerm} Ay',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            const _SectionTitle(
              title: 'Notunuz',
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _noteController,
              minLines: 4,
              maxLines: 6,
              maxLength: 500,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText:
                    'Uzmanınıza iletmek istediğiniz notu yazabilirsiniz.',
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
                      BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: _border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: _border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: _green,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: _textMuted,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'İletişim bilgileri yalnızca uzman talebinizi kabul ettikten sonra karşılıklı olarak paylaşılır.',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 12.5,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 57,
              child: ElevatedButton.icon(
                onPressed:
                    _isSubmitting ? null : _submitRequest,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      _green.withValues(alpha: 0.65),
                  disabledForegroundColor:
                      Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
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
  });

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
              const Text(
                'Uzman talebinizi inceleyecektir. Talep kabul edildiğinde iletişim bilgileri karşılıklı olarak paylaşılacaktır.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil(
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
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