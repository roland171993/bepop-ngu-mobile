import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepop_ngu/data/models/transportDashboard.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';

abstract class TransportRequestDetailsState {}

class TransportRequestDetailsInitial extends TransportRequestDetailsState {}

class TransportRequestDetailsFetchInProgress
    extends TransportRequestDetailsState {}

class TransportRequestDetailsFetchSuccess extends TransportRequestDetailsState {
  final TransportRequestsResponse requestsResponse;

  TransportRequestDetailsFetchSuccess({required this.requestsResponse});
}

class TransportRequestDetailsFetchFailure extends TransportRequestDetailsState {
  final String errorMessage;

  TransportRequestDetailsFetchFailure({required this.errorMessage});
}

class TransportRequestDetailsNoData extends TransportRequestDetailsState {}

class TransportRequestDetailsCubit extends Cubit<TransportRequestDetailsState> {
  final TransportRepository _transportRepository;

  TransportRequestDetailsCubit(
      {required TransportRepository transportRepository})
      : _transportRepository = transportRepository,
        super(TransportRequestDetailsInitial());

  Future<void> fetchTransportRequestDetails({required int userId}) async {
    try {
      emit(TransportRequestDetailsFetchInProgress());

      final result =
          await _transportRepository.getTransportRequests(userId: userId);

      if (result.data.isEmpty) {
        emit(TransportRequestDetailsNoData());
      } else {
        emit(TransportRequestDetailsFetchSuccess(requestsResponse: result));
      }
    } catch (e) {
      emit(TransportRequestDetailsFetchFailure(errorMessage: e.toString()));
    }
  }

  // Helper methods to get data from the current state
  List<TransportRequest> getTransportRequests() {
    final currentState = state;
    if (currentState is TransportRequestDetailsFetchSuccess) {
      return currentState.requestsResponse.data;
    }
    return [];
  }

  TransportRequest? getFirstTransportRequest() {
    final requests = getTransportRequests();
    return requests.isNotEmpty ? requests.first : null;
  }

  TransportRequest? getTransportRequestById(int id) {
    final requests = getTransportRequests();
    try {
      return requests.firstWhere((request) => request.id == id);
    } catch (e) {
      return null;
    }
  }

  bool hasTransportRequests() {
    return getTransportRequests().isNotEmpty;
  }
}
