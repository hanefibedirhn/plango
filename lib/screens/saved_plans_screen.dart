import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';
import '../models/saved_plan_model.dart';
import '../repositories/saved_plan_repository.dart';
import 'calculator_screen.dart';
import 'payment_plan_screen.dart';
import 'user_login_screen.dart';
import 'register_screen.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({
    super.key,
  });

  @override
  State<SavedPlansScreen> createState() =>
      _SavedPlansScreenState();
}

class _SavedPlansScreenState
    extends State<SavedPlansScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  final SavedPlanRepository _savedPlanRepository =
      SavedPlanRepository();

  final NumberFormat _currencyFormat =
      NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  String? _deletingPlanId;

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  DateTime _addMonthsClamped(
    DateTime baseDate,
    int monthsToAdd,
  ) {
    final int totalMonths =
        baseDate.year * 12 +
            baseDate.month -
            1 +
            monthsToAdd;

    final int targetYear =
        totalMonths ~/ 12;

    final int targetMonth =
        totalMonths % 12 + 1;

    final int lastDay =
        DateTime(
      targetYear,
      targetMonth + 1,
      0,
    ).day;

    final int targetDay =
        baseDate.day > lastDay
            ? lastDay
            : baseDate.day;

    return DateTime(
      targetYear,
      targetMonth,
      targetDay,
    );
  }

  Future<void> _confirmDelete(
    SavedPlan plan,
  ) async {
    final bool? shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Planı Sil',
            style: TextStyle(
              color: _navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Bu planı silmek istediğine emin misin? Bu işlem geri alınamaz.',
            style: TextStyle(
              color: _muted,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text(
                'Vazgeç',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFB42318),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Sil',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _deletePlan(plan);
  }

  Future<void> _deletePlan(
    SavedPlan plan,
  ) async {
    final User? user = _currentUser;

    if (user == null) {
      _showMessage(
        'Planı silmek için giriş yapman gerekir.',
      );
      return;
    }

    setState(() {
      _deletingPlanId = plan.id;
    });

    try {
      await _savedPlanRepository
          .deleteSavedPlan(
        userId: user.uid,
        planId: plan.id,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Plan başarıyla silindi.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Plan silinemedi. Lütfen tekrar deneyin.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingPlanId = null;
        });
      }
    }
  }

  Future<void> _openPlan(
    SavedPlan savedPlan,
  ) async {
    final CalculationPlan calculationPlan =
        CalculationPlan(
      financeAmount:
          savedPlan.financeAmount,
      downPayment:
          savedPlan.downPayment,
      monthlyInstallment:
          savedPlan.monthlyInstallment,
      increaseModel:
          savedPlan.increaseModel,
      estimatedDelivery:
          savedPlan.estimatedDelivery,
      estimatedTerm:
          savedPlan.estimatedTerm,
    );

    final DateTime fallbackStartDate =
        savedPlan.createdAt ??
            DateTime.now();

    final List<PaymentPlanItem> paymentPlan =
        savedPlan.paymentPlan.map(
      (item) {
        return PaymentPlanItem(
          month: item.month,
          paymentDate:
              item.paymentDate ??
                  _addMonthsClamped(
                    fallbackStartDate,
                    item.month - 1,
                  ),
          installment: item.installment,
          totalSaving: item.totalSaving,
          isDeliveryMonth:
              item.isDeliveryMonth,
          isLastMonth:
              item.isLastMonth,
        );
      },
    ).toList(
      growable: false,
    );

    final FpResult result =
        FpResult(
      success: true,
      estimatedTerm:
          savedPlan.estimatedTerm,
      estimatedDelivery:
          savedPlan.estimatedDelivery,
      lastInstallment:
          savedPlan.lastInstallment,
      totalPayment:
          savedPlan.totalPayment,
      paymentPlan: paymentPlan,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return PaymentPlanScreen(
            plan: calculationPlan,
            result: result,
          );
        },
      ),
    );
  }

  void _openCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CalculatorScreen(),
      ),
    );
  }

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const UserLoginScreen(),
      ),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const RegisterScreen(),
      ),
    );
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _relativeSavedDate(
    DateTime? date,
  ) {
    if (date == null) {
      return 'Kaydedilme tarihi hazırlanıyor';
    }

    final DateTime now =
        DateTime.now();

    final DateTime today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime savedDay =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    final int dayDifference =
        today
            .difference(savedDay)
            .inDays;

    if (dayDifference <= 0) {
      return 'Bugün kaydedildi';
    }

    if (dayDifference == 1) {
      return 'Dün kaydedildi';
    }

    if (dayDifference < 7) {
      return '$dayDifference gün önce kaydedildi';
    }

    if (dayDifference < 30) {
      final int week =
          (dayDifference / 7)
              .floor();

      return '$week hafta önce kaydedildi';
    }

    return DateFormat(
      'dd MMMM yyyy',
      'tr_TR',
    ).format(date);
  }

  DateTime? _deliveryDate(
    SavedPlan plan,
  ) {
    for (final SavedPaymentPlanItem item
        in plan.paymentPlan) {
      if (item.isDeliveryMonth &&
          item.paymentDate != null) {
        return item.paymentDate;
      }
    }

    return null;
  }

  String _deliveryText(
    SavedPlan plan,
  ) {
    final DateTime? date =
        _deliveryDate(plan);

    if (date == null) {
      return '${plan.estimatedDelivery} Ay';
    }

    return DateFormat(
      'MMM yyyy',
      'tr_TR',
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final User? user =
        _currentUser;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _navy,
        title: const Text(
          'Kayıtlı Planlarım',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: user == null
          ? _buildSignedOutState()
          : StreamBuilder<List<SavedPlan>>(
              stream: _savedPlanRepository
                  .watchSavedPlans(
                userId: user.uid,
              ),
              builder: (
                context,
                snapshot,
              ) {
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
                  return _buildErrorState();
                }

                final List<SavedPlan> plans =
                    snapshot.data ??
                        <SavedPlan>[];

                if (plans.isEmpty) {
                  return _buildEmptyState();
                }

                final List<SavedPlan> sortedPlans =
                    List<SavedPlan>.from(
                  plans,
                )
                      ..sort(
                        (
                          a,
                          b,
                        ) {
                          final DateTime aDate =
                              a.createdAt ??
                                  DateTime
                                      .fromMillisecondsSinceEpoch(
                                    0,
                                  );

                          final DateTime bDate =
                              b.createdAt ??
                                  DateTime
                                      .fromMillisecondsSinceEpoch(
                                    0,
                                  );

                          return bDate
                              .compareTo(
                            aDate,
                          );
                        },
                      );

                return RefreshIndicator(
                  color: _teal,
                  onRefresh: () async {
                    await Future<void>.delayed(
                      const Duration(
                        milliseconds: 400,
                      ),
                    );
                  },
                  child: ListView.separated(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      34,
                    ),
                    itemCount:
                        sortedPlans.length,
                    separatorBuilder:
                        (
                      context,
                      index,
                    ) {
                      return const SizedBox(
                        height: 12,
                      );
                    },
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      return _buildPlanCard(
                        sortedPlans[index],
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPlanCard(
    SavedPlan plan,
  ) {
    final bool isDeleting =
        _deletingPlanId ==
            plan.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.035,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        clipBehavior:
            Clip.antiAlias,
        child: InkWell(
          onTap: isDeleting
              ? null
              : () =>
                  _openPlan(plan),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              14,
              13,
              14,
              13,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE8F7F5,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .account_balance_wallet_outlined,
                        color: _teal,
                        size: 20,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Finansman Planı',
                            style:
                                TextStyle(
                              color: _navy,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            'Kaydettiğin plan',
                            style:
                                TextStyle(
                              color: _muted,
                              fontSize: 9.5,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isDeleting)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          color: _teal,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      PopupMenuButton<String>(
                        tooltip: 'Plan işlemleri',
                        color: Colors.white,
                        surfaceTintColor:
                            Colors.transparent,
                        icon: const Icon(
                          Icons
                              .more_horiz_rounded,
                          color: _muted,
                          size: 22,
                        ),
                        onSelected:
                            (value) {
                          if (value ==
                              'open') {
                            _openPlan(
                              plan,
                            );
                          }

                          if (value ==
                              'delete') {
                            _confirmDelete(
                              plan,
                            );
                          }
                        },
                        itemBuilder:
                            (context) {
                          return const [
                            PopupMenuItem(
                              value: 'open',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .arrow_forward_rounded,
                                    color:
                                        _teal,
                                    size: 19,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Devam Et',
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    color:
                                        Color(
                                      0xFFB42318,
                                    ),
                                    size: 19,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Planı Sil',
                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFFB42318,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  _currencyFormat.format(
                    plan.financeAmount,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: _navy,
                    fontSize: 22,
                    height: 1,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                const Text(
                  'Finansman Tutarı',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9.5,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _SavedPlanMetric(
                        label: 'Peşinat',
                        value:
                            _currencyFormat.format(
                          plan.downPayment,
                        ),
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child:
                          _SavedPlanMetric(
                        label: 'Aylık Taksit',
                        value:
                            _currencyFormat.format(
                          plan.monthlyInstallment,
                        ),
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child:
                          _SavedPlanMetric(
                        label:
                            'Tahmini Teslim',
                        value:
                            _deliveryText(
                          plan,
                        ),
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child:
                          _SavedPlanMetric(
                        label: 'Toplam Vade',
                        value:
                            '${plan.estimatedTerm} Ay',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 11,
                ),

                Container(
                  height: 38,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF4F8F9,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .history_rounded,
                        color: _muted,
                        size: 15,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Expanded(
                        child: Text(
                          _relativeSavedDate(
                            plan.createdAt,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: _muted,
                            fontSize: 9.5,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: isDeleting
                            ? null
                            : () =>
                                _openPlan(
                                  plan,
                                ),
                        style:
                            TextButton.styleFrom(
                          foregroundColor:
                              _teal,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          minimumSize:
                              const Size(
                            0,
                            30,
                          ),
                          tapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap,
                        ),
                        child:
                            const Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Text(
                              'Devam Et',
                              style:
                                  TextStyle(
                                fontSize:
                                    10.5,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Icon(
                              Icons
                                  .chevron_right_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 32,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFE8F7F5,
                ),
                borderRadius:
                    BorderRadius.circular(
                  26,
                ),
              ),
              child: const Icon(
                Icons
                    .bookmark_border_rounded,
                color: _teal,
                size: 38,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Henüz kayıtlı planın yok',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.25,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Bir plan oluşturduktan sonra ödeme planını kaydederek burada tekrar görüntüleyebilirsin.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.5,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              height: 44,
              child:
                  FilledButton.icon(
                onPressed:
                    _openCalculator,
                icon: const Icon(
                  Icons
                      .calculate_rounded,
                  size: 18,
                ),
                label:
                    const Text(
                  'Plan Oluştur',
                ),
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      _teal,
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  textStyle:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFFFEEEE,
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .cloud_off_outlined,
                color: Color(
                  0xFFB42318,
                ),
                size: 32,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Planların yüklenemedi',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            const Text(
              'İnternet bağlantını kontrol edip tekrar deneyebilirsin.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedOutState() {
    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 32,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFE8F7F5,
                ),
                borderRadius:
                    BorderRadius.circular(
                  26,
                ),
              ),
              child: const Icon(
                Icons
                    .lock_outline_rounded,
                color: _teal,
                size: 36,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Planlarına ulaşmak için giriş yap',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.25,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Kaydettiğin planları görüntülemek ve farklı cihazlarda hesabına erişmek için kullanıcı hesabınla giriş yapmalısın.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.5,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment:
                  WrapCrossAlignment.center,
              spacing: 4,
              children: [
                TextButton(
                  onPressed: _openLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: _teal,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Text(
                  '•',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: _openRegister,
                  style: TextButton.styleFrom(
                    foregroundColor: _teal,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPlanMetric
    extends StatelessWidget {
  const _SavedPlanMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit:
                BoxFit.scaleDown,
            alignment:
                Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF748193,
                ),
                fontSize: 8.5,
                height: 1.1,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          FittedBox(
            fit:
                BoxFit.scaleDown,
            alignment:
                Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF10243A,
                ),
                fontSize: 11,
                height: 1.1,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider
    extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 1,
      height: 32,
      color:
          const Color(
        0xFFE4E9EC,
      ),
    );
  }
}