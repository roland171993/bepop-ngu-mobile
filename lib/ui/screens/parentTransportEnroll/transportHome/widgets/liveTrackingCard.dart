import 'package:bepop_ngu/data/models/transportDashboard.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/pickupTimeRow.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/liveRouteBottomSheet.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';

class LiveTrackingCard extends StatelessWidget {
  final LiveSummary? liveSummary;
  final int? studentId;

  const LiveTrackingCard({super.key, this.liveSummary, this.studentId});

  @override
  Widget build(BuildContext context) {
    return EnrollCard(
      title: liveTrackingKey,
      trailing: SizedBox.shrink(),
      children: [
        if (liveSummary != null) ...[
          LiveTrackingContent(liveSummary: liveSummary),
          SizedBox(height: 8),
          PickupTimeRow(
            pickupTime: liveSummary?.pickupTime,
            onTap: () {
            _showLiveRouteBottomSheet(context);
          }),
        ] else ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.directions_bus_outlined,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Utils.getTranslatedLabel(noOngoingTripKey),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ],
    );
  }

  void _showLiveRouteBottomSheet(BuildContext context) {
    // Use the student ID from the widget parameter first, then fallback to auth repository
    int? userId = studentId;

    if (userId == null) {
      final student = AuthRepository.getStudentDetails();
      userId = student.id;
    }

    if (userId == null || userId == 0) {
      print("Error: No valid student ID found for live route tracking");
      return;
    }

    LiveRouteBottomSheet.show(context, userId: userId);
  }
}
