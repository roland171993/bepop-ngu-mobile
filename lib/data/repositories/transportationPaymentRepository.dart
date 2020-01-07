import 'package:bepop_ngu/data/models/paymentTransaction.dart';
import 'package:bepop_ngu/utils/api.dart';
import 'package:flutter/foundation.dart';

class TransportationPaymentRepository {
  Future<({PaymentTransaction paymentTransaction, Map<String, dynamic> data})>
      payTransportationFee({
    required String paymentMethod,
    required int userId,
    required int pickupPointId,
    required int transportationFeeId,
    int? shiftId,
    bool isChangeRoute = false,
  }) async {
    try {
      final body = {
        "payment_method": paymentMethod,
        "user_id": userId,
        "pickup_point_id": pickupPointId,
        "transportation_fee_id": transportationFeeId,
      };

      // Add shift_id if provided
      if (shiftId != null) {
        body["shift_id"] = shiftId.toString();
      }

      // Add change_route parameter if this is a route change
      if (isChangeRoute) {
        body["change_route"] = "yes";
      }

      final result = await Api.post(
          body: body, url: Api.payTransportationFees, useAuthToken: true);

      if (kDebugMode) {
        print("Transportation API Response for $paymentMethod: $result");
      }

      // Extract payment transaction
      final paymentTransaction = PaymentTransaction.fromJson(
          Map.from(result['data']['payment_transaction'] ?? {}));

      // Extract payment data based on payment method
      Map<String, dynamic> data;
      if (paymentMethod == "Flutterwave" || paymentMethod == "Paystack") {
        // For Flutterwave and Paystack, we need the entire data object as it contains the payment_link
        data = Map<String, dynamic>.from(result['data'] ?? {});

        if (kDebugMode) {
          print("Extracted payment data for $paymentMethod: $data");
        }
      } else {
        // For Stripe/Razorpay, extract payment_intent as before
        data =
            Map<String, dynamic>.from(result['data']['payment_intent'] ?? {});
      }

      return (paymentTransaction: paymentTransaction, data: data);
    } catch (e) {
      if (kDebugMode) {
        print("Error in payTransportationFee: $e");
      }
      throw ApiException(e.toString());
    }
  }

  Future<void> storeTransportationPayment({
    required String transactionId,
    required int userId,
    String? paymentId,
    String? paymentSignature,
  }) async {
    try {
      await Api.post(
        url: Api.storeFeesParent, // Using the same endpoint for now
        useAuthToken: true,
        body: {
          "transaction_id": transactionId,
          "user_id": userId,
          if (paymentId != null) "payment_id": paymentId,
          if (paymentSignature != null) "payment_signature": paymentSignature,
        },
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> failTransportationPaymentTransaction({
    required String transactionId,
  }) async {
    try {
      await Api.post(
        url: Api.failPaymentTransaction,
        body: {
          "payment_transaction_id": transactionId,
        },
        useAuthToken: true,
      );
    } catch (_) {}
  }
}
