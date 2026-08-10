import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/content_model.dart';
import '../repositories/content_repository.dart';

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({
    super.key,
  });

  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Öne Çıkanlar',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: StreamBuilder<List<ContentModel>>(
        stream: ContentRepository().watchPublishedFeatured(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: _teal,
              ),
            );
          }

          if (snapshot.hasError) {
            return const _FeaturedState(
              icon: Icons.cloud_off_outlined,
              title: 'İçerikler yüklenemedi',
              description:
                  'İnternet bağlantını kontrol edip tekrar deneyebilirsin.',
              isError: true,
            );
          }

          final List<ContentModel> contents =
              snapshot.data ?? <ContentModel>[];

          if (contents.isEmpty) {
            return const _FeaturedState(
              icon: Icons.auto_awesome_outlined,
              title: 'Henüz öne çıkan içerik yok',
              description:
                  'Yeni içerikler yayınlandığında burada görüntülenecek.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              32,
            ),
            itemCount: contents.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _FeaturedCard(
                content: contents[index],
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
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  final ContentRepository _repository =
      ContentRepository();

  @override
  void initState() {
    super.initState();

    _repository
        .incrementViewCount(widget.content.id)
        .catchError((_) {});
  }

  Future<void> _openSource() async {
    final String? source =
        widget.content.sourceUrl;

    if (source == null ||
        source.trim().isEmpty) {
      return;
    }

    String cleanedUrl = source.trim();

    if (!cleanedUrl.startsWith('http://') &&
        !cleanedUrl.startsWith('https://')) {
      cleanedUrl = 'https://$cleanedUrl';
    }

    final Uri? uri =
        Uri.tryParse(cleanedUrl);

    if (uri == null) {
      _showMessage(
        'Kaynak bağlantısı geçerli değil.',
      );
      return;
    }

    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      _showMessage(
        'Kaynak bağlantısı açılamadı.',
      );
    }
  }

  void _showMessage(
    String message,
  ) {
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
    final ContentModel content =
        widget.content;

    final DateTime? date =
        content.publishDate ??
            content.createdAt;

    final bool hasCategory =
        content.category != null &&
            content.category!.trim().isNotEmpty;

    final bool hasSource =
        content.sourceUrl != null &&
            content.sourceUrl!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Öne Çıkanlar',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          36,
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(22),
              border: Border.all(
                color: _border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.035),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    17,
                  ),
                  decoration:
                      const BoxDecoration(
                    color: _petrol,
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(21),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      if (hasCategory)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: _turquoise
                                .withOpacity(0.14),
                            borderRadius:
                                BorderRadius.circular(
                              999,
                            ),
                            border: Border.all(
                              color: _turquoise
                                  .withOpacity(0.30),
                            ),
                          ),
                          child: Text(
                            content.category!
                                .trim(),
                            style:
                                const TextStyle(
                              color: Color(
                                0xFF76E3D4,
                              ),
                              fontSize: 10.5,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                      if (hasCategory)
                        const SizedBox(
                          height: 12,
                        ),
                      Text(
                        content.title,
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          height: 1.16,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      Wrap(
                        spacing: 14,
                        runSpacing: 7,
                        children: [
                          if (date != null)
                            _DetailMeta(
                              icon: Icons
                                  .calendar_today_outlined,
                              text: DateFormat(
                                'dd.MM.yyyy',
                              ).format(date),
                            ),
                          _DetailMeta(
                            icon: Icons
                                .visibility_outlined,
                            text:
                                '${content.viewCount + 1} görüntülenme',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),
                        decoration:
                            BoxDecoration(
                          color: const Color(
                            0xFFF2F8F8,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFDCECEB,
                            ),
                          ),
                        ),
                        child: Text(
                          content.summary,
                          style:
                              const TextStyle(
                            color: _navy,
                            fontSize: 14,
                            height: 1.55,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        content.body,
                        style:
                            const TextStyle(
                          color: Color(
                            0xFF24384A,
                          ),
                          fontSize: 14,
                          height: 1.72,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                      if (hasSource) ...[
                        const SizedBox(
                          height: 24,
                        ),
                        const Divider(
                          color: _border,
                          height: 1,
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openSource,
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: const Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons
                                        .open_in_new_rounded,
                                    color: _teal,
                                    size: 17,
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    'Kaynağı Görüntüle',
                                    style:
                                        TextStyle(
                                      color: _teal,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _FeaturedCard
    extends StatelessWidget {
  const _FeaturedCard({
    required this.content,
  });

  final ContentModel content;

  static const Color _navy =
      Color(0xFF0B2239);
  static const Color _petrol =
      Color(0xFF052F3D);
  static const Color _teal =
      Color(0xFF087C72);
  static const Color _muted =
      Color(0xFF748193);
  static const Color _border =
      Color(0xFFE4EBEE);

  @override
  Widget build(BuildContext context) {
    final DateTime? date =
        content.publishDate ??
            content.createdAt;

    final bool hasCategory =
        content.category != null &&
            content.category!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    FeaturedDetailScreen(
                  content: content,
                ),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              14,
              14,
              12,
              14,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFE8F7F5,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .auto_awesome_outlined,
                    color: _teal,
                    size: 21,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      if (hasCategory) ...[
                        Text(
                          content.category!
                              .trim(),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: _teal,
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                      Text(
                        content.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color: _navy,
                          fontSize: 14,
                          height: 1.25,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: -0.15,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        content.summary,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          height: 1.4,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                      if (date != null) ...[
                        const SizedBox(
                          height: 9,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .calendar_today_outlined,
                              size: 12,
                              color: _muted,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              DateFormat(
                                'dd.MM.yyyy',
                              ).format(date),
                              style:
                                  const TextStyle(
                                color: _muted,
                                fontSize: 9.5,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                const Padding(
                  padding:
                      EdgeInsets.only(top: 10),
                  child: Icon(
                    Icons
                        .chevron_right_rounded,
                    color: _petrol,
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

class _DetailMeta
    extends StatelessWidget {
  const _DetailMeta({
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
          color:
              Colors.white.withOpacity(0.68),
          size: 14,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: TextStyle(
            color:
                Colors.white.withOpacity(0.72),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeaturedState
    extends StatelessWidget {
  const _FeaturedState({
    required this.icon,
    required this.title,
    required this.description,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    const Color navy =
        Color(0xFF0B2239);
    const Color teal =
        Color(0xFF087C72);
    const Color muted =
        Color(0xFF748193);

    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 32,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration:
                  BoxDecoration(
                color: isError
                    ? const Color(
                        0xFFFFEEEE,
                      )
                    : const Color(
                        0xFFE8F7F5,
                      ),
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
              child: Icon(
                icon,
                color: isError
                    ? const Color(
                        0xFFB42318,
                      )
                    : teal,
                size: 34,
              ),
            ),
            const SizedBox(
              height: 17,
            ),
            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.25,
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Text(
              description,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.5,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
