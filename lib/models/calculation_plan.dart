class CalculationPlan {
  const CalculationPlan({
    required this.financeAmount,
    required this.downPayment,
    required this.monthlyInstallment,
    required this.increaseModel,
    required this.estimatedDelivery,
    required this.estimatedTerm,
  });

  final double financeAmount;
  final double downPayment;
  final double monthlyInstallment;

  final String increaseModel;

  final int estimatedDelivery;
  final int estimatedTerm;

  CalculationPlan copyWith({
    double? financeAmount,
    double? downPayment,
    double? monthlyInstallment,
    String? increaseModel,
    int? estimatedDelivery,
    int? estimatedTerm,
  }) {
    return CalculationPlan(
      financeAmount:
          financeAmount ?? this.financeAmount,
      downPayment:
          downPayment ?? this.downPayment,
      monthlyInstallment:
          monthlyInstallment ??
              this.monthlyInstallment,
      increaseModel:
          increaseModel ?? this.increaseModel,
      estimatedDelivery:
          estimatedDelivery ??
              this.estimatedDelivery,
      estimatedTerm:
          estimatedTerm ?? this.estimatedTerm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'financeAmount': financeAmount,
      'downPayment': downPayment,
      'monthlyInstallment': monthlyInstallment,
      'increaseModel': increaseModel,
      'estimatedDelivery': estimatedDelivery,
      'estimatedTerm': estimatedTerm,
    };
  }

  factory CalculationPlan.fromMap(
    Map<String, dynamic> map,
  ) {
    return CalculationPlan(
      financeAmount:
          _readDouble(map['financeAmount']),
      downPayment:
          _readDouble(map['downPayment']),
      monthlyInstallment:
          _readDouble(map['monthlyInstallment']),
      increaseModel:
          map['increaseModel'] as String? ?? '',
      estimatedDelivery:
          _readInt(map['estimatedDelivery']),
      estimatedTerm:
          _readInt(map['estimatedTerm']),
    );
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  static int _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return 0;
  }
}