import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';
import '../repositories/saved_plan_repository.dart';
import 'consultation/select_company_screen.dart';
import '../services/plango_pdf_service.dart';

class PaymentPlanScreen extends StatefulWidget {
  const PaymentPlanScreen({
    super.key,
    required this.plan,
    required this.result,
  });

  final CalculationPlan plan;
  final FpResult result;

  @override
  State<PaymentPlanScreen> createState() =>
      _PaymentPlanScreenState();
}

class _PaymentPlanScreenState extends State<PaymentPlanScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _dark = Color(0xFF10231B);
  static const Color _gold = Color(0xFFD6A84F);
  static const Color _background = Color(0xFFF4F5F1);
  static const Color _blue = Color(0xFF3278C8);
  static const Color _rowBorder = Color(0xFFE6E9E4);

  final ScrollController _scrollController = ScrollController();

  final SavedPlanRepository _savedPlanRepository =
      SavedPlanRepository();

  final NumberFormat _moneyFormat = NumberFormat(
    '#,##0.##',
    'tr_TR',
  );

  final DateFormat _paymentDateFormat = DateFormat(
    'd MMMM yyyy',
    'tr_TR',
  );

  bool _isSavingPlan = false;
bool _isCreatingPdf = false;
bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final bool isAtBottom =
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 80;

    if (_isAtBottom != isAtBottom) {
      setState(() {
        _isAtBottom = isAtBottom;
      });
    }
  }

  Future<void> _scrollToBottom() async {
    if (!_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  String _money(double value) {
    return '${_moneyFormat.format(value)} ₺';
  }

  PaymentPlanItem? get _deliveryItem {
    for (final PaymentPlanItem item in widget.result.paymentPlan) {
      if (item.isDeliveryMonth) {
        return item;
      }
    }

    return null;
  }

  String _periodName(PaymentPlanItem item) {
    if (item.isDeliveryMonth) {
      return 'Tahmini Teslim';
    }

    if (item.isLastMonth) {
      return 'Son Taksit';
    }

    if (item.month < widget.result.estimatedDelivery) {
      return 'Tasarruf Dönemi';
    }

    return 'Finansman Dönemi';
  }

  Future<void> _openConsultationFlow() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        final UserCredential credential =
            await FirebaseAuth.instance.signInAnonymously();

        user = credential.user;
      }

      if (user == null) {
        throw StateError(
          'Misafir oturumu oluşturulamadı.',
        );
      }

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) {
            return SelectCompanyScreen(
              plan: widget.plan,
            );
          },
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          'Misafir oturumu başlatılamadı. '
          'Lütfen tekrar deneyin.';

      if (error.code == 'operation-not-allowed') {
        message =
            'Firebase anonim giriş özelliği '
            'etkin değil.';
      } else if (error.code == 'too-many-requests') {
        message =
            'Çok fazla deneme yapıldı. '
            'Lütfen biraz sonra tekrar deneyin.';
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Danışma ekranı açılamadı. '
              'Lütfen tekrar deneyin.',
            ),
          ),
        );
    }
  }

  Future<void> _savePlan() async {
    if (_isSavingPlan) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Plan kaydetmek için kullanıcı '
            'hesabınızla giriş yapmanız gerekir.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSavingPlan = true;
    });

    try {
      final bool wasSaved =
          await _savedPlanRepository.savePlan(
        userId: user.uid,
        plan: widget.plan,
        result: widget.result,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasSaved
                ? 'Planınız başarıyla kaydedildi.'
                : 'Bu plan daha önce kaydedilmiş.',
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          'Plan kaydedilemedi. Lütfen tekrar deneyin.';

      if (error.code == 'permission-denied') {
        message =
            'Plan kaydetme izni bulunamadı. '
            'Firestore güvenlik kurallarını '
            'kontrol etmemiz gerekiyor.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Plan kaydedilirken beklenmeyen '
            'bir hata oluştu.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPlan = false;
        });
      }
    }
  }

  Future<void> _saveToDevice() async {
  if (_isCreatingPdf) {
    return;
  }

  setState(() {
    _isCreatingPdf = true;
  });

  try {
    final DateTime createdAt = DateTime.now();

    final String planNumber =
    'PLN-${DateFormat('yyMMdd').format(createdAt)}-'
    '${createdAt.millisecondsSinceEpoch.toString().substring(7)}';

    final User? user =
        FirebaseAuth.instance.currentUser;

    String customerName = 'Değerli Kullanıcımız';

    final String? displayName =
        user?.displayName?.trim();

    if (displayName != null &&
        displayName.isNotEmpty) {
      customerName = displayName;
    }

    await PlangoPdfService.saveToDevice(
      plan: widget.plan,
      result: widget.result,
      customerName: customerName,
      createdAt: createdAt,
      planNumber: planNumber,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Ödeme planı PDF olarak oluşturuldu.',
          ),
        ),
      );
  } catch (error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'PDF oluşturulamadı: $error',
          ),
        ),
      );
  } finally {
    if (mounted) {
      setState(() {
        _isCreatingPdf = false;
      });
    }
  }
}

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'savePlan':
        _savePlan();
        break;
      case 'saveDevice':
  if (!_isCreatingPdf) {
    _saveToDevice();
  }
  break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        title: const Text(
          'Ödeme Planı',
          style: TextStyle(
            color: _dark,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: _dark,
            ),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'savePlan',
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_outline),
                      SizedBox(width: 12),
                      Text('Planı Kaydet'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'saveDevice',
                  child: Row(
                    children: [
                      Icon(Icons.download_rounded),
                      SizedBox(width: 12),
                      Text('Cihaza Kaydet'),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: _isAtBottom
          ? null
          : FloatingActionButton.small(
              onPressed: _scrollToBottom,
              backgroundColor: _dark,
              foregroundColor: Colors.white,
              tooltip: 'Planın sonuna git',
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 30,
              ),
            ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          18,
          6,
          18,
          40,
        ),
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          _buildSummaryCard(),
          const SizedBox(height: 12),
          _buildOrganizationFeeInfo(),
          const SizedBox(height: 18),
          _buildExpertConsultationButton(),
          const SizedBox(height: 24),
          const Text(
            'Tüm Vade Ödeme Planı',
            style: TextStyle(
              color: _dark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.result.estimatedTerm} aylık '
            'ödeme planının tamamı',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          _buildPaymentTable(),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed:
                  _isSavingPlan ? null : _savePlan,
              icon: _isSavingPlan
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.bookmark_add_outlined,
                    ),
              label: Text(
                _isSavingPlan
                    ? 'Kaydediliyor...'
                    : 'Planı Kaydet',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    _green.withValues(alpha: 0.65),
                disabledForegroundColor:
                    Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.explore_rounded,
            color: _gold,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'PLANGO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 3,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Kişisel Ödeme Planınız',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
        ),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Finansman Tutarı',
            _money(widget.plan.financeAmount),
          ),
          _divider(),
          _summaryRow(
            'Peşinat',
            _money(widget.plan.downPayment),
          ),
          _divider(),
          _summaryRow(
            'Başlangıç Taksiti',
            _money(widget.plan.monthlyInstallment),
          ),
          _divider(),
          _summaryRow(
            'Tahmini Teslim',
            _deliveryItem == null
                ? '${widget.result.estimatedDelivery}. Ay'
                : '${widget.result.estimatedDelivery}. Ay\n'
                    '${_paymentDateFormat.format(
                      _deliveryItem!.paymentDate,
                    )}',
            highlight: true,
          ),
          _divider(),
          _summaryRow(
            'Toplam Vade',
            '${widget.result.estimatedTerm} Ay',
          ),
          _divider(),
          _summaryRow(
            'Artış Şekli',
            widget.plan.increaseModel,
          ),
          _divider(),
          _summaryRow(
            'Organizasyon Ücreti',
            'Tahmini %7 – %8,5',
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationFeeInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _gold.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF946E21),
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Organizasyon ücreti; ilgili '
              'tasarruf finansman şirketine, '
              'kampanyaya ve sözleşme '
              'koşullarına göre değişebilir.',
              style: TextStyle(
                color: Color(0xFF6F531B),
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertConsultationButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _openConsultationFlow,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _green.withValues(
                  alpha: 0.18,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ücretsiz Uzman Görüşü Al',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Planınızı birlikte değerlendirelim.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 620,
          child: Column(
            children: [
              _buildTableHeader(),
              ...widget.result.paymentPlan.map(
                _buildPaymentRow,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      color: _dark,
      child: const Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              'Ay',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 160,
            child: Text(
              'Taksit Tarihi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 145,
            child: Text(
              'Taksit Tutarı',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              'Dönem',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(PaymentPlanItem item) {
    final bool isDelivery = item.isDeliveryMonth;
    final bool isLast = item.isLastMonth;

    Color accentColor = const Color(0xFF2E9B50);
    Color backgroundColor = Colors.white;

    if (isDelivery) {
      accentColor = _gold;
      backgroundColor = const Color(0xFFFFF7E4);
    } else if (isLast) {
      accentColor = _dark;
      backgroundColor = const Color(0xFFF2F3F1);
    } else if (item.month >
        widget.result.estimatedDelivery) {
      accentColor = _blue;
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: 68,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: 4,
          ),
          right: const BorderSide(
            color: _rowBorder,
          ),
          bottom: const BorderSide(
            color: _rowBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 51,
            child: Text(
              '${item.month}',
              style: TextStyle(
                color: accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 160,
            child: Text(
              _paymentDateFormat.format(
                item.paymentDate,
              ),
              style: const TextStyle(
                color: _dark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 145,
            child: Text(
              _money(item.installment),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _dark,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: accentColor.withValues(
                  alpha: 0.11,
                ),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                _periodName(item),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        '* Bu ödeme planı, kullanıcı '
        'tarafından girilen bilgiler '
        'doğrultusunda Plango FP Engine '
        'tarafından bilgilendirme amacıyla '
        'oluşturulmuştur. Tahmini teslim '
        'tarihi, ödeme tutarları, '
        'organizasyon ücreti ve plan '
        'koşulları tasarruf finansman '
        'şirketlerinin uygulamalarına, '
        'kampanyalarına ve sözleşme '
        'şartlarına göre farklılık '
        'gösterebilir. Size en uygun plan '
        'hakkında güncel ve resmî bilgi '
        'almak için tasarruf finansman '
        'uzmanınızla görüşebilirsiniz.',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 11.5,
          height: 1.55,
        ),
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: highlight ? _green : _dark,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 13,
      ),
      child: Divider(
        height: 1,
        color: Color(0xFFEAECE8),
      ),
    );
  }
}
