import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';
import '../models/saved_plan_model.dart';

class SavedPlanNotFoundException
    implements Exception {
  const SavedPlanNotFoundException();

  @override
  String toString() {
    return 'Kayıtlı plan bulunamadı.';
  }
}

class SavedPlanRepository {
  SavedPlanRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ??
                FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      _savedPlansCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savedPlans');
  }

  Future<bool> savePlan({
    required String userId,
    required CalculationPlan plan,
    required FpResult result,
  }) async {
    final String documentId =
        _createDocumentId(plan);

    final DocumentReference<
        Map<String, dynamic>> reference =
        _savedPlansCollection(userId).doc(
      documentId,
    );

    final DocumentSnapshot<
        Map<String, dynamic>>
        existingDocument =
        await reference.get();

    if (existingDocument.exists) {
      return false;
    }

    await reference.set({
      'userId': userId,
      'financeAmount': plan.financeAmount,
      'downPayment': plan.downPayment,
      'monthlyInstallment':
          plan.monthlyInstallment,
      'increaseModel': plan.increaseModel,
      'estimatedDelivery':
          result.estimatedDelivery,
      'estimatedTerm':
          result.estimatedTerm,
      'lastInstallment':
          result.lastInstallment,
      'totalPayment': result.totalPayment,
      'paymentPlan':
          result.paymentPlan.map((item) {
        return {
          'month': item.month,
          'installment': item.installment,
          'totalSaving': item.totalSaving,
          'isDeliveryMonth':
              item.isDeliveryMonth,
          'isLastMonth': item.isLastMonth,
        };
      }).toList(),
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    return true;
  }

  Stream<List<SavedPlan>> watchSavedPlans({
    required String userId,
  }) {
    return _savedPlansCollection(userId)
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(SavedPlan.fromDocument)
          .toList();
    });
  }

  Future<SavedPlan> getSavedPlan({
    required String userId,
    required String planId,
  }) async {
    final DocumentSnapshot<
        Map<String, dynamic>> document =
        await _savedPlansCollection(userId)
            .doc(planId)
            .get();

    if (!document.exists ||
        document.data() == null) {
      throw const SavedPlanNotFoundException();
    }

    return SavedPlan.fromDocument(document);
  }

  Future<void> deleteSavedPlan({
    required String userId,
    required String planId,
  }) async {
    await _savedPlansCollection(userId)
        .doc(planId)
        .delete();
  }

  String _createDocumentId(
    CalculationPlan plan,
  ) {
    final String rawValue = [
      (plan.financeAmount * 100).round(),
      (plan.downPayment * 100).round(),
      (plan.monthlyInstallment * 100)
          .round(),
      plan.increaseModel.trim(),
      plan.estimatedDelivery,
      plan.estimatedTerm,
    ].join('_');

    return base64Url
        .encode(
          utf8.encode(rawValue),
        )
        .replaceAll('=', '');
  }
}