import 'package:bepop_ngu/data/models/vehicleAssignmentStatus.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class VehicleAssignmentStatusState {}

class VehicleAssignmentStatusInitial extends VehicleAssignmentStatusState {}

class VehicleAssignmentStatusFetchInProgress
    extends VehicleAssignmentStatusState {}

class VehicleAssignmentStatusFetchSuccess extends VehicleAssignmentStatusState {
  final VehicleAssignmentStatus assignmentStatus;

  VehicleAssignmentStatusFetchSuccess({required this.assignmentStatus});
}

class VehicleAssignmentStatusFetchFailure extends VehicleAssignmentStatusState {
  final String errorMessage;

  VehicleAssignmentStatusFetchFailure(this.errorMessage);
}

class VehicleAssignmentStatusCubit extends Cubit<VehicleAssignmentStatusState> {
  final TransportRepository _transportRepository = TransportRepository();

  VehicleAssignmentStatusCubit() : super(VehicleAssignmentStatusInitial());

  void checkVehicleAssignmentStatus({required int userId}) async {
    try {
      emit(VehicleAssignmentStatusFetchInProgress());

      final assignmentStatus =
          await _transportRepository.getVehicleAssignmentStatus(
        userId: userId,
      );

      emit(VehicleAssignmentStatusFetchSuccess(
          assignmentStatus: assignmentStatus));
    } catch (e) {
      emit(VehicleAssignmentStatusFetchFailure(e.toString()));
    }
  }

  void refreshAssignmentStatus({required int userId}) {
    checkVehicleAssignmentStatus(userId: userId);
  }

  // Helper methods to get assignment status
  VehicleAssignmentStatus? getAssignmentStatus() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess).assignmentStatus;
    }
    return null;
  }

  bool isAssigned() {
    final status = getAssignmentStatus();
    return status?.isAssigned ?? false;
  }

  bool shouldShowTransportHome() {
    final status = getAssignmentStatus();
    return status?.shouldShowTransportHome ?? false;
  }

  bool shouldShowEnrollmentFlow() {
    final status = getAssignmentStatus();
    return status?.shouldShowEnrollmentFlow ??
        true; // Default to enrollment if unknown
  }

  bool isExpired() {
    final status = getAssignmentStatus();
    return status?.isExpired ?? false;
  }

  bool isPending() {
    final status = getAssignmentStatus();
    return status?.isPending ?? false;
  }

  bool isStatusAssigned() {
    final status = getAssignmentStatus();
    return status?.isStatusAssigned ?? false;
  }

  bool isDataLoaded() {
    return state is VehicleAssignmentStatusFetchSuccess;
  }

  bool isLoading() {
    return state is VehicleAssignmentStatusFetchInProgress;
  }

  bool hasError() {
    return state is VehicleAssignmentStatusFetchFailure;
  }

  String getErrorMessage() {
    if (state is VehicleAssignmentStatusFetchFailure) {
      return (state as VehicleAssignmentStatusFetchFailure).errorMessage;
    }
    return '';
  }
}
