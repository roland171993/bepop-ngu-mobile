import 'package:bepop_ngu/data/models/busRouteStops.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BusRouteStopsState {}

class BusRouteStopsInitial extends BusRouteStopsState {}

class BusRouteStopsFetchInProgress extends BusRouteStopsState {}

class BusRouteStopsFetchSuccess extends BusRouteStopsState {
  final BusRouteStops routeStops;

  BusRouteStopsFetchSuccess({required this.routeStops});
}

class BusRouteStopsNoData extends BusRouteStopsState {
  final String message;

  BusRouteStopsNoData({required this.message});
}

class BusRouteStopsFetchFailure extends BusRouteStopsState {
  final String errorMessage;

  BusRouteStopsFetchFailure(this.errorMessage);
}

class BusRouteStopsCubit extends Cubit<BusRouteStopsState> {
  final TransportRepository _transportRepository = TransportRepository();

  BusRouteStopsCubit() : super(BusRouteStopsInitial());

  void fetchRouteStops({required int userId}) async {
    try {
      emit(BusRouteStopsFetchInProgress());

      final routeStops = await _transportRepository.getRouteStops(
        userId: userId,
      );

      // Check if we have valid route stops data
      if (!routeStops.hasStops) {
        emit(BusRouteStopsNoData(message: "No route stops found"));
      } else {
        emit(BusRouteStopsFetchSuccess(routeStops: routeStops));
      }
    } catch (e) {
      emit(BusRouteStopsFetchFailure(e.toString()));
    }
  }

  void refreshRouteStops({required int userId}) {
    fetchRouteStops(userId: userId);
  }

  // Helper methods to get route stops data
  BusRouteStops? getRouteStops() {
    if (state is BusRouteStopsFetchSuccess) {
      return (state as BusRouteStopsFetchSuccess).routeStops;
    }
    return null;
  }

  bool isDataLoaded() {
    return state is BusRouteStopsFetchSuccess;
  }

  bool isLoading() {
    return state is BusRouteStopsFetchInProgress;
  }

  bool hasError() {
    return state is BusRouteStopsFetchFailure;
  }

  bool hasNoData() {
    return state is BusRouteStopsNoData;
  }

  String getErrorMessage() {
    if (state is BusRouteStopsFetchFailure) {
      return (state as BusRouteStopsFetchFailure).errorMessage;
    }
    return '';
  }

  String getNoDataMessage() {
    if (state is BusRouteStopsNoData) {
      return (state as BusRouteStopsNoData).message;
    }
    return 'No route stops found';
  }

  // Helper method to get current user stop index
  int getUserStopIndex() {
    final routeStops = getRouteStops();
    if (routeStops != null) {
      return routeStops.userStopIndex;
    }
    return -1;
  }

  // Helper method to check if user has a pickup stop
  bool hasUserStop() {
    final routeStops = getRouteStops();
    if (routeStops != null) {
      return routeStops.userStop != null;
    }
    return false;
  }
}
