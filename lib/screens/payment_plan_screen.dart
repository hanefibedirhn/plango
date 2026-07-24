import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';
import '../repositories/saved_plan_repository.dart';

class PaymentPlanScreen
    extends StatefulWidget {
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

class _PaymentPlanScreenState
    extends State<PaymentPlanScreen> {
  static const Color _green =
      Color(0xFF0B5D3B);

  static const Color _dark =
      Color(0xFF10231B);

  static const Color _gold =
      Color(0xFFD6A84F);

  static const Color _background =
      Color(0xFFF4F5F1);

  final ScrollController _scrollController =
      ScrollController();

  final SavedPlanRepository
    _savedPlanRepository =
    SavedPlanRepository();

bool _isSavingPlan = false;    

  final NumberFormat _moneyFormat =
      NumberFormat(
    '#,##0.##',
    'tr_TR',
  );

  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      _handleScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final bool isAtBottom =
        _scrollController.position.pixels >=
            _scrollController
                    .position.maxScrollExtent -
                80;

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
      _scrollController
          .position.maxScrollExtent,
      duration:
          const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  String _money(double value) {
    return '${_moneyFormat.format(value)} ₺';
  }

  Future<void> _savePlan() async {
  if (_isSavingPlan) {
    return;
  }

  final User? user =
      FirebaseAuth.instance.currentUser;

  if (user == null || user.isAnonymous) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
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

    ScaffoldMessenger.of(context)
        .showSnackBar(
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
          'güncellememiz gerekiyor.';
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } catch (_) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
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
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Cihaza Kaydet özelliğini '
          'PDF altyapısıyla ekleyeceğiz.',
        ),
      ),
    );
  }

  void _handleMenuSelection(
    String value,
  ) {
    switch (value) {
      case 'savePlan':
        _savePlan();
        break;

      case 'saveDevice':
        _saveToDevice();
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
            onSelected:
                _handleMenuSelection,
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'savePlan',
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Planı Kaydet',
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'saveDevice',
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_rounded,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Cihaza Kaydet',
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton:
          _isAtBottom
              ? null
              : FloatingActionButton.small(
                  onPressed:
                      _scrollToBottom,
                  backgroundColor: _dark,
                  foregroundColor:
                      Colors.white,
                  tooltip:
                      'Planın sonuna git',
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 30,
                  ),
                ),
      body: ListView(
        controller: _scrollController,
        padding:
            const EdgeInsets.fromLTRB(
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

          _buildTableHeader(),

          ...widget.result.paymentPlan.map(
            _buildPaymentRow,
          ),

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
    style:
        ElevatedButton.styleFrom(
      backgroundColor: _green,
      foregroundColor:
          Colors.white,
      disabledBackgroundColor:
          _green.withOpacity(0.65),
      disabledForegroundColor:
          Colors.white,
      elevation: 0,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      textStyle:
          const TextStyle(
        fontSize: 16,
        fontWeight:
            FontWeight.w800,
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
        borderRadius:
            BorderRadius.circular(28),
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
        borderRadius:
            BorderRadius.circular(24),
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
            _money(
              widget.plan.financeAmount,
            ),
          ),
          _divider(),
          _summaryRow(
            'Peşinat',
            _money(
              widget.plan.downPayment,
            ),
          ),
          _divider(),
          _summaryRow(
            'Başlangıç Taksiti',
            _money(
              widget
                  .plan.monthlyInstallment,
            ),
          ),
          _divider(),
          _summaryRow(
            'Tahmini Teslim',
            '${widget.result.estimatedDelivery}. Ay',
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
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: _gold.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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

  Widget _buildTableHeader() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              'Ay',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Taksit',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Toplam Birikim',
              textAlign: TextAlign.right,
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

  Widget _buildPaymentRow(
    PaymentPlanItem item,
  ) {
    final bool isDelivery =
        item.isDeliveryMonth;

    final bool isLast =
        item.isLastMonth;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: isDelivery
            ? const Color(0xFFE9F7EF)
            : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDelivery
                ? _green
                : const Color(0xFFE6E9E4),
          ),
          right: BorderSide(
            color: isDelivery
                ? _green
                : const Color(0xFFE6E9E4),
          ),
          bottom: BorderSide(
            color: isDelivery
                ? _green
                : const Color(0xFFE6E9E4),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.month}. Ay',
                  style: TextStyle(
                    color: isDelivery
                        ? _green
                        : _dark,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                if (isDelivery)
                  const Padding(
                    padding:
                        EdgeInsets.only(
                      top: 3,
                    ),
                    child: Text(
                      'Teslim',
                      style: TextStyle(
                        color: _green,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                if (isLast &&
                    !isDelivery)
                  const Padding(
                    padding:
                        EdgeInsets.only(
                      top: 3,
                    ),
                    child: Text(
                      'Son ödeme',
                      style: TextStyle(
                        color:
                            Colors.black45,
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              _money(item.installment),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _dark,
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _money(item.totalSaving),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isDelivery
                    ? _green
                    : _dark,
                fontSize: 13,
                fontWeight:
                    FontWeight.w900,
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
        borderRadius:
            BorderRadius.circular(18),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
              color: highlight
                  ? _green
                  : _dark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 13,
      ),
      child: Divider(
        height: 1,
        color: Color(0xFFEAECE8),
      ),
    );
  }
}