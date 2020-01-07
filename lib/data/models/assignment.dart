import 'package:bepop_ngu/data/models/studyMaterial.dart';
import 'package:bepop_ngu/data/models/subject.dart';

class Assignment {
  Assignment({
    required this.id,
    required this.classSectionId,
    required this.subjectId,
    required this.name,
    required this.instructions,
    required this.dueDate,
    required this.dueDateOriginal,
    required this.points,
    required this.resubmission,
    required this.extraDaysForResubmission,
    required this.sessionYearId,
    required this.subject,
    required this.createdAt,
    required this.assignmentSubmission,
    required this.referenceMaterials,
    required this.schoolId,
  });

  late final int id;
  late final int classSectionId;
  late final int subjectId;
  late final String name;
  late final String createdAt; //It will work as assigned date
  late List<StudyMaterial> referenceMaterials;
  late final String instructions;
  late final String dueDate; // Formatted date for display (from due_date)
  late final String
      dueDateOriginal; // Original date for parsing (from due_date_original)
  late final int points;
  late final int resubmission;
  late final int extraDaysForResubmission;
  late final int sessionYearId;
  late final int schoolId;
  late final AssignmentSubmission assignmentSubmission;
  late final Subject subject;

  Assignment updateAssignmentSubmission(
    AssignmentSubmission newAssignmentSubmission,
  ) {
    return Assignment(
      schoolId: schoolId,
      createdAt: createdAt,
      id: id,
      classSectionId: classSectionId,
      subjectId: subjectId,
      name: name,
      instructions: instructions,
      dueDate: dueDate,
      dueDateOriginal: dueDateOriginal,
      points: points,
      resubmission: resubmission,
      extraDaysForResubmission: extraDaysForResubmission,
      sessionYearId: sessionYearId,
      subject: subject,
      assignmentSubmission: newAssignmentSubmission,
      referenceMaterials: referenceMaterials,
    );
  }

  /// Parse the due date from dueDateOriginal for date comparisons
  DateTime? getParsedDueDate() {
    if (dueDateOriginal.isEmpty) return null;

    try {
      // Try parsing as ISO format first: "2025-09-20 10:44:00" or similar
      if (dueDateOriginal.contains('-') && dueDateOriginal.contains(':')) {
        try {
          DateTime parsed = DateTime.parse(dueDateOriginal);
          return parsed;
        } catch (e) {
          // If ISO parsing fails, try custom format
        }
      }

      // Parse the date from dueDateOriginal format: "20-09-2025 10:44 AM"
      if (dueDateOriginal.contains(' ') &&
          dueDateOriginal.toUpperCase().contains('M')) {
        List<String> dateTimeParts = dueDateOriginal.split(' ');

        if (dateTimeParts.length >= 3) {
          String datePart = dateTimeParts[0];
          String timePart = dateTimeParts[1];
          String amPmPart = dateTimeParts[2];

          // Parse date part (dd-mm-yyyy format)
          List<String> dateComponents = datePart.split('-');
          if (dateComponents.length == 3) {
            int day = int.parse(dateComponents[0]);
            int month = int.parse(dateComponents[1]);
            int year = int.parse(dateComponents[2]);

            // Parse time part
            List<String> timeComponents = timePart.split(':');
            if (timeComponents.length == 2) {
              int hour = int.parse(timeComponents[0]);
              int minute = int.parse(timeComponents[1]);

              if (amPmPart.toUpperCase() == 'PM' && hour != 12) {
                hour += 12;
              } else if (amPmPart.toUpperCase() == 'AM' && hour == 12) {
                hour = 0;
              }

              DateTime parsed = DateTime(year, month, day, hour, minute);
              return parsed;
            }
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Assignment.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    classSectionId = json['class_section_id'] ?? 0;
    subjectId = json['class_subject_id'] ?? 0; // Use class_subject_id from API
    name = json['name'] ?? "";
    instructions = json['instructions'] ?? "";
    // Use due_date (formatted string) for display
    dueDate = json['due_date'] ?? "";
    // Use due_date_original for date comparisons and parsing
    dueDateOriginal = json['due_date_original'] ?? "";
    points = json['points'] ?? 0;
    resubmission = json['resubmission'] ?? -1;
    extraDaysForResubmission = json['extra_days_for_resubmission'] ?? 0;
    sessionYearId = json['session_year_id'] ?? 0;
    referenceMaterials = ((json['file'] ?? []) as List)
        .map((file) => StudyMaterial.fromJson(Map.from(file)))
        .toList();
    assignmentSubmission =
        AssignmentSubmission.fromJson(Map.from(json['submission'] ?? {}));

    subject =
        Subject.fromJson(Map.from(json['class_subject']?['subject'] ?? {}));
    createdAt = json['created_at'] ?? ""; // Keep as string for display
    schoolId = json['school_id'] ?? 0;
  }
}

class AssignmentSubmission {
  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.sessionYearId,
    required this.feedback,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.points,
    required this.submittedFiles,
  });
  late final int id;
  late final List<StudyMaterial> submittedFiles;
  late final int assignmentId;
  late final int studentId;
  late final int sessionYearId;
  late final String feedback;
  late final int status;
  late final String createdAt;
  late final int points;
  late final String updatedAt;

  AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    points = json['points'] ?? 0;
    assignmentId = json['assignment_id'] ?? 0;
    studentId = json['student_id'] ?? 0;
    sessionYearId = json['session_year_id'] ?? 0;
    feedback = json['feedback'] ?? "";
    status = json['status'] ?? -1;
    createdAt = json['created_at'] == null
        ? DateTime.now().toString()
        : json['created_at'];
    updatedAt = json['updated_at'] == null
        ? DateTime.now().toString()
        : json['updated_at'];
    submittedFiles = ((json['file'] ?? []) as List)
        .map(
          (submittedFiles) => StudyMaterial.fromJson(Map.from(submittedFiles)),
        )
        .toList();
  }
}
