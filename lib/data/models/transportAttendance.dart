class TransportAttendanceResponse {
  final bool error;
  final String message;
  final TransportAttendanceData? data;
  final int code;

  TransportAttendanceResponse({
    required this.error,
    required this.message,
    this.data,
    required this.code,
  });

  factory TransportAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return TransportAttendanceResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? TransportAttendanceData.fromJson(json['data'])
          : null,
      code: json['code'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data?.toJson(),
      'code': code,
    };
  }
}

class TransportAttendanceData {
  final AttendanceSummary summary;
  final List<AttendanceRecord> records;

  TransportAttendanceData({
    required this.summary,
    required this.records,
  });

  factory TransportAttendanceData.fromJson(Map<String, dynamic> json) {
    return TransportAttendanceData(
      summary: AttendanceSummary.fromJson(json['summary'] ?? {}),
      records: (json['records'] as List<dynamic>?)
              ?.map((record) => AttendanceRecord.fromJson(record))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'records': records.map((record) => record.toJson()).toList(),
    };
  }
}

class AttendanceSummary {
  final int present;
  final int absent;

  AttendanceSummary({
    required this.present,
    required this.absent,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present': present,
      'absent': absent,
    };
  }

  // Helper getter for total attendance
  int get total => present + absent;
}

class AttendanceRecord {
  final String date;
  final String tripType;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.tripType,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['date'] ?? '',
      tripType: json['trip_type'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'trip_type': tripType,
      'status': status,
    };
  }

  // Helper getters
  bool get isPresent => status.toUpperCase() == 'P';
  bool get isAbsent => status.toUpperCase() == 'A';

  // Convert to DateTime for calendar usage
  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
}
