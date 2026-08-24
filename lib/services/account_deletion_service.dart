import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../repositories/consultation_repository.dart';
import '../repositories/feedback_repository.dart';
import '../repositories/saved_plan_repository.dart';
import '../repositories/user_repository.dart';

class AccountDeletionService {
  AccountDeletionService({
    FirebaseAuth? auth,
    ConsultationRepository? consultationRepository,
    FeedbackRepository? feedbackRepository,
    SavedPlanRepository? savedPlanRepository,
    UserRepository? userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _consultationRepository =
            consultationRepository ?? ConsultationRepository(),
        _feedbackRepository =
            feedbackRepository ?? FeedbackRepository(),
        _savedPlanRepository =
            savedPlanRepository ?? SavedPlanRepository(),
        _userRepository =
            userRepository ?? UserRepository();

  final FirebaseAuth _auth;
  final ConsultationRepository _consultationRepository;
  final FeedbackRepository _feedbackRepository;
  final SavedPlanRepository _savedPlanRepository;
  final UserRepository _userRepository;

  /// Kullanıcının hesabını ve uygulama içinde kullanıcı kimliğine bağlı
  /// verilerini kontrollü bir sırayla temizler.
  ///
  /// Bu metot yeniden kimlik doğrulama yapmaz. Ekran mevcut şifre ile
  /// kullanıcıyı doğruladıktan sonra bu servisi çağırmalıdır.
  Future<void> deleteCurrentAccount() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'Silinecek oturum açmış kullanıcı bulunamadı.',
      );
    }

    debugPrint('========================================');
    debugPrint('ACCOUNT DELETE => START');
    debugPrint('ACCOUNT DELETE => UID: ${user.uid}');
    debugPrint(
      'ACCOUNT DELETE => ANONYMOUS: ${user.isAnonymous}',
    );
    debugPrint('========================================');

    if (user.isAnonymous) {
      try {
        debugPrint(
          'ACCOUNT DELETE => ANONYMOUS AUTH DELETE START',
        );

        await user.delete();

        debugPrint(
          'ACCOUNT DELETE => ANONYMOUS AUTH DELETE SUCCESS',
        );
        debugPrint('ACCOUNT DELETE => COMPLETE');
        return;
      } catch (error, stackTrace) {
        debugPrint(
          'ACCOUNT DELETE => ANONYMOUS AUTH DELETE ERROR',
        );
        debugPrint('ERROR => $error');
        debugPrint('STACKTRACE => $stackTrace');
        rethrow;
      }
    }

    final String uid = user.uid;

    try {
      debugPrint(
        'ACCOUNT DELETE => EXPERT CONSULTATION CLEANUP START',
      );

      await _consultationRepository.handleExpertAccountDeleted(
        expertId: uid,
      );

      debugPrint(
        'ACCOUNT DELETE => EXPERT CONSULTATION CLEANUP SUCCESS',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'ACCOUNT DELETE => EXPERT CONSULTATION CLEANUP ERROR',
      );
      debugPrint('ERROR => $error');
      debugPrint('STACKTRACE => $stackTrace');
      rethrow;
    }

    try {
      debugPrint(
        'ACCOUNT DELETE => USER CONSULTATION CLEANUP START',
      );

      await _consultationRepository.handleUserAccountDeleted(
        userId: uid,
      );

      debugPrint(
        'ACCOUNT DELETE => USER CONSULTATION CLEANUP SUCCESS',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'ACCOUNT DELETE => USER CONSULTATION CLEANUP ERROR',
      );
      debugPrint('ERROR => $error');
      debugPrint('STACKTRACE => $stackTrace');
      rethrow;
    }

    try {
      debugPrint(
        'ACCOUNT DELETE => FEEDBACK CLEANUP START',
      );

      await _feedbackRepository.deleteAllUserFeedback(
        userId: uid,
      );

      debugPrint(
        'ACCOUNT DELETE => FEEDBACK CLEANUP SUCCESS',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'ACCOUNT DELETE => FEEDBACK CLEANUP ERROR',
      );
      debugPrint('ERROR => $error');
      debugPrint('STACKTRACE => $stackTrace');
      rethrow;
    }

    try {
      debugPrint(
        'ACCOUNT DELETE => SAVED PLANS CLEANUP START',
      );

      await _savedPlanRepository.deleteAllSavedPlans(
        userId: uid,
      );

      debugPrint(
        'ACCOUNT DELETE => SAVED PLANS CLEANUP SUCCESS',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'ACCOUNT DELETE => SAVED PLANS CLEANUP ERROR',
      );
      debugPrint('ERROR => $error');
      debugPrint('STACKTRACE => $stackTrace');
      rethrow;
    }

    try {
      debugPrint(
        'ACCOUNT DELETE => USER PROFILE DELETE START',
      );

      await _userRepository.deleteUserProfile(
        uid: uid,
      );

      debugPrint(
        'ACCOUNT DELETE => USER PROFILE DELETE SUCCESS',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'ACCOUNT DELETE => USER PROFILE DELETE ERROR',
      );
      debugPrint('ERROR => $error');
      debugPrint('STACKTRACE => $stackTrace');
      rethrow;
    }

    try {
      debugPrint(
        'ACCOUNT DELETE => FIREBASE AUTH DELETE START',
      );

      await user.delete();

      debugPrint(
        'ACCOUNT DELETE => FIREBASE AUTH DELETE SUCCESS',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'ACCOUNT DELETE => FIREBASE AUTH DELETE ERROR',
      );
      debugPrint('ERROR => $error');
      debugPrint('STACKTRACE => $stackTrace');
      rethrow;
    }

    debugPrint('========================================');
    debugPrint('ACCOUNT DELETE => COMPLETE SUCCESS');
    debugPrint('========================================');
  }
}