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
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);

  final _formKey = GlobalKey<FormState>();

  final ContentRepository _repository =
      ContentRepository();

  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _bodyController = TextEditingController();
  final _categoryController = TextEditingController();
  final _sourceController = TextEditingController();
  final _priorityController =
      TextEditingController(text: '100');

  ContentStatus _selectedStatus =
      ContentStatus.draft;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final content = widget.content;

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

  Future<void> _saveContent() async {
    FocusScope.of(context).unfocus();

    if (_isSaving) {
      return;
    }

    final isFormValid =
        _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    final priority = int.tryParse(
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
      final oldContent = widget.content;

      DateTime? publishDate;

      if (_selectedStatus ==
          ContentStatus.published) {
        publishDate =
            oldContent?.publishDate ??
            DateTime.now();
      }

      final content = ContentModel(
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
    final cleanedValue = value.trim();

    if (cleanedValue.isEmpty) {
      return null;
    }

    return cleanedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'İçeriği Düzenle'
              : 'Yeni İçerik',
        ),
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Başlık zorunludur.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Özet',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Özet zorunludur.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Detay',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 6,
              maxLines: 10,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Detay zorunludur.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Kaynak Linki',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  TextInputType.url,
            ),
            const SizedBox(height: 20),
            const Text(
              'Durum',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<
                ContentStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ContentStatus.values
                  .map(
                    (status) =>
                        DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.displayName,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedStatus =
                            value;
                      });
                    },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _priorityController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Öncelik',
                helperText:
                    'Küçük sayı daha üst sırada görünür.',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final priority = int.tryParse(
                  value?.trim() ?? '',
                );

                if (priority == null ||
                    priority < 0) {
                  return 'Geçerli bir öncelik değeri gir.';
                }

                return null;
              },
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                minimumSize:
                    const Size.fromHeight(52),
              ),
              onPressed:
                  _isSaving ? null : _saveContent,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving
                    ? 'Kaydediliyor...'
                    : widget.isEditing
                        ? 'Değişiklikleri Kaydet'
                        : 'Kaydet',
              ),
            ),
          ],
        ),
      ),
    );
  }
}