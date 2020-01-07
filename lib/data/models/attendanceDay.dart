class AttendanceDay {
  AttendanceDay({
    required this.id,
    required this.studentId,
    required this.sessionYearId,
    required this.type,
    required this.date,
    required this.remark,
  });
  late final int id;
  late final int studentId;
  late final int sessionYearId;
  late final int type;
  late final String date;
  late final String remark;

  AttendanceDay.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'] ?? 0;
      studentId = json['student_id'] ?? 0;
      sessionYearId = json['session_year_id'] ?? 0;
      type = json['type'] ?? -1;
      // Use get_date_original if available (ISO format), otherwise fallback to date
      date = json['get_date_original'] ?? json['date'] ?? "";
      remark = json['remark'] ?? "";
    } catch (e) {
      // Set default values if parsing fails
      id = 0;
      studentId = 0;
      sessionYearId = 0;
      type = -1;
      date = "";
      remark = "";
    }
  }
}
