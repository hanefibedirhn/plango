import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/expert_model.dart';
import '../../repositories/expert_repository.dart';
import 'admin_expert_applications_screen.dart';

class AdminExpertsScreen extends StatefulWidget {
  const AdminExpertsScreen({super.key});

  @override
  State<AdminExpertsScreen> createState() => _AdminExpertsScreenState();
}

class _AdminExpertsScreenState extends State<AdminExpertsScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  final ExpertRepository _expertRepository = ExpertRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  _ExpertFilter _selectedFilter = _ExpertFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<int> _watchPendingApplicationCount() {
    return _firestore
        .collection('expertApplications')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  void _openPendingApplications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminExpertApplicationsScreen(),
      ),
    );
  }

  bool _matchesFilter(Expert expert) {
    switch (_selectedFilter) {
      case _ExpertFilter.all:
        return true;

      case _ExpertFilter.active:
        return expert.status == 'active';

      case _ExpertFilter.suspended:
        return expert.status == 'suspended';

      case _ExpertFilter.notAccepting:
        return expert.status == 'active' &&
            expert.acceptsNewRequests == false;
    }
  }

  bool _matchesSearch(Expert expert) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return true;

    final searchable = [
      expert.firstName,
      expert.lastName,
      expert.companyName,
      expert.branch,
      expert.position,
      expert.corporateEmail,
      expert.phone,
    ].join(' ').toLowerCase();

    return searchable.contains(query);
  }

  Map<String, List<Expert>> _groupExpertsByCompany(
    List<Expert> experts,
  ) {
    final Map<String, List<Expert>> groups = {};

    for (final expert in experts) {
      final company = expert.companyName.trim().isEmpty
          ? 'Firma Belirtilmemiş'
          : expert.companyName.trim();

      groups.putIfAbsent(company, () => []);
      groups[company]!.add(expert);
    }

    final entries = groups.entries.toList()
      ..sort(
        (a, b) => a.key.toLowerCase().compareTo(
              b.key.toLowerCase(),
            ),
      );

    return Map<String, List<Expert>>.fromEntries(entries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Uzman Yönetimi',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: StreamBuilder<List<Expert>>(
        stream: _expertRepository.watchAllExperts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _teal,
              ),
            );
          }

          final experts = snapshot.data ?? const <Expert>[];

          final activeCount = experts
              .where((expert) => expert.status == 'active')
              .length;

          final suspendedCount = experts
              .where((expert) => expert.status == 'suspended')
              .length;

          final acceptingCount = experts
              .where(
                (expert) =>
                    expert.status == 'active' &&
                    expert.acceptsNewRequests,
              )
              .length;

          final filteredExperts = experts
              .where(_matchesFilter)
              .where(_matchesSearch)
              .toList();

          final groupedExperts =
              _groupExpertsByCompany(filteredExperts);

          return RefreshIndicator(
            color: _teal,
            onRefresh: () async {
              await Future<void>.delayed(
                const Duration(milliseconds: 450),
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                _buildHeroCard(
                  totalCount: experts.length,
                ),

                const SizedBox(height: 16),

                _buildStatistics(
                  activeCount: activeCount,
                  suspendedCount: suspendedCount,
                  acceptingCount: acceptingCount,
                ),

                const SizedBox(height: 14),

                _buildPendingApplicationsCard(),

                const SizedBox(height: 22),

                _buildSectionTitle(
                  title: 'Uzmanlar',
                  subtitle:
                      '${filteredExperts.length} uzman görüntüleniyor',
                ),

                const SizedBox(height: 10),

                _buildSearchField(),

                const SizedBox(height: 12),

                _buildFilters(),

                const SizedBox(height: 18),

                if (filteredExperts.isEmpty)
                  _buildEmptyState()
                else
                  ...groupedExperts.entries.map(
                    (entry) => _CompanyExpertGroup(
                      companyName: entry.key,
                      experts: entry.value,
                      onExpertTap: _showExpertDetails,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard({
    required int totalCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _navy,
            _petrol,
            Color(0xFF0C6268),
            _teal,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240B2239),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: _turquoise.withOpacity(.15),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFF55E2D0).withOpacity(.25),
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Color(0xFF55E2D0),
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uzman Ağı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Başvuruları ve aktif uzman ağını tek noktadan yönet.',
                  style: TextStyle(
                    color: Color(0xFFD7E5E7),
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'TOPLAM',
                style: TextStyle(
                  color: Color(0xFF9EC9CA),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics({
    required int activeCount,
    required int suspendedCount,
    required int acceptingCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: activeCount,
            title: 'Aktif',
            icon: Icons.verified_outlined,
            iconBackground: const Color(0xFFE8F7F5),
            iconColor: _teal,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _StatCard(
            value: acceptingCount,
            title: 'Talep Alıyor',
            icon: Icons.forum_outlined,
            iconBackground: const Color(0xFFEAF2F8),
            iconColor: const Color(0xFF356B91),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _StatCard(
            value: suspendedCount,
            title: 'Askıda',
            icon: Icons.pause_circle_outline_rounded,
            iconBackground: const Color(0xFFFFF1E7),
            iconColor: const Color(0xFFC76A26),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingApplicationsCard() {
    return StreamBuilder<int>(
      stream: _watchPendingApplicationCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _openPendingApplications,
            child: Ink(
              padding: const EdgeInsets.fromLTRB(
                14,
                13,
                12,
                13,
              ),
              decoration: BoxDecoration(
                color: count > 0
                    ? const Color(0xFFFFF8EC)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: count > 0
                      ? const Color(0xFFF2DFC1)
                      : _border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: count > 0
                          ? const Color(0xFFFFEBCB)
                          : const Color(0xFFE8F7F5),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      count > 0
                          ? Icons.hourglass_top_rounded
                          : Icons.task_alt_rounded,
                      color: count > 0
                          ? const Color(0xFFB96B18)
                          : _teal,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          count > 0
                              ? '$count Bekleyen Uzman Başvurusu'
                              : 'Bekleyen Başvuru Yok',
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          count > 0
                              ? 'Başvuruları incele ve sonuçlandır.'
                              : 'Uzman başvuru ekranını görüntüle.',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF93A0AA),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.25,
            ),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: const TextStyle(
        color: _navy,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Uzman, firma, şube veya pozisyon ara...',
        hintStyle: const TextStyle(
          color: Color(0xFF9AA6B1),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _teal,
          size: 21,
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                ),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _teal,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            title: 'Tümü',
            selected: _selectedFilter == _ExpertFilter.all,
            onTap: () {
              setState(() {
                _selectedFilter = _ExpertFilter.all;
              });
            },
          ),
          _FilterChip(
            title: 'Aktif',
            selected: _selectedFilter == _ExpertFilter.active,
            onTap: () {
              setState(() {
                _selectedFilter = _ExpertFilter.active;
              });
            },
          ),
          _FilterChip(
            title: 'Talep Almıyor',
            selected:
                _selectedFilter == _ExpertFilter.notAccepting,
            onTap: () {
              setState(() {
                _selectedFilter = _ExpertFilter.notAccepting;
              });
            },
          ),
          _FilterChip(
            title: 'Askıda',
            selected:
                _selectedFilter == _ExpertFilter.suspended,
            onTap: () {
              setState(() {
                _selectedFilter = _ExpertFilter.suspended;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.manage_search_rounded,
            color: Color(0xFF9AA6B1),
            size: 38,
          ),
          SizedBox(height: 12),
          Text(
            'Uzman bulunamadı',
            style: TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Arama kriterlerini veya seçili filtreyi değiştirebilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF1D2CF),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB42318),
                size: 34,
              ),
              const SizedBox(height: 12),
              const Text(
                'Uzmanlar yüklenemedi',
                style: TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeRequestStatus({
    required Expert expert,
    required bool value,
  }) async {
    try {
      await _expertRepository.setAcceptsNewRequests(
        uid: expert.uid,
        value: value,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Yeni danışma talepleri açıldı.'
                : 'Yeni danışma talepleri kapatıldı.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem tamamlanamadı: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _suspendExpert(Expert expert) async {
    final reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Uzmanı Askıya Al',
            style: TextStyle(
              color: _navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${expert.firstName} ${expert.lastName} uzman hesabı '
                'geçici olarak pasife alınacak ve yeni danışma talebi '
                'alımı kapatılacak.',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Askıya alma nedeni',
                  hintText: 'Kısa bir açıklama yaz...',
                  filled: true,
                  fillColor: _background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC76A26),
              ),
              onPressed: () {
                final value = reasonController.text.trim();
                if (value.isEmpty) return;
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Askıya Al'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.trim().isEmpty) return;

    try {
      await _expertRepository.suspendExpert(
        uid: expert.uid,
        reason: reason,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uzman askıya alındı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uzman askıya alınamadı: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _activateExpert(Expert expert) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Uzmanı Yeniden Aktifleştir',
                style: TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Text(
                '${expert.firstName} ${expert.lastName} yeniden aktif '
                'uzman durumuna getirilecek ve yeni danışma talebi '
                'alımı açılacak.',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Aktifleştir'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    try {
      await _expertRepository.activateExpert(expert: expert);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uzman yeniden aktifleştirildi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uzman aktifleştirilemedi: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteExpert(
    Expert expert,
    BuildContext sheetContext,
  ) async {
    final bool firstConfirmation = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Uzman Hesabını Sil',
                style: TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Text(
                '${expert.firstName} ${expert.lastName} uzman ağından '
                'kalıcı olarak kaldırılacak. Normal Tasarruf Planım kullanıcı '
                'hesabı korunacak.',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB42318),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Devam Et'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!firstConfirmation || !mounted) return;

    final bool finalConfirmation = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Son Onay',
                style: TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: const Text(
                'Bu işlem uzman profilini kalıcı olarak kaldıracaktır. '
                'Bu işlemi geri almak için uzmanlığın yeniden '
                'oluşturulması gerekir. Devam etmek istiyor musunuz?',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hayır'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB42318),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Evet, Sil'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!finalConfirmation) return;

    try {
      await _expertRepository.deleteExpert(uid: expert.uid);

      if (!mounted) return;

      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uzman hesabı kaldırıldı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uzman hesabı silinemedi: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showExpertDetails(Expert expert) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: .78,
          minChildSize: .50,
          maxChildSize: .94,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: StreamBuilder<Expert?>(
                stream: _expertRepository.watchExpert(expert.uid),
                initialData: expert,
                builder: (context, snapshot) {
                  final currentExpert = snapshot.data;

                  if (currentExpert == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Uzman profili artık mevcut değil.',
                          style: TextStyle(
                            color: _muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }

                  final bool isSuspended =
                      currentExpert.status == 'suspended';

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3DCE1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _ExpertAvatar(
                            firstName: currentExpert.firstName,
                            lastName: currentExpert.lastName,
                            size: 54,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentExpert.firstName} '
                                  '${currentExpert.lastName}'.trim(),
                                  style: const TextStyle(
                                    color: _navy,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.25,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                _ExpertStatusBadge(expert: currentExpert),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _DetailSection(
                        children: [
                          _DetailRow(
                            icon: Icons.business_outlined,
                            title: 'Firma',
                            value: currentExpert.companyName,
                          ),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            title: 'Şube',
                            value: currentExpert.branch,
                          ),
                          _DetailRow(
                            icon: Icons.badge_outlined,
                            title: 'Pozisyon',
                            value: currentExpert.position,
                          ),
                          _DetailRow(
                            icon: Icons.alternate_email_rounded,
                            title: 'Kurumsal E-posta',
                            value: currentExpert.corporateEmail,
                          ),
                          _DetailRow(
                            icon: Icons.phone_outlined,
                            title: 'Telefon',
                            value: currentExpert.phone,
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isSuspended
                                    ? const Color(0xFFF1F3F5)
                                    : const Color(0xFFE8F7F5),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                Icons.forum_outlined,
                                color: isSuspended
                                    ? const Color(0xFF9AA6B1)
                                    : _teal,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yeni Danışma Talepleri',
                                    style: TextStyle(
                                      color: _navy,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Uzmanın yeni talep alma durumu',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: currentExpert.acceptsNewRequests,
                              activeColor: _teal,
                              onChanged: isSuspended
                                  ? null
                                  : (value) {
                                      _changeRequestStatus(
                                        expert: currentExpert,
                                        value: value,
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                      if (isSuspended) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF3DFC9),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFC76A26),
                                size: 18,
                              ),
                              SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Askıdaki uzman yeni danışma talebi '
                                  'alamaz. Talep alımını açmak için önce '
                                  'uzmanı yeniden aktifleştirin.',
                                  style: TextStyle(
                                    color: Color(0xFF7B5A3A),
                                    fontSize: 10.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Text(
                        'Yönetim İşlemleri',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isSuspended
                                ? _teal
                                : const Color(0xFFC76A26),
                            side: BorderSide(
                              color: isSuspended
                                  ? const Color(0xFFB8E4DF)
                                  : const Color(0xFFF0D5BE),
                            ),
                            backgroundColor: isSuspended
                                ? const Color(0xFFF0F8F7)
                                : const Color(0xFFFFF8F1),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            if (isSuspended) {
                              _activateExpert(currentExpert);
                            } else {
                              _suspendExpert(currentExpert);
                            }
                          },
                          icon: Icon(
                            isSuspended
                                ? Icons.play_circle_outline_rounded
                                : Icons.pause_circle_outline_rounded,
                            size: 20,
                          ),
                          label: Text(
                            isSuspended
                                ? 'Uzmanı Yeniden Aktifleştir'
                                : 'Uzmanı Askıya Al',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6F5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFF1D2CF),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFB42318),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tehlikeli İşlem',
                                  style: TextStyle(
                                    color: Color(0xFFB42318),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Uzman hesabını Tasarruf Planım uzman ağından '
                              'kalıcı olarak kaldırır. Normal kullanıcı '
                              'hesabı korunur.',
                              style: TextStyle(
                                color: Color(0xFF7C5B58),
                                fontSize: 10.5,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 11),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFB42318),
                                  side: const BorderSide(
                                    color: Color(0xFFE8B8B4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  _deleteExpert(
                                    currentExpert,
                                    sheetContext,
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 19,
                                ),
                                label: const Text(
                                  'Uzman Hesabını Sil',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

}

enum _ExpertFilter {
  all,
  active,
  notAccepting,
  suspended,
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.title,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final int value;
  final String title;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 12, 10, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE4EBEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 17,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF0B2239),
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF748193),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF0B2239)
                  : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: selected
                    ? const Color(0xFF0B2239)
                    : const Color(0xFFE4EBEE),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(0xFF647381),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyExpertGroup extends StatefulWidget {
  const _CompanyExpertGroup({
    required this.companyName,
    required this.experts,
    required this.onExpertTap,
  });

  final String companyName;
  final List<Expert> experts;
  final ValueChanged<Expert> onExpertTap;

  @override
  State<_CompanyExpertGroup> createState() =>
      _CompanyExpertGroupState();
}

class _CompanyExpertGroupState
    extends State<_CompanyExpertGroup> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded
              ? const Color(0xFFB8E4DF)
              : const Color(0xFFE4EBEE),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B2239),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: _isExpanded
                ? const Color(0xFFF0F8F7)
                : const Color(0xFFF4F8F9),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  13,
                  12,
                  13,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _isExpanded
                            ? const Color(0xFFDDF3F0)
                            : const Color(0xFFE3F3F1),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF087C72),
                        size: 18,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.companyName,
                            style: const TextStyle(
                              color: Color(0xFF0B2239),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${widget.experts.length} uzman',
                            style: const TextStyle(
                              color: Color(0xFF748193),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              const Color(0xFFDDE7E9),
                        ),
                      ),
                      child: Text(
                        '${widget.experts.length}',
                        style: const TextStyle(
                          color: Color(0xFF087C72),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    AnimatedRotation(
                      turns: _isExpanded ? .5 : 0,
                      duration:
                          const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF7E8D98),
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox(
              width: double.infinity,
              height: 0,
            ),
            secondChild: Column(
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE8EFF1),
                ),

                ...List.generate(
                  widget.experts.length,
                  (index) {
                    final Expert expert =
                        widget.experts[index];

                    return _ExpertTile(
                      expert: expert,
                      showDivider:
                          index != widget.experts.length - 1,
                      onTap: () {
                        widget.onExpertTap(expert);
                      },
                    );
                  },
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(
              milliseconds: 220,
            ),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

class _ExpertTile extends StatelessWidget {
  const _ExpertTile({
    required this.expert,
    required this.showDivider,
    required this.onTap,
  });

  final Expert expert;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                13,
                12,
                10,
                12,
              ),
              child: Row(
                children: [
                  _ExpertAvatar(
                    firstName: expert.firstName,
                    lastName: expert.lastName,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${expert.firstName} ${expert.lastName}'
                              .trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0B2239),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            expert.branch,
                            expert.position,
                          ]
                              .where(
                                (value) => value.trim().isNotEmpty,
                              )
                              .join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF748193),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _ExpertStatusBadge(
                          expert: expert,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFA0ABB4),
                    size: 21,
                  ),
                ],
              ),
            ),
            if (showDivider)
              const Padding(
                padding: EdgeInsets.only(left: 65),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEDF1F3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpertAvatar extends StatelessWidget {
  const _ExpertAvatar({
    required this.firstName,
    required this.lastName,
    this.size = 42,
  });

  final String firstName;
  final String lastName;
  final double size;

  @override
  Widget build(BuildContext context) {
    String initials = '';

    if (firstName.trim().isNotEmpty) {
      initials += firstName.trim()[0];
    }

    if (lastName.trim().isNotEmpty) {
      initials += lastName.trim()[0];
    }

    if (initials.isEmpty) {
      initials = 'U';
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE1F3F0),
            Color(0xFFEDF8F7),
          ],
        ),
        borderRadius: BorderRadius.circular(size * .32),
      ),
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF087C72),
          fontSize: size * .32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ExpertStatusBadge extends StatelessWidget {
  const _ExpertStatusBadge({
    required this.expert,
    this.compact = false,
  });

  final Expert expert;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    late final String title;
    late final Color background;
    late final Color foreground;

    if (expert.status == 'suspended') {
      title = 'Askıda';
      background = const Color(0xFFFFEFE5);
      foreground = const Color(0xFFB85D1D);
    } else if (!expert.acceptsNewRequests) {
      title = 'Aktif • Talep Almıyor';
      background = const Color(0xFFF1F3F5);
      foreground = const Color(0xFF66727D);
    } else {
      title = 'Aktif • Talep Alıyor';
      background = const Color(0xFFE7F6F3);
      foreground = const Color(0xFF087C72);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: foreground,
            fontSize: compact ? 8.5 : 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4EBEE),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final displayValue =
        value.trim().isEmpty ? 'Belirtilmemiş' : value.trim();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF087C72),
                size: 19,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF8A96A1),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      displayValue,
                      style: const TextStyle(
                        color: Color(0xFF0B2239),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 44),
            child: Divider(
              height: 1,
              color: Color(0xFFEDF1F3),
            ),
          ),
      ],
    );
  }
}