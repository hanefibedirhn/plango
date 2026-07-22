import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType {
  featured,
  campaign,
}

extension ContentTypeExtension on ContentType {
  String get value {
    switch (this) {
      case ContentType.featured:
        return 'featured';
      case ContentType.campaign:
        return 'campaign';
    }
  }

  String get displayName {
    switch (this) {
      case ContentType.featured:
        return 'Öne Çıkan';
      case ContentType.campaign:
        return 'Kampanya';
    }
  }

  static ContentType fromValue(String? value) {
    switch (value) {
      case 'campaign':
        return ContentType.campaign;
      case 'featured':
      default:
        return ContentType.featured;
    }
  }
}

enum ContentStatus {
  draft,
  published,
  archived,
}

extension ContentStatusExtension on ContentStatus {
  String get value {
    switch (this) {
      case ContentStatus.draft:
        return 'draft';
      case ContentStatus.published:
        return 'published';
      case ContentStatus.archived:
        return 'archived';
    }
  }

  String get displayName {
    switch (this) {
      case ContentStatus.draft:
        return 'Taslak';
      case ContentStatus.published:
        return 'Yayında';
      case ContentStatus.archived:
        return 'Arşivde';
    }
  }

  static ContentStatus fromValue(String? value) {
    switch (value) {
      case 'published':
        return ContentStatus.published;
      case 'archived':
        return ContentStatus.archived;
      case 'draft':
      default:
        return ContentStatus.draft;
    }
  }
}

class ContentModel {
  const ContentModel({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.summary,
    required this.body,
    required this.priority,
    required this.viewCount,
    this.category,
    this.coverImageUrl,
    this.sourceUrl,
    this.companyId,
    this.companyName,
    this.publishDate,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  final String id;
  final ContentType type;
  final ContentStatus status;

  final String title;
  final String summary;
  final String body;

  final String? category;
  final String? coverImageUrl;
  final String? sourceUrl;

  final String? companyId;
  final String? companyName;

  final DateTime? publishDate;
  final DateTime? startDate;
  final DateTime? endDate;

  final int priority;
  final int viewCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  bool get isFeatured => type == ContentType.featured;

  bool get isCampaign => type == ContentType.campaign;

  bool get isDraft => status == ContentStatus.draft;

  bool get isPublished => status == ContentStatus.published;

  bool get isArchived => status == ContentStatus.archived;

  bool get isCampaignExpired {
    if (!isCampaign || endDate == null) {
      return false;
    }

    final campaignEnd = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      23,
      59,
      59,
    );

    return DateTime.now().isAfter(campaignEnd);
  }

  bool get hasCampaignStarted {
    if (!isCampaign || startDate == null) {
      return true;
    }

    final campaignStart = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
    );

    return !DateTime.now().isBefore(campaignStart);
  }

  bool get isVisibleToUsers {
    if (!isPublished) {
      return false;
    }

    if (publishDate != null &&
        publishDate!.isAfter(DateTime.now())) {
      return false;
    }

    if (isCampaign && !hasCampaignStarted) {
      return false;
    }

    if (isCampaignExpired) {
      return false;
    }

    return true;
  }

  factory ContentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return ContentModel(
      id: document.id,
      type: ContentTypeExtension.fromValue(
        data['type'] as String?,
      ),
      status: _readStatus(data),
      title: (data['title'] as String? ?? '').trim(),
      summary: (data['summary'] as String? ?? '').trim(),
      body: (data['body'] as String? ?? '').trim(),
      category: _nullableString(data['category']),
      coverImageUrl: _nullableString(data['coverImageUrl']),
      sourceUrl: _nullableString(data['sourceUrl']),
      companyId: _nullableString(data['companyId']),
      companyName: _nullableString(data['companyName']),
      publishDate: _dateFromFirestore(data['publishDate']),
      startDate: _dateFromFirestore(data['startDate']),
      endDate: _dateFromFirestore(data['endDate']),
      priority: _intFromFirestore(
        data['priority'],
        fallback: 100,
      ),
      viewCount: _intFromFirestore(data['viewCount']),
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
      createdBy: _nullableString(data['createdBy']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'type': type.value,
      'status': status.value,
      'title': title.trim(),
      'summary': summary.trim(),
      'body': body.trim(),
      'category': _cleanNullableString(category),
      'coverImageUrl': _cleanNullableString(coverImageUrl),
      'sourceUrl': _cleanNullableString(sourceUrl),
      'companyId': _cleanNullableString(companyId),
      'companyName': _cleanNullableString(companyName),
      'publishDate': publishDate == null
          ? null
          : Timestamp.fromDate(publishDate!),
      'startDate': startDate == null
          ? null
          : Timestamp.fromDate(startDate!),
      'endDate': endDate == null
          ? null
          : Timestamp.fromDate(endDate!),
      'priority': priority,
      'viewCount': viewCount,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': _cleanNullableString(createdBy),
    };
  }

  ContentModel copyWith({
    String? id,
    ContentType? type,
    ContentStatus? status,
    String? title,
    String? summary,
    String? body,
    String? category,
    String? coverImageUrl,
    String? sourceUrl,
    String? companyId,
    String? companyName,
    DateTime? publishDate,
    DateTime? startDate,
    DateTime? endDate,
    int? priority,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool clearCategory = false,
    bool clearCoverImageUrl = false,
    bool clearSourceUrl = false,
    bool clearCompany = false,
    bool clearPublishDate = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return ContentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      category: clearCategory ? null : category ?? this.category,
      coverImageUrl: clearCoverImageUrl
          ? null
          : coverImageUrl ?? this.coverImageUrl,
      sourceUrl:
          clearSourceUrl ? null : sourceUrl ?? this.sourceUrl,
      companyId:
          clearCompany ? null : companyId ?? this.companyId,
      companyName:
          clearCompany ? null : companyName ?? this.companyName,
      publishDate: clearPublishDate
          ? null
          : publishDate ?? this.publishDate,
      startDate:
          clearStartDate ? null : startDate ?? this.startDate,
      endDate:
          clearEndDate ? null : endDate ?? this.endDate,
      priority: priority ?? this.priority,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  static ContentStatus _readStatus(
    Map<String, dynamic> data,
  ) {
    final statusValue = data['status'] as String?;

    if (statusValue != null) {
      return ContentStatusExtension.fromValue(statusValue);
    }

    // Eski isPublished alanıyla oluşturulmuş belgeler varsa
    // sistemin bozulmadan çalışmasını sağlar.
    final oldIsPublished = data['isPublished'] as bool?;

    if (oldIsPublished == true) {
      return ContentStatus.published;
    }

    return ContentStatus.draft;
  }

  static DateTime? _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static String? _nullableString(dynamic value) {
    if (value is! String) {
      return null;
    }

    final cleanedValue = value.trim();

    return cleanedValue.isEmpty ? null : cleanedValue;
  }

  static String? _cleanNullableString(String? value) {
    final cleanedValue = value?.trim();

    if (cleanedValue == null || cleanedValue.isEmpty) {
      return null;
    }

    return cleanedValue;
  }

  static int _intFromFirestore(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return fallback;
  }
}