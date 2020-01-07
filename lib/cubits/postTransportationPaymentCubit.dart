// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:bepop_ngu/data/repositories/transportationPaymentRepository.dart';
import 'package:bepop_ngu/data/repositories/studentRepository.dart';
import 'package:bepop_ngu/utils/stripeService.dart';
import 'package:flutter/foundation.dart';

abstract class PostTransportationPaymentState {}

class PostTransportationPaymentInitial extends PostTransportationPaymentState {}

class PostTransportationPaymentSuccess extends PostTransportationPaymentState {}

class PostTransportationPaymentFailure extends PostTransportationPaymentState {
  final String errorMessage;

  PostTransportationPaymentFailure(this.errorMessage);
}

class PostTransportationPaymentInProgress
    extends PostTransportationPaymentState {}

class PostTransportationPaymentCubit
    extends Cubit<PostTransportationPaymentState> {
  final TransportationPaymentRepository _transportationPaymentRepository;
  final StudentRepository _studentRepository;

  PostTransportationPaymentCubit(
      this._transportationPaymentRepository, this._studentRepository)
      : super(PostTransportationPaymentInitial());

  Future<void> storeTransportationPayment({
    required int? status,
    required String transactionId,
    required int userId,
    required bool verifyStripePaymentIntent,
    String? stripePaymentSecretKey,
    String? paymentIntentId,
    String? paymentId,
    String? paymentSignature,
  }) async {
    emit(PostTransportationPaymentInProgress());
    try {
      if (status == 1 || verifyStripePaymentIntent) {
        // 1 is success when calling this function
        if (verifyStripePaymentIntent) {
          final paymentIntentStatus =
              await _studentRepository.confirmStripePayment(
            paymentIntentId: paymentIntentId ?? "",
            paymentSecretKey: stripePaymentSecretKey ?? "",
          );

          if (paymentIntentStatus !=
              StripeService.paymentIntentSuccessResponse) {
            throw Exception("Transportation payment failed");
          }
        }
        await _transportationPaymentRepository.storeTransportationPayment(
          userId: userId,
          transactionId: transactionId,
          paymentId: paymentId,
          paymentSignature: paymentSignature,
        );
        emit(PostTransportationPaymentSuccess());
      } else {
        if (kDebugMode) {
          print("Transportation Payment Error because of status.");
        }
        await _transportationPaymentRepository
            .failTransportationPaymentTransaction(
          transactionId: transactionId,
        );
        emit(PostTransportationPaymentFailure("Transportation payment failed"));
      }
    } catch (e, st) {
      if (kDebugMode) {
        print("Transportation Payment Error: $e $st");
      }
      await _transportationPaymentRepository
          .failTransportationPaymentTransaction(
        transactionId: transactionId,
      );
      emit(PostTransportationPaymentFailure(e.toString()));
    }
  }
}
