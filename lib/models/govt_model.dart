class VacancyModel {
  final String postName;
  final String totalPost;
  final String eligibility;

  VacancyModel({
    required this.postName,
    required this.totalPost,
    required this.eligibility,
  });
}

class GovtExamDetails {
  final String title;
  final String postUpdateDate;
  final String shortInfo;
  final Map<String, String> importantDates;
  final Map<String, String> applicationFee;
  final List<VacancyModel> vacancies;
  final Map<String, String> importantLinks;

  GovtExamDetails({
    required this.title,
    required this.postUpdateDate,
    required this.shortInfo,
    required this.importantDates,
    required this.applicationFee,
    required this.vacancies,
    required this.importantLinks,
  });
}
