class Company {
  final String name;
  final String fullName;

  final int foundedYear;
  final String branchCount;
  final String headquarters;

  final String logoAsset;

  final String shortDescription;
  final String about;

  final List<String> highlights;

  final String website;
  final String complaintUrl;

  const Company({
    required this.name,
    required this.fullName,
    required this.foundedYear,
    required this.branchCount,
    required this.headquarters,
    required this.logoAsset,
    required this.shortDescription,
    required this.about,
    required this.highlights,
    required this.website,
    required this.complaintUrl,
  });
}