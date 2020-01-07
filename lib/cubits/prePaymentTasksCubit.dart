import 'package:bepop_ngu/data/models/paymentGateway.dart';
import 'package:bepop_ngu/data/models/paymentTransaction.dart';
import 'package:bepop_ngu/data/repositories/feeRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class PrePaymentTasksState {}

class PrePaymentTasksInitial extends PrePaymentTasksState {}

class PrePaymentTasksInProgress extends PrePaymentTasksState {}

class PrePaymentTasksSuccess extends PrePaymentTasksState {
  final Map<String, dynamic> data;
  final PaymentGeteway paymentMethod;
  final PaymentTransaction paymentTransaction;

  PrePaymentTasksSuccess(
      {required this.data,
      required this.paymentMethod,
      required this.paymentTransaction});
}

class PrePaymentTasksFailure extends PrePaymentTasksState {
  final String errorMessage;

  PrePaymentTasksFailure(this.errorMessage);
}

class PrePaymentTasksCubit extends Cubit<PrePaymentTasksState> {
  final FeeRepository _feeRepository = FeeRepository();

  PrePaymentTasksCubit() : super(PrePaymentTasksInitial());

  Future<void> performPrePaymentTasks(
      {required PaymentGeteway paymentMethod,
      required int childId,
      required int feeId,
      required bool compulsoryFee,
      List<int>? installmentIds,
      double? advanceAmount,
      List<int>? optionalFeeIds}) async {
    try {
      emit(PrePaymentTasksInProgress());
      final (:paymentTransaction, :data) = compulsoryFee
          ? await _feeRepository.payCompulsoryFee(
              advanceAmount: advanceAmount,
              installmentIds: installmentIds,
              paymentMethod: paymentMethod.paymentMethod ?? "",
              childId: childId,
              feeId: feeId)
          : await _feeRepository.payOptionalFees(
              paymentMethod: paymentMethod.paymentMethod ?? "",
              childId: childId,
              feeId: feeId,
              optionalFeeIds: optionalFeeIds ?? []);

      emit(PrePaymentTasksSuccess(
          data: data,
          paymentMethod: paymentMethod,
          paymentTransaction: paymentTransaction));
    } catch (e) {
      emit(PrePaymentTasksFailure(e.toString()));
    }
  }

  String getStripePaymentIntentId() {
    if (state is PrePaymentTasksSuccess) {
      return (state as PrePaymentTasksSuccess).data['id'].toString();
    }
    return "";
  }

  String getRazorpayOrderId() {
    if (state is PrePaymentTasksSuccess) {
      return (state as PrePaymentTasksSuccess).data['id'].toString();
    }
    return "";
  }

  double getRazorpayAmountToPay() {
    if (state is PrePaymentTasksSuccess) {
      return double.parse(
          ((state as PrePaymentTasksSuccess).data['amount'] ?? 0.0).toString());
    }
    return 0.0;
  }

  PaymentGeteway getSelectedPaymentMethod() {
    if (state is PrePaymentTasksSuccess) {
      return (state as PrePaymentTasksSuccess).paymentMethod;
    }
    return PaymentGeteway.fromJson({});
  }

  PaymentTransaction getPaymentTransaction() {
    if (state is PrePaymentTasksSuccess) {
      return (state as PrePaymentTasksSuccess).paymentTransaction;
    }
    return PaymentTransaction.fromJson({});
  }

  String getStripePaymentClientSecret() {
    if (state is PrePaymentTasksSuccess) {
      return (state as PrePaymentTasksSuccess).data['client_secret'].toString();
    }
    return "";
  }

  String getFlutterwavePaymentLink() {
    if (state is PrePaymentTasksSuccess) {
      try {
        // Based on the API response structure
        final paymentData = (state as PrePaymentTasksSuccess).data;

        if (kDebugMode) {
          print("Flutterwave response data: $paymentData");
        }

        // First check if payment_link is directly in the main data
        if (paymentData.containsKey('payment_link') &&
            paymentData['payment_link'] != null) {
          final paymentLink = paymentData['payment_link'];
          if (kDebugMode) {
            print("Found Flutterwave payment link directly: $paymentLink");
          }
          return paymentLink.toString();
        }

        // Check if there is a data field and payment_link is in there
        if (paymentData.containsKey('data') && paymentData['data'] != null) {
          final nestedData = paymentData['data'];

          if (nestedData is Map && nestedData.containsKey('payment_link')) {
            final paymentLink = nestedData['payment_link'];
            if (kDebugMode) {
              print("Found Flutterwave payment link in data: $paymentLink");
            }
            return paymentLink.toString();
          }

          // Also check for payment_intent structure
          if (nestedData is Map &&
              nestedData.containsKey('payment_intent') &&
              nestedData['payment_intent'] != null) {
            final paymentIntent = nestedData['payment_intent'];
            if (paymentIntent is Map &&
                paymentIntent.containsKey('data') &&
                paymentIntent['data'] != null) {
              final intentData = paymentIntent['data'];
              if (intentData is Map && intentData.containsKey('link')) {
                final paymentLink = intentData['link'];
                if (kDebugMode) {
                  print(
                      "Found Flutterwave payment link in payment_intent: $paymentLink");
                }
                return paymentLink.toString();
              }
            }
          }
        }

        if (kDebugMode) {
          print("Error: Could not find payment_link in response: $paymentData");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error getting Flutterwave payment link: $e");
        }
      }
    }
    return "";
  }

  String getPaystackPaymentLink() {
    if (state is PrePaymentTasksSuccess) {
      try {
        // Based on the API response structure
        final paymentData = (state as PrePaymentTasksSuccess).data;

        if (kDebugMode) {
          print("Paystack response data: $paymentData");
        }

        // First check if payment_link is directly in the main data
        if (paymentData.containsKey('payment_link') &&
            paymentData['payment_link'] != null) {
          final paymentLink = paymentData['payment_link'];
          if (kDebugMode) {
            print("Found Paystack payment link directly: $paymentLink");
          }
          return paymentLink.toString();
        }

        // Check if there is a data field and payment_link is in there
        if (paymentData.containsKey('data') && paymentData['data'] != null) {
          final nestedData = paymentData['data'];

          if (nestedData is Map && nestedData.containsKey('payment_link')) {
            final paymentLink = nestedData['payment_link'];
            if (kDebugMode) {
              print("Found Paystack payment link in data: $paymentLink");
            }
            return paymentLink.toString();
          }

          // Also check for payment_intent structure like Flutterwave
          if (nestedData is Map &&
              nestedData.containsKey('payment_intent') &&
              nestedData['payment_intent'] != null) {
            final paymentIntent = nestedData['payment_intent'];
            if (paymentIntent is Map &&
                paymentIntent.containsKey('data') &&
                paymentIntent['data'] != null) {
              final intentData = paymentIntent['data'];
              if (intentData is Map && intentData.containsKey('link')) {
                final paymentLink = intentData['link'];
                if (kDebugMode) {
                  print(
                      "Found Paystack payment link in payment_intent: $paymentLink");
                }
                return paymentLink.toString();
              }
            }
          }
        }

        if (kDebugMode) {
          print("Error: Could not find payment_link in response: $paymentData");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error getting Paystack payment link: $e");
        }
      }
    }
    return "";
  }
}
