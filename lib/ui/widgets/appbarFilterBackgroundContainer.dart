import 'package:bepop_ngu/utils/constants.dart';
import 'package:flutter/material.dart';

class AppbarFilterBackgroundContainer extends StatelessWidget {
  final Widget child;
  final double height;
  const AppbarFilterBackgroundContainer(
      {super.key, required this.child, this.height = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      child: child,
    );
  }
}
