import 'package:bepop_ngu/ui/widgets/bottomsheetTopTitleAndCloseButton.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/ui/widgets/customTextFieldContainer.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';

class AdvanceInstallmentAmountBottomsheet extends StatefulWidget {
  final double advanceInstallmentAmount;
  final double maximumAmountLimit;

  const AdvanceInstallmentAmountBottomsheet({
    super.key,
    required this.maximumAmountLimit,
    required this.advanceInstallmentAmount,
  });

  @override
  State<AdvanceInstallmentAmountBottomsheet> createState() =>
      _AdvanceInstallmentAmountBottomsheetState();
}

class _AdvanceInstallmentAmountBottomsheetState
    extends State<AdvanceInstallmentAmountBottomsheet> {
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget.advanceInstallmentAmount.toString());

  @override
  void initState() {
    super.initState();
    print("initState");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * (0.075),
          right: MediaQuery.of(context).size.width * (0.075)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 25,
          ),
          BottomsheetTopTitleAndCloseButton(
            onTapCloseButton: () {
              Get.back();
            },
            titleKey: changeInstallmentAmountKey,
          ),
          CustomTextFieldContainer(
            bottomPadding: 5,
            textEditingController: _textEditingController,
            hideText: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            hintTextKey: installmentAmountKey,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              "${Utils.getTranslatedLabel(maximumAmountIsKey)} ${widget.maximumAmountLimit.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 12.0,
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: CustomRoundedButton(
              height: 40,
              widthPercentage: 0.3,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: submitKey,
              showBorder: false,
              onTap: () {
                FocusScope.of(context).unfocus();
                final advanceAmount =
                    double.tryParse(_textEditingController.text.trim());
                if (advanceAmount == null) {
                  Utils.showCustomSnackBar(
                      context: context,
                      errorMessage:
                          Utils.getTranslatedLabel(pleaseEnterValidAmountKey),
                      backgroundColor: Theme.of(context).colorScheme.error);
                  return;
                }

                if (advanceAmount <= 0.0) {
                  Utils.showCustomSnackBar(
                      context: context,
                      errorMessage:
                          Utils.getTranslatedLabel(pleaseEnterValidAmountKey),
                      backgroundColor: Theme.of(context).colorScheme.error);
                  return;
                }

                if (advanceAmount.toDouble() > widget.maximumAmountLimit) {
                  Utils.showCustomSnackBar(
                      context: context,
                      errorMessage:
                          "${Utils.getTranslatedLabel(maximumAmountIsKey)} ${widget.maximumAmountLimit.toStringAsFixed(2)}",
                      backgroundColor: Theme.of(context).colorScheme.error);
                  return;
                }
                if (widget.advanceInstallmentAmount == advanceAmount) {
                  Get.back(result: advanceAmount);
                } else {
                  Get.back(result: advanceAmount);
                }
              },
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
