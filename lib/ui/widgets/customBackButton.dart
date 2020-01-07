import 'package:bepop_ngu/ui/widgets/svgButton.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  final Function? onTap;
  final double? topPadding;
  final AlignmentDirectional? alignmentDirectional;
  const CustomBackButton({
    Key? key,
    this.onTap,
    this.topPadding,
    this.alignmentDirectional,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignmentDirectional ?? AlignmentDirectional.topStart,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: topPadding ?? 0,
          start: Utils.screenContentHorizontalPadding,
        ),
        child: SvgButton(
          onTap: () {
            if (onTap != null) {
              onTap?.call();
            } else {
              Get.back();
            }
          },
          svgIconUrl: Utils.getBackButtonPath(context),
        ),
      ),
    );
  }
}
