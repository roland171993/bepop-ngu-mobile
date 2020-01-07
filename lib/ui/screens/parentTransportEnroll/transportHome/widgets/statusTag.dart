import 'package:flutter/material.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';

class StatusTag extends StatelessWidget {
  final String text; // e.g., Pending, Rejected, Approved
  final Color bg;
  final Color fg;
  const StatusTag(
      {super.key, required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomTextContainer(
        textKey: text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
