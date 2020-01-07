import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/selectTransport/widgets/successCheckAnimatedIcon.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransportEnrollSubmittedScreen extends StatelessWidget {
  const TransportEnrollSubmittedScreen({super.key});

  static Widget getRouteInstance() {
    return const TransportEnrollSubmittedScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SuccessCheckAnimatedIcon(size: 160),
                const SizedBox(height: 24),
                CustomTextContainer(
                  textKey: requestSubmittedKey,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                CustomTextContainer(
                  textKey: requestSubmittedDescriptionKey,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                CustomRoundedButton(
                  onTap: () {
                    Get.back();
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  buttonTitle: viewRequestKey,
                  showBorder: false,
                  widthPercentage: 1.0,
                  height: 50,
                  radius: 8,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Get student ID from auth repository
                    final student = AuthRepository.getStudentDetails();
                    final studentId = student.id;

                    if (studentId != null) {
                      Get.toNamed(Routes.transportEnrollHomeScreen,
                          arguments: studentId);
                    } else {
                      Get.toNamed(Routes.transportEnrollHomeScreen);
                    }
                  },
                  child: CustomTextContainer(
                    textKey: homeKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
