import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationRequestContact {
  const ConsultationRequestContact({
    required this.requestId,
    required this.userId,
    required this.expertId,
    required this.userPhone,
    required this.createdAt,
    required this.updatedAt,
    this.expertPhone,
    this.expertCorporateEmail,
    this.contactSharedAt,
  });

  final String requestId;
  final String userId;
  final String expertId;
  final String userPhone;

  /// Yalnızca uzman "İletişime Geçildi" işlemini yaptığında dolar.
  final String? expertPhone;

  /// Yalnızca uzman "İletişime Geçildi" işlemini yaptığında dolar.
  final String? expertCorporateEmail;

  /// Uzman iletişim bilgilerinin kullanıcıyla paylaşıldığı zaman.
  final DateTime? contactSharedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasSharedExpertContact {
    return (expertPhone?.trim().isNotEmpty ?? false) ||
        (expertCorporateEmail?.trim().isNotEmpty ?? false);
  }

  factory ConsultationRequestContact.fromMap(
    Map<String, dynamic> map, {
    String? requestId,
  }) {
    return ConsultationRequestContact(
      requestId:
          requestId ?? map['requestId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      expertId: map['expertId'] as String? ?? '',
      userPhone: map['userPhone'] as String? ?? '',
      expertPhone: _readNullableString(
        map['expertPhone'],
      ),
      expertCorporateEmail: _readNullableString(
        map['expertCorporateEmail'],
      ),
      contactSharedAt: _readNullableDate(
        map['contactSharedAt'],
      ),
      createdAt: _readDate(
        map['createdAt'],
        fallback: DateTime.now(),
      ),
      updatedAt: _readDate(
        map['updatedAt'],
        fallback: DateTime.now(),
      ),
    );
  }

  factory ConsultationRequestContact.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic>? data = document.data();

    if (data == null) {
      throw StateError(
        'Danışma iletişim kaydı bulunamadı: ${document.id}',
      );
    }

    return ConsultationRequestContact.fromMap(
      data,
      requestId: document.id,
    );
  }

  static String? _readNullableString(
    dynamic value,
  ) {
    if (value is! String) {
      return null;
    }

    final String normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static DateTime _readDate(
    dynamic value, {
    required DateTime fallback,
  }) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return fallback;
  }

  static DateTime? _readNullableDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
