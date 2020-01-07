import 'package:bepop_ngu/data/models/transportShift.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ShiftsState {}

class ShiftsInitial extends ShiftsState {}

class ShiftsFetchInProgress extends ShiftsState {}

class ShiftsFetchSuccess extends ShiftsState {
  final List<TransportShift> shifts;
  ShiftsFetchSuccess({required this.shifts});
}

class ShiftsFetchFailure extends ShiftsState {
  final String errorMessage;
  ShiftsFetchFailure(this.errorMessage);
}

class ShiftsCubit extends Cubit<ShiftsState> {
  final TransportRepository _repository = TransportRepository();
  ShiftsCubit() : super(ShiftsInitial());

  Future<void> fetch({required int pickupPointId}) async {
    emit(ShiftsFetchInProgress());
    try {
      final data = await _repository.getShifts(pickupPointId: pickupPointId);
      emit(ShiftsFetchSuccess(shifts: data));
    } catch (e) {
      emit(ShiftsFetchFailure(e.toString()));
    }
  }
}
