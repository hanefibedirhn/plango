import 'package:flutter/material.dart';

import '../../models/content_model.dart';
import '../../repositories/content_repository.dart';

class AdminContentFormScreen extends StatefulWidget {
  const AdminContentFormScreen({
    super.key,
    this.content,
  });

  final ContentModel? content;

  bool get isEditing => content != null;

  @override
  State<AdminContentFormScreen> createState() =>
      _AdminContentFormScreenState();
}

class _AdminContentFormScreenState
    extends State<AdminContentFormScreen> {
  // ============================================================
  // TASARRUF PLANIM DESIGN SYSTEM
  // ============================================================

  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);

  static const Color _background = Color(0xFFF7F9FB);
  static const Color _textMuted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final ContentRepository _repository =
      ContentRepository();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _summaryController =
      TextEditingController();

  final TextEditingController _bodyController =
      TextEditingController();

  final TextEditingController _categoryController =
      TextEditingController();

  final TextEditingController _sourceController =
      TextEditingController();

  final TextEditingController _priorityController =
      TextEditingController(
    text: '100',
  );

  ContentStatus _selectedStatus =
      ContentStatus.draft;

  bool _isSaving = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final ContentModel? content = widget.content;

    if (content == null) {
      return;
    }

    _titleController.text = content.title;
    _summaryController.text = content.summary;
    _bodyController.text = content.body;
    _categoryController.text =
        content.category ?? '';
    _sourceController.text =
        content.sourceUrl ?? '';
    _priorityController.text =
        content.priority.toString();

    _selectedStatus = content.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _bodyController.dispose();
    _categoryController.dispose();
    _sourceController.dispose();
    _priorityController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveContent() async {
    FocusScope.of(context).unfocus();

    if (_isSaving) {
      return;
    }

    final bool isFormValid =
        _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    final int? priority = int.tryParse(
      _priorityController.text.trim(),
    );

    if (priority == null || priority < 0) {
      _showMessage(
        'Öncelik sıfır veya daha büyük bir sayı olmalıdır.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final ContentModel? oldContent =
          widget.content;

      DateTime? publishDate;

      if (_selectedStatus ==
          ContentStatus.published) {
        publishDate =
            oldContent?.publishDate ??
                DateTime.now();
      }

      final ContentModel content =
          ContentModel(
        id: oldContent?.id ?? '',
        type:
            oldContent?.type ??
                ContentType.featured,
        status: _selectedStatus,
        title: _titleController.text.trim(),
        summary:
            _summaryController.text.trim(),
        body: _bodyController.text.trim(),
        category: _nullableText(
          _categoryController.text,
        ),
        sourceUrl: _nullableText(
          _sourceController.text,
        ),
        coverImageUrl:
            oldContent?.coverImageUrl,
        companyId: oldContent?.companyId,
        companyName:
            oldContent?.companyName,
        startDate: oldContent?.startDate,
        endDate: oldContent?.endDate,
        priority: priority,
        viewCount:
            oldContent?.viewCount ?? 0,
        publishDate: publishDate,
        createdAt: oldContent?.createdAt,
        updatedAt: oldContent?.updatedAt,
        createdBy: oldContent?.createdBy,
      );

      if (widget.isEditing) {
        await _repository.updateContent(
          content,
        );
      } else {
        await _repository.createContent(
          content,
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        widget.isEditing
            ? 'İçerik başarıyla güncellendi.'
            : 'İçerik başarıyla kaydedildi.',
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'İşlem tamamlanamadı: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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

  String? _nullableText(String value) {
    final String cleanedValue = value.trim();

    if (cleanedValue.isEmpty) {
      return null;
    }

    return cleanedValue;
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
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isEditing
              ? 'İçeriği Düzenle'
              : 'Yeni İçerik',
          style: const TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            36,
          ),
          children: [
            _buildHero(),

            const SizedBox(height: 22),

            const _FormSectionHeader(
              icon: Icons.article_outlined,
              title: 'İçerik Bilgileri',
              subtitle:
                  'Kullanıcıların göreceği temel içeriği oluşturun.',
            ),

            const SizedBox(height: 12),

            _FormCard(
              children: [
                _TasarrufPlanimTextField(
                  controller: _titleController,
                  label: 'Başlık',
                  hint:
                      'İçeriğin başlığını yazın',
                  icon:
                      Icons.title_rounded,
                  textCapitalization:
                      TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Başlık zorunludur.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                _TasarrufPlanimTextField(
                  controller:
                      _summaryController,
                  label: 'Özet',
                  hint:
                      'İçeriği kısa ve anlaşılır şekilde özetleyin',
                  icon:
                      Icons.short_text_rounded,
                  minLines: 3,
                  maxLines: 4,
                  textCapitalization:
                      TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Özet zorunludur.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                _TasarrufPlanimTextField(
                  controller:
                      _bodyController,
                  label: 'Detay',
                  hint:
                      'İçeriğin detaylarını yazın',
                  icon:
                      Icons.notes_rounded,
                  minLines: 7,
                  maxLines: 12,
                  alignLabelWithHint: true,
                  textCapitalization:
                      TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Detay zorunludur.';
                    }

                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            const _FormSectionHeader(
              icon: Icons.tune_rounded,
              title: 'Ek Bilgiler',
              subtitle:
                  'İçeriği sınıflandırın ve gerekiyorsa kaynak ekleyin.',
            ),

            const SizedBox(height: 12),

            _FormCard(
              children: [
                _TasarrufPlanimTextField(
                  controller:
                      _categoryController,
                  label: 'Kategori',
                  hint:
                      'Örn. Sektör, Bilgilendirme',
                  icon:
                      Icons.category_outlined,
                  textCapitalization:
                      TextCapitalization.words,
                ),

                const SizedBox(height: 15),

                _TasarrufPlanimTextField(
                  controller:
                      _sourceController,
                  label: 'Kaynak Linki',
                  hint:
                      'Kaynak bağlantısı varsa ekleyin',
                  icon:
                      Icons.link_rounded,
                  keyboardType:
                      TextInputType.url,
                ),
              ],
            ),

            const SizedBox(height: 22),

            const _FormSectionHeader(
              icon: Icons.public_rounded,
              title: 'Yayın Ayarları',
              subtitle:
                  'İçeriğin durumunu ve ana sayfadaki sırasını belirleyin.',
            ),

            const SizedBox(height: 12),

            _FormCard(
              children: [
                _buildStatusSelector(),

                const SizedBox(height: 18),

                _TasarrufPlanimTextField(
                  controller:
                      _priorityController,
                  label: 'Öncelik',
                  hint: '100',
                  icon:
                      Icons.format_list_numbered_rounded,
                  keyboardType:
                      TextInputType.number,
                  helperText:
                      'Küçük sayı, içeriği daha üst sırada gösterir.',
                  validator: (value) {
                    final int? priority =
                        int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (priority == null ||
                        priority < 0) {
                      return 'Geçerli bir öncelik değeri girin.';
                    }

                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 26),

            _buildSaveButton(),

            const SizedBox(height: 10),

            const _BottomInformation(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
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
              color:
                  _turquoise.withValues(
                alpha: 0.13,
              ),
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color:
                    const Color(0xFF55E2D0)
                        .withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: Icon(
  widget.isEditing
      ? Icons.edit_note_rounded
      : Icons.post_add_rounded,
  color: const Color(0xFF55E2D0),
  size: 27,
),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing
                      ? 'İçeriği Güncelle'
                      : 'Yeni Öne Çıkan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.isEditing
                      ? 'Yayındaki veya taslaktaki içeriğin bilgilerini düzenleyin.'
                      : 'Ana sayfada gösterilecek yeni bir içerik oluşturun.',
                  style: const TextStyle(
                    color:
                        Color(0xFFD5E5E7),
                    fontSize: 11,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w500,
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
  // STATUS SELECTOR
  // ============================================================

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Durum',
          style: TextStyle(
            color: _navy,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 9),

        Row(
          children: [
            Expanded(
              child: _StatusOption(
                title: 'Taslak',
                icon:
                    Icons.edit_note_rounded,
                selected:
                    _selectedStatus ==
                        ContentStatus.draft,
                onTap: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _selectedStatus =
                              ContentStatus.draft;
                        });
                      },
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _StatusOption(
                title: 'Yayında',
                icon:
                    Icons.public_rounded,
                selected:
                    _selectedStatus ==
                        ContentStatus.published,
                onTap: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _selectedStatus =
                              ContentStatus.published;
                        });
                      },
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _StatusOption(
                title: 'Arşiv',
                icon:
                    Icons.inventory_2_outlined,
                selected:
                    _selectedStatus ==
                        ContentStatus.archived,
                onTap: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _selectedStatus =
                              ContentStatus.archived;
                        });
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: FilledButton.icon(
        onPressed:
            _isSaving ? null : _saveContent,
        style: FilledButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF9AA6B1),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(17),
          ),
          elevation: 0,
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                widget.isEditing
                    ? Icons.check_rounded
                    : Icons.add_rounded,
              ),
        label: Text(
          _isSaving
              ? 'Kaydediliyor...'
              : widget.isEditing
                  ? 'Değişiklikleri Kaydet'
                  : 'İçeriği Kaydet',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _FormSectionHeader extends StatelessWidget {
  const _FormSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color:
                const Color(0xFFE8F7F5),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color:
                const Color(0xFF087C72),
            size: 18,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color:
                      Color(0xFF0B2239),
                  fontSize: 14.5,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: const TextStyle(
                  color:
                      Color(0xFF748193),
                  fontSize: 10.5,
                  height: 1.35,
                  fontWeight:
                      FontWeight.w500,
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
// FORM CARD
// ============================================================

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFE4EBEE),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B2239),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// ============================================================
// TEXT FIELD
// ============================================================

class _TasarrufPlanimTextField
    extends StatelessWidget {
  const _TasarrufPlanimTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.helperText,
    this.alignLabelWithHint = false,
    this.textCapitalization =
        TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  final String? Function(String?)? validator;

  final int minLines;
  final int maxLines;

  final TextInputType? keyboardType;
  final String? helperText;
  final bool alignLabelWithHint;

  final TextCapitalization
      textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization:
          textCapitalization,
      style: const TextStyle(
        color: Color(0xFF0B2239),
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        alignLabelWithHint:
            alignLabelWithHint,
        labelStyle: const TextStyle(
          color: Color(0xFF657683),
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFA0ABB4),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: const TextStyle(
          color: Color(0xFF8A96A0),
          fontSize: 9.5,
          height: 1.3,
        ),
        prefixIcon: maxLines == 1
            ? Icon(
                icon,
                color:
                    const Color(0xFF087C72),
                size: 19,
              )
            : null,
        filled: true,
        fillColor:
            const Color(0xFFF9FBFC),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 14,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color:
                Color(0xFFE1E8EB),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color:
                Color(0xFF087C72),
            width: 1.4,
          ),
        ),
        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color:
                Color(0xFFB42318),
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color:
                Color(0xFFB42318),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STATUS OPTION
// ============================================================

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(14),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 160),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE8F7F5)
                : const Color(0xFFF8FAFB),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF8FD6CD)
                  : const Color(0xFFE1E8EB),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? const Color(0xFF087C72)
                    : const Color(0xFF87939E),
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF087C72)
                      : const Color(0xFF65727D),
                  fontSize: 10.5,
                  fontWeight:
                      FontWeight.w800,
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
// BOTTOM INFO
// ============================================================

class _BottomInformation
    extends StatelessWidget {
  const _BottomInformation();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: Color(0xFF87939E),
          size: 15,
        ),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            'Yayında durumundaki içerikler kullanıcı tarafında gösterilebilir.',
            style: TextStyle(
              color: Color(0xFF87939E),
              fontSize: 9.8,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}