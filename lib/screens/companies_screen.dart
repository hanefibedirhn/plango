import 'package:flutter/material.dart';

import '../data/companies.dart';
import '../models/company.dart';
import 'company_detail_screen.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  static const Color pageBg = Color(0xFFF6F7F8);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color plangoGreen = Color(0xFF0F7A4F);
  static const Color softGreen = Color(0xFFEAF7F1);
  static const Color divider = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        foregroundColor: textDark,
        elevation: 0,
        title: const Text(
          'Tasarruf Finansman Şirketleri',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 21,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: List.generate(companies.length, (index) {
                  final Company company = companies[index];
                  final bool isLast = index == companies.length - 1;

                  return Column(
                    children: [
                      _CompanyListRow(
                        company: company,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CompanyDetailScreen(company: company),
                            ),
                          );
                        },
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          indent: 70,
                          color: divider,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyListRow extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;

  const _CompanyListRow({
    required this.company,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CompaniesScreen.softGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  company.name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: CompaniesScreen.plangoGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  company.name,
                  style: const TextStyle(
                    color: CompaniesScreen.textDark,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
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
                  color: CompaniesScreen.textMuted,
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