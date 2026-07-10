import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../engine/fp_engine.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _dark = Color(0xFF10231B);
  static const Color _gold = Color(0xFFD6A84F);
  static const Color _background = Color(0xFFF7F8F5);

  final financeController = TextEditingController(text: '0');
  final downPaymentController = TextEditingController(text: '0');
  final installmentController = TextEditingController(text: '0');

  String? model;
  FpResult? result;

  @override
  void dispose() {
    financeController.dispose();
    downPaymentController.dispose();
    installmentController.dispose();
    super.dispose();
  }

  void calculate() {
    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ödeme modelini seçiniz.'),
        ),
      );
      return;
    }

    final finance =
        double.tryParse(financeController.text.replaceAll('.', '')) ?? 0;

    final downPayment =
        double.tryParse(downPaymentController.text.replaceAll('.', '')) ?? 0;

    final installment =
        double.tryParse(installmentController.text.replaceAll('.', '')) ?? 0;

    setState(() {
      result = FpEngine.calculate(
        finance: finance,
        downPayment: downPayment,
        installment: installment,
        model: model!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        title: const Text('Hesaplama'),
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
          _input('Finansman Tutarı', financeController),
          _input('Peşinat', downPaymentController),
          _input('İlk Taksit', installmentController),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: model,
            hint: const Text('Seçiniz'),
            decoration: _decor('Ödeme Modeli'),
            items: const [
              DropdownMenuItem(
                value: 'Sabit',
                child: Text('Sabit'),
              ),
              DropdownMenuItem(
                value: 'Aylık %1 Artış',
                child: Text('Aylık %1 Artış'),
              ),
              DropdownMenuItem(
                value: 'Aylık %2 Artış',
                child: Text('Aylık %2 Artış'),
              ),
              DropdownMenuItem(
                value: 'Aylık %3 Artış',
                child: Text('Aylık %3 Artış'),
              ),
              DropdownMenuItem(
                value: '3 Ayda Bir %5 Artış',
                child: Text('3 Ayda Bir %5 Artış'),
              ),
              DropdownMenuItem(
                value: '3 Ayda Bir %10 Artış',
                child: Text('3 Ayda Bir %10 Artış'),
              ),
              DropdownMenuItem(
                value: '3 Ayda Bir %15 Artış',
                child: Text('3 Ayda Bir %15 Artış'),
              ),
              DropdownMenuItem(
                value: '3 Ayda Bir %20 Artış',
                child: Text('3 Ayda Bir %20 Artış'),
              ),
              DropdownMenuItem(
                value: '6 Ayda Bir %10 Artış',
                child: Text('6 Ayda Bir %10 Artış'),
              ),
              DropdownMenuItem(
                value: '6 Ayda Bir %15 Artış',
                child: Text('6 Ayda Bir %15 Artış'),
              ),
              DropdownMenuItem(
                value: '6 Ayda Bir %20 Artış',
                child: Text('6 Ayda Bir %20 Artış'),
              ),
              DropdownMenuItem(
                value: '12 Ayda Bir %10 Artış',
                child: Text('12 Ayda Bir %10 Artış'),
              ),
              DropdownMenuItem(
                value: '12 Ayda Bir %15 Artış',
                child: Text('12 Ayda Bir %15 Artış'),
              ),
              DropdownMenuItem(
                value: '12 Ayda Bir %20 Artış',
                child: Text('12 Ayda Bir %20 Artış'),
              ),
              DropdownMenuItem(
                value: '12 Ayda Bir %30 Artış',
                child: Text('12 Ayda Bir %30 Artış'),
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
              child: const Text('Hesapla'),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 22),
            _ResultCard(result: result!),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyInputFormatter(),
        ],
        decoration: _decor(label).copyWith(
          suffixText: '₺',
        ),
      ),
    );
  }

  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final FpResult result;

  const _ResultCard({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (!result.success) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFECACA),
          ),
        ),
        child: Text(
          result.errorMessage ?? 'Hesaplama sırasında bir hata oluştu.',
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
        borderRadius: BorderRadius.circular(26),
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
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Text(
            '${result.estimatedTerm} Ay Tahmini Vade',
            style: const TextStyle(
              color: _CalculatorScreenState._gold,
              fontSize: 18,
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

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat('#,##0', 'tr_TR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('.', '');

    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.tryParse(text);

    if (number == null) {
      return oldValue;
    }

    final newText = formatter.format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }
}