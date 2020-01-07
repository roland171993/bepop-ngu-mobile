import 'package:bepop_ngu/data/models/transportPlanDetails.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TransportPlanDetailsState {}

class TransportPlanDetailsInitial extends TransportPlanDetailsState {}

class TransportPlanDetailsFetchInProgress extends TransportPlanDetailsState {}

class TransportPlanDetailsFetchSuccess extends TransportPlanDetailsState {
  final TransportPlanDetails planDetails;

  TransportPlanDetailsFetchSuccess({required this.planDetails});
}

class TransportPlanDetailsNoData extends TransportPlanDetailsState {
  final String message;

  TransportPlanDetailsNoData({required this.message});
}

class TransportPlanDetailsFetchFailure extends TransportPlanDetailsState {
  final String errorMessage;

  TransportPlanDetailsFetchFailure(this.errorMessage);
}

class TransportPlanDetailsCubit extends Cubit<TransportPlanDetailsState> {
  final TransportRepository _transportRepository = TransportRepository();

  TransportPlanDetailsCubit() : super(TransportPlanDetailsInitial());

  void fetchPlanDetails({required int userId}) async {
    try {
      emit(TransportPlanDetailsFetchInProgress());

      final planDetails = await _transportRepository.getCurrentTransportPlan(
        userId: userId,
      );

      // CRITICAL FIX: Even if payment is expired (paymentId null), we still need shift_id
      // Check if we have shift_id - that's all we need for renewal
      if (planDetails.shiftId != null) {
        emit(TransportPlanDetailsFetchSuccess(planDetails: planDetails));
      } else if (planDetails.paymentId == null &&
          planDetails.route?.name == null &&
          planDetails.pickupStop?.name == null &&
          planDetails.shiftId == null) {
        emit(TransportPlanDetailsNoData(
            message: "No current transport plan found"));
      } else {
        emit(TransportPlanDetailsFetchSuccess(planDetails: planDetails));
      }
    } catch (e) {
      emit(TransportPlanDetailsFetchFailure(e.toString()));
    }
  }

  void refreshPlanDetails({required int userId}) {
    fetchPlanDetails(userId: userId);
  }

  // Helper methods to get plan details
  TransportPlanDetails? getPlanDetails() {
    if (state is TransportPlanDetailsFetchSuccess) {
      return (state as TransportPlanDetailsFetchSuccess).planDetails;
    }
    return null;
  }

  bool isDataLoaded() {
    return state is TransportPlanDetailsFetchSuccess;
  }

  bool isLoading() {
    return state is TransportPlanDetailsFetchInProgress;
  }

  bool hasError() {
    return state is TransportPlanDetailsFetchFailure;
  }

  bool hasNoData() {
    return state is TransportPlanDetailsNoData;
  }

  String getErrorMessage() {
    if (state is TransportPlanDetailsFetchFailure) {
      return (state as TransportPlanDetailsFetchFailure).errorMessage;
    }
    return '';
  }

  String getNoDataMessage() {
    if (state is TransportPlanDetailsNoData) {
      return (state as TransportPlanDetailsNoData).message;
    }
    return 'No transport plan found';
  }
}
