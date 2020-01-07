import 'package:bepop_ngu/data/models/paymentGateway.dart';
import 'package:bepop_ngu/data/models/paymentTransaction.dart';
import 'package:bepop_ngu/data/repositories/transportationPaymentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TransportationPrePaymentTasksState {}

class TransportationPrePaymentTasksInitial
    extends TransportationPrePaymentTasksState {}

class TransportationPrePaymentTasksInProgress
    extends TransportationPrePaymentTasksState {}

class TransportationPrePaymentTasksSuccess
    extends TransportationPrePaymentTasksState {
  final PaymentGeteway paymentMethod;
  final PaymentTransaction paymentTransaction;
  final Map<String, dynamic> data;

  TransportationPrePaymentTasksSuccess({
    required this.paymentMethod,
    required this.paymentTransaction,
    required this.data,
  });
}

class TransportationPrePaymentTasksFailure
    extends TransportationPrePaymentTasksState {
  final String errorMessage;

  TransportationPrePaymentTasksFailure(this.errorMessage);
}

class TransportationPrePaymentTasksCubit
    extends Cubit<TransportationPrePaymentTasksState> {
  final TransportationPaymentRepository _transportationPaymentRepository =
      TransportationPaymentRepository();

  TransportationPrePaymentTasksCubit()
      : super(TransportationPrePaymentTasksInitial());

  Future<void> performPrePaymentTasks({
    required PaymentGeteway paymentMethod,
    required int userId,
    required int pickupPointId,
    required int transportationFeeId,
    required int shiftId,
    bool isChangeRoute = false,
  }) async {
    try {
      emit(TransportationPrePaymentTasksInProgress());

      final (:paymentTransaction, :data) =
          await _transportationPaymentRepository.payTransportationFee(
        paymentMethod: paymentMethod.paymentMethod ?? "",
        userId: userId,
        pickupPointId: pickupPointId,
        transportationFeeId: transportationFeeId,
        shiftId: shiftId,
        isChangeRoute: isChangeRoute,
      );

      emit(TransportationPrePaymentTasksSuccess(
        data: data,
        paymentMethod: paymentMethod,
        paymentTransaction: paymentTransaction,
      ));
    } catch (e) {
      emit(TransportationPrePaymentTasksFailure(e.toString()));
    }
  }

  String getStripePaymentClientSecret() {
    if (state is TransportationPrePaymentTasksSuccess) {
      return (state as TransportationPrePaymentTasksSuccess)
              .data['client_secret']
              ?.toString() ??
          "";
    }
    return "";
  }

  String getStripePaymentIntentId() {
    if (state is TransportationPrePaymentTasksSuccess) {
      return (state as TransportationPrePaymentTasksSuccess)
          .data['id']
          .toString();
    }
    return "";
  }

  String getRazorpayOrderId() {
    if (state is TransportationPrePaymentTasksSuccess) {
      return (state as TransportationPrePaymentTasksSuccess)
          .data['id']
          .toString();
    }
    return "";
  }

  String getFlutterwavePaymentLink() {
    if (state is TransportationPrePaymentTasksSuccess) {
      return (state as TransportationPrePaymentTasksSuccess)
              .data['payment_link']
              ?.toString() ??
          "";
    }
    return "";
  }

  String getPaystackPaymentLink() {
    if (state is TransportationPrePaymentTasksSuccess) {
      return (state as TransportationPrePaymentTasksSuccess)
              .data['payment_link']
              ?.toString() ??
          "";
    }
    return "";
  }

  double getRazorpayAmountToPay() {
    if (state is TransportationPrePaymentTasksSuccess) {
      return double.parse(
          ((state as TransportationPrePaymentTasksSuccess).data['amount'] ??
                  0.0)
              .toString());
    }
    return 0.0;
  }

  PaymentGeteway getSelectedPaymentMethod() {
    if (state is TransportationPrePaymentTasksSuccess) {
      return (state as TransportationPrePaymentTasksSuccess).paymentMethod;
    }
    return PaymentGeteway();
  }

  PaymentTransaction getPaymentTransaction() {
    if (state is TransportationPrePaymentTasksSuccess) {
      return (state as TransportationPrePaymentTasksSuccess).paymentTransaction;
    }
    return PaymentTransaction();
  }
}
