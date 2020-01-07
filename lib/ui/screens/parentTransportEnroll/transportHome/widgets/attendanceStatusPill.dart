import 'package:flutter/material.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';

class AttendanceStatusPill extends StatelessWidget {
  final String status; // 'P' or 'A'
  const AttendanceStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool present = status.toUpperCase() == 'P';
    final Color bg =
        present ? const Color(0xFFE6F4EA) : const Color(0xFFFFE3E3);
    final Color fg =
        present ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    return Container(
      width: 40,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomTextContainer(
          textKey: present ? 'P' : 'A',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
