import 'package:bepop_ngu/data/models/transportFee.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FeesState {}

class FeesInitial extends FeesState {}

class FeesFetchInProgress extends FeesState {}

class FeesFetchSuccess extends FeesState {
  final TransportFeesResponse feesResponse;
  FeesFetchSuccess({required this.feesResponse});
}

class FeesFetchFailure extends FeesState {
  final String errorMessage;
  FeesFetchFailure(this.errorMessage);
}

class FeesCubit extends Cubit<FeesState> {
  final TransportRepository _repository = TransportRepository();
  FeesCubit() : super(FeesInitial());

  Future<void> fetch({required int pickupPointId}) async {
    emit(FeesFetchInProgress());
    try {
      final data = await _repository.getFees(pickupPointId: pickupPointId);
      emit(FeesFetchSuccess(feesResponse: data));
    } catch (e) {
      emit(FeesFetchFailure(e.toString()));
    }
  }
}
