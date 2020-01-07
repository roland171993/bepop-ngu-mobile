import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepop_ngu/cubits/liveRouteCubit.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/data/models/liveRoute.dart';
import 'package:bepop_ngu/ui/widgets/customCircularProgressIndicator.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/liveTimeline.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';

class LiveRouteBottomSheet extends StatefulWidget {
  final int userId;

  const LiveRouteBottomSheet({
    super.key,
    required this.userId,
  });

  static void show(BuildContext context, {int? userId}) {
    // Get user ID from parameter or auth cubit
    final finalUserId =
        userId ?? context.read<AuthCubit>().getParentDetails().id ?? 0;

    if (finalUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${Utils.getTranslatedLabel(invalidUserIdKey)}. ${Utils.getTranslatedLabel(pleaseLoginAgainKey)}.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocProvider(
          create: (context) => LiveRouteCubit(),
          child: LiveRouteBottomSheet(
            userId: finalUserId,
          ),
        ),
      ),
    );
  }

  @override
  State<LiveRouteBottomSheet> createState() => _LiveRouteBottomSheetState();
}

class _LiveRouteBottomSheetState extends State<LiveRouteBottomSheet> {
  @override
  void initState() {
    super.initState();
    _fetchLiveRoute();
  }

  void _fetchLiveRoute() {
    context.read<LiveRouteCubit>().fetchLiveRoute(userId: widget.userId);
  }

  void _refreshLiveRoute() {
    if (widget.userId > 0) {
      context.read<LiveRouteCubit>().refreshLiveRoute(userId: widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight * 0.85;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: maxHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: BlocConsumer<LiveRouteCubit, LiveRouteState>(
                    listener: (context, state) {
                      if (state is LiveRouteFetchSuccess) {
                        final cubit = context.read<LiveRouteCubit>();

                        // Handle refresh completion
                        if (state.wasRefresh) {
                          if (cubit.hasActiveTrip()) {
                            // Show success message for refresh
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Live route data refreshed successfully',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }

                        if (!cubit.hasActiveTrip()) {
                          // Show snack bar for no trip
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(cubit.getNoTripMessage()),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      }

                      if (state is LiveRouteFetchFailure) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        // Only close bottom sheet if it's initial load failure, not refresh failure
                        if (!state.wasRefresh) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    builder: (context, state) {
                      // Handle initial state and loading states
                      if (state is LiveRouteInitial ||
                          state is LiveRouteFetchInProgress) {
                        // If it's a refresh and we have previous data, show it with refresh indicator
                        if (state is LiveRouteFetchInProgress &&
                            state.isRefresh &&
                            state.previousData != null) {
                          final response = state.previousData!;
                          if (response.hasTrip && response.trips.isNotEmpty) {
                            return _buildTripContent(response.trips.first);
                          }
                        }

                        // Initial loading or loading without previous data - show progress indicator
                        return Container(
                          width: double.infinity,
                          height: 300,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CustomCircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Loading live route data...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is LiveRouteFetchSuccess) {
                        final cubit = context.read<LiveRouteCubit>();
                        if (cubit.hasActiveTrip()) {
                          final trip = cubit.getFirstLiveTrip()!;
                          return _buildTripContent(trip);
                        }
                      }

                      if (state is LiveRouteFetchFailure &&
                          state.previousData != null) {
                        // Show previous data if refresh failed
                        final response = state.previousData!;
                        if (response.hasTrip && response.trips.isNotEmpty) {
                          return _buildTripContent(response.trips.first);
                        }
                      }

                      // Fallback for any other states
                      return Container(
                        width: double.infinity,
                        height: 300,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CustomCircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Loading live route data...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Live Route',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripContent(LiveTrip liveTrip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildEtaCard(liveTrip),
          const SizedBox(height: 20),
          _buildBusInfo(liveTrip),
          const SizedBox(height: 20),
          LiveTimeline(
            stops: liveTrip.stops,
            currentStopIndex: _getCurrentStopIndex(liveTrip),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEtaCard(LiveTrip liveTrip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currently at ${liveTrip.lastReachedStop?.name ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF424242),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusInfo(LiveTrip liveTrip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bus No : ${liveTrip.vehicle.number}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              liveTrip.route.name,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        BlocBuilder<LiveRouteCubit, LiveRouteState>(
          builder: (context, state) {
            final isRefreshing = context.read<LiveRouteCubit>().isRefreshing;

            return GestureDetector(
              onTap: isRefreshing ? null : () => _refreshLiveRoute(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRefreshing
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.7)
                      : Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white, size: 20),
              ),
            );
          },
        ),
      ],
    );
  }

  int _getCurrentStopIndex(LiveTrip liveTrip) {
    // Find the current stop based on last_reached_stop or completed stops
    if (liveTrip.lastReachedStop?.id != null) {
      // Find the stop with matching ID
      for (int i = 0; i < liveTrip.stops.length; i++) {
        if (liveTrip.stops[i].id == liveTrip.lastReachedStop!.id) {
          return i;
        }
      }
    }

    // Fallback: find the last completed stop
    for (int i = liveTrip.stops.length - 1; i >= 0; i--) {
      if (liveTrip.stops[i].isCompleted) {
        return i;
      }
    }

    // If no stop is completed, bus is at first stop
    return 0;
  }
}
