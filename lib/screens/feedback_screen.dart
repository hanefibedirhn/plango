import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/feedback_repository.dart';
import '../repositories/notification_repository.dart';

import 'register_screen.dart';
import 'user_login_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FeedbackRepository _feedbackRepository = FeedbackRepository();
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedType = 'Öneri';
  bool _isSending = false;

  final List<String> _types = const [
    'Öneri',
    'Şikayet',
    'Teknik Sorun',
    'Diğer',
  ];

  User? get _currentUser => _auth.currentUser;

  bool get _isLoggedIn {
  final user = _currentUser;
  return user != null && !user.isAnonymous;
}

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserLoginScreen(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _sendFeedback() async {
    final user = _currentUser;

    if (user == null || user.isAnonymous) {
  _showMessage('Talep göndermek için hesabınıza giriş yapmalısınız.');
  return;
}

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty) {
      _showMessage('Lütfen konu başlığını yazın.');
      return;
    }

    if (message.isEmpty) {
      _showMessage('Lütfen mesajınızı yazın.');
      return;
    }

    if (message.length < 10) {
      _showMessage('Mesajınız biraz daha açıklayıcı olmalıdır.');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final String feedbackId = await _feedbackRepository.createFeedback(
        userId: user.uid,
        userEmail: user.email ?? '',
        type: _selectedType,
        subject: subject,
        message: message,
      );

      // Talep başarıyla kaydedildikten sonra admine olay bildirimi oluştur.
      // Bildirim hatası kullanıcının gönderdiği talebi geçersiz kılmaz.
      try {
        await _notificationRepository.notifyAdminFeedback(
          feedbackId: feedbackId,
          feedbackType: _selectedType,
          actorUid: user.uid,
        );
      } on FirebaseException {
        // Yardımcı bildirim katmanı ana geri bildirim akışını bozmaz.
      }

      _subjectController.clear();
      _messageController.clear();

      if (!mounted) return;

      setState(() {
        _selectedType = 'Öneri';
      });

      _showMessage('Talebiniz başarıyla gönderildi.');
    } on FirebaseException catch (error) {
      _showMessage(
        error.message ?? 'Talep gönderilirken bir hata oluştu.',
      );
    } catch (_) {
      _showMessage('Talep gönderilirken bir hata oluştu.');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Şikayet ve Öneri',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          children: [
            const _FeedbackHeroCard(),

            const SizedBox(height: 16),

            if (!_isLoggedIn) ...[
              _buildGuestCard(),
            ] else ...[
              _buildNewRequestSection(),

              const SizedBox(height: 24),

              _buildSectionTitle(
                icon: Icons.history_rounded,
                title: 'Taleplerim',
              ),

              const SizedBox(height: 10),

              _buildMyRequests(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: _teal,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Talep oluşturmak için hesabınıza giriş yapın',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _navy,
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Giriş yaptıktan sonra şikayet, öneri veya teknik sorun '
            'talebi oluşturabilir; talebinizin durumunu ve Tasarruf Planım '
            'tarafından verilen cevabı buradan takip edebilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12.5,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _openLogin,
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: _openRegister,
            child: const Text(
              'Hesabınız yok mu? Hesap Oluştur',
              style: TextStyle(
                color: _teal,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewRequestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.add_comment_outlined,
          title: 'Yeni Talep',
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Talep Türü',
                style: TextStyle(
                  color: _navy,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 9),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((type) {
                  final selected = _selectedType == type;

                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    showCheckmark: false,
                    backgroundColor: const Color(0xFFF5F8F9),
                    selectedColor: const Color(0xFFE3F5F2),
                    side: BorderSide(
                      color: selected
                          ? _teal.withOpacity(.35)
                          : _border,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? _teal : _muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _subjectController,
                maxLength: 80,
                decoration: _inputDecoration(
                  label: 'Konu',
                  hint: 'Talebinizi kısaca özetleyin',
                  icon: Icons.subject_rounded,
                ),
              ),

              const SizedBox(height: 4),

              TextField(
                controller: _messageController,
                minLines: 5,
                maxLines: 8,
                maxLength: 1500,
                decoration: _inputDecoration(
                  label: 'Mesajınız',
                  hint:
                      'Şikayet, öneri veya yaşadığınız sorunu detaylı şekilde açıklayın.',
                  icon: Icons.edit_note_rounded,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: _teal,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Talebiniz Tasarruf Planım yönetim ekibine iletilir. '
                        'Yanıt verildiğinde cevabı Taleplerim bölümünden '
                        'görüntüleyebilirsiniz.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isSending ? null : _sendFeedback,
                  icon: _isSending
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          size: 18,
                        ),
                  label: Text(
                    _isSending ? 'Gönderiliyor...' : 'Talebi Gönder',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _teal.withOpacity(.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyRequests() {
    final user = _currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _feedbackRepository.watchUserFeedback(
        userId: user.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStateCard(
            icon: Icons.error_outline_rounded,
            title: 'Talepler yüklenemedi',
            message:
                'Talepleriniz görüntülenirken bir sorun oluştu.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: CircularProgressIndicator(
                color: _teal,
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _buildStateCard(
            icon: Icons.inbox_outlined,
            title: 'Henüz talebiniz yok',
            message:
                'Gönderdiğiniz şikayet, öneri ve diğer talepler burada görüntülenecek.',
          );
        }

        final sortedDocs = [...docs];

        sortedDocs.sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];

          if (aDate is Timestamp && bDate is Timestamp) {
            return bDate.compareTo(aDate);
          }

          return 0;
        });

        return Column(
          children: sortedDocs.map((doc) {
            return _buildRequestCard(
              doc.id,
              doc.data(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRequestCard(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final type = (data['type'] ?? 'Talep').toString();
    final subject = (data['subject'] ?? '').toString();
    final message = (data['message'] ?? '').toString();
    final status = (data['status'] ?? 'pending').toString();
    final adminReply = (data['adminReply'] ?? '').toString().trim();

    final createdAt = data['createdAt'];

    String dateText = 'Yeni';

    if (createdAt is Timestamp) {
      final date = createdAt.toDate();

      dateText =
          '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.'
          '${date.year}';
    }

    final statusInfo = _getStatusInfo(status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F5),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _typeIcon(type),
                    color: _teal,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.isEmpty ? type : subject,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 13.5,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$type • $dateText',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 10.5,
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
                    color: statusInfo.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusInfo.label,
                    style: TextStyle(
                      color: statusInfo.foreground,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            Text(
              message,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (adminReply.isNotEmpty) ...[
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8F7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD7ECE8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.support_agent_rounded,
                          color: _teal,
                          size: 17,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Tasarruf Planım Yanıtı',
                          style: TextStyle(
                            color: _navy,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      adminReply,
                      style: const TextStyle(
                        color: Color(0xFF48636B),
                        fontSize: 11.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: _teal,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 11.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: _teal,
          size: 18,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: true,
      prefixIcon: Icon(
        icon,
        color: _teal,
        size: 20,
      ),
      labelStyle: const TextStyle(
        color: _muted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFA0AAB4),
        fontSize: 11.5,
        height: 1.4,
      ),
      filled: true,
      fillColor: const Color(0xFFF9FBFC),
      counterStyle: const TextStyle(
        color: _muted,
        fontSize: 9,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _teal,
          width: 1.4,
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Şikayet':
        return Icons.report_problem_outlined;

      case 'Teknik Sorun':
        return Icons.build_outlined;

      case 'Diğer':
        return Icons.chat_bubble_outline_rounded;

      case 'Öneri':
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  _FeedbackStatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'answered':
      case 'resolved':
        return const _FeedbackStatusInfo(
          label: 'Yanıtlandı',
          foreground: Color(0xFF087C72),
          background: Color(0xFFE3F5F2),
        );

      case 'reviewing':
        return const _FeedbackStatusInfo(
          label: 'İnceleniyor',
          foreground: Color(0xFF8A5A00),
          background: Color(0xFFFFF3D6),
        );

      case 'closed':
        return const _FeedbackStatusInfo(
          label: 'Kapatıldı',
          foreground: Color(0xFF667085),
          background: Color(0xFFF0F2F4),
        );

      case 'pending':
      default:
        return const _FeedbackStatusInfo(
          label: 'Bekliyor',
          foreground: Color(0xFF175CD3),
          background: Color(0xFFEAF2FF),
        );
    }
  }
}

class _FeedbackHeroCard extends StatelessWidget {
  const _FeedbackHeroCard();

  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _navy,
            _petrol,
            Color(0xFF0C6268),
            _teal,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260B2239),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _turquoise.withOpacity(.16),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFF55E2D0).withOpacity(.28),
              ),
            ),
            child: const Icon(
              Icons.forum_outlined,
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
                  'Görüşünüz bizim için önemli',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Önerilerinizi, şikayetlerinizi ve karşılaştığınız '
                  'sorunları Tasarruf Planım ekibine iletebilirsiniz.',
                  style: TextStyle(
                    color: Color(0xFFD9E7E9),
                    fontSize: 12.3,
                    height: 1.5,
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
}

class _FeedbackStatusInfo {
  const _FeedbackStatusInfo({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}