import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:flutter/material.dart';
import 'package:bepop_ngu/data/models/liveRoute.dart';
import 'package:bepop_ngu/ui/styles/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Live timeline stop status enum
enum LiveStopStatus { upcoming, current, completed }

class LiveTimeline extends StatelessWidget {
  final List<TripStop> stops;
  final int? currentStopIndex;

  const LiveTimeline({
    super.key,
    required this.stops,
    this.currentStopIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (int index = 0; index < stops.length; index++)
                _buildTimelineItem(context, stops[index], index),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(BuildContext context, TripStop stop, int index) {
    final isLast = index == stops.length - 1;
    final isFirst = index == 0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column (Left side) - Fixed width for perfect alignment
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Top connecting line (if not first)
                if (!isFirst)
                  _shouldShowSolidLine(index - 1, index)
                      ? Container(
                          width: 3,
                          height: 20,
                          color: tripTimelineGreenColor,
                        )
                      : _buildDottedLine(Colors.grey.shade400, 20),

                // Stop Node/Icon
                _buildStopNode(context, stop, index),

                // Bottom connecting line (if not last)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      child: _shouldShowSolidLine(index, index + 1)
                          ? Container(
                              width: 3,
                              color: tripTimelineGreenColor,
                            )
                          : _buildDottedLine(Colors.grey.shade400, 40),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Content Column (Right side)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 35,
                top: 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Stop name and passenger info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stop Name
                        CustomTextContainer(
                          textKey: stop.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getStopStatus(index) ==
                                    LiveStopStatus.current
                                ? tripTimelineGreenColor // Current stop also green
                                : Colors.black87,
                          ),
                        ),

                        // Passenger count (if any)
                        if (stop.passengers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: CustomTextContainer(
                              textKey:
                                  "${stop.passengers.length} Passenger${stop.passengers.length > 1 ? 's' : ''}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Right side - Times
                  _buildTimeDisplay(context, stop, index),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopNode(BuildContext context, TripStop stop, int index) {
    final status = _getStopStatus(index);

    if (status == LiveStopStatus.current) {
      // Current stop - Green circle with bus icon
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: tripTimelineGreenColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/bus.svg',
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    } else if (status == LiveStopStatus.completed) {
      // Completed stop - Solid green circle
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: tripTimelineGreenColor,
          shape: BoxShape.circle,
        ),
        child: _isSchoolCampus(stop.name)
            ? Center(
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 8,
                ),
              )
            : null,
      );
    } else {
      // Upcoming stop - Hollow grey circle
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: _isSchoolCampus(stop.name)
            ? Center(
                child: Icon(
                  Icons.school,
                  color: Colors.grey.shade400,
                  size: 6,
                ),
              )
            : null,
      );
    }
  }

  LiveStopStatus _getStopStatus(int index) {
    if (currentStopIndex == null) {
      return index == 0 ? LiveStopStatus.current : LiveStopStatus.upcoming;
    }

    if (index == currentStopIndex) {
      return LiveStopStatus.current;
    } else if (index < currentStopIndex!) {
      return LiveStopStatus.completed;
    } else {
      return LiveStopStatus.upcoming;
    }
  }

  bool _shouldShowSolidLine(int fromIndex, int toIndex) {
    final fromStatus = _getStopStatus(fromIndex);
    final toStatus = _getStopStatus(toIndex);

    // Show solid green line only between completed stops
    // or from completed to current stop
    return (fromStatus == LiveStopStatus.completed &&
            toStatus == LiveStopStatus.completed) ||
        (fromStatus == LiveStopStatus.completed &&
            toStatus == LiveStopStatus.current);
  }

  Widget _buildDottedLine(Color color, double height) {
    // Constrain to 3px width so the dotted stroke can be centered exactly
    return SizedBox(
      width: 3,
      height: height,
      child: CustomPaint(
        painter: DottedLinePainter(
          color: color,
          dashWidth: 2,
          dashSpace: 2,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(BuildContext context, TripStop stop, int index) {
    final status = _getStopStatus(index);
    final hasActualTime =
        stop.actualTime != 'Pending' && stop.actualTime.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Scheduled time (always shown in black)
        CustomTextContainer(
          textKey: stop.scheduledTime,
          style: TextStyle(
            fontSize: 14,
            color: status == LiveStopStatus.upcoming
                ? Theme.of(context).colorScheme.primary
                : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Actual time (only shown if bus has reached and has actual time)
        if (status != LiveStopStatus.upcoming && hasActualTime) ...[
          const SizedBox(height: 2),
          CustomTextContainer(
            textKey: stop.actualTime,
            style: TextStyle(
              fontSize: 14,
              color: _getActualTimeColor(stop),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Color _getActualTimeColor(TripStop stop) {
    // Compare actual time with scheduled time
    final scheduledTime = _parseTime(stop.scheduledTime);
    final actualTime = _parseTime(stop.actualTime);

    if (scheduledTime != null && actualTime != null) {
      if (actualTime.isAfter(scheduledTime)) {
        // Bus arrived later than scheduled - RED
        return Colors.red.shade600;
      } else if (actualTime.isBefore(scheduledTime)) {
        // Bus arrived earlier than scheduled - GREEN
        return Colors.green.shade600;
      }
    }

    // Default color for same time or unparseable times
    return tripTimelineGreenColor;
  }

  DateTime? _parseTime(String timeString) {
    try {
      // Handle common time formats like "05:24 PM", "10:00 AM"
      final cleanTime = timeString.trim();

      // Parse time with AM/PM
      final timePattern =
          RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);
      final match = timePattern.firstMatch(cleanTime);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final period = match.group(3)!.toUpperCase();

        // Convert to 24-hour format
        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        // Create DateTime for today with the parsed time
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  bool _isSchoolCampus(String stopName) {
    return stopName.toLowerCase().contains('school') ||
        stopName.toLowerCase().contains('campus');
  }
}

/// Custom painter for creating dashed vertical lines (1px width, 2,2 pattern)
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DottedLinePainter({
    required this.color,
    this.dashWidth = 2.0,
    this.dashSpace = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0 // Fixed 1px width
      ..strokeCap = StrokeCap.square; // Square caps for clean dashes

    // Draw down the vertical center of the available width
    final double x = size.width / 2;
    double startY = 0;
    while (startY < size.height) {
      // Draw each dash segment
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace; // Move to next dash position
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
