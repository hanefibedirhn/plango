import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/theme_controller.dart';
import 'account_screen.dart';
import 'user_login_screen.dart';
import 'register_screen.dart';
import 'legal_info_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'user_agreement_screen.dart';
import 'expert_agreement_screen.dart';
import 'feedback_screen.dart';

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

if (firebaseUser == null || firebaseUser.isAnonymous) {
  return const GuestProfileScreen();
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
      backgroundColor: Color(0xFFF7F9FB),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF087C72),
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
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
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
                    backgroundColor: const Color(0xFF087C72),
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
      backgroundColor: const Color(0xFF087C72),
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

class GuestProfileScreen extends StatelessWidget {
  const GuestProfileScreen({super.key});

  static const Color _navy = Color(0xFF0B2239);
  static const Color _teal = Color(0xFF087C72);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserLoginScreen(),
      ),
    );
  }

  Future<void> _openRegister(BuildContext context) async {
  final bool? accountCreated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const RegisterScreen(),
    ),
  );

  if (!context.mounted) {
    return;
  }

  if (accountCreated == true) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AccountRouterScreen(),
      ),
    );
  }
}

  void _openAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  void _openLegal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LegalInformationScreen()),
    );
  }

  void _openPrivacy(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PrivacyPolicyScreen(),
    ),
  );
}

  void _openUserAgreement(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const UserAgreementScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;
    final Color pageBackground = isDark
        ? const Color(0xFF0B141B)
        : _background;
    final Color surfaceColor = isDark
        ? const Color(0xFF111D25)
        : Colors.white;
    final Color primaryText = isDark
        ? const Color(0xFFEAF4F5)
        : _navy;
    final Color secondaryText = isDark
        ? const Color(0xFF9FB0BA)
        : _muted;
    final Color borderColor = isDark
        ? const Color(0xFF24323B)
        : _border;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: primaryText,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            36,
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16,
              ),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: _teal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Henüz giriş yapmadın',
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Planlarını kaydetmek ve hesabını yönetmek için giriş yapabilirsin.',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 11.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment:
                              WrapCrossAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                _openLogin(context);
                              },
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  color: _teal,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Text(
                              '•',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _openRegister(context);
                              },
                              child: const Text(
                                'Hesap Oluştur',
                                style: TextStyle(
                                  color: _teal,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'Görünüm',
              style: TextStyle(
                color: primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Material(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: PlangoThemeController.themeMode,
                  builder: (context, themeMode, _) {
                    final bool isDark =
                        themeMode == ThemeMode.dark;
                    final Color titleColor = isDark
                        ? const Color(0xFFEAF4F5)
                        : _navy;
                    final Color subtitleColor = isDark
                        ? const Color(0xFF9FB0BA)
                        : _muted;

                    return SwitchListTile.adaptive(
                      value: isDark,
                      onChanged:
                          PlangoThemeController.setDarkMode,
                      activeColor: _teal,
                      secondary: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF16343A)
                              : const Color(0xFFE8F7F5),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.dark_mode_outlined,
                          color: isDark
                              ? const Color(0xFF59D9C8)
                              : _teal,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Karanlık Mod',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        isDark
                            ? 'Karanlık tema etkin'
                            : 'Karanlık tema kapalı',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 10.5,
                        ),
                      ),
                    );
                  },
                ),
            ),
          ),

            const SizedBox(height: 22),

            Text(
              'Tasarruf Planım Hakkında',
              style: TextStyle(
                color: primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: Column(
                children: [
                  _GuestMenuTile(
                    icon: Icons.gavel_rounded,
                    title: 'Yasal Bilgilendirme',
                    onTap: () => _openLegal(context),
                  ),
                  _GuestMenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Hakkımızda',
                    onTap: () => _openAbout(context),
                  ),
                  _GuestMenuTile(
  icon: Icons.chat_bubble_outline_rounded,
  title: 'Şikayet ve Öneri',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FeedbackScreen(),
      ),
    );
  },
),
                  _GuestMenuTile(
                    icon: Icons.shield_outlined,
                    title: 'Gizlilik Politikası',
                    onTap: () => _openPrivacy(context),
                  ),
                  _GuestMenuTile(
  icon: Icons.description_outlined,
  title: 'Kullanıcı Sözleşmesi',
  showDivider: false,
  onTap: () => _openUserAgreement(context),
),
_GuestMenuTile(
  icon: Icons.workspace_premium_outlined,
  title: 'Uzman Sözleşmesi',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExpertAgreementScreen(),
      ),
    );
  },
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestMenuTile extends StatelessWidget {
  const _GuestMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;
    final Color primaryText = isDark
        ? const Color(0xFFEAF4F5)
        : GuestProfileScreen._navy;
    final Color dividerColor = isDark
        ? const Color(0xFF24323B)
        : GuestProfileScreen._border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: GuestProfileScreen._teal,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9AA7B1),
                    size: 20,
                  ),
                ],
              ),
            ),
            if (showDivider)
              Padding(
                padding: EdgeInsets.only(left: 63),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: dividerColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
