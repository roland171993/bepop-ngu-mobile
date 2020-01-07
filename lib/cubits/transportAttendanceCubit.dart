import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepop_ngu/data/models/transportAttendance.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';

abstract class TransportAttendanceState {}

class TransportAttendanceInitial extends TransportAttendanceState {}

class TransportAttendanceFetchInProgress extends TransportAttendanceState {}

class TransportAttendanceFetchSuccess extends TransportAttendanceState {
  final TransportAttendanceResponse attendanceResponse;
  final String selectedTripType;
  final String selectedMonth;

  TransportAttendanceFetchSuccess({
    required this.attendanceResponse,
    required this.selectedTripType,
    required this.selectedMonth,
  });
}

class TransportAttendanceFetchFailure extends TransportAttendanceState {
  final String errorMessage;

  TransportAttendanceFetchFailure({required this.errorMessage});
}

class TransportAttendanceNoData extends TransportAttendanceState {
  final String message;

  TransportAttendanceNoData({required this.message});
}

class TransportAttendanceCubit extends Cubit<TransportAttendanceState> {
  final TransportRepository _transportRepository = TransportRepository();

  TransportAttendanceCubit() : super(TransportAttendanceInitial());

  Future<void> fetchTransportAttendance({
    required int userId,
    required String month,
    required String tripType,
  }) async {
    emit(TransportAttendanceFetchInProgress());

    try {
      final response = await _transportRepository.getTransportAttendance(
        userId: userId,
        month: month,
        tripType: tripType,
      );

      if (response.error) {
        emit(TransportAttendanceFetchFailure(errorMessage: response.message));
        return;
      }

      if (response.data == null) {
        emit(TransportAttendanceNoData(message: "No attendance data found"));
        return;
      }

      emit(TransportAttendanceFetchSuccess(
        attendanceResponse: response,
        selectedTripType: tripType,
        selectedMonth: month,
      ));
    } catch (e) {
      emit(TransportAttendanceFetchFailure(errorMessage: e.toString()));
    }
  }

  // Helper methods to get attendance data
  TransportAttendanceData? getAttendanceData() {
    if (state is TransportAttendanceFetchSuccess) {
      return (state as TransportAttendanceFetchSuccess).attendanceResponse.data;
    }
    return null;
  }

  AttendanceSummary? getAttendanceSummary() {
    return getAttendanceData()?.summary;
  }

  List<AttendanceRecord> getAttendanceRecords() {
    return getAttendanceData()?.records ?? [];
  }

  List<AttendanceRecord> getPresentRecords() {
    return getAttendanceRecords().where((record) => record.isPresent).toList();
  }

  List<AttendanceRecord> getAbsentRecords() {
    return getAttendanceRecords().where((record) => record.isAbsent).toList();
  }

  String getCurrentTripType() {
    if (state is TransportAttendanceFetchSuccess) {
      return (state as TransportAttendanceFetchSuccess).selectedTripType;
    }
    return 'pickup';
  }

  String getCurrentMonth() {
    if (state is TransportAttendanceFetchSuccess) {
      return (state as TransportAttendanceFetchSuccess).selectedMonth;
    }
    return DateTime.now().month.toString().padLeft(2, '0');
  }

  // Method to change trip type and refetch data
  Future<void> changeTripType({
    required int userId,
    required String tripType,
  }) async {
    final currentMonth = getCurrentMonth();
    await fetchTransportAttendance(
      userId: userId,
      month: currentMonth,
      tripType: tripType,
    );
  }

  // Method to change month and refetch data
  Future<void> changeMonth({
    required int userId,
    required String month,
  }) async {
    final currentTripType = getCurrentTripType();
    await fetchTransportAttendance(
      userId: userId,
      month: month,
      tripType: currentTripType,
    );
  }
}
