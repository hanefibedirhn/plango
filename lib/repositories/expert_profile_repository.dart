import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expert_profile_model.dart';

class ExpertProfileNotFoundException implements Exception {
  const ExpertProfileNotFoundException();

  @override
  String toString() {
    return 'Uzman profili bulunamadı.';
  }
}

class ExpertProfileRepository {
  ExpertProfileRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _expertProfilesCollection {
    return _firestore.collection('expertProfiles');
  }

  /// Tek bir açık uzman profilini getirir.
  Future<ExpertProfile> getExpertProfile(
    String uid,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _expertProfilesCollection.doc(uid).get();

    if (!document.exists || document.data() == null) {
      throw const ExpertProfileNotFoundException();
    }

    return ExpertProfile.fromDocument(document);
  }

  /// Tek bir açık uzman profilini gerçek zamanlı dinler.
  Stream<ExpertProfile?> watchExpertProfile(
    String uid,
  ) {
    return _expertProfilesCollection.doc(uid).snapshots().map(
      (document) {
        if (!document.exists || document.data() == null) {
          return null;
        }

        return ExpertProfile.fromDocument(document);
      },
    );
  }

  /// Seçilen şirketteki görünür uzmanları getirir.
  ///
  /// Talep alan uzmanlar önce, talep almayan uzmanlar sonra
  /// sıralanır. Aynı grup içinde ad soyada göre sıralama yapılır.
  Future<List<ExpertProfile>> getCompanyExperts(
    String companyName,
  ) async {
    final String normalizedCompanyName = companyName.trim();

    if (normalizedCompanyName.isEmpty) {
      return const [];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _expertProfilesCollection
            .where(
              'companyName',
              isEqualTo: normalizedCompanyName,
            )
            .get();

    final List<ExpertProfile> experts = snapshot.docs
        .map(ExpertProfile.fromDocument)
        .where((expert) => expert.isVisible)
        .toList();

    _sortExperts(experts);

    return experts;
  }

  /// Seçilen şirketteki görünür uzmanları gerçek zamanlı dinler.
  Stream<List<ExpertProfile>> watchCompanyExperts(
    String companyName,
  ) {
    final String normalizedCompanyName = companyName.trim();

    if (normalizedCompanyName.isEmpty) {
      return Stream<List<ExpertProfile>>.value(
        const [],
      );
    }

    return _expertProfilesCollection
        .where(
          'companyName',
          isEqualTo: normalizedCompanyName,
        )
        .snapshots()
        .map(
      (snapshot) {
        final List<ExpertProfile> experts = snapshot.docs
            .map(ExpertProfile.fromDocument)
            .where((expert) => expert.isVisible)
            .toList();

        _sortExperts(experts);

        return experts;
      },
    );
  }

  /// Seçilen şirkette şu anda danışma talebi alan uzmanları
  /// gerçek zamanlı dinler.
  Stream<List<ExpertProfile>> watchAvailableExperts(
    String companyName,
  ) {
    return watchCompanyExperts(companyName).map(
      (experts) {
        return experts
            .where(
              (expert) => expert.canReceiveRequests,
            )
            .toList();
      },
    );
  }

  /// Seçilen şirkette aktif olan ancak şu anda yeni danışma
  /// talebi almayan uzmanları gerçek zamanlı dinler.
  Stream<List<ExpertProfile>> watchUnavailableExperts(
    String companyName,
  ) {
    return watchCompanyExperts(companyName).map(
      (experts) {
        return experts
            .where(
              (expert) =>
                  expert.isVisible &&
                  !expert.acceptsNewRequests,
            )
            .toList();
      },
    );
  }

  /// Kullanıcı tarafındaki liste sıralaması:
  ///
  /// 1. Talep alan uzmanlar
  /// 2. Talep almayan uzmanlar
  /// 3. Aynı grup içinde ad soyad
  static void _sortExperts(
    List<ExpertProfile> experts,
  ) {
    experts.sort(
      (first, second) {
        if (first.acceptsNewRequests !=
            second.acceptsNewRequests) {
          return first.acceptsNewRequests ? -1 : 1;
        }

        return first.fullName.toLowerCase().compareTo(
              second.fullName.toLowerCase(),
            );
      },
    );
  }
}