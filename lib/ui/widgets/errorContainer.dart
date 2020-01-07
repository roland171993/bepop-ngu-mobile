import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/utils/animationConfiguration.dart';
import 'package:bepop_ngu/utils/errorMessageKeysAndCodes.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

class ErrorContainer extends StatelessWidget {
  final String errorMessageCode;
  final bool? showRetryButton;
  final bool? showErrorImage;
  final Color? errorMessageColor;
  final double? errorMessageFontSize;
  final Function? onTapRetry;
  final Color? retryButtonBackgroundColor;
  final Color? retryButtonTextColor;
  final bool animate;
  const ErrorContainer({
    Key? key,
    required this.errorMessageCode,
    this.errorMessageColor,
    this.errorMessageFontSize,
    this.onTapRetry,
    this.showErrorImage,
    this.retryButtonBackgroundColor,
    this.retryButtonTextColor,
    this.showRetryButton,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: animate ? customItemBounceScaleAppearanceEffects() : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final isHeightConstrained = availableHeight != double.infinity;
          
          if (isHeightConstrained) {
            // When height is constrained, use flexible layout
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Flexible(
                  flex: 3,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                      maxHeight: availableHeight * 0.4,
                    ),
                    child: SvgPicture.asset(
                      Utils.getImagePath(
                        errorMessageCode == ErrorMessageKeysAndCode.noInternetCode
                            ? "noInternet.svg"
                            : "somethingWentWrong.svg",
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      Utils.getErrorMessageFromErrorCode(context, errorMessageCode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: errorMessageColor ??
                            Theme.of(context).colorScheme.secondary,
                        fontSize: errorMessageFontSize ?? 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (showRetryButton ?? true)
                  Flexible(
                    flex: 1,
                    child: CustomRoundedButton(
                      height: 36,
                      widthPercentage: 0.3,
                      backgroundColor: retryButtonBackgroundColor ??
                          Theme.of(context).colorScheme.primary,
                      onTap: () {
                        onTapRetry?.call();
                      },
                      titleColor: retryButtonTextColor ??
                          Theme.of(context).scaffoldBackgroundColor,
                      buttonTitle: Utils.getTranslatedLabel(retryKey),
                      showBorder: false,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            );
          } else {
            // When height is unconstrained, use normal layout
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: SvgPicture.asset(
                      Utils.getImagePath(
                        errorMessageCode == ErrorMessageKeysAndCode.noInternetCode
                            ? "noInternet.svg"
                            : "somethingWentWrong.svg",
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      Utils.getErrorMessageFromErrorCode(context, errorMessageCode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: errorMessageColor ??
                            Theme.of(context).colorScheme.secondary,
                        fontSize: errorMessageFontSize ?? 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (showRetryButton ?? true)
                    CustomRoundedButton(
                      height: 40,
                      widthPercentage: 0.3,
                      backgroundColor: retryButtonBackgroundColor ??
                          Theme.of(context).colorScheme.primary,
                      onTap: () {
                        onTapRetry?.call();
                      },
                      titleColor: retryButtonTextColor ??
                          Theme.of(context).scaffoldBackgroundColor,
                      buttonTitle: Utils.getTranslatedLabel(retryKey),
                      showBorder: false,
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
