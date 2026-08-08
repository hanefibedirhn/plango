import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/consultation_request_model.dart';
import '../repositories/consultation_repository.dart';

class ExpertRequestDetailScreen extends StatefulWidget {
  const ExpertRequestDetailScreen({
    super.key,
    required this.request,
  });

  final ConsultationRequest request;

  @override
  State<ExpertRequestDetailScreen> createState() =>
      _ExpertRequestDetailScreenState();
}

class _ExpertRequestDetailScreenState
    extends State<ExpertRequestDetailScreen> {
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EAF0);
  static const Color _softTeal = Color(0xFFEAF8F5);
  static const Color _danger = Color(0xFFB42318);

  final ConsultationRepository _repository =
      ConsultationRepository();

  final NumberFormat _currencyFormatter =
      NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  bool _isProcessing = false;

  String get _requestId =>
      widget.request.requestId ?? '';

  String get _expertId =>
      widget.request.expertId?.trim() ?? '';

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

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? _danger : _teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await action();

      if (!mounted) return;

      _showMessage(successMessage);
    } on ConsultationRepositoryException catch (error) {
      if (!mounted) return;
      _showMessage(
        error.message,
        isError: true,
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        error.toString(),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _acceptRequest(
    ConsultationRequest request,
  ) async {
    await _runAction(
      () => _repository.acceptRequest(
        requestId: request.requestId!,
        expertId: request.expertId!,
      ),
      successMessage:
          'Danışma talebi kabul edildi.',
    );
  }

  Future<void> _rejectRequest(
    ConsultationRequest request,
  ) async {
    final String? reason =
        await _showRejectionReasonSheet();

    if (reason == null || !mounted) {
      return;
    }

    await _runAction(
      () => _repository.rejectRequest(
        requestId: request.requestId!,
        expertId: request.expertId!,
        rejectionReason: reason,
      ),
      successMessage:
          'Talep yönetici atama kuyruğuna gönderildi.',
    );
  }

  Future<String?> _showRejectionReasonSheet() {
    final TextEditingController controller =
        TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            2,
            20,
            MediaQuery.of(sheetContext)
                    .viewInsets
                    .bottom +
                22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Talebi Reddet',
                style: TextStyle(
                  color: _navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Talep başka bir uzmana yönlendirilebilmesi '
                'için yönetici kuyruğuna alınacaktır.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                maxLength: 250,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Red nedeni',
                  hintText:
                      'Örn. yoğunluk, izin, yanlış uzman ataması...',
                  filled: true,
                  fillColor: const Color(0xFFF7F9FB),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: _border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: _border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: _teal,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _muted,
                        side: const BorderSide(
                          color: _border,
                        ),
                        minimumSize:
                            const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Vazgeç'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final String reason =
                            controller.text.trim();

                        if (reason.length < 3) {
                          ScaffoldMessenger.of(
                            sheetContext,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lütfen geçerli bir red nedeni yazınız.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(
                          sheetContext,
                          reason,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        minimumSize:
                            const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Talebi Reddet'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  Future<void> _markAsContacted(
    ConsultationRequest request,
  ) async {
    await _runAction(
      () => _repository.markAsContacted(
        requestId: request.requestId!,
        expertId: request.expertId!,
      ),
      successMessage:
          'Talep iletişime geçildi olarak güncellendi.',
    );
  }

  Future<void> _completeRequest(
    ConsultationRequest request,
  ) async {
    final bool confirmed =
        await _confirmCompletion();

    if (!confirmed || !mounted) {
      return;
    }

    await _runAction(
      () => _repository.completeRequest(
        requestId: request.requestId!,
        expertId: request.expertId!,
      ),
      successMessage:
          'Danışma süreci tamamlandı.',
    );
  }

  Future<bool> _confirmCompletion() async {
    final bool? result =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Danışmayı Tamamla',
          ),
          content: const Text(
            'Kullanıcıyla görüşme sürecinin tamamlandığını '
            'onaylıyor musunuz?',
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
              child: const Text('Tamamla'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _openPhone(String phone) async {
    final String normalizedPhone =
        phone.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: normalizedPhone,
    );

    final bool opened =
        await launchUrl(phoneUri);

    if (!opened && mounted) {
      _showMessage(
        'Telefon uygulaması açılamadı.',
        isError: true,
      );
    }
  }

  bool _phoneCanBeShown(
    ConsultationRequest request,
  ) {
    return const {
      'accepted',
      'contacted',
      'completed',
    }.contains(request.status);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Yanıtınızı Bekliyor';
      case 'accepted':
        return 'Kabul Edildi';
      case 'contacted':
        return 'İletişime Geçildi';
      case 'completed':
        return 'Tamamlandı';
      case 'rejected':
        return 'Reddedildi';
      case 'expired':
        return 'Süresi Doldu';
      case 'cancelled':
        return 'İptal Edildi';
      case 'waiting_for_admin':
        return 'Yöneticiye Aktarıldı';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_requestId.isEmpty ||
        _expertId.isEmpty) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: Text(
            'Talep veya uzman bilgisi bulunamadı.',
          ),
        ),
      );
    }

    return StreamBuilder<ConsultationRequest?>(
      stream: _repository.watchRequestById(
        _requestId,
      ),
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
              title: const Text('Talep Detayı'),
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

        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            surfaceTintColor: _background,
            foregroundColor: _navy,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Talep Detayı',
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
                _StatusHero(
                  request: request,
                  statusLabel:
                      _statusLabel(request.status),
                  formatDate: _formatDate,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Kullanıcı Bilgileri',
                  children: [
                    _DetailRow(
                      label: 'Ad Soyad',
                      value:
                          request.userFullName,
                    ),
                    const SizedBox(height: 14),
                    _buildPhoneArea(request),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
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
                          '${request.plan.estimatedDelivery}. ay',
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
                  title: 'Süreç Bilgileri',
                  children: [
                    _DetailRow(
                      label: 'Durum',
                      value:
                          _statusLabel(request.status),
                      highlighted: true,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Talep Tarihi',
                      value: _formatDate(
                        request.createdAt,
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
                    _DetailRow(
                      label: 'Yanıt Son Tarihi',
                      value: _formatDate(
                        request.expiresAt,
                      ),
                    ),
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
                const SizedBox(height: 20),
                _buildActions(request),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneArea(
    ConsultationRequest request,
  ) {
    if (!_phoneCanBeShown(request)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFF8D9A4),
          ),
        ),
        child: const Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFB54708),
              size: 19,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Telefon numarası, talebi kabul '
                'ettiğinizde görüntülenir.',
                style: TextStyle(
                  color: Color(0xFF875A13),
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<String?>(
      future: _repository.getRequestPhone(
        requestId: request.requestId!,
        expertId: request.expertId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const _DetailRow(
            label: 'Telefon',
            value: 'Yükleniyor...',
          );
        }

        if (snapshot.hasError) {
          return const _DetailRow(
            label: 'Telefon',
            value:
                'Telefon bilgisi alınamadı.',
          );
        }

        final String phone =
            snapshot.data?.trim() ?? '';

        if (phone.isEmpty) {
          return const _DetailRow(
            label: 'Telefon',
            value:
                'Telefon bilgisi bulunamadı.',
          );
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openPhone(phone),
            borderRadius:
                BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: _softTeal,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color:
                      _turquoise.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_in_talk_rounded,
                    color: _teal,
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Telefon',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 11.5,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatPhone(phone),
                          style: const TextStyle(
                            color: _petrol,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Ara',
                    style: TextStyle(
                      color: _teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(
    ConsultationRequest request,
  ) {
    if (_isProcessing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(
            color: _teal,
          ),
        ),
      );
    }

    switch (request.status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _rejectRequest(request),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _danger,
                  side: const BorderSide(
                    color: _danger,
                  ),
                  minimumSize:
                      const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: const Text('Reddet'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () =>
                    _acceptRequest(request),
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: const Text('Kabul Et'),
              ),
            ),
          ],
        );

      case 'accepted':
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: () =>
                _markAsContacted(request),
            icon: const Icon(
              Icons.phone_in_talk_rounded,
            ),
            label: const Text(
              'İletişime Geçildi',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(17),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );

      case 'contacted':
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: () =>
                _completeRequest(request),
            icon: const Icon(
              Icons.task_alt_rounded,
            ),
            label: const Text(
              'Danışmayı Tamamla',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(17),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );

      case 'completed':
        return const _FinalStatusNotice(
          message:
              'Bu danışma süreci tamamlandı.',
          success: true,
        );

      case 'waiting_for_admin':
      case 'rejected':
        return const _FinalStatusNotice(
          message:
              'Talep yönetici tarafından başka bir uzmana yönlendirilmek üzere kuyruğa alındı.',
        );

      case 'expired':
        return const _FinalStatusNotice(
          message:
              'Bu talebin yanıt süresi doldu.',
        );

      case 'cancelled':
        return const _FinalStatusNotice(
          message:
              'Talep kullanıcı tarafından iptal edildi.',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _formatPhone(String phone) {
    String digits =
        phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length == 11 &&
        digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    if (digits.length != 10) {
      return phone;
    }

    return '0${digits.substring(0, 3)} '
        '${digits.substring(3, 6)} '
        '${digits.substring(6, 8)} '
        '${digits.substring(8, 10)}';
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({
    required this.request,
    required this.statusLabel,
    required this.formatDate,
  });

  final ConsultationRequest request;
  final String statusLabel;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    final _StatusStyle style =
        _statusStyle(request.status);

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
                .withOpacity(0.15),
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
                      request.userFullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      request.companyName,
                      style: const TextStyle(
                        color: Color(0xFFD8F6F0),
                        fontSize: 12.5,
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
          const SizedBox(height: 15),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.14),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: Color(0xFFD8F6F0),
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                'Talep: ${formatDate(request.createdAt)}',
                style: const TextStyle(
                  color: Color(0xFFD8F6F0),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
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
    required this.title,
    required this.children,
  });

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
              _ExpertRequestDetailScreenState
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
          Text(
            title,
            style: const TextStyle(
              color:
                  _ExpertRequestDetailScreenState
                      ._navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 17),
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
                  _ExpertRequestDetailScreenState
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
                  ? _ExpertRequestDetailScreenState
                      ._teal
                  : _ExpertRequestDetailScreenState
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

class _FinalStatusNotice extends StatelessWidget {
  const _FinalStatusNotice({
    required this.message,
    this.success = false,
  });

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: success
            ? _ExpertRequestDetailScreenState
                ._softTeal
            : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: success
              ? _ExpertRequestDetailScreenState
                  ._turquoise
                  .withOpacity(0.24)
              : _ExpertRequestDetailScreenState
                  ._border,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: success
              ? _ExpertRequestDetailScreenState
                  ._teal
              : _ExpertRequestDetailScreenState
                  ._muted,
          fontSize: 13,
          height: 1.45,
          fontWeight: FontWeight.w700,
        ),
      ),
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
