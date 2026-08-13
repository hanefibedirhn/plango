import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/expert_application_model.dart';
import '../../models/user_model.dart';
import '../../repositories/expert_application_repository.dart';
import '../../repositories/expert_review_repository.dart';
import '../../repositories/user_repository.dart';

// ============================================================
// Tasarruf Planım ADMIN DESIGN SYSTEM
// ============================================================

class _AdminExpertColors {
  static const Color navy = Color(0xFF0B2239);
  static const Color petrol = Color(0xFF052F3D);
  static const Color teal = Color(0xFF087C72);
  static const Color turquoise = Color(0xFF16C7B0);

  static const Color background = Color(0xFFF7F9FB);
  static const Color card = Colors.white;

  static const Color textDark = Color(0xFF0B2239);
  static const Color textMuted = Color(0xFF748193);
  static const Color border = Color(0xFFE4EBEE);

  static const Color softTeal = Color(0xFFE8F7F5);
  static const Color warning = Color(0xFFB54708);
  static const Color softWarning = Color(0xFFFFF4E5);

  static const Color danger = Color(0xFFB42318);
  static const Color softDanger = Color(0xFFFFF0EF);
}

// ============================================================
// APPLICATION LIST
// ============================================================

class AdminExpertApplicationsScreen extends StatelessWidget {
  const AdminExpertApplicationsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ExpertApplicationRepository repository =
        ExpertApplicationRepository();

