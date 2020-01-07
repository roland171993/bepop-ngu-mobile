class LiveRouteResponse {
  final bool error;
  final String message;
  final dynamic data; // Can be String or List<LiveTrip>
  final int code;

  LiveRouteResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory LiveRouteResponse.fromJson(Map<String, dynamic> json) {
    return LiveRouteResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      code: json['code'] ?? 200,
    );
  }

  // Helper methods
  bool get hasTrip => data is List && (data as List).isNotEmpty;
  bool get isNoTripMessage => data is String;
  String get noTripMessage => data is String ? data as String : '';
  List<LiveTrip> get trips => hasTrip
      ? (data as List)
          .map((item) => LiveTrip.fromJson(Map<String, dynamic>.from(item)))
          .toList()
      : [];

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data,
      'code': code,
    };
  }
}

class LiveTrip {
  final int tripId;
  final String etaToUserStopMin;
  final String status;
  final Vehicle vehicle;
  final ShiftTime shiftTime;
  final RouteInfo route;
  final List<TripStop> stops;
  final String type;
  final LastReachedStop? lastReachedStop;

  LiveTrip({
    required this.tripId,
    required this.etaToUserStopMin,
    required this.status,
    required this.vehicle,
    required this.shiftTime,
    required this.route,
    required this.stops,
    required this.type,
    this.lastReachedStop,
  });

  factory LiveTrip.fromJson(Map<String, dynamic> json) {
    return LiveTrip(
      tripId: _parseToInt(json['trip_id']) ?? 0,
      etaToUserStopMin: json['eta_to_user_stop_min']?.toString() ?? '',
      status: json['status'] ?? '',
      vehicle:
          Vehicle.fromJson(Map<String, dynamic>.from(json['vehicle'] ?? {})),
      shiftTime: ShiftTime.fromJson(
          Map<String, dynamic>.from(json['shift_time'] ?? {})),
      route: RouteInfo.fromJson(Map<String, dynamic>.from(json['route'] ?? {})),
      stops: (json['stops'] as List?)
              ?.map(
                  (stop) => TripStop.fromJson(Map<String, dynamic>.from(stop)))
              .toList() ??
          [],
      type: json['type'] ?? '',
      lastReachedStop: json['last_reached_stop'] != null
          ? LastReachedStop.fromJson(
              Map<String, dynamic>.from(json['last_reached_stop']))
          : null,
    );
  }

  /// Helper method to safely parse int from dynamic value
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.trim().isEmpty) return null;
      return int.tryParse(value.trim());
    }
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'eta_to_user_stop_min': etaToUserStopMin,
      'status': status,
      'vehicle': vehicle.toJson(),
      'shift_time': shiftTime.toJson(),
      'route': route.toJson(),
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'type': type,
      'last_reached_stop': lastReachedStop?.toJson(),
    };
  }

  // Helper method to get the current stop index based on last reached stop
  int get currentStopIndex {
    if (lastReachedStop?.id == null) return 0;

    for (int i = 0; i < stops.length; i++) {
      if (stops[i].id == lastReachedStop!.id) {
        return i;
      }
    }
    return 0;
  }

  // Helper method to get the next stop
  TripStop? get nextStop {
    final currentIndex = currentStopIndex;
    if (currentIndex < stops.length - 1) {
      return stops[currentIndex + 1];
    }
    return null;
  }

  // Helper method to check if bus has reached user's stop
  bool get hasReachedUserStop {
    // This would need to be determined based on user's assigned stop
    // For now, we'll check if the last reached stop is not the first or last stop
    return lastReachedStop?.id != null &&
        stops.isNotEmpty &&
        lastReachedStop!.id != stops.first.id &&
        lastReachedStop!.id != stops.last.id;
  }

  // Helper method to get status message for user
  String get userStatusMessage {
    switch (status.toLowerCase()) {
      case 'inprogress':
        if (hasReachedUserStop) {
          return 'Bus Has Reached Your Stop';
        } else {
          return 'Bus is on the way';
        }
      case 'completed':
        return 'Trip completed';
      case 'scheduled':
        return 'Trip scheduled';
      default:
        return 'Status unknown';
    }
  }
}

class Vehicle {
  final String name;
  final String number;

  Vehicle({
    required this.name,
    required this.number,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'] ?? '',
      number: json['number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
    };
  }
}

class ShiftTime {
  final String label;
  final String from;
  final String to;

  ShiftTime({
    required this.label,
    required this.from,
    required this.to,
  });

  factory ShiftTime.fromJson(Map<String, dynamic> json) {
    return ShiftTime(
      label: json['label'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'from': from,
      'to': to,
    };
  }
}

class RouteInfo {
  final int id;
  final String name;

  RouteInfo({
    required this.id,
    required this.name,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TripStop {
  final int? id;
  final String name;
  final String scheduledTime;
  final String? estimatedTime;
  final String actualTime;
  final List<Passenger> passengers;

  TripStop({
    this.id,
    required this.name,
    required this.scheduledTime,
    this.estimatedTime,
    required this.actualTime,
    required this.passengers,
  });

  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      id: json['id'],
      name: json['name'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      estimatedTime: json['estimated_time'],
      actualTime: json['actual_time'] ?? '',
      passengers: (json['passengers'] as List?)
              ?.map((passenger) =>
                  Passenger.fromJson(Map<String, dynamic>.from(passenger)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scheduled_time': scheduledTime,
      'estimated_time': estimatedTime,
      'actual_time': actualTime,
      'passengers': passengers.map((p) => p.toJson()).toList(),
    };
  }

  // Helper methods
  bool get isCompleted => actualTime != 'Pending' && actualTime.isNotEmpty;
  bool get isPending => actualTime == 'Pending';
  bool get hasPassengers => passengers.isNotEmpty;
}

class Passenger {
  final int id;
  final String name;
  final String role;

  Passenger({
    required this.id,
    required this.name,
    required this.role,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }
}

class LastReachedStop {
  final int? id;
  final String? name;

  LastReachedStop({
    this.id,
    this.name,
  });

  factory LastReachedStop.fromJson(Map<String, dynamic> json) {
    return LastReachedStop(
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
