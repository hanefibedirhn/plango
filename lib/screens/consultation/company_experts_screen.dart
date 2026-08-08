import 'package:flutter/material.dart';

import '../../models/calculation_plan.dart';
import '../../models/company.dart';
import 'consultation_request_screen.dart';

/// Eski uzman seçimi akışından kalan yönlendirme noktasıdır.
///
/// Kullanıcı artık uzman seçmez. Bu ekran, mevcut çağrıları kırmadan
/// seçilen şirket ve FP Engine planını doğrudan danışma talebi ekranına
/// aktarır.
class CompanyExpertsScreen extends StatelessWidget {
  const CompanyExpertsScreen({
    super.key,
    required this.company,
    required this.plan,
  });

  final Company company;
  final CalculationPlan plan;

  @override
  Widget build(BuildContext context) {
    return ConsultationRequestScreen(
      company: company,
      plan: plan,
    );
  }
}
