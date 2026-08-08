import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/consultation_request_model.dart';
import '../../models/expert_profile_model.dart';
import '../../repositories/consultation_repository.dart';
import '../../repositories/expert_profile_repository.dart';

class AdminConsultationRequestDetailScreen
    extends StatefulWidget {
  const AdminConsultationRequestDetailScreen({
    super.key,
    required this.request,
  });

  final ConsultationRequest request;

  @override
  State<AdminConsultationRequestDetailScreen>
      createState() =>
          _AdminConsultationRequestDetailScreenState();
}

class _AdminConsultationRequestDetailScreenState
    extends State<AdminConsultationRequestDetailScreen> {
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EAF0);
  static const Color _softTeal = Color(0xFFEAF8F5);
  static const Color _error = Color(0xFFB42318);

  final ConsultationRepository _consultationRepository =
      ConsultationRepository();

  final ExpertProfileRepository _expertProfileRepository =
      ExpertProfileRepository();

  final NumberFormat _currencyFormatter =
      NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  bool _isProcessing = false;

  String get _requestId =>
      widget.request.requestId ?? '';

  Future<void> _assignExpert(
    ConsultationRequest request,
  ) async {
    final ExpertProfile? expert =
        await _selectExpert(request);

    if (expert == null || !mounted) {
      return;
    }

    final bool confirmed =
        await _confirmAssignment(expert);

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _consultationRepository.assignExpert(
        requestId: request.requestId!,
        expertId: expert.uid,
        assignmentType: 'admin',
        assignedBy: 'admin',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Talep ${expert.fullName} adlı uzmana atandı.',
          ),
          backgroundColor: _teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ConsultationRepositoryException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<ExpertProfile?> _selectExpert(
    ConsultationRequest request,
  ) {
    return showModalBottomSheet<ExpertProfile>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(sheetContext).size.height *
                    0.72,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    4,
                  ),
                  child: Text(
                    (request.expertId ?? '')
                            .trim()
                            .isEmpty
                        ? 'Uzman Ata'
                        : 'Uzmanı Değiştir',
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    14,
                  ),
                  child: Text(
                    '${request.companyName} bünyesinde '
                    'yeni talep kabul eden uzmanlar',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<
                      List<ExpertProfile>>(
                    stream: _expertProfileRepository
                        .watchAvailableExperts(
                      request.companyName,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                          child:
                              CircularProgressIndicator(
                            color: _teal,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              24,
                            ),
                            child: Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _error,
                              ),
                            ),
                          ),
                        );
                      }

                      final List<ExpertProfile> experts =
                          (snapshot.data ?? [])
                              .where(
                                (expert) =>
                                    expert.uid !=
                                    request.expertId,
                              )
                              .toList();

                      if (experts.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding:
                                EdgeInsets.all(26),
                            child: Text(
                              'Bu şirkette şu anda talep '
                              'alabilecek başka bir uzman '
                              'bulunmuyor.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _muted,
                                height: 1.5,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(
                          14,
                          0,
                          14,
                          24,
                        ),
                        itemCount: experts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final ExpertProfile expert =
                              experts[index];

                          final String details = [
                            expert.position.trim(),
                            expert.branch.trim(),
                          ]
                              .where(
                                (value) =>
                                    value.isNotEmpty,
                              )
                              .join(' • ');

                          return Material(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              17,
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(
                                  sheetContext,
                                  expert,
                                );
                              },
                              borderRadius:
                                  BorderRadius.circular(
                                17,
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.all(
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                    17,
                                  ),
                                  border: Border.all(
                                    color: _border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          _softTeal,
                                      foregroundColor:
                                          _teal,
                                      child: Text(
                                        _initials(expert),
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            expert.fullName,
                                            style:
                                                const TextStyle(
                                              color: _navy,
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight
                                                      .w900,
                                            ),
                                          ),
                                          if (details
                                              .isNotEmpty) ...[
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              details,
                                              style:
                                                  const TextStyle(
                                                color:
                                                    _muted,
                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons
                                          .chevron_right_rounded,
                                      color: _teal,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmAssignment(
    ExpertProfile expert,
  ) async {
    final bool? result =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Uzman Atamasını Onayla',
          ),
          content: Text(
            'Bu danışma talebi ${expert.fullName} '
            'adlı uzmana atansın mı?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
              ),
              child: const Text('Ata'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '—';
    }

    return DateFormat(
      'dd MMM yyyy • HH:mm',
      'tr_TR',
    ).format(value);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'waiting_assignment':
        return 'Uzman ataması bekleniyor';
      case 'waiting_for_admin':
        return 'Yönetici işlemi bekleniyor';
      case 'pending':
        return 'Uzman yanıtı bekleniyor';
      case 'accepted':
        return 'Uzman kabul etti';
      case 'contacted':
        return 'İletişime geçildi';
      case 'completed':
        return 'Tamamlandı';
      case 'rejected':
        return 'Reddedildi';
      case 'expired':
        return 'Süresi doldu';
      case 'cancelled':
        return 'İptal edildi';
      default:
        return status;
    }
  }

  String _assignmentTypeLabel(String? type) {
    switch (type) {
      case 'auto':
        return 'Otomatik atama';
      case 'admin':
        return 'Yönetici ataması';
      case null:
      case '':
        return 'Henüz atama yapılmadı';
      default:
        return type;
    }
  }

  String _adminQueueReasonLabel(String? reason) {
    switch (reason) {
      case 'expert_rejected':
        return 'Uzman talebi reddetti';
      case 'response_expired':
        return 'Uzman yanıt süresi doldu';
      case null:
      case '':
        return '—';
      default:
        return reason;
    }
  }

  bool _canAssign(ConsultationRequest request) {
    return const {
      'waiting_assignment',
      'waiting_for_admin',
    }.contains(request.status);
  }

  bool _canReassign(ConsultationRequest request) {
    return const {
      'pending',
      'accepted',
      'contacted',
    }.contains(request.status);
  }

  @override
  Widget build(BuildContext context) {
    if (_requestId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Talep kimliği bulunamadı.',
          ),
        ),
      );
    }

    return StreamBuilder<ConsultationRequest?>(
      stream: _consultationRepository
          .watchRequestById(_requestId),
      initialData: widget.request,
      builder: (context, snapshot) {
        final ConsultationRequest? request =
            snapshot.data;

        if (request == null) {
          return Scaffold(
            backgroundColor: _background,
            appBar: AppBar(
              backgroundColor: _background,
              foregroundColor: _navy,
              title:
                  const Text('Danışma Detayı'),
            ),
            body: const Center(
              child: Text(
                'Danışma talebi bulunamadı.',
              ),
            ),
          );
        }

        final String note =
            request.userNote?.trim() ?? '';
        final bool showAssignmentAction =
            _canAssign(request) ||
                _canReassign(request);

        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            surfaceTintColor: _background,
            foregroundColor: _navy,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Danışma Detayı',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                8,
                18,
                36,
              ),
              children: [
                _StatusHeader(
                  status: request.status,
                  statusLabel:
                      _statusLabel(request.status),
                  companyName:
                      request.companyName,
                  requestId:
                      request.requestId ?? '',
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  icon:
                      Icons.person_outline_rounded,
                  title: 'Kullanıcı Bilgileri',
                  children: [
                    _DetailRow(
                      label: 'Ad Soyad',
                      value:
                          request.userFullName,
                    ),
                    const SizedBox(height: 14),
                    FutureBuilder<String?>(
                      future: _consultationRepository
                          .getRequestPhoneForAdmin(
                        requestId:
                            request.requestId!,
                      ),
                      builder: (context, snapshot) {
                        return _DetailRow(
                          label: 'Telefon',
                          value: snapshot
                                      .connectionState ==
                                  ConnectionState
                                      .waiting
                              ? 'Yükleniyor...'
                              : snapshot.data ??
                                  'Bulunamadı',
                          highlighted:
                              snapshot.hasData &&
                                  snapshot.data !=
                                      null,
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Kullanıcı Türü',
                      value: request.isGuest
                          ? 'Misafir kullanıcı'
                          : 'Kayıtlı kullanıcı',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons
                      .account_balance_wallet_outlined,
                  title: 'Plan Bilgileri',
                  children: [
                    _DetailRow(
                      label: 'Şirket',
                      value: request.companyName,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Finansman',
                      value: _formatCurrency(
                        request.plan.financeAmount,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Peşinat',
                      value: _formatCurrency(
                        request.plan.downPayment,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'İlk Taksit',
                      value: _formatCurrency(
                        request.plan
                            .monthlyInstallment,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Ödeme Modeli',
                      value:
                          request.plan.increaseModel,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Tahmini Teslim',
                      value:
                          '${request.plan.estimatedDelivery} ay',
                      highlighted: true,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Tahmini Vade',
                      value:
                          '${request.plan.estimatedTerm} ay',
                    ),
                  ],
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.notes_rounded,
                    title: 'Kullanıcı Notu',
                    children: [
                      Text(
                        note,
                        style: const TextStyle(
                          color: _petrol,
                          fontSize: 13.5,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons
                      .admin_panel_settings_outlined,
                  title: 'Atama ve Süreç',
                  children: [
                    _DetailRow(
                      label: 'Durum',
                      value:
                          _statusLabel(request.status),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Atama Türü',
                      value: _assignmentTypeLabel(
                        request.assignmentType,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Atama Tarihi',
                      value: _formatDate(
                        request.assignedAt,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ExpertDetailRow(
                      expertId: request.expertId,
                      repository:
                          _expertProfileRepository,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Yanıt Son Tarihi',
                      value: _formatDate(
                        request.expiresAt,
                      ),
                    ),
                    if ((request.adminQueueReason ??
                            '')
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _DetailRow(
                        label: 'Yönetici Kuyruğu',
                        value:
                            _adminQueueReasonLabel(
                          request.adminQueueReason,
                        ),
                      ),
                    ],
                    if ((request.rejectionReason ??
                            '')
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _DetailRow(
                        label: 'Red Nedeni',
                        value:
                            request.rejectionReason!,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons.history_rounded,
                  title: 'Süreç Geçmişi',
                  children: [
                    _TimelineEntry(
                      title: 'Talep oluşturuldu',
                      date: _formatDate(
                        request.createdAt,
                      ),
                      completed: true,
                    ),
                    _TimelineEntry(
                      title: 'Uzman atandı',
                      date: _formatDate(
                        request.assignedAt,
                      ),
                      completed:
                          request.assignedAt != null,
                    ),
                    _TimelineEntry(
                      title: 'Uzman kabul etti',
                      date: _formatDate(
                        request.acceptedAt,
                      ),
                      completed:
                          request.acceptedAt != null,
                    ),
                    _TimelineEntry(
                      title:
                          'İletişime geçildi',
                      date: _formatDate(
                        request.contactedAt,
                      ),
                      completed:
                          request.contactedAt != null,
                    ),
                    _TimelineEntry(
                      title:
                          'Danışma tamamlandı',
                      date: _formatDate(
                        request.completedAt,
                      ),
                      completed:
                          request.completedAt != null,
                      isLast: true,
                    ),
                  ],
                ),
                if (showAssignmentAction) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () =>
                              _assignExpert(request),
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _canAssign(request)
                                  ? Icons
                                      .person_add_alt_1_rounded
                                  : Icons
                                      .manage_accounts_rounded,
                            ),
                      label: Text(
                        _isProcessing
                            ? 'İşlem Yapılıyor'
                            : _canAssign(request)
                                ? 'Uzman Ata'
                                : 'Uzmanı Değiştir',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            _teal.withOpacity(0.55),
                        disabledForegroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            17,
                          ),
                        ),
                        textStyle:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _initials(ExpertProfile expert) {
    final String first =
        expert.firstName.trim().isEmpty
            ? ''
            : expert.firstName
                .trim()
                .characters
                .first
                .toUpperCase();

    final String last =
        expert.lastName.trim().isEmpty
            ? ''
            : expert.lastName
                .trim()
                .characters
                .first
                .toUpperCase();

    final String initials = '$first$last';

    return initials.isEmpty ? 'U' : initials;
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.status,
    required this.statusLabel,
    required this.companyName,
    required this.requestId,
  });

  final String status;
  final String statusLabel;
  final String companyName;
  final String requestId;

  @override
  Widget build(BuildContext context) {
    final _StatusStyle style =
        _statusStyle(status);

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
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF052F3D)
                .withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
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
                      companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      requestId.isEmpty
                          ? 'Danışma talebi'
                          : 'Talep No: $requestId',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD8F6F0),
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: style.foreground,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static _StatusStyle _statusStyle(
    String status,
  ) {
    switch (status) {
      case 'waiting_assignment':
      case 'waiting_for_admin':
        return const _StatusStyle(
          foreground: Color(0xFFB54708),
          background: Color(0xFFFFF4E5),
        );
      case 'pending':
        return const _StatusStyle(
          foreground: Color(0xFF175CD3),
          background: Color(0xFFEFF4FF),
        );
      case 'accepted':
      case 'contacted':
        return const _StatusStyle(
          foreground: Color(0xFF087C72),
          background: Color(0xFFEAF8F5),
        );
      case 'completed':
        return const _StatusStyle(
          foreground: Color(0xFF067647),
          background: Color(0xFFECFDF3),
        );
      case 'rejected':
      case 'expired':
        return const _StatusStyle(
          foreground: Color(0xFFB42318),
          background: Color(0xFFFEF3F2),
        );
      default:
        return const _StatusStyle(
          foreground: Color(0xFF667085),
          background: Color(0xFFF2F4F7),
        );
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color:
              _AdminConsultationRequestDetailScreenState
                  ._border,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2239)
                .withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color:
                      _AdminConsultationRequestDetailScreenState
                          ._softTeal,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color:
                      _AdminConsultationRequestDetailScreenState
                          ._teal,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color:
                        _AdminConsultationRequestDetailScreenState
                            ._navy,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color:
                  _AdminConsultationRequestDetailScreenState
                      ._muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: highlighted
                  ? _AdminConsultationRequestDetailScreenState
                      ._teal
                  : _AdminConsultationRequestDetailScreenState
                      ._petrol,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpertDetailRow extends StatelessWidget {
  const _ExpertDetailRow({
    required this.expertId,
    required this.repository,
  });

  final String? expertId;
  final ExpertProfileRepository repository;

  @override
  Widget build(BuildContext context) {
    final String normalizedId =
        expertId?.trim() ?? '';

    if (normalizedId.isEmpty) {
      return const _DetailRow(
        label: 'Atanan Uzman',
        value: 'Henüz atanmadı',
      );
    }

    return FutureBuilder<ExpertProfile>(
      future: repository.getExpertProfile(
        normalizedId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const _DetailRow(
            label: 'Atanan Uzman',
            value: 'Yükleniyor...',
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData) {
          return _DetailRow(
            label: 'Atanan Uzman',
            value: normalizedId,
          );
        }

        return _DetailRow(
          label: 'Atanan Uzman',
          value: snapshot.data!.fullName,
          highlighted: true,
        );
      },
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.title,
    required this.date,
    required this.completed,
    this.isLast = false,
  });

  final String title;
  final String date;
  final bool completed;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: completed
                    ? _AdminConsultationRequestDetailScreenState
                        ._softTeal
                    : const Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed
                    ? Icons.check_rounded
                    : Icons.more_horiz_rounded,
                color: completed
                    ? _AdminConsultationRequestDetailScreenState
                        ._teal
                    : _AdminConsultationRequestDetailScreenState
                        ._muted,
                size: 17,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: completed
                    ? _AdminConsultationRequestDetailScreenState
                        ._turquoise
                        .withOpacity(0.5)
                    : _AdminConsultationRequestDetailScreenState
                        ._border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: completed
                        ? _AdminConsultationRequestDetailScreenState
                            ._petrol
                        : _AdminConsultationRequestDetailScreenState
                            ._muted,
                    fontSize: 13,
                    fontWeight: completed
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: const TextStyle(
                    color:
                        _AdminConsultationRequestDetailScreenState
                            ._muted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
