import 'package:bepop_ngu/data/models/transportDashboard.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:flutter/material.dart';

class BusInfoCard extends StatelessWidget {
  final BusInfo? busInfo;

  const BusInfoCard({super.key, this.busInfo});

  @override
  Widget build(BuildContext context) {
    return EnrollCard(
      title: 'Bus Info',
      trailing: const SizedBox(),
      children: [
        CustomTextContainer(
          textKey:
              busInfo != null ? 'Bus No : ${busInfo!.registration}' : 'N/A',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
        ),
        ),
        PersonRow(
          label: 'Driver',
          name: busInfo?.driver?.name ?? 'N/A',
          phone: busInfo?.driver?.phone,
          avatar: busInfo?.driver?.avatar,
          userId: busInfo?.driver?.id,
        ),
        PersonRow(
          label: 'Attender',
          name: busInfo?.attender?.name ?? 'N/A',
          phone: busInfo?.attender?.phone,
          avatar: busInfo?.attender?.avatar,
          userId: busInfo?.attender?.id,
        ),
      ],
    );
  }
}
