import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/schoolConfigurationCubit.dart';
import 'package:bepop_ngu/cubits/transportationPrePaymentTasksCubit.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/errorMessageKeysAndCodes.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// A service class that handles all payment gateway integrations
/// This class provides a centralized way to handle payments across the app
class PaymentGatewayService {
  final BuildContext context;
  final Razorpay _razorpay;
  final VoidCallback onPaymentComplete;
  final TransportationPrePaymentTasksCubit transportationCubit;
  final SchoolConfigurationCubit schoolConfigCubit;
  final AuthCubit authCubit;

  PaymentGatewayService({
    required this.context,
    required Razorpay razorpay,
    required this.onPaymentComplete,
    required this.transportationCubit,
    required this.schoolConfigCubit,
    required this.authCubit,
  }) : _razorpay = razorpay {
    _initializeRazorpay();
  }

  /// Initialize Razorpay event listeners
  void _initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayPaymentError);
  }

  /// Navigate to confirm payment screen
  void _navigateToConfirmPaymentScreen() {
    Get.offNamed(Routes.confirmPayment);
  }

  /// Handle Razorpay payment success
  void _handleRazorpayPaymentSuccess(PaymentSuccessResponse response) {
    onPaymentComplete();
    _navigateToConfirmPaymentScreen();
  }

  /// Handle Razorpay payment error
  void _handleRazorpayPaymentError(PaymentFailureResponse response) {
    onPaymentComplete();
    _navigateToConfirmPaymentScreen();
  }

  /// Process payment with Razorpay
  /// [razorpayApiKey] - The API key for Razorpay
  Future<void> payWithRazorpay({required String razorpayApiKey}) async {
    try {
      final options = {
        'key': razorpayApiKey,
        'order_id': transportationCubit.getRazorpayOrderId(),
        'name': schoolConfigCubit
                .getSchoolConfiguration()
                .schoolSettings
                .schoolName ??
            '',
        'prefill': {
          'contact': authCubit.getParentDetails().mobile ?? "",
          'email': authCubit.getParentDetails().email ?? ""
        },
      };

      _razorpay.open(options);
    } catch (e) {
      onPaymentComplete();
      _navigateToConfirmPaymentScreen();
    }
  }

  /// Process payment with Stripe
  /// [stripePublishableKey] - The publishable key for Stripe
  Future<void> payWithStripe({required String stripePublishableKey}) async {
    try {
      Stripe.publishableKey = stripePublishableKey;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          billingDetailsCollectionConfiguration:
              BillingDetailsCollectionConfiguration(
            address: AddressCollectionMode.full,
            email: CollectionMode.always,
            name: CollectionMode.always,
            phone: CollectionMode.always,
          ),
          paymentIntentClientSecret:
              transportationCubit.getStripePaymentClientSecret(),
          style: ThemeMode.light,
          merchantDisplayName: schoolConfigCubit
                  .getSchoolConfiguration()
                  .schoolSettings
                  .schoolName ??
              '',
        ),
      );

      // Open payment sheet
      await Stripe.instance.presentPaymentSheet();

      onPaymentComplete();
      _navigateToConfirmPaymentScreen();
    } on StripeException catch (e) {
      // Payment cancelled by user
      if (e.error.code == FailureCode.Canceled) {
        onPaymentComplete();
        _navigateToConfirmPaymentScreen();
      }
    } on StripeConfigException catch (e) {
      if (kDebugMode) {
        print('Stripe Config Error: ${e.message}');
      }
      _showErrorSnackBar(Utils.getTranslatedLabel(
          ErrorMessageKeysAndCode.defaultErrorMessageKey));
    } catch (e) {
      if (kDebugMode) {
        print('Stripe Payment Error: ${e.toString()}');
      }
      _showErrorSnackBar(Utils.getTranslatedLabel(
          ErrorMessageKeysAndCode.defaultErrorMessageKey));
    }
  }

  /// Process payment with Flutterwave
  Future<void> payWithFlutterwave() async {
    try {
      final paymentLink = transportationCubit.getFlutterwavePaymentLink();

      if (kDebugMode) {
        print("Flutterwave payment link: $paymentLink");
      }

      if (paymentLink.isNotEmpty) {
        final result = await Get.toNamed(
          Routes.paymentWebview,
          arguments: {'paymentLink': paymentLink},
        );

        onPaymentComplete();
        if (result == true) {
          _navigateToConfirmPaymentScreen();
        } else {
          _navigateToConfirmPaymentScreen();
        }
      } else {
        if (kDebugMode) {
          print("Error: Empty payment link received from Flutterwave");
        }
        _showErrorSnackBar("Unable to get payment link. Please try again.");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error in payWithFlutterwave: $e");
        print("Stack trace: $stackTrace");
      }
      _showErrorSnackBar("Payment initialization failed. Please try again.");
    }
  }

  /// Process payment with Paystack
  Future<void> payWithPaystack() async {
    try {
      final paymentLink = transportationCubit.getPaystackPaymentLink();

      if (kDebugMode) {
        print("Paystack payment link: $paymentLink");
      }

      if (paymentLink.isNotEmpty) {
        final result = await Get.toNamed(
          Routes.paymentWebview,
          arguments: {'paymentLink': paymentLink},
        );

        onPaymentComplete();
        if (result == true) {
          _navigateToConfirmPaymentScreen();
        } else {
          _navigateToConfirmPaymentScreen();
        }
      } else {
        if (kDebugMode) {
          print("Error: Empty payment link received from Paystack");
        }
        _showErrorSnackBar("Unable to get payment link. Please try again.");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error in payWithPaystack: $e");
        print("Stack trace: $stackTrace");
      }
      _showErrorSnackBar("Payment initialization failed. Please try again.");
    }
  }

  /// Handle pre-payment tasks listener
  /// This method determines which payment gateway to use based on the API response
  void handlePrePaymentTasksListener(TransportationPrePaymentTasksState state) {
    if (state is TransportationPrePaymentTasksFailure) {
      _showErrorSnackBar(
          Utils.getErrorMessageFromErrorCode(context, state.errorMessage));
    } else if (state is TransportationPrePaymentTasksSuccess) {
      // Route to appropriate payment method based on the selected gateway
      final paymentMethod = state.paymentMethod.paymentMethod;

      if (paymentMethod == stripePaymentMethodKey) {
        payWithStripe(stripePublishableKey: state.paymentMethod.apiKey ?? "");
      } else if (paymentMethod == razorpayPaymentMethodKey) {
        payWithRazorpay(razorpayApiKey: state.paymentMethod.apiKey ?? "");
      } else if (paymentMethod == flutterwavePaymentMethodKey) {
        payWithFlutterwave();
      } else if (paymentMethod == paystackPaymentMethodKey) {
        payWithPaystack();
      }
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    Utils.showCustomSnackBar(
      context: context,
      errorMessage: message,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  /// Clean up resources
  void dispose() {
    _razorpay.clear();
  }
}
