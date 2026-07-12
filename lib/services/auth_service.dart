import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = email.trim().toLowerCase();

    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForCode(error.code),
      );
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Hesap oluşturulurken beklenmeyen bir hata oluştu.',
      );
    }
  }

  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = email.trim().toLowerCase();

    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForCode(error.code),
      );
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Giriş yapılırken beklenmeyen bir hata oluştu.',
      );
    }
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    final String normalizedEmail = email.trim().toLowerCase();

    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: normalizedEmail,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForCode(error.code),
      );
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Şifre yenileme e-postası gönderilemedi.',
      );
    }
  }

  Future<void> rollbackNewlyCreatedUser() async {
  final User? user = _firebaseAuth.currentUser;

  if (user == null) {
    return;
  }

  try {
    await user.delete();
  } on FirebaseAuthException {
    await _firebaseAuth.signOut();
  } catch (_) {
    await _firebaseAuth.signOut();
  }
}

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForCode(error.code),
      );
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Çıkış yapılırken beklenmeyen bir hata oluştu.',
      );
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final User? user = _firebaseAuth.currentUser;

    if (user == null) {
      throw const AuthServiceException(
        code: 'user-not-found',
        message: 'Aktif kullanıcı oturumu bulunamadı.',
      );
    }

    final String? email = user.email;

    if (email == null || email.isEmpty) {
      throw const AuthServiceException(
        code: 'email-not-found',
        message: 'Kullanıcının e-posta bilgisi bulunamadı.',
      );
    }

    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForCode(error.code),
      );
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Şifre güncellenirken beklenmeyen bir hata oluştu.',
      );
    }
  }

  Future<void> reauthenticateCurrentUser({
  required String currentPassword,
}) async {
  final User? user = _firebaseAuth.currentUser;

  if (user == null) {
    throw const AuthServiceException(
      code: 'user-not-found',
      message: 'Aktif kullanıcı oturumu bulunamadı.',
    );
  }

  final String? email = user.email;

  if (email == null || email.isEmpty) {
    throw const AuthServiceException(
      code: 'email-not-found',
      message: 'Kullanıcının e-posta bilgisi bulunamadı.',
    );
  }

  try {
    final AuthCredential credential =
        EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
  } on FirebaseAuthException catch (error) {
    throw AuthServiceException(
      code: error.code,
      message: _messageForCode(error.code),
    );
  } catch (_) {
    throw const AuthServiceException(
      code: 'unknown',
      message:
          'Kimliğiniz doğrulanırken beklenmeyen bir hata oluştu.',
    );
  }
}

Future<void> deleteAuthenticatedUser() async {
  final User? user = _firebaseAuth.currentUser;

  if (user == null) {
    throw const AuthServiceException(
      code: 'user-not-found',
      message: 'Aktif kullanıcı oturumu bulunamadı.',
    );
  }

  try {
    await user.delete();
  } on FirebaseAuthException catch (error) {
    throw AuthServiceException(
      code: error.code,
      message: _messageForCode(error.code),
    );
  } catch (_) {
    throw const AuthServiceException(
      code: 'unknown',
      message: 'Hesap silinirken beklenmeyen bir hata oluştu.',
    );
  }
}
  
  
  Future<void> deleteCurrentUser({
    required String currentPassword,
  }) async {
    final User? user = _firebaseAuth.currentUser;

    if (user == null) {
      throw const AuthServiceException(
        code: 'user-not-found',
        message: 'Aktif kullanıcı oturumu bulunamadı.',
      );
    }

    final String? email = user.email;

    if (email == null || email.isEmpty) {
      throw const AuthServiceException(
        code: 'email-not-found',
        message: 'Kullanıcının e-posta bilgisi bulunamadı.',
      );
    }

    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForCode(error.code),
      );
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Hesap silinirken beklenmeyen bir hata oluştu.',
      );
    }
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta adresiyle daha önce hesap oluşturulmuş.';

      case 'invalid-email':
        return 'Geçerli bir e-posta adresi giriniz.';

      case 'weak-password':
        return 'Şifreniz yeterince güçlü değil.';

      case 'user-not-found':
        return 'Bu bilgilerle eşleşen bir hesap bulunamadı.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';

      case 'user-disabled':
        return 'Bu hesap kullanıma kapatılmış.';

      case 'too-many-requests':
        return 'Çok fazla başarısız deneme yapıldı. Lütfen daha sonra tekrar deneyin.';

      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol ediniz.';

      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';

      case 'operation-not-allowed':
        return 'Bu giriş yöntemi şu anda kullanılamıyor.';

      default:
        return 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
    }
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  String toString() => message;
}