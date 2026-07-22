import 'package:flutter/material.dart';

import '../../models/consultation_request_model.dart';
import '../../models/expert_profile_model.dart';
import '../../repositories/expert_profile_repository.dart';

class AdminConsultationRequestDetailScreen
    extends StatelessWidget {
  const AdminConsultationRequestDetailScreen({
    super.key,
    required this.request,
  });

  final ConsultationRequest request;

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);

  @override
Widget build(BuildContext context) {
  final String note =
      request.userNote?.trim() ?? '';

  final ExpertProfileRepository
      expertProfileRepository =
      ExpertProfileRepository();

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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            34,
          ),
          children: [
            _SectionCard(
              icon: Icons.person_outline_rounded,
              title: 'Kullanıcı Bilgileri',
              children: [
                _DetailRow(
                  label: 'Ad Soyad',
                  value: request.userFullName,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              icon: Icons.description_outlined,
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
                    request.financeAmount,
                  ),
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  label: 'Peşinat',
                  value: _formatCurrency(
                    request.downPayment,
                  ),
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  label: 'İlk Taksit',
                  value: _formatCurrency(
                    request.monthlyInstallment,
                  ),
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  label: 'Artış Modeli',
                  value: request.increaseModel,
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  label: 'Tahmini Vade',
                  value: '${request.estimatedTerm} ay',
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  label: 'Tahmini Teslimat',
                  value:
                      '${request.estimatedDelivery}. ay',
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
                      color: _textDark,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            _SectionCard(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Atama Bilgileri',
              children: [
                _DetailRow(
                  label: 'Talep Durumu',
                  value: _statusLabel(request.status),
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
                  label: 'Admin Kuyruğu',
                  value: _adminQueueReasonLabel(
                    request.adminQueueReason,
                  ),
                ),
                if (request.rejectionReason
                        ?.trim()
                        .isNotEmpty ==
                    true) ...[
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Red Nedeni',
                    value: request.rejectionReason!,
                  ),
                ],
                if (request.expertId.trim().isNotEmpty) ...[
  const SizedBox(height: 14),
  FutureBuilder<ExpertProfile>(
    future: expertProfileRepository.getExpertProfile(
      request.expertId,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState ==
          ConnectionState.waiting) {
        return const _DetailRow(
          label: 'Önceki Uzman',
          value: 'Yükleniyor...',
        );
      }

      if (snapshot.hasError ||
          !snapshot.hasData) {
        return const _DetailRow(
          label: 'Önceki Uzman',
          value: 'Uzman bilgisi bulunamadı',
        );
      }

      return _DetailRow(
        label: 'Önceki Uzman',
        value: snapshot.data!.fullName,
      );
    },
  ),
],
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Bir sonraki adımda uzman seçme akışını bağlayacağız.
                },
                icon: const Icon(
                  Icons.person_search_rounded,
                ),
                label: const Text(
                  'Yeni Uzman Ata',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
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

  static String _statusLabel(String status) {
    switch (status) {
      case 'waiting_for_admin':
        return 'Yeni uzman ataması bekliyor';
      case 'pending':
        return 'Uzman yanıtı bekleniyor';
      case 'accepted':
        return 'Kabul edildi';
      case 'contacted':
        return 'İletişime geçildi';
      case 'completed':
        return 'Tamamlandı';
      default:
        return status;
    }
  }

  static String _adminQueueReasonLabel(
    String? reason,
  ) {
    switch (reason) {
      case 'expert_rejected':
        return 'Uzman talebi reddetti';
      case 'response_expired':
        return 'Uzman yanıt süresi doldu';
      case null:
      case '':
        return 'Belirtilmedi';
      default:
        return reason;
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              AdminConsultationRequestDetailScreen
                  ._border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      AdminConsultationRequestDetailScreen
                          ._softGreen,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color:
                      AdminConsultationRequestDetailScreen
                          ._green,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  color:
                      AdminConsultationRequestDetailScreen
                          ._textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color:
                  AdminConsultationRequestDetailScreen
                      ._textMuted,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color:
                  AdminConsultationRequestDetailScreen
                      ._textDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}