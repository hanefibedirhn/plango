import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/consultation_request_contact_model.dart';
import '../models/consultation_request_model.dart';
import '../repositories/consultation_repository.dart';

class MyConsultationRequestsScreen extends StatefulWidget {
  const MyConsultationRequestsScreen({
    super.key,
  });

  @override
  State<MyConsultationRequestsScreen> createState() =>
      _MyConsultationRequestsScreenState();
}

class _MyConsultationRequestsScreenState
    extends State<MyConsultationRequestsScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

    final ConsultationRepository _repository =
      ConsultationRepository();

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Danışma Taleplerim',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: user == null
            ? const _SignedOutView()
            : StreamBuilder<
                List<ConsultationRequest>>(
                stream: _repository
                    .watchUserRequests(user.uid),
                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const _LoadingView();
                  }

                  if (snapshot.hasError) {
                    return _ErrorView(
                      message:
                          _firebaseErrorMessage(
                        snapshot.error,
                      ),
                    );
                  }

                  final List<
                      ConsultationRequest> requests =
                      snapshot.data ?? [];

                  if (requests.isEmpty) {
                    return const _EmptyView();
                  }

                  return RefreshIndicator(
                    color: _green,
                    onRefresh: () async {
                      await Future<void>.delayed(
                        const Duration(
                          milliseconds: 500,
                        ),
                      );
                    },
                    child: ListView.separated(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(
                        18,
                        10,
                        18,
                        34,
                      ),
                      itemCount: requests.length,
                      separatorBuilder: (
                        context,
                        index,
                      ) {
                        return const SizedBox(
                          height: 12,
                        );
                      },
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final ConsultationRequest
                            request =
                            requests[index];

                        return _ConsultationCard(
                          request: request,
                          onTap: () {
                            final String? requestId =
                                request.requestId;

                            if (requestId == null ||
                                requestId.isEmpty) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Danışma talebi kimliği bulunamadı.',
                                  ),
                                  behavior:
                                      SnackBarBehavior
                                          .floating,
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ConsultationRequestDetailScreen(
                                  requestId:
                                      requestId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _firebaseErrorMessage(
    Object? error,
  ) {
    if (error is FirebaseException &&
        error.code == 'failed-precondition') {
      return 'Danışma taleplerini listelemek için '
          'Firestore indeksinin oluşturulması gerekiyor.';
    }

    if (error is FirebaseException &&
        error.code == 'permission-denied') {
      return 'Danışma taleplerinize erişim izni bulunamadı. '
          'Firestore kurallarını kontrol ediniz.';
    }

    return 'Danışma talepleriniz yüklenemedi. '
        'Lütfen tekrar deneyiniz.';
  }
}

class ConsultationRequestDetailScreen
    extends StatefulWidget {
  const ConsultationRequestDetailScreen({
    super.key,
    required this.requestId,
  });

  final String requestId;

  @override
  State<ConsultationRequestDetailScreen>
      createState() =>
          _ConsultationRequestDetailScreenState();
}

class _ConsultationRequestDetailScreenState
    extends State<
        ConsultationRequestDetailScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  final ConsultationRepository _repository =
      ConsultationRepository();

  final NumberFormat _currencyFormatter =
      NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  bool _isCancelling = false;

  Future<void> _cancelRequest(
    ConsultationRequest request,
  ) async {
    final String? requestId = request.requestId;

    final String? userId =
        FirebaseAuth.instance.currentUser?.uid;

    if (requestId == null || userId == null) {
      return;
    }

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: const Text(
            'Talebi İptal Et',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Danışma talebinizi iptal etmek '
            'istediğinizden emin misiniz?',
            style: TextStyle(height: 1.45),
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
                backgroundColor:
                    const Color(0xFFB42318),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Talebi İptal Et',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      await _repository.cancelRequest(
        requestId: requestId,
        userId: userId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Danışma talebiniz iptal edildi.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _green,
        ),
      );
    } on ConsultationRepositoryException catch (
      error
    ) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              const Color(0xFFB42318),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
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
        child: StreamBuilder<
            ConsultationRequest?>(
          stream: _repository.watchRequestById(
            widget.requestId,
          ),
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _green,
                ),
              );
            }

            if (snapshot.hasError) {
              return const _ErrorView(
                message:
                    'Danışma talebi yüklenemedi.',
              );
            }

            final ConsultationRequest? request =
                snapshot.data;

            if (request == null) {
              return const _ErrorView(
                message:
                    'Danışma talebi bulunamadı.',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                34,
              ),
              children: [
                _DetailHeader(request: request),
                const SizedBox(height: 20),

                const _DetailSectionTitle(
                  title: 'Uzman ve Şirket',
                ),
                const SizedBox(height: 10),

                _DetailCard(
                  children: [
                    _ExpertNameRow(
                      expertId: request.expertId,
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    _DetailRow(
                      label: 'Şirket',
                      value: request.companyName,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const _DetailSectionTitle(
                  title: 'Plan Özeti',
                ),
                const SizedBox(height: 10),

                _DetailCard(
                  children: [
                    _DetailRow(
                      label: 'Finansman',
                      value:
                          _currencyFormatter.format(
                        request.financeAmount,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    _DetailRow(
                      label: 'Peşinat',
                      value:
                          _currencyFormatter.format(
                        request.downPayment,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    _DetailRow(
                      label: 'İlk Taksit',
                      value:
                          _currencyFormatter.format(
                        request
                            .monthlyInstallment,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    _DetailRow(
                      label: 'Ödeme Modeli',
                      value: request.increaseModel,
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    _DetailRow(
                      label: 'Tahmini Teslim',
                      value:
                          '${request.estimatedDelivery}. Ay',
                      highlighted: true,
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    _DetailRow(
                      label: 'Tahmini Vade',
                      value:
                          '${request.estimatedTerm} Ay',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const _DetailSectionTitle(
                  title: 'Talep Bilgileri',
                ),
                const SizedBox(height: 10),

                _DetailCard(
                  children: [
                    _DetailRow(
                      label: 'Talep Tarihi',
                      value: _formatDateTime(
                        request.createdAt,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    _DetailRow(
                      label: 'Yanıt Süresi',
                      value: _formatDateTime(
                        request.expiresAt,
                      ),
                    ),
                    if (request.userNote != null) ...[
                      const Divider(
                        height: 1,
                        color: _border,
                      ),
                      _DetailRow(
                        label: 'Notunuz',
                        value: request.userNote!,
                      ),
                    ],
                    if (request.rejectionReason !=
                        null) ...[
                      const Divider(
                        height: 1,
                        color: _border,
                      ),
                      _DetailRow(
                        label: 'Açıklama',
                        value:
                            request.rejectionReason!,
                      ),
                    ],
                  ],
                ),

                if (request.status == 'accepted') ...[
                  const SizedBox(height: 18),
                  const _AcceptedNotice(),
                ],

                if (request.status == 'contacted' ||
                    request.status ==
                        'completed') ...[
                  const SizedBox(height: 20),
                  const _DetailSectionTitle(
                    title: 'Uzman İletişim Bilgileri',
                  ),
                  const SizedBox(height: 10),
                  _ExpertContactSection(
                    requestId: widget.requestId,
                    userId: request.userId,
                  ),
                ],

                if (request.status == 'pending' ||
                    request.status ==
                        'accepted') ...[
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _isCancelling
                          ? null
                          : () {
                              _cancelRequest(request);
                            },
                      icon: _isCancelling
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.close_rounded,
                            ),
                      label: Text(
                        _isCancelling
                            ? 'İptal Ediliyor'
                            : 'Talebi İptal Et',
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFFB42318),
                        side: const BorderSide(
                          color:
                              Color(0xFFF2B8B5),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
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
            );
          },
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({
    required this.request,
    required this.onTap,
  });

  final ConsultationRequest request;
  final VoidCallback onTap;

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final _StatusVisual status =
        _statusVisual(request);

    final NumberFormat currencyFormatter =
        NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: _border,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE8F1EC),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.handshake_outlined,
                      color: _green,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.companyName,
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _ExpertNameText(
                          expertId:
                              request.expertId,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: status.background,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color: status.foreground,
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: _CardValue(
                      label: 'Finansman',
                      value: currencyFormatter
                          .format(
                        request.financeAmount,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _CardValue(
                      label: 'Teslim',
                      value:
                          '${request.estimatedDelivery}. Ay',
                    ),
                  ),
                  Expanded(
                    child: _CardValue(
                      label: 'Vade',
                      value:
                          '${request.estimatedTerm} Ay',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: _textMuted,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _formatDate(
                      request.createdAt,
                    ),
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 12.5,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Detayı Gör',
                    style: TextStyle(
                      color: _green,
                      fontSize: 12.5,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _green,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpertNameText extends StatelessWidget {
  const _ExpertNameText({
    required this.expertId,
  });

  final String expertId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('expertProfiles')
          .doc(expertId)
          .get(),
      builder: (
        context,
        snapshot,
      ) {
        if (!snapshot.hasData ||
            snapshot.data?.data() == null) {
          return const Text(
            'Uzman bilgisi yükleniyor',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12.5,
            ),
          );
        }

        final Map<String, dynamic> data =
            snapshot.data!.data()!;

        return Text(
          _readExpertName(data),
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

class _ExpertNameRow extends StatelessWidget {
  const _ExpertNameRow({
    required this.expertId,
  });

  final String expertId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('expertProfiles')
          .doc(expertId)
          .get(),
      builder: (
        context,
        snapshot,
      ) {
        String value = 'Uzman bilgisi yükleniyor';

        if (snapshot.hasData &&
            snapshot.data?.data() != null) {
          value = _readExpertName(
            snapshot.data!.data()!,
          );
        }

        return _DetailRow(
          label: 'Uzman',
          value: value,
        );
      },
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.request,
  });

  final ConsultationRequest request;

  @override
  Widget build(BuildContext context) {
    final _StatusVisual visual =
        _statusVisual(request);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            visual.icon,
            color: visual.foreground,
            size: 29,
          ),
          const SizedBox(height: 14),
          Text(
            visual.label,
            style: TextStyle(
              color: visual.foreground,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            visual.description,
            style: TextStyle(
              color: visual.foreground
                  .withValues(alpha: 0.82),
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertContactSection
    extends StatelessWidget {
  const _ExpertContactSection({
    required this.requestId,
    required this.userId,
  });

  final String requestId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final ConsultationRepository repository =
        ConsultationRepository();

    return StreamBuilder<
        ConsultationRequestContact?>(
      stream: repository.watchRequestContactForUser(
        requestId: requestId,
        userId: userId,
      ),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _ContactMessageCard(
            icon: Icons.hourglass_top_rounded,
            message:
                'Uzman iletişim bilgileri hazırlanıyor.',
          );
        }

        if (snapshot.hasError) {
          return const _ContactMessageCard(
            icon: Icons.error_outline_rounded,
            message:
                'Uzman iletişim bilgileri yüklenemedi.',
            isError: true,
          );
        }

        final ConsultationRequestContact? contact =
            snapshot.data;

        if (contact == null ||
            !contact.hasSharedExpertContact) {
          return const _ContactMessageCard(
            icon: Icons.info_outline_rounded,
            message:
                'Uzman iletişim bilgileri henüz paylaşılmadı.',
          );
        }

        return _DetailCard(
          children: [
            if (contact.expertPhone != null)
              _DetailRow(
                label: 'Telefon',
                value: contact.expertPhone!,
                highlighted: true,
              ),
            if (contact.expertPhone != null &&
                contact.expertCorporateEmail != null)
              const Divider(
                height: 1,
                color: Color(0xFFE5E7EB),
              ),
            if (contact.expertCorporateEmail != null)
              _DetailRow(
                label: 'Kurumsal E-posta',
                value:
                    contact.expertCorporateEmail!,
              ),
            if (contact.contactSharedAt != null) ...[
              const Divider(
                height: 1,
                color: Color(0xFFE5E7EB),
              ),
              _DetailRow(
                label: 'Paylaşım Tarihi',
                value: _formatDateTime(
                  contact.contactSharedAt!,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ContactMessageCard
    extends StatelessWidget {
  const _ContactMessageCard({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isError
        ? const Color(0xFFB42318)
        : const Color(0xFF0B5D3B);

    final Color background = isError
        ? const Color(0xFFFDECEC)
        : const Color(0xFFE8F1EC);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: foreground,
            size: 22,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foreground,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptedNotice extends StatelessWidget {
  const _AcceptedNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_rounded,
            color: Color(0xFF0B5D3B),
            size: 22,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Uzman talebinizi kabul etti. '
              'Uzman sizinle kayıtlı telefon numaranız '
              'üzerinden iletişime geçecektir.',
              style: TextStyle(
                color: Color(0xFF0B5D3B),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
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
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: highlighted
                    ? const Color(0xFF0B5D3B)
                    : const Color(0xFF111827),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSectionTitle
    extends StatelessWidget {
  const _DetailSectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CardValue extends StatelessWidget {
  const _CardValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        34,
      ),
      itemCount: 4,
      separatorBuilder: (
        context,
        index,
      ) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (
        context,
        index,
      ) {
        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const _MessageView(
      icon: Icons.handshake_outlined,
      title: 'Henüz danışma talebiniz yok',
      description:
          'FP Engine sonuç ekranından bir şirket '
          've uzman seçerek danışma talebi '
          'oluşturabilirsiniz.',
    );
  }
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView();

  @override
  Widget build(BuildContext context) {
    return const _MessageView(
      icon: Icons.lock_outline_rounded,
      title: 'Oturum bulunamadı',
      description:
          'Danışma taleplerinizi görüntülemek için '
          'hesabınıza giriş yapınız.',
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
    return _MessageView(
      icon: Icons.error_outline_rounded,
      title: 'Bir sorun oluştu',
      description: message,
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F1EC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0B5D3B),
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusVisual {
  const _StatusVisual({
    required this.label,
    required this.description,
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final String label;
  final String description;
  final Color foreground;
  final Color background;
  final IconData icon;
}

_StatusVisual _statusVisual(
  ConsultationRequest request,
) {
  final DateTime? expiresAt = request.expiresAt;

if (request.status == 'pending' &&
    expiresAt != null &&
    !DateTime.now().isBefore(expiresAt)) {
  return const _StatusVisual(
    label: 'Yanıt Süresi Doldu',
    description:
        'Uzmanın yanıt süresi doldu. Talebiniz '
        'yönetici incelemesine aktarılacaktır.',
    foreground: Color(0xFF92400E),
    background: Color(0xFFFFF3D6),
    icon: Icons.schedule_rounded,
  );
}

  switch (request.status) {
    case 'pending':
      return const _StatusVisual(
        label: 'Beklemede',
        description:
            'Uzmanın danışma talebinizi '
            'değerlendirmesi bekleniyor.',
        foreground: Color(0xFF92400E),
        background: Color(0xFFFFF3D6),
        icon: Icons.schedule_rounded,
      );

    case 'accepted':
      return const _StatusVisual(
        label: 'Kabul Edildi',
        description:
            'Uzman talebinizi kabul etti ve sizinle '
            'iletişime geçecektir.',
        foreground: Color(0xFF0B5D3B),
        background: Color(0xFFE8F1EC),
        icon: Icons.check_circle_outline_rounded,
      );

    case 'contacted':
      return const _StatusVisual(
        label: 'İletişime Geçildi',
        description:
            'Uzman sizinle iletişime geçtiğini '
            'bildirdi.',
        foreground: Color(0xFF075985),
        background: Color(0xFFE0F2FE),
        icon: Icons.phone_in_talk_outlined,
      );

    case 'completed':
      return const _StatusVisual(
        label: 'Tamamlandı',
        description:
            'Danışma süreci tamamlandı.',
        foreground: Color(0xFF0B5D3B),
        background: Color(0xFFE8F1EC),
        icon: Icons.verified_outlined,
      );

    case 'waiting_for_admin':
      return const _StatusVisual(
        label: 'İnceleniyor',
        description:
            'Talebiniz yönetici tarafından '
            'inceleniyor ve uygun uzmana '
            'yönlendirilecek.',
        foreground: Color(0xFF5B21B6),
        background: Color(0xFFEDE9FE),
        icon:
            Icons.admin_panel_settings_outlined,
      );

    case 'reassigned':
      return const _StatusVisual(
        label: 'Yönlendirildi',
        description:
            'Bu talep başka bir uzmana '
            'yönlendirildi.',
        foreground: Color(0xFF075985),
        background: Color(0xFFE0F2FE),
        icon: Icons.swap_horiz_rounded,
      );

    case 'cancelled':
      return const _StatusVisual(
        label: 'İptal Edildi',
        description:
            'Danışma talebi kullanıcı tarafından '
            'iptal edildi.',
        foreground: Color(0xFF6B7280),
        background: Color(0xFFF3F4F6),
        icon: Icons.cancel_outlined,
      );

    case 'rejected':
      return const _StatusVisual(
        label: 'Reddedildi',
        description:
            'Danışma talebi uzman tarafından '
            'kabul edilmedi.',
        foreground: Color(0xFFB42318),
        background: Color(0xFFFDECEC),
        icon: Icons.close_rounded,
      );

    case 'expired':
      return const _StatusVisual(
        label: 'Süresi Doldu',
        description:
            'Talebin yanıt süresi sona erdi.',
        foreground: Color(0xFF92400E),
        background: Color(0xFFFFF3D6),
        icon: Icons.timer_off_outlined,
      );

    default:
      return const _StatusVisual(
        label: 'İnceleniyor',
        description:
            'Danışma talebiniz işleme alındı.',
        foreground: Color(0xFF6B7280),
        background: Color(0xFFF3F4F6),
        icon: Icons.info_outline_rounded,
      );
  }
}

String _readExpertName(
  Map<String, dynamic> data,
) {
  final String fullName =
      data['fullName'] as String? ?? '';

  if (fullName.trim().isNotEmpty) {
    return fullName.trim();
  }

  final String firstName =
      data['firstName'] as String? ?? '';

  final String lastName =
      data['lastName'] as String? ?? '';

  final String combined =
      '$firstName $lastName'.trim();

  return combined.isEmpty
      ? 'Plango Uzmanı'
      : combined;
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return '-';
  }

  return DateFormat(
    'd MMMM yyyy',
    'tr_TR',
  ).format(date);
}

String _formatDateTime(DateTime? date) {
  if (date == null) {
    return '-';
  }

  return DateFormat(
    'd MMMM yyyy • HH:mm',
    'tr_TR',
  ).format(date);
}