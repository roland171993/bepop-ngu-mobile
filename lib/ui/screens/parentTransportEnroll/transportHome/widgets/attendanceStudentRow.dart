import 'package:flutter/material.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';

class AttendanceStudentRow extends StatelessWidget {
  final String name;
  final String roll;
  final String time;
  final bool present;
  final ValueChanged<bool> onChanged;

  const AttendanceStudentRow({
    super.key,
    required this.name,
    required this.roll,
    required this.time,
    required this.present,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                  textKey: name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                CustomTextContainer(
                  textKey: 'Roll $roll • $time',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: present,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}
