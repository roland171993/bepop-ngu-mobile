class TransportDashboard {
  final String? status; // For "No plan found" message
  final TransportPlan? plan;
  final BusInfo? busInfo;
  final LiveSummary? liveSummary;
  final TodayAttendance? todayAttendance;
  final TransportRequest? requests;

  TransportDashboard({
    this.status,
    this.plan,
    this.busInfo,
    this.liveSummary,
    this.todayAttendance,
    this.requests,
  });

  factory TransportDashboard.fromJson(Map<String, dynamic> json) {
    return TransportDashboard(
      status: json['status'] as String?, // Handle status field
      plan: json['plan'] != null ? TransportPlan.fromJson(json['plan']) : null,
      busInfo:
          json['bus_info'] != null ? BusInfo.fromJson(json['bus_info']) : null,
      liveSummary: json['live_summary'] != null && json['live_summary'] is Map
          ? LiveSummary.fromJson(
              Map<String, dynamic>.from(json['live_summary']))
          : null,
      todayAttendance: json['today_attendance'] != null
          ? TodayAttendance.fromJson(json['today_attendance'])
          : null,
      requests: json['requests'] != null
          ? TransportRequest.fromJson(json['requests'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'plan': plan?.toJson(),
      'bus_info': busInfo?.toJson(),
      'live_summary': liveSummary?.toJson(),
      'today_attendance': todayAttendance?.toJson(),
      'requests': requests?.toJson(),
    };
  }

  // Helper method to check if this is a "no data" response
  bool get hasNoData {
    return status != null &&
        status!.toLowerCase().contains('no plan') &&
        plan == null &&
        busInfo == null &&
        liveSummary == null &&
        todayAttendance == null;
  }

  // Helper method to check if this response has actual transport data
  bool get hasTransportData {
    return plan != null ||
        busInfo != null ||
        liveSummary != null ||
        todayAttendance != null;
  }
}

class TransportPlan {
  final int? planId;
  final String? status;
  final String? duration;
  final String? validFrom;
  final String? validTo;
  final TransportRoute? route;
  final PickupStop? pickupStop;
  final int? expiresInDays;
  final int? shiftId;

  TransportPlan({
    this.planId,
    this.status,
    this.duration,
    this.validFrom,
    this.validTo,
    this.route,
    this.pickupStop,
    this.expiresInDays,
    this.shiftId,
  });

  factory TransportPlan.fromJson(Map<String, dynamic> json) {
    return TransportPlan(
      planId: json['plan_id'],
      status: json['status'],
      duration: json['duration'],
      validFrom: json['valid_from'],
      validTo: json['valid_to'],
      route:
          json['route'] != null ? TransportRoute.fromJson(json['route']) : null,
      pickupStop: json['pickup_stop'] != null
          ? PickupStop.fromJson(json['pickup_stop'])
          : null,
      expiresInDays: json['expires_in_days'],
      shiftId: json['shift_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'status': status,
      'duration': duration,
      'valid_from': validFrom,
      'valid_to': validTo,
      'route': route?.toJson(),
      'pickup_stop': pickupStop?.toJson(),
      'expires_in_days': expiresInDays,
      'shift_id': shiftId,
    };
  }
}

class TransportRoute {
  final int? id;
  final String? name;

  TransportRoute({
    this.id,
    this.name,
  });

  factory TransportRoute.fromJson(Map<String, dynamic> json) {
    return TransportRoute(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PickupStop {
  final int? id;
  final String? name;
  final String? pickUpTime;
  final String? dropTime;

  PickupStop({
    this.id,
    this.name,
    this.pickUpTime,
    this.dropTime,
  });

  factory PickupStop.fromJson(Map<String, dynamic> json) {
    return PickupStop(
      id: json['id'],
      name: json['name'],
      pickUpTime: json['pickup_time'],
      dropTime: json['drop_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pickup_time': pickUpTime,
      'drop_time': dropTime,
    };
  }
}

class BusInfo {
  final int? vehicleId;
  final String? vehicleName;
  final String? registration;
  final TransportDriver? driver;
  final TransportAttender? attender;

  BusInfo({
    this.vehicleId,
    this.vehicleName,
    this.registration,
    this.driver,
    this.attender,
  });

  factory BusInfo.fromJson(Map<String, dynamic> json) {
    return BusInfo(
      vehicleId: json['vehicle_id'],
      vehicleName: json['vehicle_name'],
      registration: json['registration'],
      driver: json['driver'] != null
          ? TransportDriver.fromJson(json['driver'])
          : null,
      attender: json['attender'] != null
          ? TransportAttender.fromJson(json['attender'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'vehicle_name': vehicleName,
      'registration': registration,
      'driver': driver?.toJson(),
      'attender': attender?.toJson(),
    };
  }
}

class TransportDriver {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? avatar;

  TransportDriver({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.avatar,
  });

  factory TransportDriver.fromJson(Map<String, dynamic> json) {
    return TransportDriver(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      avatar: json['avtar'], // Note: API uses 'avtar' not 'avatar'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avtar': avatar,
    };
  }
}

class TransportAttender {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? avatar;

  TransportAttender({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.avatar,
  });

  factory TransportAttender.fromJson(Map<String, dynamic> json) {
    return TransportAttender(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      avatar: json['avtar'], // Note: API uses 'avtar' not 'avatar'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avtar': avatar,
    };
  }
}

class LiveSummary {
  final String? currentLocation;
  final String? nextLocation;
  final String? pickupTime;

  LiveSummary({
    this.currentLocation,
    this.nextLocation,
    this.pickupTime,
  });

  factory LiveSummary.fromJson(dynamic json) {
    if (json is String) {
      // Handle case where live_summary is just a string message
      return LiveSummary(
        currentLocation: json,
        nextLocation: null,
        pickupTime: null,
      );
    } else if (json is Map<String, dynamic>) {
      // Handle case where live_summary is a proper object
      return LiveSummary(
        currentLocation: json['current_location'],
        nextLocation: json['next_location'],
        pickupTime: json['estimated_time'],
      );
    }
    return LiveSummary();
  }

  Map<String, dynamic> toJson() {
    return {
      'current_location': currentLocation,
      'next_location': nextLocation,
      'estimated_time': pickupTime,
    };
  }
}

class TodayAttendance {
  final String? status;
  final String? tripType;
  final List<AttendanceRecord>? records;

  TodayAttendance({
    this.status,
    this.tripType,
    this.records,
  });

  factory TodayAttendance.fromJson(dynamic json) {
    if (json is List) {
      if (json.isEmpty) {
        return TodayAttendance();
      }
      // Sometimes API returns list of strings like ["No attendance found for today"]
      if (json.first is String) {
        return TodayAttendance();
      }
      // Normal case: list of objects
      final List<AttendanceRecord> attendanceRecords = json
          .whereType<Map<String, dynamic>>()
          .map((item) => AttendanceRecord.fromJson(item))
          .toList();

      if (attendanceRecords.isEmpty) {
        return TodayAttendance();
      }

      final firstRecord = attendanceRecords.first;

      return TodayAttendance(
        status: firstRecord.status,
        tripType: firstRecord.tripType,
        records: attendanceRecords,
      );
    } else if (json is Map<String, dynamic>) {
      // Handle case where today_attendance is a single object
      return TodayAttendance(
        status: json['status'],
        tripType: json['trip_type'],
        records: [AttendanceRecord.fromJson(json)],
      );
    }
    return TodayAttendance();
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'trip_type': tripType,
      'records': records?.map((r) => r.toJson()).toList(),
    };
  }

  // Get pickup attendance status
  String? get pickupStatus {
    if (records != null && records!.isNotEmpty) {
      final pickupRecord = records!.firstWhere(
        (r) => r.tripType?.toLowerCase() == 'pickup',
        orElse: () => records!.first,
      );
      return pickupRecord.status;
    }
    return status;
  }

  // Get drop attendance status
  String? get dropStatus {
    if (records != null && records!.length > 1) {
      final dropRecord = records!.firstWhere(
        (r) => r.tripType?.toLowerCase() == 'drop',
        orElse: () => records!.last,
      );
      return dropRecord.status;
    }
    return null;
  }
}

class AttendanceRecord {
  final String? status;
  final String? tripType;

  AttendanceRecord({
    this.status,
    this.tripType,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      status: json['status'],
      tripType: json['trip_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'trip_type': tripType,
    };
  }
}

class TransportRequest {
  final int? id;
  final String? status;
  final String? requestedOn;
  final String? requestType;
  final RequestedBy? requestedBy;
  final RequestDetails? details;
  final RequestReview? review;
  final String? mode;
  final ContactDetails? contactDetails;

  TransportRequest({
    this.id,
    this.status,
    this.requestedOn,
    this.requestType,
    this.requestedBy,
    this.details,
    this.review,
    this.mode,
    this.contactDetails,
  });

  factory TransportRequest.fromJson(Map<String, dynamic> json) {
    return TransportRequest(
      id: json['id'],
      status: json['status'],
      requestedOn: json['requested_on'],
      requestType: json['request_type'],
      requestedBy: json['requested_by'] != null
          ? RequestedBy.fromJson(json['requested_by'])
          : null,
      details: json['details'] != null
          ? RequestDetails.fromJson(json['details'])
          : null,
      review: json['review'] != null
          ? RequestReview.fromJson(json['review'])
          : null,
      mode: json['mode'],
      contactDetails: json['contact_details'] != null
          ? ContactDetails.fromJson(json['contact_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'requested_on': requestedOn,
      'requested_by': requestedBy?.toJson(),
      'details': details?.toJson(),
      'review': review?.toJson(),
      'mode': mode,
      'contact_details': contactDetails?.toJson(),
    };
  }
}

class RequestedBy {
  final int? studentId;
  final String? name;

  RequestedBy({
    this.studentId,
    this.name,
  });

  factory RequestedBy.fromJson(Map<String, dynamic> json) {
    return RequestedBy(
      studentId: json['student_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
    };
  }
}

class RequestDetails {
  final PickupStop? pickupStop;
  final TransportRoute? route;
  final RequestPlan? plan;

  RequestDetails({
    this.pickupStop,
    this.route,
    this.plan,
  });

  factory RequestDetails.fromJson(Map<String, dynamic> json) {
    return RequestDetails(
      pickupStop: json['pickup_stop'] != null
          ? PickupStop.fromJson(json['pickup_stop'])
          : null,
      route:
          json['route'] != null ? TransportRoute.fromJson(json['route']) : null,
      plan: json['plan'] != null ? RequestPlan.fromJson(json['plan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_stop': pickupStop?.toJson(),
      'plan': plan?.toJson(),
    };
  }
}

class RequestPlan {
  final String? duration;
  final String? validity;

  RequestPlan({
    this.duration,
    this.validity,
  });

  factory RequestPlan.fromJson(Map<String, dynamic> json) {
    return RequestPlan(
      duration: json['duration'],
      validity: json['validity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'validity': validity,
    };
  }
}

class RequestReview {
  final String? respondedOn;

  RequestReview({
    this.respondedOn,
  });

  factory RequestReview.fromJson(Map<String, dynamic> json) {
    return RequestReview(
      respondedOn: json['responded_on'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responded_on': respondedOn,
    };
  }
}

class ContactDetails {
  final String? schoolEmail;
  final String? schoolPhone;

  ContactDetails({
    this.schoolEmail,
    this.schoolPhone,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      schoolEmail: json['school_email'],
      schoolPhone: json['school_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_email': schoolEmail,
      'school_phone': schoolPhone,
    };
  }
}

class TransportRequestsResponse {
  final bool error;
  final String message;
  final List<TransportRequest> data;
  final int code;

  TransportRequestsResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory TransportRequestsResponse.fromJson(Map<String, dynamic> json) {
    return TransportRequestsResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => TransportRequest.fromJson(item))
              .toList() ??
          [],
      code: json['code'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'code': code,
    };
  }
}
