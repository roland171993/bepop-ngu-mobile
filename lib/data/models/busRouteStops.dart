class BusRouteStops {
  final RouteInfo? route;
  final List<BusStop> stops;

  BusRouteStops({
    this.route,
    required this.stops,
  });

  factory BusRouteStops.fromJson(Map<String, dynamic> json) {
    return BusRouteStops(
      route: json['route'] != null ? RouteInfo.fromJson(json['route']) : null,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((stop) => BusStop.fromJson(stop))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route': route?.toJson(),
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }

  // Helper method to get the user's current stop
  BusStop? get userStop {
    try {
      return stops.firstWhere((stop) => stop.isUserStop);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get user stop index
  int get userStopIndex {
    for (int i = 0; i < stops.length; i++) {
      if (stops[i].isUserStop) {
        return i;
      }
    }
    return -1;
  }

  // Helper method to check if there are any stops
  bool get hasStops => stops.isNotEmpty;

  // Helper method to get route display info
  String get routeDisplayInfo {
    if (route?.name != null && route?.vehicleRegistration != null) {
      return 'Route : ${route!.name} | ${route!.vehicleRegistration}';
    } else if (route?.name != null) {
      return 'Route : ${route!.name}';
    }
    return 'Route information not available';
  }

  // Helper method to get user pickup info
  String get userPickupInfo {
    final userStopData = userStop;
    if (userStopData != null) {
      return 'Your Pickup : ${userStopData.name} | ${userStopData.scheduledTime}';
    }
    return 'Your pickup information not available';
  }
}

class RouteInfo {
  final int? id;
  final String? name;
  final String? vehicleName;
  final String? vehicleRegistration;

  RouteInfo({
    this.id,
    this.name,
    this.vehicleName,
    this.vehicleRegistration,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'],
      name: json['name'],
      vehicleName: json['vehicle_name'],
      vehicleRegistration: json['vehicle_registration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicle_name': vehicleName,
      'vehicle_registration': vehicleRegistration,
    };
  }
}

class BusStop {
  final int? id;
  final String? name;
  final String? scheduledTime;
  final bool isUserStop;

  BusStop({
    this.id,
    this.name,
    this.scheduledTime,
    required this.isUserStop,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      name: json['name'],
      scheduledTime: json['scheduled_time'],
      isUserStop: json['is_user_stop'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scheduled_time': scheduledTime,
      'is_user_stop': isUserStop,
    };
  }

  // Helper method to get display name
  String get displayName => name ?? 'Unknown Stop';

  // Helper method to get display time
  String get displayTime => scheduledTime ?? 'Time not available';
}
