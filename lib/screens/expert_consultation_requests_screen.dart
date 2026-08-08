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
    _ExpertFilter(key: 'pending', label: 'Yeni'),
    _ExpertFilter(key: 'accepted', label: 'Kabul'),
    _ExpertFilter(key: 'contacted', label: 'İletişim'),
    _ExpertFilter(key: 'completed', label: 'Tamamlanan'),
    _ExpertFilter(key: 'rejected', label: 'Reddedilen'),
    _ExpertFilter(key: 'expired', label: 'Süresi Dolan'),
    _ExpertFilter(key: 'all', label: 'Tümü'),
  ];

  List<ConsultationRequest> _filtered(List<ConsultationRequest> requests) {
    switch (_selectedFilter) {
      case 'active':
        return requests
            .where((request) => const {
                  'pending',
                  'accepted',
                  'contacted',
                }.contains(request.status))
            .toList();
      case 'pending':
      case 'accepted':
      case 'contacted':
      case 'completed':
      case 'rejected':
      case 'expired':
        return requests
            .where((request) => request.status == _selectedFilter)
            .toList();
      case 'all':
      default:
        return requests;
    }
  }

  int _countStatus(List<ConsultationRequest> requests, String status) {
    return requests.where((request) => request.status == status).length;
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
                _ExpertSummary(
                  newCount: _countStatus(allRequests, 'pending'),
                  acceptedCount: _countStatus(allRequests, 'accepted'),
                  contactedCount: _countStatus(allRequests, 'contacted'),
                  completedCount: _countStatus(allRequests, 'completed'),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final selected = filter.key == _selectedFilter;

                      return ChoiceChip(
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() => _selectedFilter = filter.key);
                        },
                        label: Text(filter.label),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : _petrol,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        selectedColor: _teal,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: selected ? _teal : _border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Talepler',
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
                        'Seçtiğiniz filtreye ait danışma talebi bulunmuyor.',
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

class _ExpertSummary extends StatelessWidget {
  const _ExpertSummary({
    required this.newCount,
    required this.acceptedCount,
    required this.contactedCount,
    required this.completedCount,
  });

  final int newCount;
  final int acceptedCount;
  final int contactedCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF052F3D), Color(0xFF087C72)],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF052F3D).withOpacity(0.15),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danışma Özeti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryItem(label: 'Yeni', value: newCount),
              const _SummaryDivider(),
              _SummaryItem(label: 'Kabul', value: acceptedCount),
              const _SummaryDivider(),
              _SummaryItem(label: 'İletişim', value: contactedCount),
              const _SummaryDivider(),
              _SummaryItem(label: 'Biten', value: completedCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD8F6F0),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withOpacity(0.16),
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
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
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
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8F5),
                        borderRadius: BorderRadius.circular(14),
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
                    const SizedBox(width: 12),
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(label: 'Finansman', value: financeText),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _MetricBox(
                        label: 'İlk Taksit',
                        value: installmentText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(
                        label: 'Teslim',
                        value: '${request.plan.estimatedDelivery}. ay',
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _MetricBox(
                        label: 'Vade',
                        value: '${request.plan.estimatedTerm} ay',
                      ),
                    ),
                  ],
                ),
                if ((request.userNote ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 11),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FB),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      request.userNote!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ExpertConsultationRequestsScreenState._muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  color: _ExpertConsultationRequestsScreenState._border,
                ),
                const SizedBox(height: 11),
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

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _ExpertConsultationRequestsScreenState._muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ExpertConsultationRequestsScreenState._petrol,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(21),
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
