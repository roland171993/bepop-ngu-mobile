import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PaymentStatusScreen extends StatefulWidget {
  final bool isSuccess;

  const PaymentStatusScreen({Key? key, required this.isSuccess})
      : super(key: key);

  static PaymentStatusScreen routeInstance({required bool isSuccess}) {
    return PaymentStatusScreen(isSuccess: isSuccess);
  }

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Auto-navigate to the confirmation screen after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Add a small delay before navigating
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Get.offNamed(Routes.confirmPayment);
          }
        });
      }
    });

    // Play animation once
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            Expanded(
              flex: 3,
              child: Center(
                child: Lottie.asset(
                  widget.isSuccess
                      ? 'assets/animations/payment_success.json'
                      : 'assets/animations/payment_cancel.json',
                  controller: _animationController,
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ),

            // Status message
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.isSuccess
                          ? Utils.getTranslatedLabel(paymentSuccessTitleKey)
                          : Utils.getTranslatedLabel(paymentFailureTitleKey),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.isSuccess
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isSuccess
                          ? Utils.getTranslatedLabel(paymentSuccessMsgKey)
                          : Utils.getTranslatedLabel(paymentFailureMsgKey),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offNamed(Routes.confirmPayment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
