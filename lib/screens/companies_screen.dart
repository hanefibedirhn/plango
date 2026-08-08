import 'package:flutter/material.dart';

import '../data/companies.dart';
import '../models/company.dart';
import 'company_detail_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  static const Color _pageBg = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _teal = Color(0xFF087C72);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5EAEE);

  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  List<Company> get _visibleCompanies {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return companies;
    }

    return companies.where((company) {
      return company.name.toLowerCase().contains(query) ||
          company.fullName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCompany(Company company) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompanyDetailScreen(company: company),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleCompanies = _visibleCompanies;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        title: const Text(
          'Şirketler',
          style: TextStyle(
            color: _navy,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            _buildSearchField(),
            const SizedBox(height: 18),
            if (visibleCompanies.isEmpty)
              _buildEmptyState()
            else
              _buildCompanyList(visibleCompanies),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {
            _query = value;
          });
        },
        style: const TextStyle(
          color: _navy,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Şirket ara',
          hintStyle: const TextStyle(
            color: Color(0xFF9AA3AC),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _teal,
            size: 22,
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
                    size: 20,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyList(List<Company> visibleCompanies) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: List.generate(
            visibleCompanies.length,
            (index) {
              final company = visibleCompanies[index];
              final isLast = index == visibleCompanies.length - 1;

              return Column(
                children: [
                  _CompanyListItem(
                    company: company,
                    onTap: () => _openCompany(company),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 120,
                      endIndent: 18,
                      color: _border,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 44,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: _muted,
            size: 38,
          ),
          SizedBox(height: 14),
          Text(
            'Şirket bulunamadı',
            style: TextStyle(
              color: _navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Arama kelimesini kontrol ederek tekrar deneyin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyListItem extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;

  const _CompanyListItem({
    required this.company,
    required this.onTap,
  });

  static const Color _navy = Color(0xFF0B2239);
  static const Color _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
  16,
  10,
  14,
  10,
),
          child: Row(
            children: [
              _CompanyLogo(company: company),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  company.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F7),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: _muted,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final Company company;

  const _CompanyLogo({
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
height: 46,
padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE5EAEE),
        ),
      ),
      child: Image.asset(
        company.logoAsset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              company.name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF087C72),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        },
      ),
    );
  }
}