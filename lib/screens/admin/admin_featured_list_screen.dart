import 'package:flutter/material.dart';

import '../../models/content_model.dart';
import '../../repositories/content_repository.dart';
import 'admin_content_form_screen.dart';

class AdminFeaturedListScreen
    extends StatelessWidget {
  const AdminFeaturedListScreen({
    super.key,
  });

  static const Color _green =
      Color(0xFF0B5D3B);
  static const Color _background =
      Color(0xFFF7F8F5);
  static const Color _textDark =
      Color(0xFF111827);
  static const Color _textMuted =
      Color(0xFF6B7280);
  static const Color _border =
      Color(0xFFE5E7EB);
  static const Color _softGreen =
      Color(0xFFE8F1EC);

  @override
  Widget build(BuildContext context) {
    final repository = ContentRepository();

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
      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AdminContentFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni İçerik'),
      ),
      body: StreamBuilder<List<ContentModel>>(
        stream:
            repository.watchAdminContentsByType(
          ContentType.featured,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  'İçerikler alınamadı:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final contents =
              snapshot.data ?? [];

          if (contents.isEmpty) {
            return const _EmptyContentView();
          }

          return ListView.builder(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              100,
            ),
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final content =
                  contents[index];

              return _ContentCard(
                content: content,
                repository: repository,
              );
            },
          );
        },
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.content,
    required this.repository,
  });

  final ContentModel content;
  final ContentRepository repository;

  static const Color _green =
      Color(0xFF0B5D3B);
  static const Color _textDark =
      Color(0xFF111827);
  static const Color _textMuted =
      Color(0xFF6B7280);
  static const Color _border =
      Color(0xFFE5E7EB);
  static const Color _softGreen =
      Color(0xFFE8F1EC);

  Color get _statusColor {
    switch (content.status) {
      case ContentStatus.draft:
        return Colors.orange;
      case ContentStatus.published:
        return Colors.green;
      case ContentStatus.archived:
        return Colors.grey;
    }
  }

  Future<void> _openEditScreen(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminContentFormScreen(
          content: content,
        ),
      ),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    ContentStatus status,
  ) async {
    if (status == content.status) {
      return;
    }

    try {
      await repository.updateStatus(
        contentId: content.id,
        status: status,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'İçerik durumu '
              '"${status.displayName}" olarak güncellendi.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Durum değiştirilemedi: $error',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: _border,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: () =>
            _openEditScreen(context),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: _green,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 15,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      content.summary,
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color: _textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: _statusColor
                                .withOpacity(.12),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              999,
                            ),
                          ),
                          child: Text(
                            content.status
                                .displayName,
                            style: TextStyle(
                              color:
                                  _statusColor,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .blueGrey
                                .withOpacity(.10),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              999,
                            ),
                          ),
                          child: Text(
                            'Öncelik: '
                            '${content.priority}',
                            style:
                                const TextStyle(
                              color:
                                  Colors.blueGrey,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                tooltip: 'İşlemler',
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _openEditScreen(
                        context,
                      );
                      break;

                    case 'draft':
                      _changeStatus(
                        context,
                        ContentStatus.draft,
                      );
                      break;

                    case 'published':
                      _changeStatus(
                        context,
                        ContentStatus
                            .published,
                      );
                      break;

                    case 'archived':
                      _changeStatus(
                        context,
                        ContentStatus
                            .archived,
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(
                        Icons.edit_outlined,
                      ),
                      title: Text(
                        'Düzenle',
                      ),
                      contentPadding:
                          EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  _statusMenuItem(
                    status:
                        ContentStatus.draft,
                    icon:
                        Icons.edit_note_outlined,
                  ),
                  _statusMenuItem(
                    status:
                        ContentStatus
                            .published,
                    icon:
                        Icons.public_outlined,
                  ),
                  _statusMenuItem(
                    status:
                        ContentStatus
                            .archived,
                    icon:
                        Icons.archive_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _statusMenuItem({
    required ContentStatus status,
    required IconData icon,
  }) {
    final isSelected =
        content.status == status;

    return PopupMenuItem(
      value: status.value,
      enabled: !isSelected,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(
          status.displayName,
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check,
                color: _green,
              )
            : null,
      ),
    );
  }
}

class _EmptyContentView
    extends StatelessWidget {
  const _EmptyContentView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 64,
              color: Color(0xFF0B5D3B),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz içerik bulunmuyor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk Öne Çıkan içeriğini oluşturmak için '
              '"Yeni İçerik" butonunu kullan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}