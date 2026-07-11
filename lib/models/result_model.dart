class SubjectModel {
  final String subjectCode;
  final String name;
  final int internalMarks;
  final int externalMarks;
  final int marksObtained;
  final int totalMarks;
  final String grade;
  final int credits;

  SubjectModel({
    required this.subjectCode,
    required this.name,
    required this.internalMarks,
    required this.externalMarks,
    required this.marksObtained,
    required this.totalMarks,
    required this.grade,
    required this.credits,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectCode: json['subjectCode'] ?? 'SUB101',
      name: json['name'] ?? '',
      internalMarks: json['internalMarks'] ?? 0,
      externalMarks: json['externalMarks'] ?? 0,
      marksObtained: json['marksObtained'] ?? 0,
      totalMarks: json['totalMarks'] ?? 100,
      grade: json['grade'] ?? '',
      credits: json['credits'] ?? 3,
    );
  }
}

class ResultModel {
  final String studentName;
  final String rollNumber;
  final String courseName;
  final String semester;
  final String status;
  final double cgpa;
  final List<SubjectModel> subjects;

  ResultModel({
    required this.studentName,
    required this.rollNumber,
    required this.courseName,
    required this.semester,
    required this.status,
    required this.cgpa,
    required this.subjects,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    var subjectList = json['subjects'] as List? ?? [];
    List<SubjectModel> subjects = subjectList.map((i) => SubjectModel.fromJson(i)).toList();

    return ResultModel(
      studentName: json['studentName'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      courseName: json['courseName'] ?? '',
      semester: json['semester'] ?? '',
      status: json['status'] ?? 'Pending',
      cgpa: (json['cgpa'] ?? 0.0).toDouble(),
      subjects: subjects,
    );
  }
}
