class PaymentPlanItem {
  final int month;
  final double installment;
  final double totalSaving;
  final bool isDeliveryMonth;
  final bool isLastMonth;

  const PaymentPlanItem({
    required this.month,
    required this.installment,
    required this.totalSaving,
    required this.isDeliveryMonth,
    required this.isLastMonth,
  });

  PaymentPlanItem copyWith({
    int? month,
    double? installment,
    double? totalSaving,
    bool? isDeliveryMonth,
    bool? isLastMonth,
  }) {
    return PaymentPlanItem(
      month: month ?? this.month,
      installment: installment ?? this.installment,
      totalSaving: totalSaving ?? this.totalSaving,
      isDeliveryMonth:
          isDeliveryMonth ?? this.isDeliveryMonth,
      isLastMonth: isLastMonth ?? this.isLastMonth,
    );
  }
}

class FpResult {
  final bool success;
  final String? errorMessage;
  final int estimatedTerm;
  final int estimatedDelivery;
  final double lastInstallment;
  final double totalPayment;
  final List<PaymentPlanItem> paymentPlan;

  const FpResult({
    required this.success,
    this.errorMessage,
    required this.estimatedTerm,
    required this.estimatedDelivery,
    required this.lastInstallment,
    required this.totalPayment,
    required this.paymentPlan,
  });
}

class FpEngine {
  static FpResult calculate({
    required double finance,
    required double downPayment,
    required double installment,
    required String model,
  }) {
    if (finance <= 0) {
      return _error(
        'Finansman tutarı 0’dan büyük olmalıdır.',
      );
    }

    if (installment <= 0) {
      return _error(
        'Taksit tutarı 0’dan büyük olmalıdır.',
      );
    }

    if (downPayment < 0) {
      return _error(
        'Peşinat negatif olamaz.',
      );
    }

    if (downPayment >= finance) {
      return _error(
        'Peşinat finansman tutarından küçük olmalıdır.',
      );
    }

    final _IncreaseRule increase =
        _getIncreaseRule(model);

    double remaining = finance - downPayment;
    double currentInstallment = installment;
    double totalPaid = downPayment;
    double minInstallment = installment;
    double maxInstallment = installment;

    final double requiredSaving =
        finance * 0.45;

    int saving45Month = 0;

    if (totalPaid >= requiredSaving) {
      saving45Month = 1;
    }

    int month = 0;
    double lastInstallment = installment;

    final List<PaymentPlanItem>
        temporaryPaymentPlan = [];

    while (remaining > 0 && month < 240) {
      month++;

      if (month > 1 && increase.period > 0) {
        if ((month - 1) % increase.period == 0) {
          currentInstallment *=
              (1 + increase.rate);
        }
      }

      double payment = currentInstallment;

      if (payment > remaining) {
        payment = remaining;
      }

      remaining -= payment;

      // Son kalan tutar normal taksitten küçükse
      // ve birleşmiş ödeme üç kat kuralını aşmıyorsa
      // aynı ay içerisinde kapatılır.
      if (remaining > 0 &&
          remaining < currentInstallment) {
        final double mergedPayment =
            payment + remaining;

        if (mergedPayment <=
            minInstallment * 3) {
          payment = mergedPayment;
          remaining = 0;
        }
      }

      totalPaid += payment;
      lastInstallment = payment;

      if (payment < minInstallment) {
        minInstallment = payment;
      }

      if (payment > maxInstallment) {
        maxInstallment = payment;
      }

      if (saving45Month == 0 &&
          totalPaid >= requiredSaving) {
        saving45Month = month;
      }

      temporaryPaymentPlan.add(
        PaymentPlanItem(
          month: month,
          installment: payment,
          totalSaving: totalPaid,
          isDeliveryMonth: false,
          isLastMonth: remaining <= 0,
        ),
      );
    }

    if (month >= 240 && remaining > 0) {
      return _error(
        'Vade 240 ayı aşıyor. '
        'Lütfen taksit veya peşinatı artırın.',
      );
    }

    if (minInstallment <
        maxInstallment / 3) {
      return _error(
        'En düşük taksit tutarı, en yüksek '
        'taksitin üçte birinden az olamaz.',
      );
    }

    final int baseDelivery =
        (month * 0.45).ceil();

    final double downPaymentRate =
        downPayment / finance;

    int deliveryMonth =
        (baseDelivery *
                (1 - downPaymentRate))
            .floor();

    if (month >= 50 &&
        installment <= 10000) {
      deliveryMonth += 1;
    }

    if (saving45Month > 0 &&
        deliveryMonth < saving45Month) {
      deliveryMonth = saving45Month;
    }

    if (deliveryMonth < 7) {
      deliveryMonth = 7;
    }

    if (deliveryMonth > month) {
      deliveryMonth = month;
    }

    final List<PaymentPlanItem>
        finalPaymentPlan =
        temporaryPaymentPlan.map((item) {
      return item.copyWith(
        isDeliveryMonth:
            item.month == deliveryMonth,
      );
    }).toList(growable: false);

    return FpResult(
      success: true,
      estimatedTerm: month,
      estimatedDelivery: deliveryMonth,
      lastInstallment: lastInstallment,
      totalPayment: totalPaid,
      paymentPlan: finalPaymentPlan,
    );
  }

