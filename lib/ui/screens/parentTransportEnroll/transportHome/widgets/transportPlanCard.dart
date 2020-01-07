import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/data/models/transportDashboard.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TransportPlanCard extends StatelessWidget {
  final TransportPlan? plan;
  final int? studentId;

  const TransportPlanCard({super.key, this.plan, this.studentId});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(plan?.status);
    final isExpiring = plan?.expiresInDays != null && plan!.expiresInDays! <= 7;
    final isParent = context.read<AuthCubit>().isParent();

    return EnrollCard(
      onTap: isParent
          ? () {
              Get.toNamed(Routes.transportPlanDetailsScreen,
                  arguments: studentId);
            }
          : null,
      title: transportationPlanKey,
      trailing: EnrollStatusChip(
        title: plan?.status?.capitalize ?? activeKey,
        background: statusColor.background,
        foreground: statusColor.foreground,
      ),
      children: [
        LabelValue(
          label: planKey,
          value: plan?.duration ?? monthlyKey,
        ),
        LabelValue(
          label: validityKey,
          value:
              plan != null && plan!.validFrom != null && plan!.validTo != null
                  ? '${plan!.validFrom} - ${plan!.validTo}'
                  : 'N/A',
        ),
        LabelValue(
          label: routeNameKey,
          value: plan?.route?.name ?? 'N/A',
        ),
        if (isExpiring) ...[
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isParent
                ? () => Get.toNamed(
                      Routes.planRenewalScreen,
                      arguments: {
                        'plan': plan,
                        'userId': studentId,
                      },
                    )
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8E8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utils.getTranslatedLabel(planExpiringTitleKey),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE53935),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Utils.getTranslatedLabel(yourPlanWillExpireInKey)} ${plan?.expiresInDays} ${Utils.getTranslatedLabel(daysKey)}.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isParent)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward,
                          color: Color(0xFF29638A)),
                    )
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  ({Color background, Color foreground}) _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return (
          background: const Color(0xFFDFF6E2),
          foreground: const Color(0xFF37C748),
        );
      case 'inactive':
        return (
          background: const Color(0xFFFFF2E8),
          foreground: const Color(0xFFFF8C00),
        );
      case 'expired':
        return (
          background: const Color(0xFFFFE8E8),
          foreground: const Color(0xFFE53935),
        );
      default:
        return (
          background: const Color(0xFFDFF6E2),
          foreground: const Color(0xFF37C748),
        );
    }
  }
}
