import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/transportDashboardCubit.dart';
import 'package:bepop_ngu/cubits/transportRequestDetailsCubit.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/data/repositories/transportRepository.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/busInfoCard.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/liveTrackingCard.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/transportPlanCard.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/transportRequest.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/shimmerLoadingContainer.dart';
import 'package:bepop_ngu/ui/widgets/customShimmerContainer.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';
import 'package:bepop_ngu/ui/widgets/noDataContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TransportHomeScreen extends StatefulWidget {
  final int? studentId;

  const TransportHomeScreen({super.key, this.studentId});

  static Widget getRouteInstance() {
    final int? studentId = Get.arguments as int?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransportDashboardCubit(),
        ),
        BlocProvider(
          create: (context) => TransportRequestDetailsCubit(
            transportRepository: TransportRepository(),
          ),
        ),
      ],
      child: TransportHomeScreen(studentId: studentId),
    );
  }

  @override
  State<TransportHomeScreen> createState() => _TransportHomeScreenState();
}

class _TransportHomeScreenState extends State<TransportHomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  void _fetchDashboardData() {
    // Use the student ID from navigation arguments
    // If not available, fallback to getting from auth repository
    int? userId = widget.studentId;

    if (userId == null) {
      final student = AuthRepository.getStudentDetails();
      userId = student.id;
    }

    // If still null, this means we don't have a valid student ID
    if (userId == null) {
      print("Error: No valid student ID found for transport dashboard");
      return;
    }

    context.read<TransportDashboardCubit>().fetchDashboard(
          userId: userId,
          pickupDrop: 1, // 1 for pickup, 0 for drop
        );

    // Also fetch transport request details
    context.read<TransportRequestDetailsCubit>().fetchTransportRequestDetails(
          userId: userId,
        );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(appContentHorizontalPadding),
      child: Column(
        children: [
          ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 150,
              width: double.infinity,
              borderRadius: 12,
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ),
          ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 120,
              width: double.infinity,
              borderRadius: 12,
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ),
          ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 130,
              width: double.infinity,
              borderRadius: 12,
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ),
          ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 100,
              width: double.infinity,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const CustomAppBar(
            title: transportationKey,
            showBackButton: true,
          ),
          Expanded(
            child:
                BlocBuilder<TransportDashboardCubit, TransportDashboardState>(
              builder: (context, state) {
                if (state is TransportDashboardFetchInProgress) {
                  return _buildLoadingState();
                }

                if (state is TransportDashboardNoData) {
                  return Center(
                    child: NoDataContainer(
                      titleKey: state.statusMessage,
                    ),
                  );
                }

                if (state is TransportDashboardFetchFailure) {
                  return ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: _fetchDashboardData,
                  );
                }

                if (state is TransportDashboardFetchSuccess) {
                  return RefreshIndicator(
                    onRefresh: () async => _fetchDashboardData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(appContentHorizontalPadding),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 460;
                          final columnGap = isWide ? 16.0 : 12.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TransportPlanCard(
                                plan: state.dashboard.plan,
                                studentId: widget.studentId,
                              ),
                              SizedBox(height: columnGap),
                              BusInfoCard(busInfo: state.dashboard.busInfo),
                              SizedBox(height: columnGap),
                              LiveTrackingCard(
                                
                                  liveSummary: context
                                      .read<TransportDashboardCubit>()
                                      .getLiveSummary(),
                                  studentId: widget.studentId),
                              const SizedBox(height: 8),
                              SizedBox(height: columnGap),
                              AttendanceCard(
                                todayAttendance:
                                    state.dashboard.todayAttendance,
                                pickupStopName:
                                    state.dashboard.plan?.pickupStop?.name,
                                studentId: widget.studentId,
                                pickupTime: state.dashboard.plan?.pickupStop?.pickUpTime,
                                
                              ),
                              // Only show Transport Request for parents
                              if (context.read<AuthCubit>().isParent()) ...[
                                SizedBox(height: columnGap),
                                BlocBuilder<TransportRequestDetailsCubit,
                                    TransportRequestDetailsState>(
                                  builder: (context, requestState) {
                                    if (requestState
                                        is TransportRequestDetailsFetchSuccess) {
                                      final firstRequest = context
                                          .read<TransportRequestDetailsCubit>()
                                          .getFirstTransportRequest();
                                      return TransportRequest(
                                          requestData: firstRequest);
                                    }
                                    return const TransportRequest(
                                        requestData: null);
                                  },
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }

                // Default fallback state
                return SingleChildScrollView(
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 460;
                      final columnGap = isWide ? 16.0 : 12.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TransportPlanCard(studentId: widget.studentId),
                          SizedBox(height: columnGap),
                          const BusInfoCard(),
                          SizedBox(height: columnGap),
                          LiveTrackingCard(studentId: widget.studentId),
                          const SizedBox(height: 8),
                          SizedBox(height: columnGap),
                          AttendanceCard(studentId: widget.studentId),
                          // Only show Transport Request for parents
                          if (context.read<AuthCubit>().isParent()) ...[
                            SizedBox(height: columnGap),
                            BlocBuilder<TransportRequestDetailsCubit,
                                TransportRequestDetailsState>(
                              builder: (context, requestState) {
                                if (requestState
                                    is TransportRequestDetailsFetchSuccess) {
                                  final firstRequest = context
                                      .read<TransportRequestDetailsCubit>()
                                      .getFirstTransportRequest();
                                  return TransportRequest(
                                      requestData: firstRequest);
                                }
                                return const TransportRequest(
                                    requestData: null);
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
