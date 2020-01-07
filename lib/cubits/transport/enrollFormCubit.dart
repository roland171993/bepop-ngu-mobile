import 'package:bepop_ngu/data/models/pickupPoint.dart';
import 'package:bepop_ngu/data/models/transportFee.dart';
import 'package:bepop_ngu/data/models/transportShift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransportEnrollFormState {
  final bool isPickupOpen;
  final bool isShiftOpen;
  final bool isDurationOpen;
  final PickupPoint? selectedPickup;
  final TransportShift? selectedShift;
  final TransportFeePlan? selectedFee;

  const TransportEnrollFormState({
    required this.isPickupOpen,
    required this.isShiftOpen,
    required this.isDurationOpen,
    this.selectedPickup,
    this.selectedShift,
    this.selectedFee,
  });

  TransportEnrollFormState copyWith({
    bool? isPickupOpen,
    bool? isShiftOpen,
    bool? isDurationOpen,
    PickupPoint? selectedPickup,
    TransportShift? selectedShift,
    TransportFeePlan? selectedFee,
  }) {
    return TransportEnrollFormState(
      isPickupOpen: isPickupOpen ?? this.isPickupOpen,
      isShiftOpen: isShiftOpen ?? this.isShiftOpen,
      isDurationOpen: isDurationOpen ?? this.isDurationOpen,
      selectedPickup: selectedPickup ?? this.selectedPickup,
      selectedShift: selectedShift ?? this.selectedShift,
      selectedFee: selectedFee ?? this.selectedFee,
    );
  }
}

class TransportEnrollFormCubit extends Cubit<TransportEnrollFormState> {
  TransportEnrollFormCubit()
      : super(const TransportEnrollFormState(
          isPickupOpen: false,
          isShiftOpen: false,
          isDurationOpen: false,
        ));

  void togglePickupOpen() {
    emit(state.copyWith(
      isPickupOpen: !state.isPickupOpen,
      isShiftOpen: false,
      isDurationOpen: false,
    ));
  }

  void toggleShiftOpen() {
    emit(state.copyWith(
      isShiftOpen: !state.isShiftOpen,
      isPickupOpen: false,
      isDurationOpen: false,
    ));
  }

  void toggleDurationOpen() {
    emit(state.copyWith(
      isDurationOpen: !state.isDurationOpen,
      isPickupOpen: false,
      isShiftOpen: false,
    ));
  }

  void selectPickup(PickupPoint pickupPoint) {
    emit(state.copyWith(
      selectedPickup: pickupPoint,
      selectedShift: null,
      selectedFee: null,
      isPickupOpen: false,
    ));
  }

  void selectShift(TransportShift shift) {
    emit(state.copyWith(
      selectedShift: shift,
      isShiftOpen: false,
    ));
  }

  void selectFee(TransportFeePlan fee) {
    emit(state.copyWith(
      selectedFee: fee,
      isDurationOpen: false,
    ));
  }
}
