import 'package:bepop_ngu/data/models/pickupPoint.dart';
import 'package:bepop_ngu/data/models/transportFee.dart';
import 'package:bepop_ngu/data/models/transportShift.dart';
import 'package:bepop_ngu/data/models/transportDashboard.dart';
import 'package:bepop_ngu/data/models/vehicleAssignmentStatus.dart';
import 'package:bepop_ngu/data/models/transportPlanDetails.dart';
import 'package:bepop_ngu/data/models/busRouteStops.dart';
import 'package:bepop_ngu/data/models/transportAttendance.dart';
import 'package:bepop_ngu/utils/api.dart';

class TransportRepository {
  Future<List<PickupPoint>> getPickupPoints() async {
    try {
      final result =
          await Api.get(url: Api.getPickupPoints, useAuthToken: true);
      return ((result['data'] ?? []) as List)
          .map((e) => PickupPoint.fromJson(Map<String, dynamic>.from(e ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<TransportShift>> getShifts({required int pickupPointId}) async {
    try {
      final result = await Api.get(
          url: Api.getTransportationShifts,
          queryParameters: {"pickup_point_id": pickupPointId},
          useAuthToken: true);
      return ((result['data'] ?? []) as List)
          .map((e) =>
              TransportShift.fromJson(Map<String, dynamic>.from(e ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<TransportFeesResponse> getFees({required int pickupPointId}) async {
    try {
      final result = await Api.get(
          url: Api.getTransportationFees,
          queryParameters: {"pickup_point_id": pickupPointId},
          useAuthToken: true);
      return TransportFeesResponse.fromJson(result);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<TransportDashboard> getDashboard({
    required int userId,
    required int pickupDrop,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getTransportDashboard,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
          'pickup_drop': pickupDrop.toString(),
        },
      );
      return TransportDashboard.fromJson(Map.from(result['data'] ?? {}));
    } catch (e, st) {
      print("this is the error: $e");
      print("this is the stack trace: $st");
      throw ApiException(e.toString());
    }
  }

  Future<VehicleAssignmentStatus> getVehicleAssignmentStatus({
    required int userId,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getVehicleAssignmentStatus,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );
      return VehicleAssignmentStatus.fromJson(Map.from(result));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<TransportPlanDetails> getCurrentTransportPlan({
    required int userId,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getCurrentTransportPlan,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );
      return TransportPlanDetails.fromJson(Map.from(result['data'] ?? {}));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<BusRouteStops> getRouteStops({
    required int userId,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getRouteStops,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );
      return BusRouteStops.fromJson(Map.from(result['data'] ?? {}));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<TransportAttendanceResponse> getTransportAttendance({
    required int userId,
    required String month,
    required String tripType,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getTransportAttendanceList,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
          'month': month,
          'trip_type': tripType,
        },
      );
      return TransportAttendanceResponse.fromJson(Map.from(result));
    } catch (e) {
      throw Exception('Failed to get transport attendance: ${e.toString()}');
    }
  }

  Future<TransportRequestsResponse> getTransportRequests({
    required int userId,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getTransportRequests,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );
      return TransportRequestsResponse.fromJson(Map.from(result));
    } catch (e) {
      throw Exception('Failed to get transport requests: ${e.toString()}');
    }
  }
}
