import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/busRouteStopsCubit.dart';
import 'package:bepop_ngu/data/models/transportPlanDetails.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/ui/widgets/shimmerLoadingContainer.dart';
import 'package:bepop_ngu/ui/widgets/customShimmerContainer.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';
import 'package:bepop_ngu/ui/widgets/noDataContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class BusRouteScreen extends StatefulWidget {
  final int? studentId;
  final TransportPlanDetails? planDetails;

  const BusRouteScreen({super.key, this.studentId, this.planDetails});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final int? studentId = arguments?['studentId'] as int?;
    final TransportPlanDetails? planDetails =
        arguments?['planDetails'] as TransportPlanDetails?;
    return BlocProvider(
      create: (context) => BusRouteStopsCubit(),
      child: BusRouteScreen(studentId: studentId, planDetails: planDetails),
    );
  }

  @override
  State<BusRouteScreen> createState() => _BusRouteScreenState();
}

class _BusRouteScreenState extends State<BusRouteScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRouteStops();
  }

  void _fetchRouteStops() {
    // Use the student ID from navigation arguments
    // If not available, fallback to getting from auth repository
    int? userId = widget.studentId;

    if (userId == null) {
      final student = AuthRepository.getStudentDetails();
      userId = student.id;
    }

    // If still null, this means we don't have a valid student ID
    if (userId == null) {
      print("Error: No valid student ID found for bus route stops");
      return;
    }

    context.read<BusRouteStopsCubit>().fetchRouteStops(userId: userId);
  }

  Widget _currentRouteCard(BuildContext context, routeStops) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF57CC99)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteMetaRow(left: routeStops.routeDisplayInfo, right: ''),
          SizedBox(height: 4),
          _RouteMetaRow(left: routeStops.userPickupInfo, right: ''),
        ],
      ),
    );
  }

  Widget _stopsTimeline(BuildContext context, routeStops) {
    final stops = routeStops.stops;

    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth >= 460;
      final double tileHeight = isWide ? 60.0 : 56.0;
      final double totalHeight = tileHeight * stops.length;
      final int currentIndex = routeStops.userStopIndex;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: totalHeight,
            child: CustomPaint(
              painter: _TimelineColumnPainter(
                itemCount: stops.length,
                currentIndex: currentIndex,
                tileHeight: tileHeight,
                lineWidth: 3.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: List.generate(stops.length, (index) {
                final stop = stops[index];
                final bool isCurrent = index == currentIndex;
                return SizedBox(
                  height: tileHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomTextContainer(
                          textKey: stop.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isCurrent
                                ? const Color(0xFF57CC99)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomTextContainer(
                        textKey: stop.displayTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isCurrent
                              ? const Color(0xFF57CC99)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
        vertical: 16,
      ),
      child: Column(
        children: [
          ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 100,
              width: double.infinity,
              borderRadius: 12,
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ),
          ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 300,
              width: double.infinity,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteContent(routeStops) {
    return RefreshIndicator(
      onRefresh: () async => _fetchRouteStops(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding,
          vertical: 16,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 600;
            final double contentGap = isWide ? 20.0 : 16.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _currentRouteCard(context, routeStops),
                SizedBox(height: contentGap),
                _stopsTimeline(context, routeStops),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomButton(routeStops) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(appContentHorizontalPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: CustomRoundedButton(
          onTap: () {
            Get.toNamed(
              Routes.changeRouteScreen,
              arguments: {
                'routeStops': routeStops,
                'planDetails': widget.planDetails,
              },
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          buttonTitle: changeRouteKey,
          showBorder: false,
          widthPercentage: 1.0,
          height: 50,
          radius: 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(title: busRouteKey, showBackButton: true),
          Expanded(
            child: BlocBuilder<BusRouteStopsCubit, BusRouteStopsState>(
              builder: (context, state) {
                if (state is BusRouteStopsFetchInProgress) {
                  return _buildLoadingState();
                }

                if (state is BusRouteStopsNoData) {
                  return Center(
                    child: NoDataContainer(
                      titleKey: noTransportAssignedKey,
                    ),
                  );
                }

                if (state is BusRouteStopsFetchFailure) {
                  return ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: _fetchRouteStops,
                  );
                }

                if (state is BusRouteStopsFetchSuccess) {
                  return _buildRouteContent(state.routeStops);
                }

                // Default loading state
                return _buildLoadingState();
              },
            ),
          ),
          BlocBuilder<BusRouteStopsCubit, BusRouteStopsState>(
            builder: (context, state) {
              if (state is BusRouteStopsFetchSuccess) {
                return _buildBottomButton(state.routeStops);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _RouteMetaRow extends StatelessWidget {
  final String left;
  final String right;
  const _RouteMetaRow({required this.left, required this.right});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextContainer(
            textKey: left,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
                height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (right.isNotEmpty) ...[
          const SizedBox(width: 6),
          CustomTextContainer(
            textKey: right,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
                height: 1.2),
          ),
        ],
      ],
    );
  }
}

class _TimelineColumnPainter extends CustomPainter {
  final int itemCount;
  final int currentIndex;
  final double tileHeight;
  final double lineWidth;
  _TimelineColumnPainter({
    required this.itemCount,
    required this.currentIndex,
    required this.tileHeight,
    this.lineWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    const double dotRadius = 6;
    final Paint linePaint = Paint()
      ..color = const Color(0xFFEBEEF3)
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.butt;
    for (int i = 0; i < itemCount; i++) {
      final double centerY = (i * tileHeight) + (tileHeight / 2);
      final double topY = i == 0 ? centerY : (i * tileHeight);
      final double bottomY =
          i == itemCount - 1 ? centerY : ((i + 1) * tileHeight);

      if (i != 0) {
        canvas.drawLine(
          Offset(centerX, topY),
          Offset(centerX, centerY - dotRadius),
          linePaint,
        );
      }

      final bool isCurrent = i == currentIndex;
      final Paint dotPaint = Paint()
        ..color = isCurrent ? const Color(0xFF57CC99) : const Color(0xFFEBEEF3);
      canvas.drawCircle(Offset(centerX, centerY), dotRadius, dotPaint);

      if (i != itemCount - 1) {
        canvas.drawLine(
          Offset(centerX, centerY + dotRadius),
          Offset(centerX, bottomY),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineColumnPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.tileHeight != tileHeight ||
        oldDelegate.lineWidth != lineWidth;
  }
}
