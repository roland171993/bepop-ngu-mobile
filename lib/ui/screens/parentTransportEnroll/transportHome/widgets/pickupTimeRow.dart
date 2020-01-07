import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PickupTimeRow extends StatelessWidget {
  final VoidCallback onTap;
  final String? pickupTime;
  const PickupTimeRow({super.key, required this.onTap, this.pickupTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LabelValue(
            label: 'Pickup Time',
            value: "$pickupTime (Estimated)",
            smallValueStyle: true,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1F4B63),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                Utils.getImagePath('directions.svg'),
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
