import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:flutter/material.dart';

class RouteStopRow extends StatelessWidget {
  final String stopName;
  final String time;
  final bool isCurrent;
  const RouteStopRow(
      {super.key,
      required this.stopName,
      required this.time,
      this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    final Color textColor = isCurrent
        ? const Color(0xFF57CC99)
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Expanded(
          child: CustomTextContainer(
            textKey: stopName,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
          ),
        ),
        CustomTextContainer(
          textKey: time,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        )
      ],
    );
  }
}
