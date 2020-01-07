import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String buttonTextKey;
  final Function()? onTapButton;
  final TextStyle? textStyle;
  const CustomTextButton(
      {super.key,
      required this.buttonTextKey,
      required this.onTapButton,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapButton,
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        child: CustomTextContainer(
          textKey: buttonTextKey,
          style: textStyle,
        ),
      ),
    );
  }
}
