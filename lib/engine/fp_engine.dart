class FpResult {
  final bool success;
  final String? errorMessage;
  final int estimatedTerm;
  final int estimatedDelivery;
  final double lastInstallment;
  final double totalPayment;

  FpResult({
    required this.success,
    this.errorMessage,
    required this.estimatedTerm,
    required this.estimatedDelivery,
    required this.lastInstallment,
    required this.totalPayment,
  });
}

class FpEngine {
  static FpResult calculate({
    required double finance,
    required double downPayment,
    required double installment,
    required String model,
  }) {
    if (finance <= 0) return _error('Finansman tutarı 0’dan büyük olmalıdır.');
    if (installment <= 0) return _error('Taksit tutarı 0’dan büyük olmalıdır.');
    if (downPayment < 0) return _error('Peşinat negatif olamaz.');
    if (downPayment >= finance) {
      return _error('Peşinat finansman tutarından küçük olmalıdır.');
    }

    final increase = _getIncreaseRule(model);

    double remaining = finance - downPayment;
    double currentInstallment = installment;
    double totalPaid = downPayment;
    double minInstallment = installment;
    double maxInstallment = installment;
    final requiredSaving = finance * 0.45;
int saving45Month = 0;

if (totalPaid >= requiredSaving) {
  saving45Month = 1;
}

    int month = 0;
    double lastInstallment = installment;

    while (remaining > 0 && month < 240) {
  month++;

  if (month > 1 && increase.period > 0) {
    if ((month - 1) % increase.period == 0) {
      currentInstallment *= (1 + increase.rate);
    }
  }

  double payment = currentInstallment;

  if (payment > remaining) {
    payment = remaining;
  }

  remaining -= payment;

  // Son kalan tutar normal taksitten küçükse
  // ve son ödeme 3 kat kuralını aşmıyorsa aynı ayda toparla.
  if (remaining > 0 && remaining < currentInstallment) {
    final mergedPayment = payment + remaining;

    if (mergedPayment <= minInstallment * 3) {
      payment = mergedPayment;
      remaining = 0;
    }
  }

  totalPaid += payment;
  lastInstallment = payment;

  if (payment < minInstallment) minInstallment = payment;
  if (payment > maxInstallment) maxInstallment = payment;

  if (saving45Month == 0 && totalPaid >= requiredSaving) {
    saving45Month = month;
  }
}

    if (month >= 240) {
      return _error('Vade 240 ayı aşıyor. Lütfen taksit veya peşinatı artırın.');
    }

    if (minInstallment < maxInstallment / 3) {
      return _error(
        'En düşük taksit tutarı, en yüksek taksitin üçte birinden az olamaz.',
      );
    }

    final baseDelivery = (month * 0.45).ceil();
    final downPaymentRate = downPayment / finance;

    int deliveryMonth = (baseDelivery * (1 - downPaymentRate)).floor();
    if (month >= 50 && installment <= 10000) {
  deliveryMonth += 1;
}
if (saving45Month > 0 && deliveryMonth < saving45Month) {
  deliveryMonth = saving45Month;
}

    if (deliveryMonth < 7) deliveryMonth = 7;
    if (deliveryMonth > month) deliveryMonth = month;

    return FpResult(
      success: true,
      estimatedTerm: month,
      estimatedDelivery: deliveryMonth,
      lastInstallment: lastInstallment,
      totalPayment: totalPaid,
    );
  }

  static FpResult _error(String message) {
    return FpResult(
      success: false,
      errorMessage: message,
      estimatedTerm: 0,
      estimatedDelivery: 0,
      lastInstallment: 0,
      totalPayment: 0,
    );
  }

  static _IncreaseRule _getIncreaseRule(String model) {
    switch (model) {
      case 'Aylık %1 Artış':
        return _IncreaseRule(period: 1, rate: 0.01);
      case 'Aylık %2 Artış':
        return _IncreaseRule(period: 1, rate: 0.02);
      case 'Aylık %3 Artış':
        return _IncreaseRule(period: 1, rate: 0.03);
      case '3 Ayda Bir %5 Artış':
        return _IncreaseRule(period: 3, rate: 0.05);
      case '3 Ayda Bir %10 Artış':
        return _IncreaseRule(period: 3, rate: 0.10);
      case '3 Ayda Bir %15 Artış':
        return _IncreaseRule(period: 3, rate: 0.15);
      case '3 Ayda Bir %20 Artış':
        return _IncreaseRule(period: 3, rate: 0.20);
      case '6 Ayda Bir %10 Artış':
        return _IncreaseRule(period: 6, rate: 0.10);
      case '6 Ayda Bir %15 Artış':
        return _IncreaseRule(period: 6, rate: 0.15);
      case '6 Ayda Bir %20 Artış':
        return _IncreaseRule(period: 6, rate: 0.20);
      case '12 Ayda Bir %10 Artış':
        return _IncreaseRule(period: 12, rate: 0.10);
      case '12 Ayda Bir %15 Artış':
        return _IncreaseRule(period: 12, rate: 0.15);
      case '12 Ayda Bir %20 Artış':
        return _IncreaseRule(period: 12, rate: 0.20);
      case '12 Ayda Bir %30 Artış':
        return _IncreaseRule(period: 12, rate: 0.30);
      case 'Sabit':
      default:
        return _IncreaseRule(period: 0, rate: 0);
    }
  }
}

class _IncreaseRule {
  final int period;
  final double rate;

  _IncreaseRule({
    required this.period,
    required this.rate,
  });
}