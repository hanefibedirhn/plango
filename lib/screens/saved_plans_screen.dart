import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';
import '../models/saved_plan_model.dart';
import '../repositories/saved_plan_repository.dart';
import 'payment_plan_screen.dart';

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
  final SavedPlanRepository
      _savedPlanRepository =
      SavedPlanRepository();

  final NumberFormat _currencyFormat =
      NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  final DateFormat _dateFormat =
      DateFormat('dd.MM.yyyy');

  String? _deletingPlanId;

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  Future<void> _confirmDelete(
    SavedPlan plan,
  ) async {
    final bool? shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Planı Sil',
          ),
          content: const Text(
            'Bu planı silmek istediğinize '
            'emin misiniz? Bu işlem geri '
            'alınamaz.',
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
                    Colors.red.shade700,
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
        'Planı silmek için giriş yapmanız '
        'gerekir.',
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
        'Plan silinemedi. Lütfen tekrar '
        'deneyin.',
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

  final List<PaymentPlanItem> paymentPlan =
      savedPlan.paymentPlan.map((item) {
    return PaymentPlanItem(
      month: item.month,
      installment: item.installment,
      totalSaving: item.totalSaving,
      isDeliveryMonth:
          item.isDeliveryMonth,
      isLastMonth:
          item.isLastMonth,
    );
  }).toList(growable: false);

  final FpResult result = FpResult(
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

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kayıtlı Planlarım',
        ),
        centerTitle: true,
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
                        CircularProgressIndicator(),
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

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future<void>.delayed(
                      const Duration(
                        milliseconds: 500,
                      ),
                    );
                  },
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount: plans.length,
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
                      return _buildPlanCard(
                        plans[index],
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
        _deletingPlanId == plan.id;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(0.35),
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: isDeleting
            ? null
            : () => _openPlan(plan),
        child: Padding(
          padding:
              const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .account_balance_wallet_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Finansman Planı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          _currencyFormat.format(
                            plan.financeAmount,
                          ),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                Theme.of(context)
                                    .colorScheme
                                    .primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    enabled: !isDeleting,
                    onSelected: (value) {
                      if (value == 'detail') {
                        _openPlan(plan);
                      }

                      if (value == 'delete') {
                        _confirmDelete(plan);
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'detail',
                          child: Row(
                            children: [
                              Icon(
                                Icons
                                    .visibility_outlined,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Detayı Gör',
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
                                    .delete_outline,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Planı Sil',
                                style: TextStyle(
                                  color:
                                      Colors.red,
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
              const SizedBox(height: 18),
              _buildInformationRow(
                label: 'Başlangıç taksiti',
                value:
                    _currencyFormat.format(
                  plan.monthlyInstallment,
                ),
              ),
              const SizedBox(height: 10),
              _buildInformationRow(
                label: 'Peşinat',
                value:
                    _currencyFormat.format(
                  plan.downPayment,
                ),
              ),
              const SizedBox(height: 10),
              _buildInformationRow(
                label: 'Tahmini teslimat',
                value:
                    '${plan.estimatedDelivery}. ay',
              ),
              const SizedBox(height: 10),
              _buildInformationRow(
                label: 'Tahmini vade',
                value:
                    '${plan.estimatedTerm} ay',
              ),
              const SizedBox(height: 10),
              _buildInformationRow(
                label: 'Artış modeli',
                value:
                    plan.increaseModel.isEmpty
                        ? 'Belirtilmedi'
                        : plan.increaseModel,
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      plan.createdAt == null
                          ? 'Kaydedilme tarihi '
                              'hazırlanıyor'
                          : '${_dateFormat.format(plan.createdAt!)} tarihinde kaydedildi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (isDeleting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else
                    TextButton(
                      onPressed:
                          () => _openPlan(plan),
                      child: const Text(
                        'Detay',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .bookmark_border_rounded,
                size: 44,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Henüz kayıtlı planınız yok',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hesaplama yaptıktan sonra '
              'ödeme planınızı kaydederek '
              'buradan tekrar görüntüleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
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
            const EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 54,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Kayıtlı planlar yüklenemedi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'İnternet bağlantınızı kontrol '
              'edip tekrar deneyin.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedOutState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 56,
            ),
            SizedBox(height: 16),
            Text(
              'Kayıtlı planlarınızı görmek '
              'için kullanıcı hesabınızla '
              'giriş yapmanız gerekir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}