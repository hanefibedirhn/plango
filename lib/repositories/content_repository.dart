import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/content_model.dart';

class ContentRepository {
  ContentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>
      get _contentCollection {
    return _firestore.collection('content');
  }

  CollectionReference<Map<String, dynamic>>
      get _notificationCollection {
    return _firestore.collection('notifications');
  }

  Stream<List<ContentModel>> watchAllContents() {
    return _contentCollection.snapshots().map((snapshot) {
      final contents = snapshot.docs
          .map(ContentModel.fromFirestore)
          .toList();

      contents.sort(_sortForAdmin);
      return contents;
    });
  }

  Stream<List<ContentModel>> watchAdminContentsByType(
    ContentType type,
  ) {
    return _contentCollection
        .where('type', isEqualTo: type.value)
        .snapshots()
        .map((snapshot) {
      final contents = snapshot.docs
          .map(ContentModel.fromFirestore)
          .toList();

      contents.sort(_sortForAdmin);
      return contents;
    });
  }

  Stream<List<ContentModel>> watchPublishedFeatured({
    int? limit,
  }) {
    return _watchPublishedContents(
      type: ContentType.featured,
      limit: limit,
    );
  }

  Stream<List<ContentModel>> watchPublishedCampaigns({
    int? limit,
  }) {
    return _watchPublishedContents(
      type: ContentType.campaign,
      limit: limit,
    );
  }

  Stream<List<ContentModel>> _watchPublishedContents({
    required ContentType type,
    int? limit,
  }) {
    return _contentCollection
        .where('type', isEqualTo: type.value)
        .where(
          'status',
          isEqualTo: ContentStatus.published.value,
        )
        .snapshots()
        .map((snapshot) {
      final contents = snapshot.docs
          .map(ContentModel.fromFirestore)
          .where((content) => content.isVisibleToUsers)
          .toList();

      contents.sort(_sortForUsers);

      if (limit != null && contents.length > limit) {
        return contents.take(limit).toList(growable: false);
      }

      return contents;
    });
  }

  Future<ContentModel?> getContentById(
    String contentId,
  ) async {
    final document =
        await _contentCollection.doc(contentId).get();

    if (!document.exists) {
      return null;
    }

    return ContentModel.fromFirestore(document);
  }

  Future<String> createContent(
    ContentModel content,
  ) async {
    _validateContent(content);

    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw StateError(
        'İçerik oluşturmak için yönetici oturumu gereklidir.',
      );
    }

    final document = _contentCollection.doc();

    final contentToCreate = content.copyWith(
      id: document.id,
      createdBy: currentUser.uid,
    );

    final WriteBatch batch = _firestore.batch();

    batch.set(
      document,
      contentToCreate.toFirestore(),
    );

    if (_shouldCreateFeaturedNotification(
      oldStatus: null,
      newContent: contentToCreate,
    )) {
      _addFeaturedNotificationToBatch(
        batch: batch,
        content: contentToCreate,
      );
    }

