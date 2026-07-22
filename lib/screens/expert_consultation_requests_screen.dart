import 'package:flutter/material.dart';

import '../../models/consultation_request_model.dart';
import '../../repositories/consultation_repository.dart';
import 'package:plango/screens/expert_request_detail_screen.dart';

class ExpertConsultationRequestsScreen
    extends StatelessWidget {
  ExpertConsultationRequestsScreen({
    super.key,
    required this.expertId,
  });

  final String expertId;

  final ConsultationRepository _repository =
      ConsultationRepository();

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

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
          'Danışma Taleplerim',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<List<ConsultationRequest>>(
        stream: _repository.watchExpertRequests(
          expertId,
        ),
        builder: (context, snapshot) {
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
  debugPrint('Danışma talepleri hatası: ${snapshot.error}');

  return _RequestMessage(
    icon: Icons.error_outline_rounded,
    title: 'Talepler Yüklenemedi',
    message: snapshot.error.toString(),
  );
}

          final List<ConsultationRequest> requests =
    (snapshot.data ?? [])
        .where(
          (request) => request.status != 'expired',
        )
        .toList();
          if (requests.isEmpty) {
            return const _RequestMessage(
              icon: Icons.inbox_outlined,
              title: 'Henüz Talep Yok',
              message:
                  'Size gönderilen danışma talepleri burada görüntülenecek.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              30,
            ),
            itemCount: requests.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _RequestCard(
  request: requests[index],
  repository: _repository,
  expertId: expertId,
);
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.repository,
    required this.expertId,
  });

  final ConsultationRequest request;
  final ConsultationRepository repository;
  final String expertId;

  @override
  Widget build(BuildContext context) {
    final _StatusInformation status =
        _statusInformation(request.status);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              ExpertConsultationRequestsScreen._border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color:
                      ExpertConsultationRequestsScreen
                          ._green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userFullName,
                      style: const TextStyle(
                        color:
                            ExpertConsultationRequestsScreen
                                ._textDark,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.companyName,
                      style: const TextStyle(
                        color:
                            ExpertConsultationRequestsScreen
                                ._textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.textColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _InformationRow(
            label: 'Finansman',
            value: _formatCurrency(
              request.financeAmount,
            ),
          ),
          const SizedBox(height: 8),
          _InformationRow(
            label: 'İlk Taksit',
            value: _formatCurrency(
              request.monthlyInstallment,
            ),
          ),
          const SizedBox(height: 8),
          _InformationRow(
            label: 'Tahmini Teslimat',
            value:
                '${request.estimatedDelivery}. ay',
          ),
          const SizedBox(height: 8),
          _InformationRow(
            label: 'Talep Tarihi',
            value: _formatDate(request.createdAt),
          ),
          if (request.userNote?.trim().isNotEmpty ==
              true) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                request.userNote!,
                style: const TextStyle(
                  color:
                      ExpertConsultationRequestsScreen
                          ._textMuted,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
          ],
          if (request.status == 'pending') ...[
  const SizedBox(height: 18),
  Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () async {
            try {
              await repository.rejectRequest(
                requestId: request.requestId!,
                expertId: expertId,
                rejectionReason: "Uzman tarafından reddedildi",
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
            }
          },
          child: const Text("Reddet"),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton(
          onPressed: () async {
            try {
              await repository.acceptRequest(
                requestId: request.requestId!,
                expertId: expertId,
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
            }
          },
          child: const Text("Kabul Et"),
        ),
      ),
    ],
  ),
],

if (request.status == 'accepted' ||
    request.status == 'contacted' ||
    request.status == 'completed') ...[
  const SizedBox(height: 18),
  SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      icon: const Icon(Icons.visibility_outlined),
      label: const Text("Talep Detayını Gör"),
      onPressed: () {
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
        ],
      ),
    );
  }

  static String _formatCurrency(double value) {
    final String digits = value
        .round()
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
        );

    return '$digits ₺';
  }

  static String _formatDate(DateTime value) {
    final String day =
        value.day.toString().padLeft(2, '0');
    final String month =
        value.month.toString().padLeft(2, '0');
    final String hour =
        value.hour.toString().padLeft(2, '0');
    final String minute =
        value.minute.toString().padLeft(2, '0');

    return '$day.$month.${value.year} $hour:$minute';
  }

  static _StatusInformation _statusInformation(
    String status,
  ) {
    switch (status) {
      case 'accepted':
        return const _StatusInformation(
          label: 'Kabul Edildi',
          backgroundColor: Color(0xFFE8F1EC),
          textColor: Color(0xFF0B5D3B),
        );

      case 'contacted':
        return const _StatusInformation(
          label: 'İletişime Geçildi',
          backgroundColor: Color(0xFFEFF6FF),
          textColor: Color(0xFF1D4ED8),
        );

      case 'completed':
        return const _StatusInformation(
          label: 'Tamamlandı',
          backgroundColor: Color(0xFFF3F4F6),
          textColor: Color(0xFF4B5563),
        );

      case 'cancelled':
        return const _StatusInformation(
          label: 'İptal Edildi',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: Color(0xFFB91C1C),
        );

      case 'reassigned':
        return const _StatusInformation(
          label: 'Yönlendirildi',
          backgroundColor: Color(0xFFF3F4F6),
          textColor: Color(0xFF6B7280),
        );

      case 'rejected':
        return const _StatusInformation(
          label: 'Reddedildi',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: Color(0xFFB91C1C),
        );

      case 'expired':
        return const _StatusInformation(
          label: 'Süresi Doldu',
          backgroundColor: Color(0xFFF3F4F6),
          textColor: Color(0xFF6B7280),
        );

      default:
        return const _StatusInformation(
          label: 'Yeni Talep',
          backgroundColor: Color(0xFFFFF4E5),
          textColor: Color(0xFFB54708),
        );
    }
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color:
                  ExpertConsultationRequestsScreen
                      ._textMuted,
              fontSize: 12.5,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color:
                ExpertConsultationRequestsScreen
                    ._textDark,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StatusInformation {
  const _StatusInformation({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
}

class _RequestMessage extends StatelessWidget {
  const _RequestMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  ExpertConsultationRequestsScreen
                      ._green,
              size: 48,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    ExpertConsultationRequestsScreen
                        ._textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    ExpertConsultationRequestsScreen
                        ._textMuted,
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