import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/content_model.dart';
import '../repositories/content_repository.dart';

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({
    super.key,
  });

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Öne Çıkanlar',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<List<ContentModel>>(
        stream: ContentRepository().watchPublishedFeatured(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'İçerikler yüklenemedi.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final contents = snapshot.data ?? [];

          if (contents.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Şu anda yayınlanmış içerik bulunmuyor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final content = contents[index];

              return _FeaturedCard(
                content: content,
              );
            },
          );
        },
      ),
    );
  }
}

class FeaturedDetailScreen extends StatefulWidget {
  const FeaturedDetailScreen({
    super.key,
    required this.content,
  });

  final ContentModel content;

  @override
  State<FeaturedDetailScreen> createState() =>
      _FeaturedDetailScreenState();
}

class _FeaturedDetailScreenState
    extends State<FeaturedDetailScreen> {
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  final ContentRepository _repository = ContentRepository();

  @override
  void initState() {
    super.initState();

    _repository
        .incrementViewCount(widget.content.id)
        .catchError((_) {});
  }

  Future<void> _openSource() async {
    final source = widget.content.sourceUrl;

    if (source == null || source.trim().isEmpty) {
      return;
    }

    var cleanedUrl = source.trim();

    if (!cleanedUrl.startsWith('http://') &&
        !cleanedUrl.startsWith('https://')) {
      cleanedUrl = 'https://$cleanedUrl';
    }

    final uri = Uri.tryParse(cleanedUrl);

    if (uri == null) {
      _showMessage('Kaynak bağlantısı geçerli değil.');
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      _showMessage('Kaynak bağlantısı açılamadı.');
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

  @override
  Widget build(BuildContext context) {
    final content = widget.content;

    final date =
        content.publishDate ??
        content.createdAt;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'İçerik Detayı',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (content.category != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  content.category!,
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (content.category != null)
            const SizedBox(height: 16),
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 27,
              height: 1.2,
              fontWeight: FontWeight.w900,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (date != null) ...[
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 17,
                  color: _textMuted,
                ),
                const SizedBox(width: 7),
                Text(
                  DateFormat(
                    'dd.MM.yyyy',
                  ).format(date),
                  style: const TextStyle(
                    color: _textMuted,
                  ),
                ),
              ],
              if (date != null)
                const SizedBox(width: 18),
              const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: _textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                '${content.viewCount + 1} görüntülenme',
                style: const TextStyle(
                  color: _textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            content.summary,
            style: const TextStyle(
              fontSize: 17,
              height: 1.55,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 18),
          Text(
            content.body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.65,
              color: _textDark,
            ),
          ),
          if (content.sourceUrl != null) ...[
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: _openSource,
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(
                  color: _green,
                ),
              ),
              icon: const Icon(
                Icons.open_in_new,
              ),
              label: const Text(
                'Kaynağı Görüntüle',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.content,
  });

  final ContentModel content;

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final date =
        content.publishDate ??
        content.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  FeaturedDetailScreen(
                content: content,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F1),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: _green,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (content.category != null) ...[
                      Text(
                        content.category!,
                        style: const TextStyle(
                          color: _green,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      content.title,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      content.summary,
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMuted,
                        height: 1.4,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        DateFormat(
                          'dd.MM.yyyy',
                        ).format(date),
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}