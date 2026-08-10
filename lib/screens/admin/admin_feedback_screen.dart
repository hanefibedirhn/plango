import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() =>
      _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<_FeedbackFilter> _filters = const [
    _FeedbackFilter(
      key: 'all',
      label: 'Tümü',
    ),
    _FeedbackFilter(
      key: 'pending',
      label: 'Bekleyen',
    ),
    _FeedbackFilter(
      key: 'reviewing',
      label: 'İnceleniyor',
    ),
    _FeedbackFilter(
      key: 'answered',
      label: 'Yanıtlandı',
    ),
    _FeedbackFilter(
      key: 'closed',
      label: 'Kapatıldı',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _feedbackStream() {
    return _firestore
        .collection('feedbackRequests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.where((doc) {
      final data = doc.data();

      final status =
          (data['status'] ?? 'pending').toString().toLowerCase();

      final subject =
          (data['subject'] ?? '').toString().toLowerCase();

      final message =
          (data['message'] ?? '').toString().toLowerCase();

      final email =
          (data['userEmail'] ?? '').toString().toLowerCase();

      final type =
          (data['type'] ?? '').toString().toLowerCase();

      final query = _searchQuery.trim().toLowerCase();

      final matchesFilter =
          _selectedFilter == 'all' || status == _selectedFilter;

      final matchesSearch = query.isEmpty ||
          subject.contains(query) ||
          message.contains(query) ||
          email.contains(query) ||
          type.contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countByStatus(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String status,
  ) {
    return docs.where((doc) {
      final value =
          (doc.data()['status'] ?? 'pending').toString().toLowerCase();

      return value == status;
    }).length;
  }

  int _answeredCount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.where((doc) {
      final data = doc.data();

      final status =
          (data['status'] ?? 'pending').toString().toLowerCase();

      final reply = (data['adminReply'] ?? '').toString().trim();

      return status == 'answered' ||
          status == 'resolved' ||
          reply.isNotEmpty;
    }).length;
  }

  Future<void> _setStatus(
    String documentId,
    String status,
  ) async {
    await _firestore
        .collection('feedbackRequests')
        .doc(documentId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _markReviewing(
    String documentId,
  ) async {
    try {
      await _setStatus(documentId, 'reviewing');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Talep incelemeye alındı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Talep durumu güncellenirken bir hata oluştu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _closeRequest(
    String documentId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Talebi Kapat',
            style: TextStyle(
              color: _navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Bu talebi kapatmak istediğine emin misin?',
            style: TextStyle(
              color: _muted,
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
                backgroundColor: _navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _setStatus(documentId, 'closed');

      if (!mounted) return;

      Navigator.of(context).maybePop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Talep kapatıldı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Talep kapatılırken bir hata oluştu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showReplyDialog(
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final existingReply =
        (data['adminReply'] ?? '').toString().trim();

    final controller = TextEditingController(
      text: existingReply,
    );

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 560,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.reply_rounded,
                        color: _teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kullanıcıya Yanıt Ver',
                            style: TextStyle(
                              color: _navy,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Yanıt kullanıcının Taleplerim ekranında görünecek.',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 5,
                  maxLines: 9,
                  maxLength: 1500,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Kullanıcıya gönderilecek yanıtı yaz...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA6B2),
                    ),
                    filled: true,
                    fillColor: _background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _teal,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _navy,
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(
                            color: _border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Vazgeç',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final text = controller.text.trim();

                          if (text.isEmpty) return;

                          Navigator.pop(
                            dialogContext,
                            text,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          existingReply.isEmpty
                              ? 'Yanıtla'
                              : 'Yanıtı Güncelle',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) return;

    try {
      await _firestore
          .collection('feedbackRequests')
          .doc(documentId)
          .update({
        'adminReply': result.trim(),
        'status': 'answered',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Yanıt kullanıcıya iletildi.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Yanıt kaydedilirken bir hata oluştu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openDetail(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StreamBuilder<
            DocumentSnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('feedbackRequests')
              .doc(doc.id)
              .snapshots(),
          builder: (context, snapshot) {
            final data =
                snapshot.data?.data() ?? doc.data();

            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.65,
              maxChildSize: 0.96,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4DDE2),
                          borderRadius:
                              BorderRadius.circular(99),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            18,
                            18,
                            18,
                            34,
                          ),
                          children: [
                            _buildDetailHeader(data),
                            const SizedBox(height: 14),
                            _buildUserCard(data),
                            const SizedBox(height: 12),
                            _buildMessageCard(data),
                            if ((data['adminReply'] ?? '')
                                .toString()
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildReplyCard(data),
                            ],
                            const SizedBox(height: 18),
                            _buildDetailActions(
                              doc.id,
                              data,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailHeader(
    Map<String, dynamic> data,
  ) {
    final subject =
        (data['subject'] ?? 'Konu belirtilmedi').toString();

    final status =
        (data['status'] ?? 'pending').toString();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _navy,
            _petrol,
            Color(0xFF07585A),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: Color(0xFF55E2D0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Talep Detayı',
                      style: TextStyle(
                        color: Color(0xFFB7D8DA),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatusBadge(status: status),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    Map<String, dynamic> data,
  ) {
    final email =
        (data['userEmail'] ?? 'E-posta bulunamadı').toString();

    final type = _typeLabel(
      (data['type'] ?? '').toString(),
    );

    final createdAt = _formatTimestamp(
      data['createdAt'],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _whiteCardDecoration(),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Kullanıcı',
            value: email,
          ),
          const Divider(
            height: 24,
            color: _border,
          ),
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Talep Türü',
            value: type,
          ),
          const Divider(
            height: 24,
            color: _border,
          ),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Gönderim Tarihi',
            value: createdAt,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(
    Map<String, dynamic> data,
  ) {
    final message =
        (data['message'] ?? 'Mesaj bulunamadı').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: _teal,
                size: 19,
              ),
              SizedBox(width: 8),
              Text(
                'Kullanıcının Mesajı',
                style: TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(
    Map<String, dynamic> data,
  ) {
    final reply =
        (data['adminReply'] ?? '').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD3EBE7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_outlined,
                color: _teal,
                size: 19,
              ),
              SizedBox(width: 8),
              Text(
                'Plango Yanıtı',
                style: TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            reply,
            style: const TextStyle(
              color: Color(0xFF48636B),
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailActions(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final status =
        (data['status'] ?? 'pending').toString().toLowerCase();

    final hasReply =
        (data['adminReply'] ?? '').toString().trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status == 'pending')
          OutlinedButton.icon(
            onPressed: () async {
              await _markReviewing(documentId);
            },
            icon: const Icon(
              Icons.visibility_outlined,
            ),
            label: const Text(
              'İncelemeye Al',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(
                color: Color(0xFFB9DDD8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        if (status == 'pending')
          const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () {
            _showReplyDialog(
              documentId,
              data,
            );
          },
          icon: Icon(
            hasReply
                ? Icons.edit_note_rounded
                : Icons.reply_rounded,
          ),
          label: Text(
            hasReply
                ? 'Yanıtı Güncelle'
                : 'Kullanıcıya Yanıt Ver',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (status != 'closed') ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              _closeRequest(documentId);
            },
            icon: const Icon(
              Icons.archive_outlined,
            ),
            label: const Text(
              'Talebi Kapat',
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB42318),
              minimumSize: const Size.fromHeight(46),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: _border,
      ),
      boxShadow: [
        BoxShadow(
          color: _navy.withOpacity(.025),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'complaint':
        return 'Şikayet';

      case 'suggestion':
        return 'Öneri';

      case 'other':
        return 'Diğer';

      default:
        if (type.trim().isEmpty) {
          return 'Belirtilmedi';
        }

        return type;
    }
  }

  String _formatTimestamp(dynamic value) {
    if (value is! Timestamp) {
      return 'Tarih bilgisi yok';
    }

    final date = value.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.$year • $hour:$minute';
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
          'Şikayet & Öneri',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -.35,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _feedbackStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: _teal,
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          final visibleDocs = _filteredDocs(docs);

          final pending =
              _countByStatus(docs, 'pending');

          final reviewing =
              _countByStatus(docs, 'reviewing');

          final answered =
              _answeredCount(docs);

          return RefreshIndicator(
            color: _teal,
            onRefresh: () async {
              await Future<void>.delayed(
                const Duration(milliseconds: 450),
              );
            },
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                36,
              ),
              children: [
                _buildHeroCard(
                  total: docs.length,
                  pending: pending,
                ),
                const SizedBox(height: 16),
                _buildStats(
                  total: docs.length,
                  pending: pending,
                  reviewing: reviewing,
                  answered: answered,
                ),
                const SizedBox(height: 18),
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildFilters(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Talepler',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.2,
                        ),
                      ),
                    ),
                    Text(
                      '${visibleDocs.length} kayıt',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (visibleDocs.isEmpty)
                  _buildEmptyState()
                else
                  ...visibleDocs.map(
                    (doc) => _FeedbackRequestCard(
                      document: doc,
                      onTap: () {
                        _openDetail(doc);
                      },
                      formatDate: _formatTimestamp,
                      typeLabel: _typeLabel,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard({
    required int total,
    required int pending,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260B2239),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _turquoise.withOpacity(.14),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFF55E2D0)
                    .withOpacity(.24),
              ),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFF55E2D0),
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
                  'Kullanıcı Geri Bildirimleri',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pending > 0
                      ? '$pending talep yanıt veya inceleme bekliyor.'
                      : total > 0
                          ? 'Tüm talepler kontrol altında.'
                          : 'Henüz kullanıcı talebi bulunmuyor.',
                  style: const TextStyle(
                    color: Color(0xFFD7E6E8),
                    fontSize: 12,
                    height: 1.45,
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

  Widget _buildStats({
    required int total,
    required int pending,
    required int reviewing,
    required int answered,
  }) {
    return Row(
      children: [
        Expanded(
          child: _AdminStatCard(
            icon: Icons.inbox_outlined,
            value: total.toString(),
            label: 'Toplam',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AdminStatCard(
            icon: Icons.schedule_rounded,
            value: pending.toString(),
            label: 'Bekleyen',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AdminStatCard(
            icon: Icons.visibility_outlined,
            value: reviewing.toString(),
            label: 'İncelenen',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AdminStatCard(
            icon: Icons.task_alt_rounded,
            value: answered.toString(),
            label: 'Yanıtlanan',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: const TextStyle(
        color: _navy,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText:
            'Konu, e-posta veya mesaj içinde ara...',
        hintStyle: const TextStyle(
          color: Color(0xFF9AA6B2),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _teal,
          size: 21,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _teal,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final filter = _filters[index];

          final selected =
              _selectedFilter == filter.key;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedFilter = filter.key;
              });
            },
            borderRadius: BorderRadius.circular(99),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? _navy
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(99),
                border: Border.all(
                  color: selected
                      ? _navy
                      : _border,
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : _muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: _whiteCardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF9EB0B8),
            size: 42,
          ),
          SizedBox(height: 13),
          Text(
            'Talep bulunamadı',
            style: TextStyle(
              color: _navy,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Seçili filtre veya arama kriterine uygun kullanıcı talebi bulunmuyor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _whiteCardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB42318),
                size: 38,
              ),
              const SizedBox(height: 12),
              const Text(
                'Talepler yüklenemedi',
                style: TextStyle(
                  color: _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackRequestCard extends StatelessWidget {
  const _FeedbackRequestCard({
    required this.document,
    required this.onTap,
    required this.formatDate,
    required this.typeLabel,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>>
      document;

  final VoidCallback onTap;

  final String Function(dynamic) formatDate;

  final String Function(String) typeLabel;

  static const Color _navy = Color(0xFF0B2239);
  static const Color _teal = Color(0xFF087C72);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final subject =
        (data['subject'] ?? 'Konu belirtilmedi').toString();

    final email =
        (data['userEmail'] ?? 'E-posta yok').toString();

    final type =
        typeLabel((data['type'] ?? '').toString());

    final status =
        (data['status'] ?? 'pending').toString();

    final date =
        formatDate(data['createdAt']);

    final reply =
        (data['adminReply'] ?? '').toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFEAF7F5),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    type == 'Şikayet'
                        ? Icons.report_problem_outlined
                        : type == 'Öneri'
                            ? Icons.lightbulb_outline_rounded
                            : Icons.chat_bubble_outline_rounded,
                    color: _teal,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subject,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: _navy,
                                fontSize: 13.5,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(
                            status: status,
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 10.8,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          _MiniInfo(
                            icon:
                                Icons.category_outlined,
                            text: type,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniInfo(
                              icon:
                                  Icons.schedule_rounded,
                              text: date,
                            ),
                          ),
                          if (reply.isNotEmpty)
                            const Padding(
                              padding:
                                  EdgeInsets.only(left: 7),
                              child: Icon(
                                Icons
                                    .mark_chat_read_outlined,
                                color: _teal,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(top: 11),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9AA6B2),
                    size: 21,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    this.compact = false,
  });

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    late final String label;
    late final Color foreground;
    late final Color background;

    switch (normalized) {
      case 'reviewing':
        label = 'İnceleniyor';
        foreground = const Color(0xFF9A6700);
        background = const Color(0xFFFFF4D6);
        break;

      case 'answered':
      case 'resolved':
        label = 'Yanıtlandı';
        foreground = const Color(0xFF087C72);
        background = const Color(0xFFE7F7F4);
        break;

      case 'closed':
        label = 'Kapatıldı';
        foreground = const Color(0xFF667085);
        background = const Color(0xFFF0F2F4);
        break;

      default:
        label = 'Bekliyor';
        foreground = const Color(0xFFB54708);
        background = const Color(0xFFFFEEDB);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: compact ? 9.5 : 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4EBEE),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF087C72),
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0B2239),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF748193),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF087C72),
            size: 18,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF748193),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0B2239),
                  fontSize: 12.5,
                  height: 1.35,
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

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFF8A98A5),
          size: 13,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF748193),
              fontSize: 9.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackFilter {
  const _FeedbackFilter({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;
}