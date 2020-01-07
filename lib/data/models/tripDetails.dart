enum TripStatus { upcoming, inProgress, completed }

enum PassengerStatus { present, absent, notMarked }

enum StopStatus { upcoming, current, completed }

class TripDetails {
  final String id;
  final String route;
  final String shiftTime;
  final TripStatus status;
  final int totalStops;
  final int totalPassengers;
  final int presentCount;
  final int absentCount;
  final List<TripStop> stops;
  final List<PassengerGroup> passengerGroups;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? busNumber;

  TripDetails({
    required this.id,
    required this.route,
    required this.shiftTime,
    required this.status,
    required this.totalStops,
    required this.totalPassengers,
    this.presentCount = 0,
    this.absentCount = 0,
    required this.stops,
    required this.passengerGroups,
    this.startTime,
    this.endTime,
    this.busNumber,
  });

  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
      id: json['id'] ?? '',
      route: json['route'] ?? '',
      shiftTime: json['shift_time'] ?? '',
      status: _parseStatus(json['status']),
      totalStops: json['total_stops'] ?? 0,
      totalPassengers: json['total_passengers'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      stops:
          (json['stops'] as List?)?.map((e) => TripStop.fromJson(e)).toList() ??
              [],
      passengerGroups: (json['passenger_groups'] as List?)
              ?.map((e) => PassengerGroup.fromJson(e))
              .toList() ??
          [],
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'])
          : null,
      endTime:
          json['end_time'] != null ? DateTime.tryParse(json['end_time']) : null,
      busNumber: json['bus_number'],
    );
  }

  static TripStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'upcoming':
        return TripStatus.upcoming;
      case 'in_progress':
      case 'in-progress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      default:
        return TripStatus.upcoming;
    }
  }
}

class TripStop {
  final String id;
  final String name;
  final String time;
  final String? actualTime;
  final int passengerCount;
  final StopStatus status;
  final bool isSchoolCampus;
  final String? arrivalNote;

  TripStop({
    required this.id,
    required this.name,
    required this.time,
    this.actualTime,
    required this.passengerCount,
    required this.status,
    this.isSchoolCampus = false,
    this.arrivalNote,
  });

  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      actualTime: json['actual_time'],
      passengerCount: json['passenger_count'] ?? 0,
      status: _parseStopStatus(json['status']),
      isSchoolCampus: json['is_school_campus'] ?? false,
      arrivalNote: json['arrival_note'],
    );
  }

  static StopStatus _parseStopStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'current':
        return StopStatus.current;
      case 'completed':
        return StopStatus.completed;
      case 'upcoming':
      default:
        return StopStatus.upcoming;
    }
  }
}

class PassengerGroup {
  final String stopId;
  final String stopName;
  final String time;
  final List<Passenger> passengers;
  final bool isExpanded;
  final String? pickupNote;
  final bool isOnTime;

  PassengerGroup({
    required this.stopId,
    required this.stopName,
    required this.time,
    required this.passengers,
    this.isExpanded = false,
    this.pickupNote,
    this.isOnTime = true,
  });

  factory PassengerGroup.fromJson(Map<String, dynamic> json) {
    return PassengerGroup(
      stopId: json['stop_id'] ?? '',
      stopName: json['stop_name'] ?? '',
      time: json['time'] ?? '',
      passengers: (json['passengers'] as List?)
              ?.map((e) => Passenger.fromJson(e))
              .toList() ??
          [],
      isExpanded: json['is_expanded'] ?? false,
      pickupNote: json['pickup_note'],
      isOnTime: json['is_on_time'] ?? true,
    );
  }
}

class Passenger {
  final String id;
  final String name;
  final String type; // Student, Staff
  final String? profileImage;
  final PassengerStatus attendanceStatus;
  final bool canCall;
  final String? phoneNumber;

  Passenger({
    required this.id,
    required this.name,
    required this.type,
    this.profileImage,
    required this.attendanceStatus,
    this.canCall = false,
    this.phoneNumber,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Student',
      profileImage: json['profile_image'],
      attendanceStatus: _parsePassengerStatus(json['attendance_status']),
      canCall: json['can_call'] ?? false,
      phoneNumber: json['phone_number'],
    );
  }

  static PassengerStatus _parsePassengerStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
      case 'p':
        return PassengerStatus.present;
      case 'absent':
      case 'a':
        return PassengerStatus.absent;
      case 'not_marked':
      default:
        return PassengerStatus.notMarked;
    }
  }
}
