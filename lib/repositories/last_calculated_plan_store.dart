import 'package:flutter/foundation.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';

class LastCalculatedPlanData {
  const LastCalculatedPlanData({
    required this.plan,
    required this.result,
  });

  final CalculationPlan plan;
  final FpResult result;
}

class LastCalculatedPlanStore {
  LastCalculatedPlanStore._();

  static final LastCalculatedPlanStore instance =
      LastCalculatedPlanStore._();

  final ValueNotifier<LastCalculatedPlanData?> dataNotifier =
      ValueNotifier<LastCalculatedPlanData?>(null);

  LastCalculatedPlanData? get data => dataNotifier.value;

  void save({
    required CalculationPlan plan,
    required FpResult result,
  }) {
    dataNotifier.value = LastCalculatedPlanData(
      plan: plan,
      result: result,
    );
  }

  void clear() {
    dataNotifier.value = null;
  }
}