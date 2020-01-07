import 'package:bepop_ngu/data/models/transportDashboard.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TransportDashboardState {}

class TransportDashboardInitial extends TransportDashboardState {}

class TransportDashboardFetchInProgress extends TransportDashboardState {}

class TransportDashboardFetchSuccess extends TransportDashboardState {
  final TransportDashboard dashboard;

  TransportDashboardFetchSuccess({required this.dashboard});
}

class TransportDashboardNoData extends TransportDashboardState {
  final String statusMessage;

  TransportDashboardNoData({required this.statusMessage});
}

class TransportDashboardFetchFailure extends TransportDashboardState {
  final String errorMessage;

  TransportDashboardFetchFailure(this.errorMessage);
}

class TransportDashboardCubit extends Cubit<TransportDashboardState> {
  final TransportRepository _transportRepository = TransportRepository();

  TransportDashboardCubit() : super(TransportDashboardInitial());

  void fetchDashboard({
    required int userId,
    required int pickupDrop,
  }) async {
    try {
      emit(TransportDashboardFetchInProgress());

      final dashboard = await _transportRepository.getDashboard(
        userId: userId,
        pickupDrop: pickupDrop,
      );

      // Check if response indicates no data available
      if (dashboard.hasNoData) {
        emit(TransportDashboardNoData(
            statusMessage: dashboard.status ?? "No transport plan found"));
      } else {
        emit(TransportDashboardFetchSuccess(dashboard: dashboard));
      }
    } catch (e) {
      emit(TransportDashboardFetchFailure(e.toString()));
    }
  }

  // Helper method to get live summary data
  LiveSummary? getLiveSummary() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess).dashboard.liveSummary;
    }
    return null;
  }

  void refreshDashboard({
    required int userId,
    required int pickupDrop,
  }) {
    fetchDashboard(userId: userId, pickupDrop: pickupDrop);
  }

  // Helper methods to get specific data
  TransportPlan? getPlan() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess).dashboard.plan;
    }
    return null;
  }

  BusInfo? getBusInfo() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess).dashboard.busInfo;
    }
    return null;
  }



  TodayAttendance? getTodayAttendance() {
    if (state is TransportDashboardFetchSuccess) {
      return (state as TransportDashboardFetchSuccess)
          .dashboard
          .todayAttendance;
    }
    return null;
  }

  bool isDataLoaded() {
    return state is TransportDashboardFetchSuccess;
  }

  bool isLoading() {
    return state is TransportDashboardFetchInProgress;
  }

  bool hasError() {
    return state is TransportDashboardFetchFailure;
  }

  bool hasNoData() {
    return state is TransportDashboardNoData;
  }

  String getErrorMessage() {
    if (state is TransportDashboardFetchFailure) {
      return (state as TransportDashboardFetchFailure).errorMessage;
    }
    return '';
  }

  String getNoDataMessage() {
    if (state is TransportDashboardNoData) {
      return (state as TransportDashboardNoData).statusMessage;
    }
    return 'No transport plan found';
  }
}