    await batch.commit();
    return document.id;
  }

  Future<void> updateContent(
    ContentModel content,
  ) async {
    if (content.id.trim().isEmpty) {
      throw ArgumentError(
        'Güncellenecek içerik kimliği bulunamadı.',
      );
    }

    _validateContent(content);

    final reference = _contentCollection.doc(content.id);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);

      if (!snapshot.exists) {
        throw StateError('Güncellenecek içerik bulunamadı.');
      }

      final oldContent =
          ContentModel.fromFirestore(snapshot);

      final data = content.toFirestore();
      data.remove('createdAt');

      transaction.update(reference, data);

      if (_shouldCreateFeaturedNotification(
        oldStatus: oldContent.status,
        newContent: content,
      )) {
        final notificationReference =
            _featuredNotificationReference(content.id);

        transaction.set(
          notificationReference,
          _featuredNotificationData(content),
        );
      }
    });
  }

  Future<void> updateStatus({
    required String contentId,
    required ContentStatus status,
  }) async {
    if (contentId.trim().isEmpty) {
      throw ArgumentError(
        'İçerik kimliği bulunamadı.',
      );
    }

    final reference = _contentCollection.doc(contentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);

      if (!snapshot.exists) {
        throw StateError('İçerik bulunamadı.');
      }

      final oldContent =
          ContentModel.fromFirestore(snapshot);

      final Map<String, dynamic> updates = {
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == ContentStatus.published) {
        updates['publishDate'] =
            FieldValue.serverTimestamp();
      } else {
        updates['publishDate'] = null;
      }

      transaction.update(reference, updates);

      if (oldContent.type == ContentType.featured &&
          oldContent.status != ContentStatus.published &&
          status == ContentStatus.published) {
        final notificationReference =
            _featuredNotificationReference(contentId);

        transaction.set(
          notificationReference,
          _featuredNotificationData(oldContent),
        );
      }
    });
  }

  Future<void> updatePriority({
    required String contentId,
    required int priority,
  }) async {
    if (contentId.trim().isEmpty) {
      throw ArgumentError(
        'İçerik kimliği bulunamadı.',
      );
    }

    if (priority < 0) {
      throw ArgumentError(
        'Öncelik değeri sıfırdan küçük olamaz.',
      );
    }

    await _contentCollection.doc(contentId).update({
      'priority': priority,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementViewCount(
    String contentId,
  ) async {
    if (contentId.trim().isEmpty) {
      return;
    }

    await _contentCollection.doc(contentId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  bool _shouldCreateFeaturedNotification({
    required ContentStatus? oldStatus,
    required ContentModel newContent,
  }) {
    return newContent.type == ContentType.featured &&
        newContent.status == ContentStatus.published &&
        oldStatus != ContentStatus.published;
  }

  DocumentReference<Map<String, dynamic>>
      _featuredNotificationReference(
    String contentId,
  ) {
    return _notificationCollection.doc(
      'featured_$contentId',
    );
  }

  Map<String, dynamic> _featuredNotificationData(
    ContentModel content,
  ) {
    final String notificationId =
        'featured_${content.id}';

    return {
      'notificationId': notificationId,
      'audience': 'all',
      'title': _notificationTitleFor(content),
      'message': content.title.trim(),
      'type': 'featured',
      'targetScreen': 'featured_detail',
      'targetId': content.id,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String _notificationTitleFor(
    ContentModel content,
  ) {
    final String category =
        content.category?.trim() ?? '';

    if (category.isEmpty) {
      return 'Yeni Bilgilendirme';
    }

    return 'Yeni $category Bilgilendirmesi';
  }

  void _addFeaturedNotificationToBatch({
    required WriteBatch batch,
    required ContentModel content,
  }) {
    batch.set(
      _featuredNotificationReference(content.id),
      _featuredNotificationData(content),
    );
  }

  void _validateContent(
    ContentModel content,
  ) {
    if (content.title.trim().isEmpty) {
      throw ArgumentError(
        'İçerik başlığı boş bırakılamaz.',
      );
    }

    if (content.summary.trim().isEmpty) {
      throw ArgumentError(
        'İçerik özeti boş bırakılamaz.',
      );
    }

    if (content.body.trim().isEmpty) {
      throw ArgumentError(
        'İçerik detayı boş bırakılamaz.',
      );
    }

    if (content.priority < 0) {
      throw ArgumentError(
        'Öncelik değeri sıfırdan küçük olamaz.',
      );
    }

    if (content.type == ContentType.campaign) {
      if (content.companyId == null ||
          content.companyId!.trim().isEmpty) {
        throw ArgumentError(
          'Kampanya için firma seçilmelidir.',
        );
      }

      if (content.companyName == null ||
          content.companyName!.trim().isEmpty) {
        throw ArgumentError(
          'Kampanya firma adı bulunamadı.',
        );
      }

      if (content.startDate == null) {
        throw ArgumentError(
          'Kampanya başlangıç tarihi seçilmelidir.',
        );
      }

      if (content.endDate == null) {
        throw ArgumentError(
          'Kampanya bitiş tarihi seçilmelidir.',
        );
      }

      if (content.endDate!.isBefore(
        content.startDate!,
      )) {
        throw ArgumentError(
          'Kampanya bitiş tarihi başlangıç tarihinden önce olamaz.',
        );
      }
    }
  }

  static int _sortForAdmin(
    ContentModel first,
    ContentModel second,
  ) {
    final firstDate =
        first.updatedAt ??
        first.createdAt ??
        first.publishDate ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final secondDate =
        second.updatedAt ??
        second.createdAt ??
        second.publishDate ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return secondDate.compareTo(firstDate);
  }

  static int _sortForUsers(
    ContentModel first,
    ContentModel second,
  ) {
    final priorityComparison =
        first.priority.compareTo(second.priority);

    if (priorityComparison != 0) {
      return priorityComparison;
    }

    final firstDate =
        first.publishDate ??
        first.createdAt ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final secondDate =
        second.publishDate ??
        second.createdAt ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return secondDate.compareTo(firstDate);
  }
}
