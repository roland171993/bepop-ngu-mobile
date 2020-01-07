import 'package:bepop_ngu/data/models/transportDashboard.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:bepop_ngu/ui/screens/chat/chatScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bepop_ngu/app/routes.dart';

class EnrollCard extends StatelessWidget {
  final String title;
  final Widget trailing;
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool showHeader;
  const EnrollCard(
      {super.key,
      required this.title,
      required this.trailing,
      required this.children,
      this.onTap,
      this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomTextContainer(
                      textKey: title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  trailing,
                ],
              ),
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class EnrollStatusChip extends StatelessWidget {
  final String title;
  final Color background;
  final Color foreground;
  const EnrollStatusChip(
      {super.key,
      required this.title,
      required this.background,
      required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(4)),
      child: CustomTextContainer(
          textKey: title, style: TextStyle(color: foreground, fontSize: 14)),
    );
  }
}

class LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool smallValueStyle;
  final bool addTopSpacing;
  final bool addBottomSpacing;
  const LabelValue(
      {super.key,
      required this.label,
      required this.value,
      this.smallValueStyle = false,
      this.addTopSpacing = true,
      this.addBottomSpacing = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: addBottomSpacing ? 8 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (addTopSpacing) const SizedBox(height: 2),
          CustomTextContainer(
            textKey: label,
            style: const TextStyle(color: Color(0xFF6D6E6F), fontSize: 12),
          ),
          if (addBottomSpacing) const SizedBox(height: 2),
          CustomTextContainer(
            textKey: value,
            style: TextStyle(
              color: const Color(0xFF1A1C1D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: smallValueStyle ? 1.0 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class IconPill extends StatelessWidget {
  final IconData icon;
  final Color? pillColor;
  const IconPill({super.key, required this.icon, this.pillColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: pillColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class PersonRow extends StatelessWidget {
  final String label;
  final String name;
  final String? phone;
  final String? avatar;
  final int? userId;
  const PersonRow({
    super.key,
    required this.label,
    required this.name,
    this.phone,
    this.avatar,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
            child: avatar != null && avatar!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: avatar!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CustomTextContainer(
                        textKey: name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      errorWidget: (context, url, error) => CustomTextContainer(
                        textKey: name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                : CustomTextContainer(
                    textKey: name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                    textKey: label,
                    style: const TextStyle(
                        color: Color(0xFF6D6E6F), fontSize: 12)),
                CustomTextContainer(
                  textKey: name,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          // Phone icon with functionality
          GestureDetector(
            onTap: () {
              if (phone != null && phone!.isNotEmpty) {
                Utils.launchPhoneDialer(phone!);
              }
            },
            child: IconPill(
              icon: Icons.phone,
              pillColor: phone != null && phone!.isNotEmpty
                  ? const Color(0xFFF7F9FF)
                  : const Color(0xFFF0F0F0),
            ),
          ),
          const SizedBox(width: 8),
          // Chat icon with functionality
          GestureDetector(
            onTap: () {
              if (userId != null) {
                Get.toNamed(
                  Routes.chat,
                  arguments: ChatScreen.buildArguments(
                    receiverId: userId!,
                    image: avatar ?? '',
                    teacherName: name,
                    appbarSubtitle: label,
                  ),
                );
              }
            },
            child: IconPill(
              icon: Icons.message,
              pillColor: userId != null
                  ? const Color(0xFFF7F9FF)
                  : const Color(0xFFF0F0F0),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveTrackingContent extends StatelessWidget {
  final LiveSummary? liveSummary;

  const LiveTrackingContent({super.key, this.liveSummary});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DottedTimeline(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelValue(
                label: 'Current Location',
                value: liveSummary?.currentLocation ?? 'N/A',
              ),
              const SizedBox(height: 8),
              LabelValue(
                label: 'Next Point',
                value: liveSummary?.nextLocation ?? 'N/A',
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _DottedTimeline extends StatelessWidget {
  const _DottedTimeline();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TimelineCircle(color: Color(0xFF61C29F), diameter: 14),
        SizedBox(height: 2),
        _DottedLineVertical(
            height: 72,
            color: Color(0xFF61C29F),
            thickness: 2,
            dashLength: 5,
            gap: 5),
        SizedBox(height: 2),
        _DiamondMarker(size: 12, color: Color(0xFF61C29F)),
      ],
    );
  }
}

class _TimelineCircle extends StatelessWidget {
  final Color color;
  final double diameter;
  const _TimelineCircle({required this.color, required this.diameter});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _DiamondMarker extends StatelessWidget {
  final double size;
  final Color color;
  const _DiamondMarker({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
        angle: 45.0 * 3.1415926535 / 180.0,
        child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))));
  }
}

class _DottedLineVertical extends StatelessWidget {
  final double height;
  final Color color;
  final double thickness;
  final double dashLength;
  final double gap;
  const _DottedLineVertical(
      {required this.height,
      required this.color,
      this.thickness = 2,
      this.dashLength = 4,
      this.gap = 4});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: thickness,
        height: height,
        child: CustomPaint(
            painter: _DottedPainter(
                color: color,
                thickness: thickness,
                dashLength: dashLength,
                gap: gap)));
  }
}

class _DottedPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashLength;
  final double gap;
  _DottedPainter(
      {required this.color,
      required this.thickness,
      required this.dashLength,
      required this.gap});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    double y = 0;
    while (y < size.height) {
      final double endY = (y + dashLength).clamp(0.0, size.height.toDouble());
      canvas.drawLine(
          Offset(size.width / 2, y), Offset(size.width / 2, endY), paint);
      y += dashLength + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AttendanceCard extends StatelessWidget {
  final TodayAttendance? todayAttendance;
  final String? pickupStopName;
  final int? studentId;
  final String? pickupTime;

  const AttendanceCard({
    super.key,
    this.todayAttendance,
    this.pickupStopName,
    this.studentId,
    this.pickupTime,
  });

  @override
  Widget build(BuildContext context) {
    // Use pickupStatus instead of status to get the correct pickup attendance
    final pickupStatus = todayAttendance?.pickupStatus;
    final statusData = _getAttendanceStatusData(pickupStatus);

    return EnrollCard(
      title: 'Attendance',
      trailing: EnrollStatusChip(
        title: statusData.title,
        background: statusData.background,
        foreground: statusData.foreground,
      ),
      children: [
        LabelValue(
          label: 'Pick Up Point',
          value: pickupStopName ?? 'N/A',
        ),
        Row(
          children: [
            Expanded(
              child: LabelValue(
                label: 'Pickup Time',
                value: pickupTime ?? 'N/A',
                smallValueStyle: true,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(Routes.transportAttendanceScreen,
                    arguments: studentId);
              },
              child: IconPill(
                  icon: Icons.event,
                  pillColor: const Color(0xFF29638A).withValues(alpha: 0.15)),
            ),
          ],
        ),
      ],
    );
  }

  ({String title, Color background, Color foreground}) _getAttendanceStatusData(
      String? status) {
    switch (status?.toUpperCase()) {
      case 'P':
        return (
          title: 'Present',
          background: const Color(0xFFDFF6E2),
          foreground: const Color(0xFF37C748),
        );
      case 'A':
        return (
          title: 'Absent',
          background: const Color(0xFFFFE8E8),
          foreground: const Color(0xFFE53935),
        );
      case 'L':
        return (
          title: 'Late',
          background: const Color(0xFFFFF2E8),
          foreground: const Color(0xFFFF8C00),
        );
      case 'W':
      default:
        return (
          title: 'Waiting',
          background: const Color(0xFFE0EDF6),
          foreground: const Color(0xFF29638A),
        );
    }
  }
}

class RequestCard extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusBg;
  final String? requestedOn;
  final String? pickupStopName;
  final String? planDuration;
  final String? planValidity;
  final String? planType;

  const RequestCard({
    super.key,
    required this.title,
    required this.statusText,
    required this.statusBg,
    this.requestedOn,
    this.pickupStopName,
    this.planDuration,
    this.planValidity,
    this.planType,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextContainer(
                    textKey: title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomTextContainer(
                    textKey: statusText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (requestedOn != null)
              LabelValue(
                label: 'Requested On',
                value: requestedOn!,
              ),
            if (pickupStopName != null)
              LabelValue(
                label: 'Pickup Point',
                value: pickupStopName!,
              ),
            if (planDuration != null)
              LabelValue(
                label: 'Plan Duration',
                value: planDuration!,
              ),
            if (planType != null)
              LabelValue(
                label: 'Plan Type',
                value: planType!,
              ),
            if (planValidity != null)
              LabelValue(
                label: 'Validity',
                value: planValidity!,
              ),
          ],
        ),
      );
}
