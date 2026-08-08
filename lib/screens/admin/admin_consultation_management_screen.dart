import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/consultation_request_model.dart';
import '../../repositories/consultation_repository.dart';
import 'admin_consultation_request_detail_screen.dart';

class AdminConsultationManagementScreen
    extends StatefulWidget {
  const AdminConsultationManagementScreen({
    super.key,
  });

  @override
  State<AdminConsultationManagementScreen>
      createState() =>
          _AdminConsultationManagementScreenState();
}

class _AdminConsultationManagementScreenState
    extends State<AdminConsultationManagementScreen> {
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

  final ConsultationRepository _repository =
      ConsultationRepository();

  final TextEditingController _searchController =
      TextEditingController();

  final NumberFormat _currencyFormatter =
      NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  String _selectedFilter = 'all';
  String _searchQuery = '';

  static const List<_StatusFilter> _filters = [
    _StatusFilter(
      key: 'all',
      label: 'Tümü',
    ),
    _StatusFilter(
      key: 'waiting',
      label: 'Atama Bekleyen',
    ),
    _StatusFilter(
      key: 'pending',
      label: 'Atandı',
    ),
    _StatusFilter(
      key: 'accepted',
      label: 'Kabul Edilen',
    ),
    _StatusFilter(
      key: 'contacted',
      label: 'İletişime Geçilen',
    ),
    _StatusFilter(
      key: 'completed',
      label: 'Tamamlanan',
    ),
    _StatusFilter(
      key: 'rejected',
      label: 'Reddedilen',
    ),
    _StatusFilter(
      key: 'expired',
      label: 'Süresi Dolan',
    ),
    _StatusFilter(
      key: 'cancelled',
      label: 'İptal Edilen',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ConsultationRequest> _applyFilters(
    List<ConsultationRequest> requests,
  ) {
    final String query =
        _searchQuery.trim().toLowerCase();

    return requests.where((request) {
      final bool matchesStatus =
          _matchesStatus(request.status);

      if (!matchesStatus) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return request.userFullName
              .toLowerCase()
              .contains(query) ||
          request.companyName
              .toLowerCase()
              .contains(query) ||
          (request.requestId ?? '')
              .toLowerCase()
              .contains(query) ||
          (request.expertId ?? '')
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  bool _matchesStatus(String status) {
    switch (_selectedFilter) {
      case 'all':
        return true;
      case 'waiting':
        return status == 'waiting_assignment' ||
            status == 'waiting_for_admin';
      case 'pending':
        return status == 'pending';
      case 'accepted':
        return status == 'accepted';
      case 'contacted':
        return status == 'contacted';
      case 'completed':
        return status == 'completed';
      case 'rejected':
        return status == 'rejected';
      case 'expired':
        return status == 'expired';
      case 'cancelled':
        return status == 'cancelled';
      default:
        return true;
    }
  }

  int _countFor(
    String filter,
    List<ConsultationRequest> requests,
  ) {
    switch (filter) {
      case 'all':
        return requests.length;
      case 'waiting':
        return requests
            .where(
              (request) =>
                  request.status ==
                      'waiting_assignment' ||
                  request.status ==
                      'waiting_for_admin',
            )
            .length;
      case 'active':
        return requests
            .where(
              (request) => const {
                'pending',
                'accepted',
                'contacted',
              }.contains(request.status),
            )
            .length;
      case 'completed':
        return requests
            .where(
              (request) =>
                  request.status == 'completed',
            )
            .length;
      default:
        return 0;
    }
  }

  String _formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Danışma Yönetimi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<
            List<ConsultationRequest>>(
          stream: _repository.watchAllRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _teal,
                ),
              );
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message:
                    'Danışma talepleri yüklenemedi.\n'
                    '${snapshot.error}',
              );
            }

            final List<ConsultationRequest> allRequests =
                snapshot.data ?? [];

            final List<ConsultationRequest>
                filteredRequests =
                _applyFilters(allRequests);

            return RefreshIndicator(
              color: _teal,
              onRefresh: () async {
                setState(() {});
              },
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  36,
                ),
                children: [
                  const _AdminHeader(),
                  const SizedBox(height: 18),
                  _SummaryGrid(
                    total: _countFor(
                      'all',
                      allRequests,
                    ),
                    waiting: _countFor(
                      'waiting',
                      allRequests,
                    ),
                    active: _countFor(
                      'active',
                      allRequests,
                    ),
                    completed: _countFor(
                      'completed',
                      allRequests,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Kullanıcı, şirket veya talep no ara',
                      hintStyle: const TextStyle(
                        color: _muted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _teal,
                      ),
                      suffixIcon:
                          _searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController
                                        .clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: _muted,
                                  ),
                                ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                        borderSide:
                            const BorderSide(
                          color: _border,
                        ),
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                        borderSide:
                            const BorderSide(
                          color: _border,
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                        borderSide:
                            const BorderSide(
                          color: _teal,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection:
                          Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        width: 8,
                      ),
                      itemBuilder: (context, index) {
                        final _StatusFilter filter =
                            _filters[index];
                        final bool selected =
                            _selectedFilter ==
                                filter.key;

                        return ChoiceChip(
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter =
                                  filter.key;
                            });
                          },
                          label: Text(filter.label),
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : _petrol,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w800,
                          ),
                          selectedColor: _teal,
                          backgroundColor:
                              Colors.white,
                          side: BorderSide(
                            color: selected
                                ? _teal
                                : _border,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              999,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Danışma Talepleri',
                          style: TextStyle(
                            color: _navy,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${filteredRequests.length} kayıt',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (filteredRequests.isEmpty)
                    const _EmptyView()
                  else
                    ...filteredRequests.map(
                      (request) =>
                          _AdminRequestCard(
                        request: request,
                        repository: _repository,
                        financeText:
                            _formatCurrency(
                          request.plan.financeAmount,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminConsultationRequestDetailScreen(
                                request: request,
                              ),
                            ),
                          );
                        },
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

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF052F3D),
            Color(0xFF087C72),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF052F3D)
                .withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Row(
        children: [
          _HeaderIcon(),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Danışma Operasyon Merkezi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tüm talepleri, atamaları ve '
                  'danışma süreçlerini tek ekrandan '
                  'takip edin.',
                  style: TextStyle(
                    color: Color(0xFFD8F6F0),
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.support_agent_rounded,
        color: Colors.white,
        size: 27,
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.total,
    required this.waiting,
    required this.active,
    required this.completed,
  });

  final int total;
  final int waiting;
  final int active;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.75,
      children: [
        _SummaryCard(
          label: 'Tüm Talepler',
          value: total,
          icon: Icons.inbox_outlined,
        ),
        _SummaryCard(
          label: 'Atama Bekleyen',
          value: waiting,
          icon: Icons.person_search_rounded,
          warning: true,
        ),
        _SummaryCard(
          label: 'Aktif Süreç',
          value: active,
          icon: Icons.sync_rounded,
        ),
        _SummaryCard(
          label: 'Tamamlanan',
          value: completed,
          icon: Icons.task_alt_rounded,
          success: true,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.warning = false,
    this.success = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final bool warning;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final Color accent = warning
        ? const Color(0xFFB54708)
        : success
            ? const Color(0xFF087C72)
            : const Color(0xFF0B2239);

    final Color soft = warning
        ? const Color(0xFFFFF4E5)
        : success
            ? const Color(0xFFEAF8F5)
            : const Color(0xFFF1F4F7);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              _AdminConsultationManagementScreenState
                  ._border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: soft,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: accent,
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        _AdminConsultationManagementScreenState
                            ._muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
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

class _AdminRequestCard extends StatelessWidget {
  const _AdminRequestCard({
    required this.request,
    required this.repository,
    required this.financeText,
    required this.onTap,
  });

  final ConsultationRequest request;
  final ConsultationRepository repository;
  final String financeText;
  final VoidCallback onTap;

  String _formatDate(DateTime value) {
    return DateFormat(
      'dd MMM yyyy • HH:mm',
      'tr_TR',
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final _StatusPresentation presentation =
        _statusPresentation(request.status);

    final String expertText =
        (request.expertId ?? '').trim().isEmpty
            ? 'Henüz atanmadı'
            : 'Uzman atandı';

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color:
              _AdminConsultationManagementScreenState
                  ._border,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2239)
                .withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.userFullName,
                            style: const TextStyle(
                              color:
                                  _AdminConsultationManagementScreenState
                                      ._navy,
                              fontSize: 15.5,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.companyName,
                            style: const TextStyle(
                              color:
                                  _AdminConsultationManagementScreenState
                                      ._muted,
                              fontSize: 12.5,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: presentation.background,
                        borderRadius:
                            BorderRadius.circular(999),
                      ),
                      child: Text(
                        presentation.label,
                        style: TextStyle(
                          color: presentation.foreground,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoLine(
                  icon: Icons.phone_outlined,
                  label: 'Telefon',
                  child: FutureBuilder<String?>(
                    future:
                        repository.getRequestPhoneForAdmin(
                      requestId:
                          request.requestId ?? '',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text(
                          'Yükleniyor...',
                          style: TextStyle(
                            color:
                                _AdminConsultationManagementScreenState
                                    ._muted,
                            fontSize: 12.5,
                          ),
                        );
                      }

                      return Text(
                        snapshot.data ??
                            'Telefon bulunamadı',
                        style: const TextStyle(
                          color:
                              _AdminConsultationManagementScreenState
                                  ._petrol,
                          fontSize: 12.5,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 9),
                _InfoLine(
                  icon: Icons.person_outline_rounded,
                  label: 'Uzman',
                  child: Text(
                    expertText,
                    style: TextStyle(
                      color:
                          (request.expertId ?? '')
                                  .trim()
                                  .isEmpty
                              ? const Color(0xFFB54708)
                              : _AdminConsultationManagementScreenState
                                  ._teal,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                _InfoLine(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Finansman',
                  child: Text(
                    financeText,
                    style: const TextStyle(
                      color:
                          _AdminConsultationManagementScreenState
                              ._petrol,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                _InfoLine(
                  icon: Icons.schedule_rounded,
                  label: 'Oluşturulma',
                  child: Text(
                    _formatDate(request.createdAt),
                    style: const TextStyle(
                      color:
                          _AdminConsultationManagementScreenState
                              ._muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                const Divider(
                  height: 1,
                  color:
                      _AdminConsultationManagementScreenState
                          ._border,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      request.requestId == null
                          ? 'Talep kaydı'
                          : 'Talep No: ${request.requestId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            _AdminConsultationManagementScreenState
                                ._muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Detayı Gör',
                      style: TextStyle(
                        color:
                            _AdminConsultationManagementScreenState
                                ._teal,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color:
                          _AdminConsultationManagementScreenState
                              ._teal,
                      size: 19,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StatusPresentation _statusPresentation(
    String status,
  ) {
    switch (status) {
      case 'waiting_assignment':
        return const _StatusPresentation(
          label: 'Atama Bekliyor',
          foreground: Color(0xFFB54708),
          background: Color(0xFFFFF4E5),
        );
      case 'waiting_for_admin':
        return const _StatusPresentation(
          label: 'Yönetici Bekliyor',
          foreground: Color(0xFFB54708),
          background: Color(0xFFFFF4E5),
        );
      case 'pending':
        return const _StatusPresentation(
          label: 'Uzman Atandı',
          foreground: Color(0xFF175CD3),
          background: Color(0xFFEFF4FF),
        );
      case 'accepted':
        return const _StatusPresentation(
          label: 'Kabul Edildi',
          foreground: Color(0xFF087C72),
          background: Color(0xFFEAF8F5),
        );
      case 'contacted':
        return const _StatusPresentation(
          label: 'İletişime Geçildi',
          foreground: Color(0xFF087C72),
          background: Color(0xFFEAF8F5),
        );
      case 'completed':
        return const _StatusPresentation(
          label: 'Tamamlandı',
          foreground: Color(0xFF067647),
          background: Color(0xFFECFDF3),
        );
      case 'rejected':
        return const _StatusPresentation(
          label: 'Reddedildi',
          foreground: Color(0xFFB42318),
          background: Color(0xFFFEF3F2),
        );
      case 'expired':
        return const _StatusPresentation(
          label: 'Süresi Doldu',
          foreground: Color(0xFFB42318),
          background: Color(0xFFFEF3F2),
        );
      case 'cancelled':
        return const _StatusPresentation(
          label: 'İptal Edildi',
          foreground: Color(0xFF667085),
          background: Color(0xFFF2F4F7),
        );
      default:
        return const _StatusPresentation(
          label: 'Bilinmiyor',
          foreground: Color(0xFF667085),
          background: Color(0xFFF2F4F7),
        );
    }
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              _AdminConsultationManagementScreenState
                  ._teal,
          size: 18,
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              color:
                  _AdminConsultationManagementScreenState
                      ._muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color:
              _AdminConsultationManagementScreenState
                  ._border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color:
                _AdminConsultationManagementScreenState
                    ._muted,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Bu filtrede danışma talebi bulunmuyor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  _AdminConsultationManagementScreenState
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB42318),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _StatusFilter {
  const _StatusFilter({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}
