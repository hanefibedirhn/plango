import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/expert_application_model.dart';
import '../../models/user_model.dart';
import '../../repositories/expert_application_repository.dart';
import '../../repositories/expert_review_repository.dart';
import '../../repositories/user_repository.dart';

class AdminExpertApplicationsScreen extends StatelessWidget {
  const AdminExpertApplicationsScreen({
    super.key,
  });

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _softGreen = Color(0xFFE8F1EC);
  static const Color _warning = Color(0xFFB54708);

  @override
  Widget build(BuildContext context) {
    final ExpertApplicationRepository repository =
        ExpertApplicationRepository();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Uzman Başvuruları',
          style: TextStyle(
            fontWeight: FontWeight.w900,
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
                18,
                10,
                18,
                32,
              ),
              children: [
                _PendingSummaryCard(
                  count: applications.length,
                ),
                const SizedBox(height: 20),
                const _SectionTitle(
                  title: 'İnceleme Bekleyenler',
                ),
                const SizedBox(height: 10),
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
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _danger = Color(0xFFB42318);
  static const Color _warning = Color(0xFFB54708);

  final UserRepository _userRepository = UserRepository();

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: const Icon(
            Icons.verified_outlined,
            color: _green,
            size: 38,
          ),
          title: const Text(
            'Başvuruyu Onayla',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            '$applicantName adlı kullanıcının '
            '${widget.application.companyName} uzmanlık '
            'başvurusunu onaylamak istediğinizden emin misiniz?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _green,
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

      final String message = error
              .toString()
              .contains('permission-denied')
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

  Future<void> _showRejectDialog() async {
    if (_isProcessing) {
      return;
    }

    final TextEditingController noteController =
        TextEditingController();

    String? validationMessage;

    final String? reviewNote = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              icon: const Icon(
                Icons.cancel_outlined,
                color: _danger,
                size: 38,
              ),
              title: const Text(
                'Başvuruyu Reddet',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                          'Örneğin kurumsal e-posta doğrulanamadı.',
                      errorText: validationMessage,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
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
                    backgroundColor: _danger,
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

      final String message = error
              .toString()
              .contains('permission-denied')
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

  @override
  Widget build(BuildContext context) {
    final ExpertApplication application =
        widget.application;

    final String applicantName =
        _isLoadingUser
            ? 'Kullanıcı bilgisi yükleniyor...'
            : (_applicant?.fullName.trim().isNotEmpty ==
                    true
                ? _applicant!.fullName
                : 'Kullanıcı bulunamadı');

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Başvuru Detayı',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  28,
                ),
                children: [
                  _ApplicationTypeHeader(
                    application: application,
                  ),
                  const SizedBox(height: 17),
                  _DetailCard(
                    title: 'Başvuru Sahibi',
                    children: [
                      _DetailRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Ad Soyad',
                        value: applicantName,
                      ),
                      _DetailRow(
                        icon: Icons.alternate_email_rounded,
                        label: 'Kullanıcı Adı',
                        value:
                            _applicant?.username ?? '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  _DetailCard(
                    title: 'Kurumsal Bilgiler',
                    children: [
                      _DetailRow(
                        icon: Icons.apartment_rounded,
                        label: 'Şirket',
                        value: application.companyName,
                      ),
                      _DetailRow(
                        icon:
                            Icons.location_city_outlined,
                        label: 'Şube',
                        value: application.branch,
                      ),
                      _DetailRow(
                        icon: Icons.work_outline_rounded,
                        label: 'Pozisyon',
                        value: application.position,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  _DetailCard(
                    title: 'İletişim Bilgileri',
                    children: [
                      _DetailRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Kurumsal E-posta',
                        value:
                            application.corporateEmail,
                        selectable: true,
                      ),
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
                    const SizedBox(height: 13),
                    _PreviousInformationCard(
                      application: application,
                    ),
                  ],
                  const SizedBox(height: 13),
                  _DetailCard(
                    title: 'Başvuru Bilgileri',
                    children: [
                      _DetailRow(
                        icon: Icons.schedule_rounded,
                        label: 'Başvuru Tarihi',
                        value: _formatDate(
                          application.createdAt,
                        ),
                      ),
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

class _PendingSummaryCard extends StatelessWidget {
  const _PendingSummaryCard({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AdminExpertApplicationsScreen._softGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.pending_actions_outlined,
              color: AdminExpertApplicationsScreen._green,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bekleyen Başvurular',
                  style: TextStyle(
                    color:
                        AdminExpertApplicationsScreen
                            ._textDark,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count başvuru inceleme bekliyor.',
                  style: const TextStyle(
                    color:
                        AdminExpertApplicationsScreen
                            ._textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AdminExpertApplicationsScreen._green,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AdminExpertApplicationsScreen._textDark,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

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
                : 'Başvuru Sahibi';

        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(19),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color:
                        AdminExpertApplicationsScreen
                            ._border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color:
                                  AdminExpertApplicationsScreen
                                      ._textDark,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _StatusBadge(
                          application: application,
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    _CompactInformation(
                      icon: Icons.apartment_rounded,
                      text: application.companyName,
                    ),
                    const SizedBox(height: 7),
                    _CompactInformation(
                      icon:
                          Icons.location_city_outlined,
                      text: application.branch,
                    ),
                    const SizedBox(height: 7),
                    _CompactInformation(
                      icon: Icons.work_outline_rounded,
                      text: application.position,
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 17,
                          color:
                              AdminExpertApplicationsScreen
                                  ._textMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _relativeDate(
                              application.createdAt,
                            ),
                            style: const TextStyle(
                              color:
                                  AdminExpertApplicationsScreen
                                      ._textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF9CA3AF),
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

    if (difference.isNegative) {
      return 'Az önce';
    }

    if (difference.inMinutes < 1) {
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.application,
  });

  final ExpertApplication application;

  @override
  Widget build(BuildContext context) {
    final bool isUpdate =
        application.isProfileUpdateApplication;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isUpdate
            ? const Color(0xFFFFF4E5)
            : AdminExpertApplicationsScreen._softGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isUpdate ? 'Değişiklik' : 'İlk Başvuru',
        style: TextStyle(
          color: isUpdate
              ? AdminExpertApplicationsScreen._warning
              : AdminExpertApplicationsScreen._green,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CompactInformation extends StatelessWidget {
  const _CompactInformation({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AdminExpertApplicationsScreen._green,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color:
                  AdminExpertApplicationsScreen._textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApplicationTypeHeader extends StatelessWidget {
  const _ApplicationTypeHeader({
    required this.application,
  });

  final ExpertApplication application;

  @override
  Widget build(BuildContext context) {
    final bool isUpdate =
        application.isProfileUpdateApplication;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isUpdate
            ? const Color(0xFFFFF4E5)
            : const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(
            isUpdate
                ? Icons.sync_alt_rounded
                : Icons.person_add_alt_1_outlined,
            color: isUpdate
                ? _AdminExpertApplicationDetailScreenState
                    ._warning
                : _AdminExpertApplicationDetailScreenState
                    ._green,
            size: 31,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isUpdate
                      ? 'Profil Güncelleme Başvurusu'
                      : 'İlk Uzmanlık Başvurusu',
                  style: const TextStyle(
                    color:
                        _AdminExpertApplicationDetailScreenState
                            ._textDark,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Durum: İnceleme Bekliyor',
                  style: TextStyle(
                    color:
                        _AdminExpertApplicationDetailScreenState
                            ._textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        17,
        16,
        17,
        7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              _AdminExpertApplicationDetailScreenState
                  ._border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color:
                  _AdminExpertApplicationDetailScreenState
                      ._textDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
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
              color:
                  _AdminExpertApplicationDetailScreenState
                      ._textDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          )
        : Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color:
                  _AdminExpertApplicationDetailScreenState
                      ._textDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                _AdminExpertApplicationDetailScreenState
                    ._green,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color:
                    _AdminExpertApplicationDetailScreenState
                        ._textMuted,
                fontSize: 13,
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

class _PreviousInformationCard extends StatelessWidget {
  const _PreviousInformationCard({
    required this.application,
  });

  final ExpertApplication application;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Önceki Uzman Bilgileri',
      children: [
        _DetailRow(
          icon: Icons.apartment_outlined,
          label: 'Önceki Şirket',
          value: application.previousCompanyName ?? '-',
        ),
        _DetailRow(
          icon: Icons.location_city_outlined,
          label: 'Önceki Şube',
          value: application.previousBranch ?? '-',
        ),
        _DetailRow(
          icon: Icons.work_outline_rounded,
          label: 'Önceki Pozisyon',
          value: application.previousPosition ?? '-',
        ),
        _DetailRow(
          icon: Icons.mail_outline_rounded,
          label: 'Önceki E-posta',
          value:
              application.previousCorporateEmail ?? '-',
          selectable: true,
        ),
      ],
    );
  }
}

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
        18,
        12,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
                  isProcessing ? null : onReject,
              icon: const Icon(
                Icons.close_rounded,
              ),
              label: const Text('Reddet'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _AdminExpertApplicationDetailScreenState
                        ._danger,
                side: const BorderSide(
                  color: Color(0xFFF2B8B5),
                ),
                minimumSize:
                    const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed:
                  isProcessing ? null : onApprove,
              icon: isProcessing
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_rounded,
                    ),
              label: Text(
                isProcessing
                    ? 'İşleniyor'
                    : 'Onayla',
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    _AdminExpertApplicationDetailScreenState
                        ._green,
                foregroundColor: Colors.white,
                minimumSize:
                    const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
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

class _ApplicationsLoadingView extends StatelessWidget {
  const _ApplicationsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AdminExpertApplicationsScreen._green,
      ),
    );
  }
}

class _ApplicationsErrorView extends StatelessWidget {
  const _ApplicationsErrorView({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
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
                color:
                    AdminExpertApplicationsScreen
                        ._textDark,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyApplicationsView extends StatelessWidget {
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
                    AdminExpertApplicationsScreen
                        ._softGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color:
                    AdminExpertApplicationsScreen
                        ._green,
                size: 41,
              ),
            ),
            const SizedBox(height: 19),
            const Text(
              'Bekleyen Başvuru Yok',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    AdminExpertApplicationsScreen
                        ._textDark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yeni uzman başvuruları geldiğinde '
              'bu ekranda otomatik olarak listelenecektir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    AdminExpertApplicationsScreen
                        ._textMuted,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}