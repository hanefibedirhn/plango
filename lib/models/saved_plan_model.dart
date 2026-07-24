import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPaymentPlanItem {
  const SavedPaymentPlanItem({
    required this.month,
    required this.installment,
    required this.totalSaving,
    required this.isDeliveryMonth,
    required this.isLastMonth,
  });

  final int month;
  final double installment;
  final double totalSaving;
  final bool isDeliveryMonth;
  final bool isLastMonth;

  factory SavedPaymentPlanItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return SavedPaymentPlanItem(
      month: _readInt(map['month']),
      installment:
          _readDouble(map['installment']),
      totalSaving:
          _readDouble(map['totalSaving']),
      isDeliveryMonth:
          map['isDeliveryMonth'] as bool? ??
              false,
      isLastMonth:
          map['isLastMonth'] as bool? ??
              false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'installment': installment,
      'totalSaving': totalSaving,
      'isDeliveryMonth': isDeliveryMonth,
      'isLastMonth': isLastMonth,
    };
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

class SavedPlan {
  const SavedPlan({
    required this.id,
    required this.userId,
    required this.financeAmount,
    required this.downPayment,
    required this.monthlyInstallment,
    required this.increaseModel,
    required this.estimatedDelivery,
    required this.estimatedTerm,
    required this.lastInstallment,
    required this.totalPayment,
    required this.paymentPlan,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;

  final double financeAmount;
  final double downPayment;
  final double monthlyInstallment;

  final String increaseModel;

  final int estimatedDelivery;
  final int estimatedTerm;

  final double lastInstallment;
  final double totalPayment;

  final List<SavedPaymentPlanItem> paymentPlan;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SavedPlan.fromDocument(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) {
    final Map<String, dynamic> data =
        document.data() ??
            <String, dynamic>{};

    final List<dynamic> rawPaymentPlan =
        data['paymentPlan'] is List
            ? data['paymentPlan']
                as List<dynamic>
            : <dynamic>[];

    return SavedPlan(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      financeAmount:
          _readDouble(data['financeAmount']),
      downPayment:
          _readDouble(data['downPayment']),
      monthlyInstallment:
          _readDouble(
        data['monthlyInstallment'],
      ),
      increaseModel:
          data['increaseModel'] as String? ??
              '',
      estimatedDelivery:
          _readInt(data['estimatedDelivery']),
      estimatedTerm:
          _readInt(data['estimatedTerm']),
      lastInstallment:
          _readDouble(data['lastInstallment']),
      totalPayment:
          _readDouble(data['totalPayment']),
      paymentPlan: rawPaymentPlan
          .whereType<Map>()
          .map(
            (item) =>
                SavedPaymentPlanItem.fromMap(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList(),
      createdAt:
          _readDateTime(data['createdAt']),
      updatedAt:
          _readDateTime(data['updatedAt']),
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

  static DateTime? _readDateTime(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}