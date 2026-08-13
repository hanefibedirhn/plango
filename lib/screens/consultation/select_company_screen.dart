import 'package:flutter/material.dart';

import '../../data/companies.dart';
import '../../models/calculation_plan.dart';
import '../../models/company.dart';
import 'company_experts_screen.dart';

class SelectCompanyScreen extends StatefulWidget {
  const SelectCompanyScreen({
    super.key,
    required this.plan,
  });

  final CalculationPlan plan;

  @override
  State<SelectCompanyScreen> createState() =>
      _SelectCompanyScreenState();
}

class _SelectCompanyScreenState
    extends State<SelectCompanyScreen> {
  static const Color _background =
      Color(0xFFF7F9FB);
  static const Color _navy =
      Color(0xFF0B2239);
  static const Color _petrol =
      Color(0xFF052F3D);
  static const Color _teal =
      Color(0xFF087C72);
  static const Color _turquoise =
      Color(0xFF16C7B0);
  static const Color _muted =
      Color(0xFF748193);
  static const Color _border =
      Color(0xFFE4EAF0);
  static const Color _softTeal =
      Color(0xFFEAF8F5);

  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Company> get _filteredCompanies {
    final String normalizedQuery =
        _query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return companies;
    }

    return companies.where((company) {
      return company.name
              .toLowerCase()
              .contains(normalizedQuery) ||
          company.fullName
              .toLowerCase()
              .contains(normalizedQuery);
    }).toList();
  }

  void _selectCompany(Company company) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyExpertsScreen(
          company: company,
          plan: widget.plan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Company> filteredCompanies =
        _filteredCompanies;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Şirket Seç',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            18,
            6,
            18,
            36,
          ),
          children: [
            const _ConsultationProgress(
              currentStep: 1,
            ),
            const SizedBox(height: 22),
            const Text(
              'Hangi şirket için görüşmek istiyorsunuz?',
              style: TextStyle(
                color: _navy,
                fontSize: 23,
                height: 1.15,
                letterSpacing: -0.4,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Talebiniz, seçtiğiniz şirkette görev yapan '
              'uygun bir uzmana otomatik olarak yönlendirilir.',
              style: TextStyle(
                color: _muted,
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Şirket ara',
                hintStyle: const TextStyle(
                  color: _muted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _teal,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: _muted,
                        ),
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: _border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: _border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: _teal,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (filteredCompanies.isEmpty)
              const _EmptyCompanyView()
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(24),
                  border: Border.all(
                    color: _border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withOpacity(0.035),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(24),
                  child: Column(
                    children: List.generate(
                      filteredCompanies.length,
                      (index) {
                        final Company company =
                            filteredCompanies[index];
                        final bool isLast =
                            index ==
                                filteredCompanies.length -
                                    1;

                        return Column(
                          children: [
                            _CompanySelectionRow(
                              company: company,
                              onTap: () =>
                                  _selectCompany(
                                company,
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                indent: 78,
                                color: _border,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _petrol.withOpacity(0.045),
                borderRadius:
                    BorderRadius.circular(17),
                border: Border.all(
                  color: _petrol.withOpacity(0.08),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: _teal,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tasarruf Planım herhangi bir şirketi '
                      'tavsiye etmez veya öne çıkarmaz. '
                      'Seçim yalnızca danışma talebinizin '
                      'hangi şirketteki uzmana '
                      'yönlendirileceğini belirler.',
                      style: TextStyle(
                        color: Color(0xFF5E6D7E),
                        fontSize: 11.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
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
    'Talep',
    'Onay',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        _steps.length,
        (index) {
          final int step = index + 1;
          final bool isCompleted =
              step < currentStep;
          final bool isCurrent =
              step == currentStep;
          final bool isActive =
              step <= currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 31,
                        height: 31,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _SelectCompanyScreenState
                                  ._teal
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? _SelectCompanyScreenState
                                    ._teal
                                : _SelectCompanyScreenState
                                    ._border,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                '$step',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : _SelectCompanyScreenState
                                          ._muted,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _steps[index],
                        style: TextStyle(
                          color: isCurrent
                              ? _SelectCompanyScreenState
                                  ._navy
                              : _SelectCompanyScreenState
                                  ._muted,
                          fontSize: 12,
                          fontWeight: isCurrent
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < _steps.length - 1)
                  Container(
                    width: 24,
                    height: 2,
                    margin:
                        const EdgeInsets.only(
                      bottom: 25,
                    ),
                    color: step < currentStep
                        ? _SelectCompanyScreenState
                            ._teal
                        : _SelectCompanyScreenState
                            ._border,
                  ),
              ],
            ),
          );
        },
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
            vertical: 15,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color:
                      _SelectCompanyScreenState
                          ._softTeal,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Image.asset(
                  company.logoAsset,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        company.name.characters.first
                            .toUpperCase(),
                        style: const TextStyle(
                          color:
                              _SelectCompanyScreenState
                                  ._teal,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        color:
                            _SelectCompanyScreenState
                                ._navy,
                        fontSize: 15.5,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Uygun uzmana yönlendir',
                      style: TextStyle(
                        color:
                            _SelectCompanyScreenState
                                ._muted,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6F7),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color:
                      _SelectCompanyScreenState
                          ._teal,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCompanyView extends StatelessWidget {
  const _EmptyCompanyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              _SelectCompanyScreenState
                  ._border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color:
                _SelectCompanyScreenState
                    ._muted,
            size: 38,
          ),
          SizedBox(height: 12),
          Text(
            'Aramanızla eşleşen şirket bulunamadı.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  _SelectCompanyScreenState
                      ._navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