  static FpResult _error(
    String message,
  ) {
    return FpResult(
      success: false,
      errorMessage: message,
      estimatedTerm: 0,
      estimatedDelivery: 0,
      lastInstallment: 0,
      totalPayment: 0,
      paymentPlan: const [],
    );
  }

  static _IncreaseRule _getIncreaseRule(
    String model,
  ) {
    switch (model) {
      case 'Aylık %1 Artış':
        return const _IncreaseRule(
          period: 1,
          rate: 0.01,
        );

      case 'Aylık %2 Artış':
        return const _IncreaseRule(
          period: 1,
          rate: 0.02,
        );

      case 'Aylık %3 Artış':
        return const _IncreaseRule(
          period: 1,
          rate: 0.03,
        );

      case '3 Ayda Bir %5 Artış':
        return const _IncreaseRule(
          period: 3,
          rate: 0.05,
        );

      case '3 Ayda Bir %10 Artış':
        return const _IncreaseRule(
          period: 3,
          rate: 0.10,
        );

      case '3 Ayda Bir %15 Artış':
        return const _IncreaseRule(
          period: 3,
          rate: 0.15,
        );

      case '3 Ayda Bir %20 Artış':
        return const _IncreaseRule(
          period: 3,
          rate: 0.20,
        );

      case '6 Ayda Bir %10 Artış':
        return const _IncreaseRule(
          period: 6,
          rate: 0.10,
        );

      case '6 Ayda Bir %15 Artış':
        return const _IncreaseRule(
          period: 6,
          rate: 0.15,
        );

      case '6 Ayda Bir %20 Artış':
        return const _IncreaseRule(
          period: 6,
          rate: 0.20,
        );

      case '12 Ayda Bir %10 Artış':
        return const _IncreaseRule(
          period: 12,
          rate: 0.10,
        );

      case '12 Ayda Bir %15 Artış':
        return const _IncreaseRule(
          period: 12,
          rate: 0.15,
        );

      case '12 Ayda Bir %20 Artış':
        return const _IncreaseRule(
          period: 12,
          rate: 0.20,
        );

      case '12 Ayda Bir %30 Artış':
        return const _IncreaseRule(
          period: 12,
          rate: 0.30,
        );

      case 'Sabit':
      default:
        return const _IncreaseRule(
          period: 0,
          rate: 0,
        );
    }
  }
}

class _IncreaseRule {
  final int period;
  final double rate;

  const _IncreaseRule({
    required this.period,
    required this.rate,
  });
}