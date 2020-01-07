import 'package:bepop_ngu/data/models/diaryStudent.dart';
import 'package:bepop_ngu/data/models/studentDetails.dart';

class StudentDiaryDetails extends StudentDetails {
  final List<DiaryStudent> diaryStudent;

  StudentDiaryDetails({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.mobile,
    required super.email,
    required super.gender,
    required super.image,
    required super.dob,
    required super.fullName,
    required super.schoolNames,
    required super.student,
    required this.diaryStudent,
  });

  StudentDiaryDetails.fromJson(Map<String, dynamic> json)
      : diaryStudent = ((json['diary_student'] ?? []) as List)
            .map((diaryStudentData) =>
                DiaryStudent.fromJson(Map.from(diaryStudentData ?? {})))
            .toList(),
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['diary_student'] = diaryStudent.map((ds) => ds.toJson()).toList();
    return data;
  }
}
