import 'package:flutter/material.dart';

import '../../models/calculation_plan.dart';
import '../../models/company.dart';
import '../../models/expert_profile_model.dart';
import '../../repositories/expert_profile_repository.dart';
import 'consultation_request_screen.dart';

class CompanyExpertsScreen extends StatelessWidget {
  const CompanyExpertsScreen({
    super.key,
    required this.company,
    required this.plan,
  });

  final Company company;
  final CalculationPlan plan;

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);
  static const Color _unavailableBackground =
      Color(0xFFF3F4F6);

  void _selectExpert(
    BuildContext context,
    ExpertProfile expert,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationRequestScreen(
  company: company,
  expert: expert,
  plan: plan,
),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpertProfileRepository repository =
        ExpertProfileRepository();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '${company.name} Uzmanları',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ExpertProfile>>(
          stream: repository.watchCompanyExperts(
            company.name,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _LoadingView();
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message: _messageForError(
                  snapshot.error,
                ),
              );
            }

            final List<ExpertProfile> experts =
                snapshot.data ?? const [];

            final List<ExpertProfile>
                availableExperts = experts
                    .where(
                      (expert) =>
                          expert.canReceiveRequests,
                    )
                    .toList();

            final List<ExpertProfile>
                unavailableExperts = experts
                    .where(
                      (expert) =>
                          expert.isVisible &&
                          !expert.acceptsNewRequests,
                    )
                    .toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                34,
              ),
              children: [
                const _ConsultationProgress(
                  currentStep: 1,
                ),
                const SizedBox(height: 22),

                _CompanyHeader(
                  companyName: company.name,
                ),
                const SizedBox(height: 24),

                if (experts.isEmpty)
                  const _EmptyExpertView()
                else ...[
                  if (availableExperts.isNotEmpty) ...[
                    const _SectionHeader(
                      icon: Icons.forum_outlined,
                      title:
                          'Danışma Talebi Oluşturabileceğiniz Uzmanlar',
                    ),
                    const SizedBox(height: 11),

                    for (final ExpertProfile expert
                        in availableExperts)
                      _ExpertCard(
                        expert: expert,
                        isAvailable: true,
                        onTap: () {
                          _selectExpert(
                            context,
                            expert,
                          );
                        },
                      ),
                  ],

                  if (availableExperts.isEmpty)
                    const _NoAvailableExpertNotice(),

                  if (unavailableExperts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionHeader(
                      icon:
                          Icons.schedule_outlined,
                      title:
                          'Şu Anda Talep Almayan Uzmanlar',
                    ),
                    const SizedBox(height: 11),

                    for (final ExpertProfile expert
                        in unavailableExperts)
                      _ExpertCard(
                        expert: expert,
                        isAvailable: false,
                      ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  static String _messageForError(
    Object? error,
  ) {
    final String message = error.toString();

    if (message.contains('permission-denied')) {
      return 'Uzman profillerini görüntülemek için '
          'Firestore erişim kurallarının güncellenmesi gerekiyor.';
    }

    if (message.contains('failed-precondition') ||
        message.contains('index')) {
      return 'Uzmanların listelenmesi için Firestore '
          'dizini oluşturulması gerekiyor.';
    }

    return 'Uzmanlar yüklenirken bir sorun oluştu.';
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
          color: CompanyExpertsScreen._border,
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
                            color:
                                isCompleted || isCurrent
                                    ? CompanyExpertsScreen
                                        ._green
                                    : const Color(
                                        0xFFF3F4F6,
                                      ),
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
                                        : CompanyExpertsScreen
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
                            color:
                                isCompleted || isCurrent
                                    ? CompanyExpertsScreen
                                        ._green
                                    : CompanyExpertsScreen
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
                  if (index <
                      _steps.length - 1)
                    Container(
                      width: 20,
                      height: 2,
                      margin:
                          const EdgeInsets.only(
                        left: 3,
                        right: 3,
                        bottom: 22,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? CompanyExpertsScreen
                                ._green
                            : CompanyExpertsScreen
                                ._border,
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

class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader({
    required this.companyName,
  });

  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: CompanyExpertsScreen._softGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Text(
              companyName.characters.first
                  .toUpperCase(),
              style: const TextStyle(
                color: CompanyExpertsScreen._green,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: const TextStyle(
                    color:
                        CompanyExpertsScreen._textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Plango uzmanları',
                  style: TextStyle(
                    color:
                        CompanyExpertsScreen._textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: CompanyExpertsScreen._green,
          size: 22,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color:
                  CompanyExpertsScreen._textDark,
              fontSize: 15.5,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({
    required this.expert,
    required this.isAvailable,
    this.onTap,
  });

  final ExpertProfile expert;
  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 11,
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: CompanyExpertsScreen._border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? CompanyExpertsScreen
                            ._softGreen
                        : CompanyExpertsScreen
                            ._unavailableBackground,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Text(
                    _initials(expert),
                    style: TextStyle(
                      color: isAvailable
                          ? CompanyExpertsScreen
                              ._green
                          : CompanyExpertsScreen
                              ._textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.fullName,
                        style: const TextStyle(
                          color:
                              CompanyExpertsScreen
                                  ._textDark,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        expert.position,
                        style: const TextStyle(
                          color:
                              CompanyExpertsScreen
                                  ._textMuted,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_city_outlined,
                  color:
                      CompanyExpertsScreen._green,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    expert.branch,
                    style: const TextStyle(
                      color:
                          CompanyExpertsScreen
                              ._textDark,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isAvailable)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.forum_outlined,
                    size: 20,
                  ),
                  label: const Text(
                    'Görüş Al',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        CompanyExpertsScreen._green,
                    side: const BorderSide(
                      color:
                          CompanyExpertsScreen._green,
                    ),
                    minimumSize:
                        const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: CompanyExpertsScreen
                      ._unavailableBackground,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Text(
                  'Şu anda yeni danışma talebi almıyor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        CompanyExpertsScreen._textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _initials(
    ExpertProfile expert,
  ) {
    final String firstInitial =
        expert.firstName.trim().isEmpty
            ? ''
            : expert.firstName
                .trim()
                .characters
                .first
                .toUpperCase();

    final String lastInitial =
        expert.lastName.trim().isEmpty
            ? ''
            : expert.lastName
                .trim()
                .characters
                .first
                .toUpperCase();

    final String initials =
        '$firstInitial$lastInitial';

    return initials.isEmpty ? 'U' : initials;
  }
}

class _NoAvailableExpertNotice
    extends StatelessWidget {
  const _NoAvailableExpertNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.schedule_outlined,
            color: Color(0xFF92400E),
            size: 22,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Bu şirkette şu anda yeni danışma talebi alan uzman bulunmuyor.',
              style: TextStyle(
                color: Color(0xFF78350F),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyExpertView extends StatelessWidget {
  const _EmptyExpertView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        22,
        30,
        22,
        30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CompanyExpertsScreen._border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            color: CompanyExpertsScreen._green,
            size: 45,
          ),
          SizedBox(height: 15),
          Text(
            'Uzman Bulunamadı',
            style: TextStyle(
              color: CompanyExpertsScreen._textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Bu şirkette görev yapan Plango uzmanları '
            'eklendiğinde burada görüntülenecektir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CompanyExpertsScreen._textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: CompanyExpertsScreen._green,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB42318),
              size: 44,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CompanyExpertsScreen._textDark,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}