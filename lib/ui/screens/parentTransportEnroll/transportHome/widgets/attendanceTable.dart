import 'package:flutter/material.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/attendanceStatusPill.dart';

class AttendanceTable extends StatelessWidget {
  final List<AttendanceRowData> rows;
  const AttendanceTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EDF3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: const [
                SizedBox(
                    width: 24,
                    child: CustomTextContainer(
                        textKey: '#',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                SizedBox(width: 16),
                Expanded(
                    flex: 2,
                    child: CustomTextContainer(
                        textKey: 'Date',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                Expanded(
                    child: CustomTextContainer(
                        textKey: 'Status',
                        style: TextStyle(fontWeight: FontWeight.w700))),
              ],
            ),
          ),

          // Data rows
          ...rows.asMap().entries.map((e) {
            final idx = e.key + 1;
            final row = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top:
                      BorderSide(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    child: CustomTextContainer(
                        textKey: '$idx', style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomTextContainer(
                      textKey: row.dateText,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                          AttendanceStatusPill(status: row.present ? 'P' : 'A'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class AttendanceRowData {
  final String dateText;
  final bool present;
  const AttendanceRowData({required this.dateText, required this.present});
}
