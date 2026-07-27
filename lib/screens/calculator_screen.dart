import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';
import 'consultation/select_company_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_plan_screen.dart';
import '../repositories/last_calculated_plan_store.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
  });

  @override
  State<CalculatorScreen> createState() =>
      _CalculatorScreenState();
}

class _CalculatorScreenState
    extends State<CalculatorScreen> {
  static const Color _green =
      Color(0xFF0B5D3B);
  static const Color _dark =
      Color(0xFF10231B);
  static const Color _gold =
      Color(0xFFD6A84F);
  static const Color _background =
      Color(0xFFF7F8F5);

  final TextEditingController financeController =
      TextEditingController(text: '0');

  final TextEditingController downPaymentController =
      TextEditingController(text: '0');

  final TextEditingController installmentController =
      TextEditingController(text: '0');

  String? model;
  FpResult? result;
  CalculationPlan? calculationPlan;

  @override
  void dispose() {
    financeController.dispose();
    downPaymentController.dispose();
    installmentController.dispose();
    super.dispose();
  }

  double _readAmount(
    TextEditingController controller,
  ) {
    return double.tryParse(
          controller.text.replaceAll('.', ''),
        ) ??
        0;
  }

  void calculate() {
    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen ödeme modelini seçiniz.',
          ),
        ),
      );
      return;
    }

    final double finance =
        _readAmount(financeController);

    final double downPayment =
        _readAmount(downPaymentController);

    final double installment =
        _readAmount(installmentController);

    final FpResult calculatedResult =
    FpEngine.calculate(
  finance: finance,
  downPayment: downPayment,
  installment: installment,
  model: model!,
  calculationDate: DateTime.now(),
);

    setState(() {
      result = calculatedResult;

      if (calculatedResult.success) {
  final CalculationPlan newPlan = CalculationPlan(
    financeAmount: finance,
    downPayment: downPayment,
    monthlyInstallment: installment,
    increaseModel: model!,
    estimatedDelivery:
        calculatedResult.estimatedDelivery,
    estimatedTerm:
        calculatedResult.estimatedTerm,
  );

  calculationPlan = newPlan;

  LastCalculatedPlanStore.instance.save(
  plan: newPlan,
  result: calculatedResult,
);
} else {
  calculationPlan = null;
}
    });
  }

  void _openPaymentPlan() {
  final CalculationPlan? plan =
      calculationPlan;

  final FpResult? calculatedResult =
      result;

  if (plan == null ||
      calculatedResult == null ||
      !calculatedResult.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Önce geçerli bir plan hesaplayınız.',
        ),
      ),
    );

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
  
  Future<void> _openConsultationFlow() async {
  final CalculationPlan? plan = calculationPlan;

  if (plan == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Önce geçerli bir plan hesaplayınız.',
        ),
      ),
    );
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
      throw StateError(
        'Misafir oturumu oluşturulamadı.',
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectCompanyScreen(
          plan: plan,
        ),
      ),
    );
  } on FirebaseAuthException catch (error) {
    if (!mounted) {
      return;
    }

    final String message;

    if (error.code == 'operation-not-allowed') {
      message =
          'Firebase anonim giriş özelliği etkin değil.';
    } else if (error.code == 'too-many-requests') {
      message =
          'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.';
    } else {
      message =
          'Misafir oturumu başlatılamadı. Lütfen tekrar deneyin.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } catch (_) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Danışma ekranı açılamadı. Lütfen tekrar deneyin.',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        title: const Text(
          'Hesaplama',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Planını oluştur',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),

          _input(
            'Finansman Tutarı',
            financeController,
          ),
          _input(
            'Peşinat',
            downPaymentController,
          ),
          _input(
            'İlk Taksit',
            installmentController,
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: model,
            hint: const Text('Seçiniz'),
            decoration: _decor(
              'Ödeme Modeli',
            ),
            items: const [
              DropdownMenuItem(
                value: 'Sabit',
                child: Text('Sabit'),
              ),
              DropdownMenuItem(
                value: 'Aylık %1 Artış',
                child: Text(
                  'Aylık %1 Artış',
                ),
              ),
              DropdownMenuItem(
                value: 'Aylık %2 Artış',
                child: Text(
                  'Aylık %2 Artış',
                ),
              ),
              DropdownMenuItem(
                value: 'Aylık %3 Artış',
                child: Text(
                  'Aylık %3 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '3 Ayda Bir %5 Artış',
                child: Text(
                  '3 Ayda Bir %5 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '3 Ayda Bir %10 Artış',
                child: Text(
                  '3 Ayda Bir %10 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '3 Ayda Bir %15 Artış',
                child: Text(
                  '3 Ayda Bir %15 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '3 Ayda Bir %20 Artış',
                child: Text(
                  '3 Ayda Bir %20 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '6 Ayda Bir %10 Artış',
                child: Text(
                  '6 Ayda Bir %10 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '6 Ayda Bir %15 Artış',
                child: Text(
                  '6 Ayda Bir %15 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '6 Ayda Bir %20 Artış',
                child: Text(
                  '6 Ayda Bir %20 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '12 Ayda Bir %10 Artış',
                child: Text(
                  '12 Ayda Bir %10 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '12 Ayda Bir %15 Artış',
                child: Text(
                  '12 Ayda Bir %15 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '12 Ayda Bir %20 Artış',
                child: Text(
                  '12 Ayda Bir %20 Artış',
                ),
              ),
              DropdownMenuItem(
                value:
                    '12 Ayda Bir %30 Artış',
                child: Text(
                  '12 Ayda Bir %30 Artış',
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                model = value;
              });
            },
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Hesapla',
              ),
            ),
          ),

          if (result != null) ...[
            const SizedBox(height: 22),

            _ResultCard(
              result: result!,
            ),

            if (result!.success) ...[
  const SizedBox(height: 14),

  SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton.icon(
      onPressed: _openConsultationFlow,
      icon: const Icon(
        Icons.support_agent_rounded,
        size: 22,
      ),
      label: const Text(
        'Ücretsiz Uzman Görüşü Al',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            16,
          ),
        ),
        textStyle: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  ),

  const SizedBox(height: 12),

  SizedBox(
    width: double.infinity,
    height: 56,
    child: OutlinedButton.icon(
      onPressed: _openPaymentPlan,
      icon: const Icon(
        Icons.receipt_long_rounded,
        size: 22,
      ),
      label: const Text(
        'Ödeme Planını Göster',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _dark,
        side: const BorderSide(
          color: _dark,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            16,
          ),
        ),
        textStyle: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  ),
],
          ],
        ],
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter
              .digitsOnly,
          CurrencyInputFormatter(),
        ],
        decoration: _decor(label).copyWith(
          suffixText: '₺',
        ),
      ),
    );
  }

  InputDecoration _decor(
    String label,
  ) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  _ResultCard({
    required this.result,
  });

  final FpResult result;

 PaymentPlanItem? get _deliveryItem {
  for (final item in result.paymentPlan) {
    if (item.isDeliveryMonth) {
      return item;
    }
  }

  return null;
}

  @override
  Widget build(BuildContext context) {

    final DateFormat _dateFormat =
    DateFormat(
  'd MMMM yyyy',
  'tr_TR',
);
    if (!result.success) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius:
              BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFECACA),
          ),
        ),
        child: Text(
          result.errorMessage ??
              'Hesaplama sırasında bir hata oluştu.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF991B1B),
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _CalculatorScreenState._dark,
        borderRadius:
            BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Text(
            '${result.estimatedDelivery} Ay',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'Tahmini Teslim Süresi',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 18),

Text(
  _deliveryItem == null
      ? '-'
      : _dateFormat.format(
          _deliveryItem!.paymentDate,
        ),
  style: const TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  ),
),

const SizedBox(height: 4),

const Text(
  'Tahmini Teslim Tarihi',
  style: TextStyle(
    color: Colors.white60,
    fontSize: 13,
  ),
),

const SizedBox(height: 18),

Text(
  'Toplam Vade: ${result.estimatedTerm} Ay',
  style: const TextStyle(
    color: _CalculatorScreenState._gold,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  ),
),
          const SizedBox(height: 18),
          const Text(
            'Bu tahmini analiz FP Engine tarafından oluşturulmuştur. '
            'Resmî plan, sözleşme ve teslim bilgileri ilgili tasarruf finansman '
            'kuruluşu tarafından belirlenir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyInputFormatter
    extends TextInputFormatter {
  final NumberFormat formatter =
      NumberFormat(
    '#,##0',
    'tr_TR',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text =
        newValue.text.replaceAll('.', '');

    if (text.isEmpty) {
      return const TextEditingValue(
        text: '',
      );
    }

    final int? number =
        int.tryParse(text);

    if (number == null) {
      return oldValue;
    }

    final String newText =
        formatter
            .format(number)
            .replaceAll(',', '.');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }
}