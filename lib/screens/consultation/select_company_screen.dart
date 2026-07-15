import 'package:flutter/material.dart';

import '../../data/companies.dart';
import '../../models/calculation_plan.dart';
import '../../models/company.dart';
import 'company_experts_screen.dart';

class SelectCompanyScreen extends StatelessWidget {
  const SelectCompanyScreen({
    super.key,
    required this.plan,
  });

  final CalculationPlan plan;

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);

  void _selectCompany(
    BuildContext context,
    Company company,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyExpertsScreen(
          company: company,
          plan: plan,
        ),
      ),
    );
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
          'Ücretsiz Uzman Görüşü Al',
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
            32,
          ),
          children: [
            const _ConsultationProgress(
              currentStep: 0,
            ),
            const SizedBox(height: 22),
            const Text(
              'Şirket Seçiniz',
              style: TextStyle(
                color: _textDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.035,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: List.generate(
                    companies.length,
                    (index) {
                      final Company company =
                          companies[index];

                      final bool isLast =
                          index == companies.length - 1;

                      return Column(
                        children: [
                          _CompanySelectionRow(
                            company: company,
                            onTap: () {
                              _selectCompany(
                                context,
                                company,
                              );
                            },
                          ),
                          if (!isLast)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              indent: 72,
                              color: _border,
                            ),
                        ],
                      );
                    },
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

class _ConsultationProgress extends StatelessWidget {
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
          color: SelectCompanyScreen._border,
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
                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isCurrent || isCompleted
                                ? SelectCompanyScreen._green
                                : const Color(0xFFF3F4F6),
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
                                        : SelectCompanyScreen
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
                            color: isCurrent || isCompleted
                                ? SelectCompanyScreen._green
                                : SelectCompanyScreen
                                    ._textMuted,
                            fontSize: 11.5,
                            fontWeight: isCurrent
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < _steps.length - 1)
                    Container(
                      width: 20,
                      height: 2,
                      margin: const EdgeInsets.only(
                        left: 3,
                        right: 3,
                        bottom: 22,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? SelectCompanyScreen._green
                            : SelectCompanyScreen._border,
                        borderRadius:
                            BorderRadius.circular(999),
                      ),
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

class _CompanySelectionRow extends StatelessWidget {
  const _CompanySelectionRow({
    required this.company,
    required this.onTap,
  });

  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SelectCompanyScreen._softGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  company.name.characters.first
                      .toUpperCase(),
                  style: const TextStyle(
                    color: SelectCompanyScreen._green,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  company.name,
                  style: const TextStyle(
                    color:
                        SelectCompanyScreen._textDark,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color:
                      SelectCompanyScreen._textMuted,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}