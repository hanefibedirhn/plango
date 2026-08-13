import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';
import '../repositories/last_calculated_plan_store.dart';
import '../repositories/saved_plan_repository.dart';
import 'consultation/select_company_screen.dart';
import 'payment_plan_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4E9EE);

  final TextEditingController financeController =
      TextEditingController(text: '0');
  final TextEditingController downPaymentController =
      TextEditingController(text: '0');
  final TextEditingController installmentController =
      TextEditingController(text: '0');

  final SavedPlanRepository _savedPlanRepository = SavedPlanRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();

  bool _isIncreasing = false;
  bool _isCalculating = false;
  bool _isSavingPlan = false;

  String _increasePeriod = 'Aylık';
  String _increaseRate = '%1';

  FpResult? result;
  CalculationPlan? calculationPlan;

  final List<String> _periods = const [
    'Aylık',
    '3 Ayda Bir',
    '6 Ayda Bir',
    '12 Ayda Bir',
  ];

  Map<String, List<String>> get _ratesByPeriod => const {
        'Aylık': ['%1', '%2', '%3'],
        '3 Ayda Bir': ['%5', '%10', '%15', '%20'],
        '6 Ayda Bir': ['%10', '%15', '%20'],
        '12 Ayda Bir': ['%10', '%15', '%20', '%30'],
      };

  @override
  void dispose() {
    financeController.dispose();
    downPaymentController.dispose();
    installmentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double _readAmount(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll('.', '')) ?? 0;
  }

  String get _engineModel {
    if (!_isIncreasing) return 'Sabit';
    return '$_increasePeriod $_increaseRate Artış';
  }

  void _selectAll(TextEditingController controller) {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> calculate() async {
    if (_isCalculating) return;

    FocusScope.of(context).unfocus();

    final double finance = _readAmount(financeController);
    final double downPayment = _readAmount(downPaymentController);
    final double installment = _readAmount(installmentController);

    if (finance <= 0) {
      _showMessage('Lütfen finansman tutarını giriniz.');
      return;
    }
    if (installment <= 0) {
      _showMessage('Lütfen ilk taksit tutarını giriniz.');
      return;
    }
    if (downPayment < 0) {
      _showMessage('Peşinat tutarı sıfırdan küçük olamaz.');
      return;
    }
    if (downPayment >= finance) {
      _showMessage('Peşinat, finansman tutarından küçük olmalıdır.');
      return;
    }

    setState(() {
      _isCalculating = true;
      result = null;
      calculationPlan = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final String selectedModel = _engineModel;
    final FpResult calculatedResult = FpEngine.calculate(
      finance: finance,
      downPayment: downPayment,
      installment: installment,
      model: selectedModel,
      calculationDate: DateTime.now(),
    );

    CalculationPlan? newPlan;
    if (calculatedResult.success) {
      newPlan = CalculationPlan(
        financeAmount: finance,
        downPayment: downPayment,
        monthlyInstallment: installment,
        increaseModel: selectedModel,
        estimatedDelivery: calculatedResult.estimatedDelivery,
        estimatedTerm: calculatedResult.estimatedTerm,
      );

      LastCalculatedPlanStore.instance.save(
        plan: newPlan,
        result: calculatedResult,
      );
    }

    setState(() {
      result = calculatedResult;
      calculationPlan = newPlan;
      _isCalculating = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    final BuildContext? resultContext = _resultKey.currentContext;
    if (resultContext != null) {
      await Scrollable.ensureVisible(
        resultContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    }
  }

  void _openPaymentPlan() {
    final CalculationPlan? plan = calculationPlan;
    final FpResult? calculatedResult = result;

    if (plan == null ||
        calculatedResult == null ||
        !calculatedResult.success) {
      _showMessage('Önce geçerli bir plan hesaplayınız.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPlanScreen(
          plan: plan,
          result: calculatedResult,
        ),
      ),
    );
  }

  Future<void> _savePlan() async {
    if (_isSavingPlan) return;

    final CalculationPlan? plan = calculationPlan;
    final FpResult? calculatedResult = result;

    if (plan == null ||
        calculatedResult == null ||
        !calculatedResult.success) {
      _showMessage('Önce geçerli bir plan hesaplayınız.');
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      _showMessage(
        'Plan kaydetmek için kullanıcı hesabınızla giriş yapmanız gerekir.',
      );
      return;
    }

    setState(() => _isSavingPlan = true);

    try {
      final bool wasSaved = await _savedPlanRepository.savePlan(
        userId: user.uid,
        plan: plan,
        result: calculatedResult,
      );

      if (!mounted) return;
      _showMessage(
        wasSaved
            ? 'Planınız başarıyla kaydedildi.'
            : 'Bu plan daha önce kaydedilmiş.',
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      _showMessage(
        error.code == 'permission-denied'
            ? 'Plan kaydetme izni bulunamadı. Firestore güvenlik kurallarını kontrol etmemiz gerekiyor.'
            : 'Plan kaydedilemedi. Lütfen tekrar deneyin.',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Plan kaydedilirken beklenmeyen bir hata oluştu.');
    } finally {
      if (mounted) setState(() => _isSavingPlan = false);
    }
  }

  Future<void> _openConsultationFlow() async {
    final CalculationPlan? plan = calculationPlan;

    if (plan == null) {
      _showMessage('Önce geçerli bir plan hesaplayınız.');
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final UserCredential credential =
            await FirebaseAuth.instance.signInAnonymously();
        user = credential.user;
      }

      if (user == null) {
        throw StateError('Misafir oturumu oluşturulamadı.');
      }
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectCompanyScreen(plan: plan),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message =
          'Misafir oturumu başlatılamadı. Lütfen tekrar deneyin.';
      if (error.code == 'operation-not-allowed') {
        message = 'Firebase anonim giriş özelliği etkin değil.';
      } else if (error.code == 'too-many-requests') {
        message =
            'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.';
      }
      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Danışma ekranı açılamadı. Lütfen tekrar deneyin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final FpResult? currentResult = result;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        title: const Text(
          'Hesaplama',
          style: TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
        children: [
          const Text(
            'Planını oluştur',
            style: TextStyle(
              color: _navy,
              fontSize: 24,
              height: 1.12,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Finansman ve ödeme bilgilerini girerek tahmini teslim tarihini öğren.',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          _buildPlanCard(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final Animation<Offset> slideAnimation = Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: child,
                ),
              );
            },
            child: currentResult == null
                ? const SizedBox.shrink(key: ValueKey('empty-result'))
                : Padding(
                    key: _resultKey,
                    padding: const EdgeInsets.only(top: 18),
                    child: Column(
                      children: [
                        _ResultCard(
                          result: currentResult,
                          paymentModel: calculationPlan?.increaseModel ?? _engineModel,
                        ),
                        if (currentResult.success) ...[
                          const SizedBox(height: 14),
                          _buildPrimaryAction(
                            icon: Icons.receipt_long_rounded,
                            label: 'Ödeme Planını Gör',
                            onPressed: _openPaymentPlan,
                          ),
                          const SizedBox(height: 10),
                          _buildSecondaryAction(
                            icon: Icons.bookmark_add_outlined,
                            label: _isSavingPlan
                                ? 'Kaydediliyor...'
                                : 'Planı Kaydet',
                            isLoading: _isSavingPlan,
                            onPressed: _isSavingPlan ? null : _savePlan,
                          ),
                          const SizedBox(height: 10),
                          _buildSecondaryAction(
                            icon: Icons.support_agent_rounded,
                            label: 'Uzmana Danış',
                            onPressed: _openConsultationFlow,
                          ),
                          const SizedBox(height: 14),
                          _buildDisclaimer(),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Bilgileri',
            style: TextStyle(
              color: _navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _input(
            label: 'Finansman Tutarı',
            controller: financeController,
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _input(
            label: 'Peşinat',
            controller: downPaymentController,
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 12),
          _input(
            label: 'İlk Taksit',
            controller: installmentController,
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 18),
          const Text(
            'Ödeme Modeli',
            style: TextStyle(
              color: _navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _modelOption(
                    label: 'Sabit',
                    icon: Icons.horizontal_rule_rounded,
                    selected: !_isIncreasing,
                    onTap: () => setState(() => _isIncreasing = false),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _modelOption(
                    label: 'Artışlı',
                    icon: Icons.trending_up_rounded,
                    selected: _isIncreasing,
                    onTap: () => setState(() => _isIncreasing = true),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _isIncreasing
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _dropdownField(
                            label: 'Artış Sıklığı',
                            value: _increasePeriod,
                            items: _periods,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _increasePeriod = value;
                                _increaseRate = _ratesByPeriod[value]!.first;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _dropdownField(
                            label: 'Artış Oranı',
                            value: _increaseRate,
                            items: _ratesByPeriod[_increasePeriod]!,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _increaseRate = value);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isCalculating ? null : calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _turquoise,
                foregroundColor: _petrol,
                disabledBackgroundColor: _turquoise.withOpacity(0.62),
                disabledForegroundColor: _petrol.withOpacity(0.75),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _isCalculating
                    ? const Row(
                        key: ValueKey('calculating'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: _petrol,
                            ),
                          ),
                          SizedBox(width: 11),
                          Text('Hesaplanıyor...'),
                        ],
                      )
                    : const Row(
                        key: ValueKey('calculate'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calculate_outlined, size: 21),
                          SizedBox(width: 9),
                          Text('Hesapla'),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onTap: () {
        if (controller.text == '0') _selectAll(controller);
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      style: const TextStyle(
        color: _navy,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _teal, size: 20),
        suffixText: 'TL',
        suffixStyle: const TextStyle(
          color: _muted,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        labelStyle: const TextStyle(
          color: _muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: _teal,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FBFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _turquoise, width: 1.6),
        ),
      ),
    );
  }

  Widget _modelOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _navy.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? _teal : _muted),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? _navy : _muted,
                  fontSize: 13.5,
                  fontWeight:
                      selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return PopupMenuButton<String>(
      initialValue: value,
      tooltip: '',
      elevation: 8,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: _navy.withOpacity(0.16),
      constraints: const BoxConstraints(
        minWidth: 170,
        maxWidth: 240,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: _border,
        ),
      ),
      offset: const Offset(0, 56),
      onSelected: (selectedValue) {
        onChanged(selectedValue);
      },
      itemBuilder: (context) {
        return items.map((item) {
          final bool isSelected = item == value;

          return PopupMenuItem<String>(
            value: item,
            height: 48,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? _turquoise.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? _teal : _navy,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_rounded,
                      color: _teal,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList();
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            color: _teal,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          filled: true,
          fillColor: const Color(0xFFF9FBFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _border,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _border,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _teal,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _teal,
                ),
              )
            : Icon(icon, size: 21),
        label: Text(label),
        style: OutlinedButton.styleFrom(
  foregroundColor: _teal,
  side: const BorderSide(
    color: _teal,
    width: 1.2,
  ),
  backgroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  textStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
  ),
),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _teal, size: 19),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tasarruf Planım sonuçları tahmini ve bilgilendirme amaçlıdır. Kesin plan, sözleşme ve teslimat koşulları ilgili tasarruf finansman kuruluşu tarafından belirlenir.',
              style: TextStyle(
                color: Color(0xFF5E6D7E),
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.paymentModel,
  });

  final FpResult result;
  final String paymentModel;

  PaymentPlanItem? get _deliveryItem {
    for (final PaymentPlanItem item in result.paymentPlan) {
      if (item.isDeliveryMonth) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!result.success) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF7C9CE)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB42332),
              size: 28,
            ),
            const SizedBox(height: 9),
            Text(
              result.errorMessage ??
                  'Hesaplama sırasında bir hata oluştu.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8B1F2A),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');
    final PaymentPlanItem? deliveryItem = _deliveryItem;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _CalculatorScreenState._petrol,
            _CalculatorScreenState._teal,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _CalculatorScreenState._petrol.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: _CalculatorScreenState._turquoise.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _CalculatorScreenState._turquoise.withOpacity(0.35),
              ),
            ),
            child: const Text(
              'TAHMİNİ TESLİMAT',
              style: TextStyle(
                color: _CalculatorScreenState._turquoise,
                fontSize: 10,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${result.estimatedDelivery} Ay',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            deliveryItem == null
                ? '-'
                : dateFormat.format(deliveryItem.paymentDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _resultDetail(
                  label: 'Toplam Vade',
                  value: '${result.estimatedTerm} Ay',
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: Colors.white.withOpacity(0.15),
              ),
              Expanded(
                child: _resultDetail(
                  label: 'Ödeme Modeli',
                  value: paymentModel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultDetail({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: value.length > 14 ? 12 : 14,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat('#,##0', 'tr_TR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text.replaceAll('.', '');

    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final int? number = int.tryParse(text);
    if (number == null) return oldValue;

    final String newText = formatter.format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
