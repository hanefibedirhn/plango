import 'package:flutter/material.dart';

import '../../models/content_model.dart';
import '../../repositories/content_repository.dart';
import 'admin_content_form_screen.dart';

class AdminFeaturedListScreen extends StatefulWidget {
  const AdminFeaturedListScreen({super.key});

  @override
  State<AdminFeaturedListScreen> createState() =>
      _AdminFeaturedListScreenState();
}

class _AdminFeaturedListScreenState
    extends State<AdminFeaturedListScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  final ContentRepository _repository = ContentRepository();
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  _ContentFilter _selectedFilter = _ContentFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openNewContent() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AdminContentFormScreen(),
    ),
  );
}

  void _openEditContent(ContentModel content) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AdminContentFormScreen(
        content: content,
      ),
    ),
  );
}

  // ============================================================
  // FILTERS
  // ============================================================

  bool _matchesSearch(ContentModel content) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    return content.title.toLowerCase().contains(query) ||
        content.summary.toLowerCase().contains(query);
  }

  bool _matchesFilter(ContentModel content) {
    switch (_selectedFilter) {
      case _ContentFilter.all:
        return true;

      case _ContentFilter.published:
        return content.status == ContentStatus.published;

      case _ContentFilter.draft:
        return content.status == ContentStatus.draft;

      case _ContentFilter.archived:
        return content.status == ContentStatus.archived;
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  Future<void> _changeStatus(
    ContentModel content,
    ContentStatus status,
  ) async {
    try {
      await _repository.updateStatus(
        contentId: content.id,
        status: status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _statusSuccessMessage(status),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'İşlem tamamlanamadı: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _statusSuccessMessage(ContentStatus status) {
    switch (status) {
      case ContentStatus.published:
        return 'İçerik yayına alındı.';
      case ContentStatus.draft:
        return 'İçerik taslağa alındı.';
      case ContentStatus.archived:
        return 'İçerik arşivlendi.';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        surfaceTintColor: Colors.transparent,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewContent,
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(
          Icons.add_rounded,
          size: 21,
        ),
        label: const Text(
          'Yeni İçerik',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<List<ContentModel>>(
        stream: _repository.watchAdminContentsByType(
          ContentType.featured,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _teal,
              ),
            );
          }

          final contents =
              snapshot.data ?? const <ContentModel>[];

          final publishedCount = contents
              .where(
                (content) =>
                    content.status == ContentStatus.published,
              )
              .length;

          final draftCount = contents
              .where(
                (content) =>
                    content.status == ContentStatus.draft,
              )
              .length;

          final archivedCount = contents
              .where(
                (content) =>
                    content.status == ContentStatus.archived,
              )
              .length;

          final filteredContents = contents
              .where(_matchesFilter)
              .where(_matchesSearch)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              100,
            ),
            children: [
              _buildHeader(),

              const SizedBox(height: 16),

              _buildStatistics(
                publishedCount: publishedCount,
                draftCount: draftCount,
                archivedCount: archivedCount,
              ),

              const SizedBox(height: 22),

              _buildListHeader(
                visibleCount: filteredContents.length,
              ),

              const SizedBox(height: 10),

              _buildSearchField(),

              const SizedBox(height: 11),

              _buildFilters(),

              const SizedBox(height: 16),

              if (filteredContents.isEmpty)
                _buildEmptyState(contents.isEmpty)
              else
                ...filteredContents.map(
                  (content) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: _FeaturedContentCard(
                      content: content,
                      onTap: () {
                        _openEditContent(content);
                      },
                      onEdit: () {
                        _openEditContent(content);
                      },
                      onPublish: () {
                        _changeStatus(
                          content,
                          ContentStatus.published,
                        );
                      },
                      onDraft: () {
                        _changeStatus(
                          content,
                          ContentStatus.draft,
                        );
                      },
                      onArchive: () {
                        _changeStatus(
                          content,
                          ContentStatus.archived,
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        17,
        17,
        17,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _navy,
            _petrol,
            Color(0xFF07535A),
            _teal,
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _turquoise.withValues(
                alpha: 0.13,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF55E2D0).withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: Color(0xFF55E2D0),
              size: 26,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İçerik Yönetimi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Ana sayfadaki Öne Çıkanlar '
                  'içeriklerini yönetin.',
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
        ],
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics({
    required int publishedCount,
    required int draftCount,
    required int archivedCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _ContentStatCard(
            value: publishedCount,
            title: 'Yayında',
            icon: Icons.public_rounded,
            iconBackground: const Color(0xFFE7F6F3),
            iconColor: _teal,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _ContentStatCard(
            value: draftCount,
            title: 'Taslak',
            icon: Icons.edit_note_rounded,
            iconBackground: const Color(0xFFFFF4DF),
            iconColor: const Color(0xFFB87916),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _ContentStatCard(
            value: archivedCount,
            title: 'Arşiv',
            icon: Icons.inventory_2_outlined,
            iconBackground: const Color(0xFFF0F2F4),
            iconColor: const Color(0xFF65727D),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LIST HEADER
  // ============================================================

  Widget _buildListHeader({
    required int visibleCount,
  }) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'İçerikler',
            style: TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.25,
            ),
          ),
        ),
        Text(
          '$visibleCount içerik',
          style: const TextStyle(
            color: _muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

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
        hintText: 'İçerik ara...',
        hintStyle: const TextStyle(
          color: Color(0xFF9AA6B1),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _teal,
          size: 21,
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                ),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
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
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ContentFilterChip(
            title: 'Tümü',
            selected:
                _selectedFilter == _ContentFilter.all,
            onTap: () {
              setState(() {
                _selectedFilter = _ContentFilter.all;
              });
            },
          ),
          _ContentFilterChip(
            title: 'Yayında',
            selected:
                _selectedFilter ==
                    _ContentFilter.published,
            onTap: () {
              setState(() {
                _selectedFilter =
                    _ContentFilter.published;
              });
            },
          ),
          _ContentFilterChip(
            title: 'Taslak',
            selected:
                _selectedFilter ==
                    _ContentFilter.draft,
            onTap: () {
              setState(() {
                _selectedFilter =
                    _ContentFilter.draft;
              });
            },
          ),
          _ContentFilterChip(
            title: 'Arşiv',
            selected:
                _selectedFilter ==
                    _ContentFilter.archived,
            onTap: () {
              setState(() {
                _selectedFilter =
                    _ContentFilter.archived;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY / ERROR
  // ============================================================

  Widget _buildEmptyState(bool completelyEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            completelyEmpty
                ? Icons.article_outlined
                : Icons.manage_search_rounded,
            color: const Color(0xFF9AA6B1),
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            completelyEmpty
                ? 'Henüz içerik yok'
                : 'İçerik bulunamadı',
            style: const TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            completelyEmpty
                ? 'Yeni İçerik butonuyla ilk '
                    'Öne Çıkan içeriğini oluşturabilirsin.'
                : 'Arama kriterini veya seçili '
                    'filtreyi değiştirebilirsin.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF1D2CF),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB42318),
                size: 34,
              ),
              const SizedBox(height: 12),
              const Text(
                'İçerikler yüklenemedi',
                style: TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$error',
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

// ============================================================
// FILTER
// ============================================================

enum _ContentFilter {
  all,
  published,
  draft,
  archived,
}

// ============================================================
// STAT CARD
// ============================================================

class _ContentStatCard extends StatelessWidget {
  const _ContentStatCard({
    required this.value,
    required this.title,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final int value;
  final String title;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        11,
        12,
        10,
        11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE4EBEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF0B2239),
              fontSize: 19,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
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

// ============================================================
// FILTER CHIP
// ============================================================

class _ContentFilterChip extends StatelessWidget {
  const _ContentFilterChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF0B2239)
                  : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: selected
                    ? const Color(0xFF0B2239)
                    : const Color(0xFFE4EBEE),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(0xFF647381),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CONTENT CARD
// ============================================================

class _FeaturedContentCard extends StatelessWidget {
  const _FeaturedContentCard({
    required this.content,
    required this.onTap,
    required this.onEdit,
    required this.onPublish,
    required this.onDraft,
    required this.onArchive,
  });

  final ContentModel content;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onDraft;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            14,
            13,
            8,
            13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFE4EBEE),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080B2239),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STATUS INDICATOR
              Container(
                width: 4,
                height: 62,
                decoration: BoxDecoration(
                  color: _statusColor(content.status),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBadge(
                      status: content.status,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0B2239),
                        fontSize: 13.5,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      content.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF748193),
                        fontSize: 10.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        const Icon(
                          Icons.sort_rounded,
                          size: 14,
                          color: Color(0xFF87939E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Öncelik ${content.priority}',
                          style: const TextStyle(
                            color: Color(0xFF87939E),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (content.viewCount > 0) ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: Color(0xFF87939E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${content.viewCount}',
                            style: const TextStyle(
                              color: Color(0xFF87939E),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<_ContentAction>(
                tooltip: 'İşlemler',
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF7F8C97),
                  size: 21,
                ),
                onSelected: (action) {
                  switch (action) {
                    case _ContentAction.edit:
                      onEdit();
                      break;

                    case _ContentAction.publish:
                      onPublish();
                      break;

                    case _ContentAction.draft:
                      onDraft();
                      break;

                    case _ContentAction.archive:
                      onArchive();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: _ContentAction.edit,
                      child: _MenuItem(
                        icon: Icons.edit_outlined,
                        title: 'Düzenle',
                      ),
                    ),

                    if (content.status !=
                        ContentStatus.published)
                      const PopupMenuItem(
                        value: _ContentAction.publish,
                        child: _MenuItem(
                          icon: Icons.public_rounded,
                          title: 'Yayına Al',
                        ),
                      ),

                    if (content.status !=
                        ContentStatus.draft)
                      const PopupMenuItem(
                        value: _ContentAction.draft,
                        child: _MenuItem(
                          icon: Icons.edit_note_rounded,
                          title: 'Taslağa Al',
                        ),
                      ),

                    if (content.status !=
                        ContentStatus.archived)
                      const PopupMenuItem(
                        value: _ContentAction.archive,
                        child: _MenuItem(
                          icon: Icons.inventory_2_outlined,
                          title: 'Arşivle',
                        ),
                      ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _statusColor(
    ContentStatus status,
  ) {
    switch (status) {
      case ContentStatus.published:
        return const Color(0xFF087C72);

      case ContentStatus.draft:
        return const Color(0xFFCA8216);

      case ContentStatus.archived:
        return const Color(0xFF7B8792);
    }
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final ContentStatus status;

  @override
  Widget build(BuildContext context) {
    late final String title;
    late final Color background;
    late final Color foreground;

    switch (status) {
      case ContentStatus.published:
        title = 'YAYINDA';
        background = const Color(0xFFE7F6F3);
        foreground = const Color(0xFF087C72);
        break;

      case ContentStatus.draft:
        title = 'TASLAK';
        background = const Color(0xFFFFF4DF);
        foreground = const Color(0xFFAE7017);
        break;

      case ContentStatus.archived:
        title = 'ARŞİV';
        background = const Color(0xFFF0F2F4);
        foreground = const Color(0xFF65727D);
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: foreground,
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.35,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MENU
// ============================================================

enum _ContentAction {
  edit,
  publish,
  draft,
  archive,
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xFF087C72),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0B2239),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}