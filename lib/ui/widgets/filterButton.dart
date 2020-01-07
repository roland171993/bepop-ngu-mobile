import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String titleKey;
  final double width;
  final Function onTap;
  final TextStyle? titleTextStyle;
  const FilterButton(
      {super.key,
      required this.onTap,
      required this.titleKey,
      this.titleTextStyle,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        width: width,
        height: double.maxFinite,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
            borderRadius: BorderRadius.circular(10.0)),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CustomTextContainer(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textKey: titleKey,
                style: titleTextStyle ??
                    TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }
}
