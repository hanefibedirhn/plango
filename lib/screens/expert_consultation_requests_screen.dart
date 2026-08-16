import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/consultation_request_model.dart';
import '../repositories/consultation_repository.dart';
import 'expert_request_detail_screen.dart';

class ExpertConsultationRequestsScreen extends StatefulWidget {
  const ExpertConsultationRequestsScreen({
    super.key,
    required this.expertId,
  });

  final String expertId;

  @override
  State<ExpertConsultationRequestsScreen> createState() =>
      _ExpertConsultationRequestsScreenState();
}

class _ExpertConsultationRequestsScreenState
    extends State<ExpertConsultationRequestsScreen> {
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EAF0);

  final ConsultationRepository _repository = ConsultationRepository();
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  String _selectedFilter = 'active';

  static const List<_ExpertFilter> _filters = [
    _ExpertFilter(key: 'active', label: 'Aktif'),
    _ExpertFilter(key: 'completed', label: 'Biten'),
  ];

  bool _isVisibleToExpert(ConsultationRequest request) {
    if (request.status == 'rejected' || request.status == 'expired') {
      return false;
    }

    if (request.status == 'pending') {
      final DateTime? deadline = request.expiresAt;
      if (deadline != null && !deadline.isAfter(DateTime.now())) {
        return false;
      }
    }

    return true;
  }

  List<ConsultationRequest> _filtered(List<ConsultationRequest> requests) {
    final visible = requests.where(_isVisibleToExpert);

    if (_selectedFilter == 'completed') {
      return visible
          .where((request) => request.status == 'completed')
          .toList();
    }

    return visible
        .where(
          (request) => const {
            'pending',
            'accepted',
            'contacted',
          }.contains(request.status),
        )
        .toList();
  }

  String _formatCurrency(double value) => _currencyFormatter.format(value);

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
          'Danışma Taleplerim',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ConsultationRequest>>(
          stream: _repository.watchExpertRequests(widget.expertId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _teal),
              );
            }

            if (snapshot.hasError) {
              return _MessageView(
                icon: Icons.error_outline_rounded,
                title: 'Talepler Yüklenemedi',
                message: snapshot.error.toString(),
              );
            }

            final allRequests = snapshot.data ?? <ConsultationRequest>[];
            final requests = _filtered(allRequests);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: _filters.map((filter) {
                      final selected = filter.key == _selectedFilter;
                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(
                            () => _selectedFilter = filter.key,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? _teal : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              filter.label,
                              style: TextStyle(
                                color: selected ? Colors.white : _petrol,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danışma Talepleri',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${requests.length} kayıt',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (requests.isEmpty)
                  const _MessageView(
                    icon: Icons.inbox_outlined,
                    title: 'Talep Bulunmuyor',
                    message:
                        'Bu bölümde gösterilecek danışma talebi bulunmuyor.',
                    embedded: true,
                  )
                else
                  ...requests.map(
                    (request) => _ExpertRequestCard(
                      request: request,
                      financeText:
                          _formatCurrency(request.plan.financeAmount),
                      installmentText:
                          _formatCurrency(request.plan.monthlyInstallment),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpertRequestDetailScreen(
                              request: request,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExpertRequestCard extends StatelessWidget {
  const _ExpertRequestCard({
    required this.request,
    required this.financeText,
    required this.installmentText,
    required this.onTap,
  });

  final ConsultationRequest request;
  final String financeText;
  final String installmentText;
  final VoidCallback onTap;

  String _formatDate(DateTime value) {
    return DateFormat('dd MMM yyyy • HH:mm', 'tr_TR').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _ExpertConsultationRequestsScreenState._border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2239).withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _initials(request.userFullName),
                        style: const TextStyle(
                          color: _ExpertConsultationRequestsScreenState._teal,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.userFullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ExpertConsultationRequestsScreenState._navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.companyName,
                            style: const TextStyle(
                              color: _ExpertConsultationRequestsScreenState._muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status.background,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          color: status.foreground,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FB),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CompactMetric(
                          label: 'Finansman',
                          value: financeText,
                        ),
                      ),
                      const _CompactDivider(),
                      Expanded(
                        child: _CompactMetric(
                          label: 'Taksit',
                          value: installmentText,
                        ),
                      ),
                      const _CompactDivider(),
                      Expanded(
                        child: _CompactMetric(
                          label: 'Teslim',
                          value: '${request.plan.estimatedDelivery}. ay',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(
                  height: 1,
                  color: _ExpertConsultationRequestsScreenState._border,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: _ExpertConsultationRequestsScreenState._muted,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(request.createdAt),
                      style: const TextStyle(
                        color: _ExpertConsultationRequestsScreenState._muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Detayı Gör',
                      style: TextStyle(
                        color: _ExpertConsultationRequestsScreenState._teal,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _ExpertConsultationRequestsScreenState._teal,
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

  static String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'K';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  static _RequestStatusStyle _statusStyle(String status) {
    switch (status) {
      case 'pending':
        return const _RequestStatusStyle(
          label: 'Yeni Talep',
          foreground: Color(0xFF175CD3),
          background: Color(0xFFEFF4FF),
        );
      case 'accepted':
        return const _RequestStatusStyle(
          label: 'Kabul Edildi',
          foreground: Color(0xFF087C72),
          background: Color(0xFFEAF8F5),
        );
      case 'contacted':
        return const _RequestStatusStyle(
          label: 'İletişime Geçildi',
          foreground: Color(0xFF087C72),
          background: Color(0xFFEAF8F5),
        );
      case 'completed':
        return const _RequestStatusStyle(
          label: 'Tamamlandı',
          foreground: Color(0xFF067647),
          background: Color(0xFFECFDF3),
        );
      case 'rejected':
        return const _RequestStatusStyle(
          label: 'Reddedildi',
          foreground: Color(0xFFB42318),
          background: Color(0xFFFEF3F2),
        );
      case 'expired':
        return const _RequestStatusStyle(
          label: 'Süresi Doldu',
          foreground: Color(0xFFB42318),
          background: Color(0xFFFEF3F2),
        );
      default:
        return const _RequestStatusStyle(
          label: 'Bilinmiyor',
          foreground: Color(0xFF667085),
          background: Color(0xFFF2F4F7),
        );
    }
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _ExpertConsultationRequestsScreenState._muted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _ExpertConsultationRequestsScreenState._petrol,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CompactDivider extends StatelessWidget {
  const _CompactDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 27,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: _ExpertConsultationRequestsScreenState._border,
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.embedded = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _ExpertConsultationRequestsScreenState._muted,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ExpertConsultationRequestsScreenState._navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ExpertConsultationRequestsScreenState._muted,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    if (!embedded) return Center(child: content);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _ExpertConsultationRequestsScreenState._border,
        ),
      ),
      child: content,
    );
  }
}

class _ExpertFilter {
  const _ExpertFilter({required this.key, required this.label});

  final String key;
  final String label;
}

class _RequestStatusStyle {
  const _RequestStatusStyle({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}
