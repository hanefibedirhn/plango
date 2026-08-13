import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';
import '../repositories/saved_plan_repository.dart';
import '../services/plango_pdf_service.dart';
import 'consultation/select_company_screen.dart';
import 'user_login_screen.dart';

class PaymentPlanScreen extends StatefulWidget {
  const PaymentPlanScreen({
    super.key,
    required this.plan,
    required this.result,
  });

  final CalculationPlan plan;
  final FpResult result;

  @override
  State<PaymentPlanScreen> createState() => _PaymentPlanScreenState();
}

class _PaymentPlanScreenState extends State<PaymentPlanScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4E9EE);
  static const Color _softTeal = Color(0xFFEAF7F5);
  static const Color _deliveryBackground = Color(0xFFE8FBF7);
  static const Color _lastBackground = Color(0xFFF1F5F7);

  final ScrollController _scrollController = ScrollController();
  final SavedPlanRepository _savedPlanRepository = SavedPlanRepository();

  final NumberFormat _moneyFormat = NumberFormat('#,##0.##', 'tr_TR');
  final DateFormat _paymentDateFormat = DateFormat('d MMM yyyy', 'tr_TR');
  final DateFormat _longDateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

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
    if (!_scrollController.hasClients) return;

    final bool isAtBottom =
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 80;

    if (_isAtBottom != isAtBottom && mounted) {
      setState(() => _isAtBottom = isAtBottom);
    }
  }

  Future<void> _scrollToBottom() async {
    if (!_scrollController.hasClients) return;

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;

    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  String _money(double value) {
    return '${_moneyFormat.format(value)} ₺';
  }

  PaymentPlanItem? get _deliveryItem {
    for (final PaymentPlanItem item in widget.result.paymentPlan) {
      if (item.isDeliveryMonth) return item;
    }
    return null;
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
        throw StateError('Misafir oturumu oluşturulamadı.');
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SelectCompanyScreen(plan: widget.plan),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message =
          'Misafir oturumu başlatılamadı. Lütfen tekrar deneyin.';

      if (error.code == 'operation-not-allowed') {
        message = 'Firebase anonim giriş özelliği etkin değil.';
      } else if (error.code == 'too-many-requests') {
        message =
            'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.';
      }

      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Danışma ekranı açılamadı. Lütfen tekrar deneyin.');
    }
  }

  Future<void> _savePlan() async {
    if (_isSavingPlan) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      final bool shouldLogin = await _showLoginRequiredDialog();
      if (!shouldLogin || !mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const UserLoginScreen(),
        ),
      );

      if (!mounted) return;

      user = FirebaseAuth.instance.currentUser;

      if (user == null || user.isAnonymous) {
        return;
      }
    }

    setState(() => _isSavingPlan = true);

    try {
      final bool wasSaved = await _savedPlanRepository.savePlan(
        userId: user.uid,
        plan: widget.plan,
        result: widget.result,
      );

      if (!mounted) return;

      _showMessage(
        wasSaved
            ? 'Planınız başarıyla kaydedildi.'
            : 'Bu plan daha önce kaydedilmiş.',
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.code == 'permission-denied'
            ? 'Plan kaydetme izni bulunamadı. Firestore güvenlik kurallarını kontrol etmemiz gerekiyor.'
            : 'Plan kaydedilemedi. Lütfen tekrar deneyin.',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Plan kaydedilirken beklenmeyen bir hata oluştu.');
    } finally {
      if (mounted) {
        setState(() => _isSavingPlan = false);
      }
    }
  }

  Future<bool> _showLoginRequiredDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
          actionsPadding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
          title: const Row(
            children: [
              Icon(
                Icons.bookmark_add_outlined,
                color: _teal,
                size: 25,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Planını Kaydet',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Planını kaydetmek ve daha sonra Planlarım bölümünden '
            'ulaşabilmek için kullanıcı hesabınla giriş yapmalısın.',
            style: TextStyle(
              color: _muted,
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: _muted,
              ),
              child: const Text(
                'Vazgeç',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _saveToDevice() async {
    if (_isCreatingPdf) return;

    setState(() => _isCreatingPdf = true);

    try {
      final DateTime createdAt = DateTime.now();

      final String planNumber =
          'PLN-${DateFormat('yyMMdd').format(createdAt)}-'
          '${createdAt.millisecondsSinceEpoch.toString().substring(7)}';

      final User? user = FirebaseAuth.instance.currentUser;
      String customerName = 'Değerli Kullanıcımız';

      final String? displayName = user?.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        customerName = displayName;
      }

      await PlangoPdfService.saveToDevice(
        plan: widget.plan,
        result: widget.result,
        customerName: customerName,
        createdAt: createdAt,
        planNumber: planNumber,
      );

      if (!mounted) return;
      _showMessage('Ödeme planı PDF olarak oluşturuldu.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('PDF oluşturulamadı: $error');
    } finally {
      if (mounted) {
        setState(() => _isCreatingPdf = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'saveDevice':
        _saveToDevice();
        break;
      case 'savePlan':
        _savePlan();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        toolbarHeight: 66,
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 2,
        iconTheme: const IconThemeData(color: _navy),
        title: Image.asset(
          'assets/images/tasarruf_planim_home_logo.png',
          height: 43,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: '',
            elevation: 10,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: _navy.withOpacity(0.16),
            offset: const Offset(-8, 48),
            constraints: const BoxConstraints(
              minWidth: 205,
              maxWidth: 230,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: _border),
            ),
            icon: const Icon(
              Icons.more_vert_rounded,
              color: _navy,
            ),
            onSelected: _handleMenuSelection,
            itemBuilder: (_) {
              return [
                PopupMenuItem<String>(
                  value: 'saveDevice',
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: _menuItem(
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'PDF Oluştur',
                    subtitle: 'Cihazına kaydet',
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'savePlan',
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: _menuItem(
                    icon: Icons.bookmark_outline_rounded,
                    title: 'Planı Kaydet',
                    subtitle: 'Planlarıma ekle',
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 7),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 96),
            children: [
          const Text(
            'Ödeme Planı',
            style: TextStyle(
              color: _navy,
              fontSize: 24,
              height: 1.12,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Planının teslim, vade ve aylık ödeme detaylarını incele.',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          _buildDeliveryCard(),
          const SizedBox(height: 14),
          _buildPlanInfoCard(),
          const SizedBox(height: 24),
          _buildPaymentPlanTitle(),
          const SizedBox(height: 12),
          _buildPaymentTable(),
          const SizedBox(height: 24),
          _buildPrimaryPdfButton(),
          const SizedBox(height: 10),
          _buildSecondaryButton(
            icon: Icons.bookmark_add_outlined,
            text: _isSavingPlan ? 'Kaydediliyor...' : 'Planı Kaydet',
            onPressed: _isSavingPlan ? null : _savePlan,
            showProgress: _isSavingPlan,
          ),
          const SizedBox(height: 10),
          _buildSecondaryButton(
            icon: Icons.support_agent_rounded,
            text: 'Uzmana Danış',
            onPressed: _openConsultationFlow,
          ),
          const SizedBox(height: 16),
              _buildDisclaimer(),
            ],
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: Material(
                color: _petrol,
                elevation: 5,
                shadowColor: _navy.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: _isAtBottom ? _scrollToTop : _scrollToBottom,
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      _isAtBottom
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: _turquoise.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _teal, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    final PaymentPlanItem? deliveryItem = _deliveryItem;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_petrol, _teal],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _petrol.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _turquoise.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _turquoise.withOpacity(0.35),
              ),
            ),
            child: const Text(
              'TAHMİNİ TESLİMAT',
              style: TextStyle(
                color: _turquoise,
                fontSize: 10,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.result.estimatedDelivery} Ay',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            deliveryItem == null
                ? '-'
                : _longDateFormat.format(deliveryItem.paymentDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _resultDetail(
                  label: 'Toplam Vade',
                  value: '${widget.result.estimatedTerm} Ay',
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: Colors.white.withOpacity(0.15),
              ),
              Expanded(
                child: _resultDetail(
                  label: 'Ödeme Modeli',
                  value: widget.plan.increaseModel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultDetail({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: value.length > 14 ? 12 : 14,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Bilgileri',
            style: TextStyle(
              color: _navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(
            'Finansman Tutarı',
            _money(widget.plan.financeAmount),
          ),
          _divider(),
          _infoRow('Peşinat', _money(widget.plan.downPayment)),
          _divider(),
          _infoRow(
            'Başlangıç Taksiti',
            _money(widget.plan.monthlyInstallment),
          ),
          _divider(),
          _infoRow(
            'Tahmini Teslim',
            '${widget.result.estimatedDelivery}. Ay',
            highlight: true,
          ),
          _divider(),
          _infoRow(
            'Tahmini Teslim Tarihi',
            _deliveryItem == null
                ? '-'
                : _longDateFormat.format(_deliveryItem!.paymentDate),
            highlight: true,
          ),
          _divider(),
          _infoRow(
            'Toplam Vade',
            '${widget.result.estimatedTerm} Ay',
          ),
          _divider(),
          _infoRow(
            'Ödeme Modeli',
            widget.plan.increaseModel,
          ),
          _divider(),
          _infoRow(
            'Organizasyon Ücreti',
            'Tahmini %7 – %8,5',
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _softTeal,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _turquoise.withOpacity(0.18),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: _teal,
                  size: 18,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Organizasyon ücreti; şirkete, kampanyaya ve sözleşme koşullarına göre değişebilir.',
                    style: TextStyle(
                      color: Color(0xFF506C72),
                      fontSize: 11,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPlanTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tüm Vade Ödeme Planı',
                style: TextStyle(
                  color: _navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Taksit ve birikim tutarlarını tek bakışta incele.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _softTeal,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            '${widget.result.estimatedTerm} AY',
            style: const TextStyle(
              color: _teal,
              fontSize: 10.5,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildTableHeader(),
            ...widget.result.paymentPlan.asMap().entries.map(
                  (entry) => _buildPaymentRow(
                    entry.value,
                    entry.key,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      color: _petrol,
      child: const Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              'Ay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              'Tarih',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Text(
              'Taksit',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 11,
            child: Text(
              'Toplam Birikim',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
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
    int index,
  ) {
    final bool isDelivery = item.isDeliveryMonth;
    final bool isLast = item.isLastMonth;

    final Color backgroundColor = isDelivery
        ? _deliveryBackground
        : isLast
            ? _lastBackground
            : index.isEven
                ? Colors.white
                : const Color(0xFFFAFCFD);

    final Color accentColor = isDelivery
        ? _turquoise
        : isLast
            ? _petrol
            : _teal;

    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: isDelivery ? 35 : 29,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '${item.month}',
                  style: TextStyle(
                    color: isDelivery ? _teal : _navy,
                    fontSize: isDelivery ? 14 : 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _paymentDateFormat.format(item.paymentDate),
                    maxLines: 1,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 11.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isDelivery || isLast) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isDelivery ? 'TESLİM AYI' : 'SON TAKSİT',
                      style: TextStyle(
                        color: isDelivery ? _teal : _petrol,
                        fontSize: 8.2,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _money(item.installment),
                maxLines: 1,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 11.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 11,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _money(item.totalSaving),
                maxLines: 1,
                style: TextStyle(
                  color: isDelivery ? _teal : _navy,
                  fontSize: 11.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryPdfButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _isCreatingPdf ? null : _saveToDevice,
        icon: _isCreatingPdf
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: _petrol,
                ),
              )
            : const Icon(
                Icons.picture_as_pdf_outlined,
                size: 21,
              ),
        label: Text(
          _isCreatingPdf ? 'PDF Hazırlanıyor...' : 'PDF Oluştur',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _turquoise,
          foregroundColor: _petrol,
          disabledBackgroundColor: _turquoise.withOpacity(0.62),
          disabledForegroundColor: _petrol.withOpacity(0.75),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    bool showProgress = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: showProgress
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _teal,
                ),
              )
            : Icon(icon, size: 21),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: _teal,
          side: const BorderSide(
            color: _teal,
            width: 1.2,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _teal,
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tasarruf Planım sonuçları tahmini ve bilgilendirme amaçlıdır. '
              'Kesin plan, sözleşme, organizasyon ücreti ve teslimat '
              'koşulları ilgili tasarruf finansman kuruluşu tarafından '
              'belirlenir.',
              style: TextStyle(
                color: Color(0xFF5E6D7E),
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: highlight ? _teal : _navy,
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: _border,
      ),
    );
  }
}
