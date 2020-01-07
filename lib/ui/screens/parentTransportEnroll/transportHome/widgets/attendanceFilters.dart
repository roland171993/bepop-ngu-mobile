import 'package:flutter/material.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';

class AttendanceDropdown extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const AttendanceDropdown(
      {super.key,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomTextContainer(
                textKey: value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }
}
