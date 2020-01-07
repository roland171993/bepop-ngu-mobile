import 'package:bepop_ngu/data/models/liveRoute.dart';
import 'package:bepop_ngu/data/repositories/liveRouteRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LiveRouteState {}

class LiveRouteInitial extends LiveRouteState {}

class LiveRouteFetchInProgress extends LiveRouteState {
  final bool isRefresh;
  final LiveRouteResponse? previousData;

  LiveRouteFetchInProgress({this.isRefresh = false, this.previousData});
}

class LiveRouteFetchSuccess extends LiveRouteState {
  final LiveRouteResponse liveRouteResponse;
  final bool wasRefresh;

  LiveRouteFetchSuccess({
    required this.liveRouteResponse,
    this.wasRefresh = false,
  });
}

class LiveRouteFetchFailure extends LiveRouteState {
  final String errorMessage;
  final bool wasRefresh;
  final LiveRouteResponse? previousData;

  LiveRouteFetchFailure(
    this.errorMessage, {
    this.wasRefresh = false,
    this.previousData,
  });
}

// Cubit
class LiveRouteCubit extends Cubit<LiveRouteState> {
  final LiveRouteRepository _repository = LiveRouteRepository();

  LiveRouteCubit() : super(LiveRouteInitial());

  Future<void> fetchLiveRoute({
    required int userId,
    bool isRefresh = false,
  }) async {
    final currentData = state is LiveRouteFetchSuccess
        ? (state as LiveRouteFetchSuccess).liveRouteResponse
        : null;

    emit(
      LiveRouteFetchInProgress(isRefresh: isRefresh, previousData: currentData),
    );

    try {
      final response = await _repository.getLiveRoute(userId: userId);
      emit(
        LiveRouteFetchSuccess(
          liveRouteResponse: response,
          wasRefresh: isRefresh,
        ),
      );
    } catch (e) {
      emit(
        LiveRouteFetchFailure(
          e.toString(),
          wasRefresh: isRefresh,
          previousData: currentData,
        ),
      );
    }
  }

  Future<void> refreshLiveRoute({required int userId}) async {
    await fetchLiveRoute(userId: userId, isRefresh: true);
  }

  // Helper methods
  bool hasActiveTrip() {
    if (state is LiveRouteFetchSuccess) {
      final response = (state as LiveRouteFetchSuccess).liveRouteResponse;
      return response.hasTrip;
    }
    if (state is LiveRouteFetchInProgress) {
      final inProgressState = state as LiveRouteFetchInProgress;
      if (inProgressState.previousData != null) {
        return inProgressState.previousData!.hasTrip;
      }
    }
    if (state is LiveRouteFetchFailure) {
      final failureState = state as LiveRouteFetchFailure;
      if (failureState.previousData != null) {
        return failureState.previousData!.hasTrip;
      }
    }
    return false;
  }

  String getNoTripMessage() {
    if (state is LiveRouteFetchSuccess) {
      final response = (state as LiveRouteFetchSuccess).liveRouteResponse;
      return response.isNoTripMessage
          ? response.noTripMessage
          : 'No trip found';
    }
    if (state is LiveRouteFetchInProgress) {
      final inProgressState = state as LiveRouteFetchInProgress;
      if (inProgressState.previousData != null) {
        final response = inProgressState.previousData!;
        return response.isNoTripMessage
            ? response.noTripMessage
            : 'No trip found';
      }
    }
    if (state is LiveRouteFetchFailure) {
      final failureState = state as LiveRouteFetchFailure;
      if (failureState.previousData != null) {
        final response = failureState.previousData!;
        return response.isNoTripMessage
            ? response.noTripMessage
            : 'No trip found';
      }
    }
    return 'No trip found';
  }

  List<LiveTrip> getLiveTrips() {
    if (state is LiveRouteFetchSuccess) {
      final response = (state as LiveRouteFetchSuccess).liveRouteResponse;
      return response.trips;
    }
    if (state is LiveRouteFetchInProgress) {
      final inProgressState = state as LiveRouteFetchInProgress;
      if (inProgressState.previousData != null) {
        return inProgressState.previousData!.trips;
      }
    }
    if (state is LiveRouteFetchFailure) {
      final failureState = state as LiveRouteFetchFailure;
      if (failureState.previousData != null) {
        return failureState.previousData!.trips;
      }
    }
    return [];
  }

  LiveTrip? getFirstLiveTrip() {
    final trips = getLiveTrips();
    return trips.isNotEmpty ? trips.first : null;
  }

  bool get isRefreshing =>
      state is LiveRouteFetchInProgress &&
      (state as LiveRouteFetchInProgress).isRefresh;
}
