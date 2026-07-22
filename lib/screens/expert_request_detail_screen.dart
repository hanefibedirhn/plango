import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/consultation_request_model.dart';
import '../../repositories/consultation_repository.dart';

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
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);

  final ConsultationRepository _repository =
      ConsultationRepository();

  late Future<String?> _phoneFuture;

  @override
  void initState() {
    super.initState();

    final String? requestId = widget.request.requestId;

    _phoneFuture = requestId == null
        ? Future<String?>.value(null)
        : _repository.getRequestPhone(
            requestId: requestId,
            expertId: widget.request.expertId,
          );
  }

  Future<void> _openPhone(String phone) async {
    final String normalizedPhone = phone.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: normalizedPhone,
    );

    final bool opened = await launchUrl(phoneUri);

    if (!opened && mounted) {
      _showMessage(
        'Telefon uygulaması açılamadı.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ConsultationRequest request =
        widget.request;

    final String note =
        request.userNote?.trim() ?? '';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
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
                const SizedBox(height: 14),
                FutureBuilder<String?>(
                  future: _phoneFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const _PhoneLoadingRow();
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

                    return _PhoneRow(
                      phone: _formatPhone(phone),
                      onTap: () =>
                          _openPhone(phone),
                    );
                  },
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
                  value:
                      '${request.estimatedTerm} ay',
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
            const SizedBox(height: 22),
            _buildStatusArea(request),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusArea(
    ConsultationRequest request,
  ) {
    if (request.isAccepted) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () async {
  final String? requestId = request.requestId;

  if (requestId == null) {
    _showMessage('Talep bilgisi bulunamadı.');
    return;
  }

  try {
    await _repository.markAsContacted(
      requestId: requestId,
      expertId: request.expertId,
    );

    if (!mounted) return;

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    _showMessage(e.toString());
  }
},
          icon: const Icon(
            Icons.phone_in_talk_outlined,
          ),
          label: const Text(
            'İletişime Geçildi',
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
      );
    }

    if (request.isContacted) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () async {
  final String? requestId = request.requestId;

  if (requestId == null) {
    _showMessage('Talep bilgisi bulunamadı.');
    return;
  }

  try {
    await _repository.completeRequest(
      requestId: requestId,
      expertId: request.expertId,
    );

    if (!mounted) return;

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    _showMessage(e.toString());
  }
},
          icon: const Icon(
            Icons.check_circle_outline_rounded,
          ),
          label: const Text(
            'Süreci Tamamla',
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
      );
    }

    if (request.isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _softGreen,
          borderRadius: BorderRadius.circular(17),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: _green,
            ),
            SizedBox(width: 11),
            Expanded(
              child: Text(
                'Danışmanlık süreci tamamlandı.',
                style: TextStyle(
                  color: _green,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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

  static String _formatPhone(String value) {
    String digits = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.length == 11 &&
        digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    if (digits.length != 10) {
      return value;
    }

    return '0${digits.substring(0, 3)} '
        '${digits.substring(3, 6)} '
        '${digits.substring(6, 8)} '
        '${digits.substring(8, 10)}';
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
              _ExpertRequestDetailScreenState._border,
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
                      _ExpertRequestDetailScreenState
                          ._softGreen,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color:
                      _ExpertRequestDetailScreenState
                          ._green,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  color:
                      _ExpertRequestDetailScreenState
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
                  _ExpertRequestDetailScreenState
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
                  _ExpertRequestDetailScreenState
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

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({
    required this.phone,
    required this.onTap,
  });

  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Telefon',
                style: TextStyle(
                  color:
                      _ExpertRequestDetailScreenState
                          ._textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              phone,
              style: const TextStyle(
                color:
                    _ExpertRequestDetailScreenState
                        ._green,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 7),
            const Icon(
              Icons.phone_outlined,
              color:
                  _ExpertRequestDetailScreenState
                      ._green,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneLoadingRow extends StatelessWidget {
  const _PhoneLoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Telefon',
            style: TextStyle(
              color:
                  _ExpertRequestDetailScreenState
                      ._textMuted,
              fontSize: 13,
            ),
          ),
        ),
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color:
                _ExpertRequestDetailScreenState
                    ._green,
          ),
        ),
      ],
    );
  }
}