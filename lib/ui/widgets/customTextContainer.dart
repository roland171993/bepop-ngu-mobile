import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextContainer extends StatelessWidget {
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final String textKey;
  final TextOverflow? overflow;

  const CustomTextContainer(
      {super.key,
      required this.textKey,
      this.maxLines,
      this.style,
      this.textAlign,
      this.overflow});

  @override
  Widget build(BuildContext context) {
    return Text(
      textKey.tr,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
