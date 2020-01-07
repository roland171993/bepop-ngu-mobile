import 'package:bepop_ngu/data/models/subject.dart';
import 'package:bepop_ngu/data/models/offlineExamTimetableSlot.dart';

class OfflineExamSubjectResult {
  final int? id;
  final int? examTimetableId;
  final int? studentId;
  final int? classSubjectId;
  final int? obtainedMarks;
  final String? teacherReview;
  final int? passingStatus;
  final int? sessionYearId;
  final String? grade;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final Subject? subject;
  final OfflineExamTimeTableSlot? offlineExamTimeTableSlot;

  OfflineExamSubjectResult(
      {this.id,
      this.examTimetableId,
      this.studentId,
      this.classSubjectId,
      this.obtainedMarks,
      this.teacherReview,
      this.passingStatus,
      this.sessionYearId,
      this.grade,
      this.schoolId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.offlineExamTimeTableSlot,
      this.subject});

  OfflineExamSubjectResult copyWith({
    int? id,
    int? examTimetableId,
    int? studentId,
    int? classSubjectId,
    int? obtainedMarks,
    String? teacherReview,
    int? passingStatus,
    int? sessionYearId,
    String? grade,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return OfflineExamSubjectResult(
      id: id ?? this.id,
      examTimetableId: examTimetableId ?? this.examTimetableId,
      studentId: studentId ?? this.studentId,
      classSubjectId: classSubjectId ?? this.classSubjectId,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      teacherReview: teacherReview ?? this.teacherReview,
      passingStatus: passingStatus ?? this.passingStatus,
      sessionYearId: sessionYearId ?? this.sessionYearId,
      grade: grade ?? this.grade,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  OfflineExamSubjectResult.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        examTimetableId = json['exam_timetable_id'] as int?,
        studentId = json['student_id'] as int?,
        classSubjectId = json['class_subject_id'] as int?,
        obtainedMarks = json['obtained_marks'] as int?,
        teacherReview = json['teacher_review'] as String?,
        passingStatus = json['passing_status'] as int?,
        sessionYearId = json['session_year_id'] as int?,
        grade = json['grade'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        offlineExamTimeTableSlot = OfflineExamTimeTableSlot.fromJson(
            Map.from(json['timetable'] ?? {})),
        subject =
            Subject.fromJson(Map.from((json['subject'] as List).first ?? {})),
        deletedAt = json['deleted_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam_timetable_id': examTimetableId,
        'student_id': studentId,
        'class_subject_id': classSubjectId,
        'obtained_marks': obtainedMarks,
        'teacher_review': teacherReview,
        'passing_status': passingStatus,
        'session_year_id': sessionYearId,
        'grade': grade,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt
      };
}
