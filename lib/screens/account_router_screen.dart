import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'account_screen.dart';
import 'login_selection_screen.dart';

class AccountRouterScreen extends StatelessWidget {
  AccountRouterScreen({super.key});

  final UserRepository _userRepository = UserRepository();

  ExpertApplicationStatus _mapExpertStatus(String status) {
    switch (status) {
      case 'pending':
        return ExpertApplicationStatus.pending;

      case 'rejected':
        return ExpertApplicationStatus.rejected;

      case 'approved':
        return ExpertApplicationStatus.approved;

      case 'none':
      default:
        return ExpertApplicationStatus.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _AccountLoadingScreen();
        }

        final User? firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          return const LoginSelectionScreen();
        }

        return StreamBuilder<AppUser?>(
          stream: _userRepository.watchUserById(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _AccountLoadingScreen();
            }

            if (userSnapshot.hasError) {
              return _AccountErrorScreen(
                message:
                    'Hesap bilgileriniz alınırken bir sorun oluştu.',
                onRetry: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountRouterScreen(),
                    ),
                  );
                },
              );
            }

            final AppUser? appUser = userSnapshot.data;

            if (appUser == null) {
  return _AccountErrorScreen(
    message:
        'Bu oturum için kullanıcı profili bulunamadı.',
    onSignOut: () async {
      await FirebaseAuth.instance.signOut();
    },
  );
}

            return AccountScreen(
              userName: appUser.fullName,
              expertStatus: _mapExpertStatus(
                appUser.expertStatus,
              ),
              isAdmin: appUser.isAdmin,
            );
          },
        );
      },
    );
  }
}

class _AccountLoadingScreen extends StatelessWidget {
  const _AccountLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F8F5),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0B5D3B),
        ),
      ),
    );
  }
}

class _AccountErrorScreen extends StatelessWidget {
  const _AccountErrorScreen({
    required this.message,
    this.onRetry,
    this.onSignOut,
  });

  final String message;
  final VoidCallback? onRetry;
  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F5),
        title: const Text(
          'Hesabım',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB42318),
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B5D3B),
                  ),
                  child: const Text('Tekrar Dene'),
                ),
              ],
              if (onSignOut != null) ...[
  const SizedBox(height: 18),
  FilledButton(
    onPressed: () async {
      await onSignOut!();
    },
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF0B5D3B),
    ),
    child: const Text('Oturumu Kapat'),
  ),
],
            ],
          ),
        ),
      ),
    );
  }
}