    return Scaffold(
      backgroundColor: _AdminExpertColors.background,
      appBar: AppBar(
        backgroundColor: _AdminExpertColors.background,
        foregroundColor: _AdminExpertColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Uzman Başvuruları',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ExpertApplication>>(
          stream: repository.watchPendingApplications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _ApplicationsLoadingView();
            }

            if (snapshot.hasError) {
              return _ApplicationsErrorView(
                message: _messageForError(snapshot.error),
              );
            }

            final List<ExpertApplication> applications =
                snapshot.data ?? const [];

            if (applications.isEmpty) {
              return const _EmptyApplicationsView();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                32,
              ),
              children: [
                _ApplicationsHero(
                  count: applications.length,
                ),

                const SizedBox(height: 24),

                _SectionHeader(
                  title: 'İnceleme Bekleyenler',
                  subtitle:
                      '${applications.length} uzman başvurusu karar bekliyor.',
                ),

                const SizedBox(height: 12),

                for (final application in applications)
                  _ApplicationListItem(
                    application: application,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminExpertApplicationDetailScreen(
                            application: application,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _messageForError(Object? error) {
    final String errorText = error.toString();

    if (errorText.contains('failed-precondition') ||
        errorText.contains('index')) {
      return 'Başvuruların listelenmesi için Firestore indeksi '
          'oluşturulması gerekiyor. Terminaldeki Firebase '
          'indeks bağlantısını açarak indeksi oluşturunuz.';
    }

    if (errorText.contains('permission-denied')) {
      return 'Bu bölümü görüntülemek için yönetici yetkisi gerekiyor.';
    }

    return 'Uzman başvuruları alınırken bir sorun oluştu.';
  }
}

// ============================================================
// LIST HERO
// ============================================================

class _ApplicationsHero extends StatelessWidget {
  const _ApplicationsHero({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        17,
        18,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _AdminExpertColors.navy,
            _AdminExpertColors.petrol,
            Color(0xFF07535A),
            _AdminExpertColors.teal,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B2239),
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _AdminExpertColors.turquoise
                  .withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF55E2D0)
                    .withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.how_to_reg_rounded,
              color: Color(0xFF55E2D0),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uzman Başvuruları',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Yeni uzmanlık ve profil güncelleme '
                  'başvurularını inceleyin.',
                  style: TextStyle(
                    color: Color(0xFFD5E5E7),
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            constraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _AdminExpertColors.softTeal,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.pending_actions_rounded,
            color: _AdminExpertColors.teal,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _AdminExpertColors.navy,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _AdminExpertColors.textMuted,
                  fontSize: 10.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// APPLICATION CARD
// ============================================================

class _ApplicationListItem extends StatelessWidget {
  const _ApplicationListItem({
    required this.application,
    required this.onTap,
  });

  final ExpertApplication application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser>(
      future: UserRepository().getUserById(
        application.uid,
      ),
      builder: (context, snapshot) {
        final AppUser? user = snapshot.data;

        final String name =
            user?.fullName.trim().isNotEmpty == true
                ? user!.fullName
                : snapshot.connectionState ==
                        ConnectionState.waiting
                    ? 'Yükleniyor...'
                    : 'Başvuru Sahibi';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _AdminExpertColors.border,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x070B2239),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _ApplicantAvatar(
                          name: name,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:
                                      _AdminExpertColors.navy,
                                  fontSize: 14.5,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                application.companyName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:
                                      _AdminExpertColors.teal,
                                  fontSize: 11.5,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ApplicationTypeBadge(
                          application: application,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFB),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: const Color(0xFFEDF1F3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MiniInformation(
                              icon: Icons.location_city_outlined,
                              label: 'Şube',
                              value: application.branch,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 31,
                            color: _AdminExpertColors.border,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniInformation(
                              icon: Icons.work_outline_rounded,
                              label: 'Pozisyon',
                              value: application.position,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: _AdminExpertColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _relativeDate(
                              application.createdAt,
                            ),
                            style: const TextStyle(
                              color:
                                  _AdminExpertColors.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Text(
                          'İncele',
                          style: TextStyle(
                            color: _AdminExpertColors.teal,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _AdminExpertColors.teal,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _relativeDate(DateTime date) {
    final Duration difference =
        DateTime.now().difference(date);

    if (difference.isNegative ||
        difference.inMinutes < 1) {
      return 'Az önce';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    }

    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

class _ApplicantAvatar extends StatelessWidget {
  const _ApplicantAvatar({
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    String initial = 'U';

    final String cleanName = name.trim();

    if (cleanName.isNotEmpty &&
        cleanName != 'Yükleniyor...' &&
        cleanName != 'Başvuru Sahibi') {
      initial = cleanName.substring(0, 1).toUpperCase();
    }

    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: _AdminExpertColors.softTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: _AdminExpertColors.teal,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ApplicationTypeBadge extends StatelessWidget {
  const _ApplicationTypeBadge({
    required this.application,
  });

  final ExpertApplication application;

  @override
  Widget build(BuildContext context) {
    final bool isUpdate =
        application.isProfileUpdateApplication;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isUpdate
            ? _AdminExpertColors.softWarning
            : _AdminExpertColors.softTeal,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isUpdate ? 'Değişiklik' : 'Yeni',
        style: TextStyle(
          color: isUpdate
              ? _AdminExpertColors.warning
              : _AdminExpertColors.teal,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniInformation extends StatelessWidget {
  const _MiniInformation({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: _AdminExpertColors.teal,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _AdminExpertColors.textMuted,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.trim().isEmpty ? '-' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _AdminExpertColors.navy,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DETAIL SCREEN
// ============================================================

class AdminExpertApplicationDetailScreen
    extends StatefulWidget {
  const AdminExpertApplicationDetailScreen({
    required this.application,
    super.key,
  });

  final ExpertApplication application;

  @override
  State<AdminExpertApplicationDetailScreen> createState() =>
      _AdminExpertApplicationDetailScreenState();
}

class _AdminExpertApplicationDetailScreenState
    extends State<AdminExpertApplicationDetailScreen> {
  final UserRepository _userRepository =
      UserRepository();

  final ExpertReviewRepository _reviewRepository =
      ExpertReviewRepository();

  AppUser? _applicant;

  bool _isLoadingUser = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadApplicant();
  }

  Future<void> _loadApplicant() async {
    try {
      final AppUser user =
          await _userRepository.getUserById(
        widget.application.uid,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _applicant = user;
        _isLoadingUser = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // APPROVE
  // ============================================================

  Future<void> _confirmApproval() async {
    if (_isProcessing) {
      return;
    }

    final String applicantName =
        _applicant?.fullName.trim().isNotEmpty == true
            ? _applicant!.fullName
            : 'Bu kullanıcı';

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _AdminExpertColors.softTeal,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: _AdminExpertColors.teal,
              size: 29,
            ),
          ),
          title: const Text(
            'Başvuruyu Onayla',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _AdminExpertColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            '$applicantName adlı kullanıcının '
            '${widget.application.companyName} uzmanlık '
            'başvurusunu onaylamak istediğinizden emin misiniz?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _AdminExpertColors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    _AdminExpertColors.navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _approveApplication();
  }

  Future<void> _approveApplication() async {
    final String? adminUid =
        FirebaseAuth.instance.currentUser?.uid;

    if (adminUid == null) {
      _showMessage(
        'Aktif yönetici oturumu bulunamadı.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _reviewRepository.approveApplication(
        application: widget.application,
        adminUid: adminUid,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Uzman başvurusu başarıyla onaylandı.',
      );

      Navigator.pop(context);
    } on ExpertReviewException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.message);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String message =
          error.toString().contains('permission-denied')
              ? 'Bu işlem için yönetici yetkisi gerekiyor.'
              : 'Başvuru onaylanırken bir sorun oluştu.';

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _showRejectDialog() async {
    if (_isProcessing) {
      return;
    }

    final TextEditingController noteController =
        TextEditingController();

    String? validationMessage;

    final String? reviewNote =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(22),
              ),
              icon: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color:
                      _AdminExpertColors.softDanger,
                  borderRadius:
                      BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: _AdminExpertColors.danger,
                  size: 29,
                ),
              ),
              title: const Text(
                'Başvuruyu Reddet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _AdminExpertColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Red nedeni kullanıcıya gösterilecektir. '
                    'Lütfen açıklayıcı bir bilgi yazınız.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          _AdminExpertColors.textMuted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 17),
                  TextField(
                    controller: noteController,
                    autofocus: true,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 300,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Red Nedeni',
                      hintText:
                          'Örn. Kurumsal e-posta doğrulanamadı.',
                      errorText: validationMessage,
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor:
                          const Color(0xFFF9FBFC),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color:
                              _AdminExpertColors.border,
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color:
                              _AdminExpertColors.teal,
                          width: 1.4,
                        ),
                      ),
                      errorBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color:
                              _AdminExpertColors.danger,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: () {
                    final String note =
                        noteController.text.trim();

                    if (note.length < 5) {
                      setDialogState(() {
                        validationMessage =
                            'En az 5 karakterlik bir açıklama yazınız.';
                      });
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      note,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _AdminExpertColors.danger,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reddet'),
                ),
              ],
            );
          },
        );
      },
    );

    noteController.dispose();

    if (reviewNote == null ||
        reviewNote.isEmpty ||
        !mounted) {
      return;
    }

    await _rejectApplication(reviewNote);
  }

  Future<void> _rejectApplication(
    String reviewNote,
  ) async {
    final String? adminUid =
        FirebaseAuth.instance.currentUser?.uid;

    if (adminUid == null) {
      _showMessage(
        'Aktif yönetici oturumu bulunamadı.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _reviewRepository.rejectApplication(
        application: widget.application,
        adminUid: adminUid,
        reviewNote: reviewNote,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Uzman başvurusu reddedildi.',
      );

      Navigator.pop(context);
    } on ExpertReviewException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.message);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String message =
          error.toString().contains('permission-denied')
              ? 'Bu işlem için yönetici yetkisi gerekiyor.'
              : 'Başvuru reddedilirken bir sorun oluştu.';

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD DETAIL
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ExpertApplication application =
        widget.application;

    final String applicantName = _isLoadingUser
        ? 'Kullanıcı bilgisi yükleniyor...'
        : (_applicant?.fullName.trim().isNotEmpty ==
                true
            ? _applicant!.fullName
            : 'Kullanıcı bulunamadı');

    return Scaffold(
      backgroundColor: _AdminExpertColors.background,
      appBar: AppBar(
        backgroundColor: _AdminExpertColors.background,
        foregroundColor: _AdminExpertColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Başvuru Detayı',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  28,
                ),
                children: [
                  _ApplicationDetailHero(
                    application: application,
                    applicantName: applicantName,
                  ),

                  const SizedBox(height: 22),

                  const _DetailSectionHeader(
                    icon: Icons.person_outline_rounded,
                    title: 'Başvuru Sahibi',
                  ),

                  const SizedBox(height: 10),

                  _DetailCard(
                    children: [
                      _DetailRow(
                        icon: Icons.badge_outlined,
                        label: 'Ad Soyad',
                        value: applicantName,
                      ),
                      _DetailDivider(),
                      _DetailRow(
                        icon:
                            Icons.alternate_email_rounded,
                        label: 'Kullanıcı Adı',
                        value:
                            _applicant?.email ?? '-',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const _DetailSectionHeader(
                    icon: Icons.apartment_rounded,
                    title: 'Kurumsal Bilgiler',
                  ),

                  const SizedBox(height: 10),

                  _DetailCard(
                    children: [
                      _DetailRow(
                        icon: Icons.apartment_rounded,
                        label: 'Şirket',
                        value: application.companyName,
                      ),
                      const _DetailDivider(),
                      _DetailRow(
                        icon:
                            Icons.location_city_outlined,
                        label: 'Şube',
                        value: application.branch,
                      ),
                      const _DetailDivider(),
                      _DetailRow(
                        icon:
                            Icons.work_outline_rounded,
                        label: 'Pozisyon',
                        value: application.position,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const _DetailSectionHeader(
                    icon: Icons.contact_mail_outlined,
                    title: 'İletişim Bilgileri',
                  ),

                  const SizedBox(height: 10),

                  _DetailCard(
                    children: [
                      _DetailRow(
                        icon:
                            Icons.mail_outline_rounded,
                        label: 'Kurumsal E-posta',
                        value:
                            application.corporateEmail,
                        selectable: true,
                      ),
                      const _DetailDivider(),
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Telefon',
                        value: application.phone,
                        selectable: true,
                      ),
                    ],
                  ),

                  if (application
                      .isProfileUpdateApplication) ...[
                    const SizedBox(height: 18),
                    const _DetailSectionHeader(
                      icon: Icons.history_rounded,
                      title: 'Önceki Uzman Bilgileri',
                    ),
                    const SizedBox(height: 10),
                    _PreviousInformationCard(
                      application: application,
                    ),
                  ],

                  const SizedBox(height: 18),

                  const _DetailSectionHeader(
                    icon: Icons.receipt_long_outlined,
                    title: 'Başvuru Bilgileri',
                  ),

                  const SizedBox(height: 10),

                  _DetailCard(
                    children: [
                      _DetailRow(
                        icon: Icons.schedule_rounded,
                        label: 'Başvuru Tarihi',
                        value: _formatDate(
                          application.createdAt,
                        ),
                      ),
                      const _DetailDivider(),
                      _DetailRow(
                        icon: Icons.tag_rounded,
                        label: 'Başvuru Kimliği',
                        value:
                            application.applicationId ??
                                '-',
                        selectable: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _ReviewActions(
              isProcessing: _isProcessing,
              onApprove: _confirmApproval,
              onReject: _showRejectDialog,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(date.day)}.'
        '${twoDigits(date.month)}.'
        '${date.year} '
        '${twoDigits(date.hour)}:'
        '${twoDigits(date.minute)}';
  }
}

// ============================================================
// DETAIL HERO
// ============================================================

class _ApplicationDetailHero extends StatelessWidget {
  const _ApplicationDetailHero({
    required this.application,
    required this.applicantName,
  });

  final ExpertApplication application;
  final String applicantName;

  @override
  Widget build(BuildContext context) {
    final bool isUpdate =
        application.isProfileUpdateApplication;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _AdminExpertColors.navy,
            _AdminExpertColors.petrol,
            Color(0xFF07535A),
            _AdminExpertColors.teal,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B2239),
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isUpdate
                  ? Icons.sync_alt_rounded
                  : Icons.person_add_alt_1_rounded,
              color: const Color(0xFF55E2D0),
              size: 27,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUpdate
                      ? 'Profil Güncelleme Başvurusu'
                      : 'İlk Uzmanlık Başvurusu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  applicantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD5E5E7),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Bekliyor',
              style: TextStyle(
                color: _AdminExpertColors.warning,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DETAIL COMPONENTS
// ============================================================

class _DetailSectionHeader extends StatelessWidget {
  const _DetailSectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _AdminExpertColors.softTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _AdminExpertColors.teal,
            size: 17,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: _AdminExpertColors.navy,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _AdminExpertColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x070B2239),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F3F5),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget = selectable
        ? SelectableText(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _AdminExpertColors.navy,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          )
        : Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _AdminExpertColors.navy,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8F8),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: _AdminExpertColors.teal,
              size: 16,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _AdminExpertColors.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: valueWidget,
          ),
        ],
      ),
    );
  }
}

class _PreviousInformationCard
    extends StatelessWidget {
  const _PreviousInformationCard({
    required this.application,
  });

  final ExpertApplication application;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      children: [
        _DetailRow(
          icon: Icons.apartment_outlined,
          label: 'Önceki Şirket',
          value:
              application.previousCompanyName ?? '-',
        ),
        const _DetailDivider(),
        _DetailRow(
          icon: Icons.location_city_outlined,
          label: 'Önceki Şube',
          value: application.previousBranch ?? '-',
        ),
        const _DetailDivider(),
        _DetailRow(
          icon: Icons.work_outline_rounded,
          label: 'Önceki Pozisyon',
          value:
              application.previousPosition ?? '-',
        ),
        const _DetailDivider(),
        _DetailRow(
          icon: Icons.mail_outline_rounded,
          label: 'Önceki E-posta',
          value:
              application.previousCorporateEmail ??
                  '-',
          selectable: true,
        ),
      ],
    );
  }
}

// ============================================================
// REVIEW ACTIONS
// ============================================================

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        11,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: _AdminExpertColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D0B2239),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
                  isProcessing ? null : onReject,
              icon: const Icon(
                Icons.close_rounded,
                size: 19,
              ),
              label: const Text('Reddet'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _AdminExpertColors.danger,
                side: const BorderSide(
                  color: Color(0xFFEAB4B1),
                ),
                minimumSize:
                    const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed:
                  isProcessing ? null : onApprove,
              icon: isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_rounded,
                      size: 19,
                    ),
              label: Text(
                isProcessing
                    ? 'İşleniyor...'
                    : 'Başvuruyu Onayla',
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    _AdminExpertColors.navy,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF9AA6B1),
                minimumSize:
                    const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _ApplicationsLoadingView
    extends StatelessWidget {
  const _ApplicationsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: _AdminExpertColors.teal,
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ApplicationsErrorView
    extends StatelessWidget {
  const _ApplicationsErrorView({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color:
                    _AdminExpertColors.softDanger,
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _AdminExpertColors.danger,
                size: 35,
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              'Başvurular Yüklenemedi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _AdminExpertColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    _AdminExpertColors.textMuted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyApplicationsView
    extends StatelessWidget {
  const _EmptyApplicationsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color:
                    _AdminExpertColors.softTeal,
                borderRadius:
                    BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: _AdminExpertColors.teal,
                size: 39,
              ),
            ),
            const SizedBox(height: 19),
            const Text(
              'Bekleyen Başvuru Yok',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _AdminExpertColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tüm uzman başvuruları incelenmiş durumda.\n'
              'Yeni bir başvuru geldiğinde burada otomatik olarak görünecek.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    _AdminExpertColors.textMuted,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}