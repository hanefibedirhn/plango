import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertApplication {
  const ExpertApplication({
    this.applicationId,
    required this.uid,
    required this.type,
    required this.companyName,
    required this.branch,
    required this.position,
    required this.corporateEmail,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.reviewNote,
    this.updatedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.previousCompanyName,
    this.previousBranch,
    this.previousPosition,
    this.previousCorporateEmail,
  });

  /// Firestore tarafından otomatik oluşturulan belge kimliği.
  final String? applicationId;

  /// Başvuruyu yapan kullanıcının Firebase UID değeri.
  final String uid;

  /// initial veya profileUpdate
  final String type;

  final String companyName;
  final String branch;
  final String position;
  final String corporateEmail;
  final String phone;

  /// pending, approved veya rejected
  final String status;

  /// Yönetici tarafından kullanıcıya gösterilecek inceleme notu.
  final String? reviewNote;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Yönetici incelemesinin tamamlandığı tarih.
  final DateTime? reviewedAt;

  /// Başvuruyu inceleyen yönetici UID değeri.
  final String? reviewedBy;

  /// Profil güncelleme başvurularında önceki uzman bilgileri.
  final String? previousCompanyName;
  final String? previousBranch;
  final String? previousPosition;
  final String? previousCorporateEmail;

  bool get isInitialApplication => type == 'initial';

  bool get isProfileUpdateApplication => type == 'profileUpdate';

  bool get isPending => status == 'pending';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'type': type,
      'companyName': companyName.trim(),
      'branch': branch.trim(),
      'position': position.trim(),
      'corporateEmail': corporateEmail.trim().toLowerCase(),
      'phone': phone.trim(),
      'status': status,
      'reviewNote': reviewNote?.trim(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null
          ? null
          : Timestamp.fromDate(updatedAt!),
      'reviewedAt': reviewedAt == null
          ? null
          : Timestamp.fromDate(reviewedAt!),
      'reviewedBy': reviewedBy,
      'previousCompanyName': previousCompanyName?.trim(),
      'previousBranch': previousBranch?.trim(),
      'previousPosition': previousPosition?.trim(),
      'previousCorporateEmail':
          previousCorporateEmail?.trim().toLowerCase(),
    };
  }

  factory ExpertApplication.fromMap(
    Map<String, dynamic> map, {
    String? applicationId,
  }) {
    final dynamic createdAtValue = map['createdAt'];
    final dynamic updatedAtValue = map['updatedAt'];
    final dynamic reviewedAtValue = map['reviewedAt'];

    return ExpertApplication(
      applicationId: applicationId,
      uid: map['uid'] as String? ?? '',
      type: map['type'] as String? ?? 'initial',
      companyName: map['companyName'] as String? ?? '',
      branch: map['branch'] as String? ?? '',
      position: map['position'] as String? ?? '',
      corporateEmail:
          map['corporateEmail'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      reviewNote: map['reviewNote'] as String?,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      updatedAt: updatedAtValue is Timestamp
          ? updatedAtValue.toDate()
          : null,
      reviewedAt: reviewedAtValue is Timestamp
          ? reviewedAtValue.toDate()
          : null,
      reviewedBy: map['reviewedBy'] as String?,
      previousCompanyName:
          map['previousCompanyName'] as String?,
      previousBranch:
          map['previousBranch'] as String?,
      previousPosition:
          map['previousPosition'] as String?,
      previousCorporateEmail:
          map['previousCorporateEmail'] as String?,
    );
  }

  factory ExpertApplication.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic>? data = document.data();

    if (data == null) {
      throw StateError(
        'Uzman başvurusu bulunamadı: ${document.id}',
      );
    }

    return ExpertApplication.fromMap(
      data,
      applicationId: document.id,
    );
  }
}