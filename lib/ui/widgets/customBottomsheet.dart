import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomBottomsheet extends StatelessWidget {
  final Widget child;
  final String titleLabelKey;
  final Widget? trailing;

  const CustomBottomsheet(
      {super.key,
      required this.child,
      required this.titleLabelKey,
      this.trailing});

  Widget _buildContent({required BuildContext context}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 5,
          decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.5)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: 15, horizontal: appContentHorizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textKey: titleLabelKey,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w800),
                ),
              ),
              trailing ?? const SizedBox()
            ],
          ),
        ),
        Container(
          width: double.maxFinite,
          height: 2,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        Flexible(child: SingleChildScrollView(child: child))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * (0.85)),
        padding: EdgeInsets.symmetric(
            vertical: appContentHorizontalPadding * (1.25)),
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(bottomsheetBorderRadius),
                topRight: Radius.circular(bottomsheetBorderRadius))),
        child: _buildContent(context: context),
      ),
    );
  }
}
