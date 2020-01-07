// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bepop_ngu/utils/utils.dart';

class CustomTextFieldContainer extends StatelessWidget {
  final String hintTextKey;
  final bool hideText;
  final double? bottomPadding;
  final Widget? suffixWidget;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  CustomTextFieldContainer({
    Key? key,
    required this.hintTextKey,
    required this.hideText,
    this.bottomPadding,
    this.suffixWidget,
    this.textEditingController,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: bottomPadding ?? 20.0),
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Utils.getColorScheme(context).secondary),
      ),
      child: TextField(
          controller: textEditingController,
          obscureText: hideText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enableInteractiveSelection: true,
          enableSuggestions: keyboardType != TextInputType.number,
          autofocus: false,
          decoration: InputDecoration(
            suffixIcon: suffixWidget,
            hintStyle:
                TextStyle(color: Utils.getColorScheme(context).secondary),
            hintText: Utils.getTranslatedLabel(hintTextKey),
            border: InputBorder.none,
            contentPadding:
                suffixWidget != null ? const EdgeInsets.only(top: 12.5) : null,
          )),
    );
  }
}
