import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/transportPlanDetailsCubit.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
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

class TransportPlanDetailsScreen extends StatefulWidget {
  final int? studentId;

  const TransportPlanDetailsScreen({super.key, this.studentId});

  static Widget getRouteInstance() {
    final int? studentId = Get.arguments as int?;
    return BlocProvider(
      create: (context) => TransportPlanDetailsCubit(),
      child: TransportPlanDetailsScreen(studentId: studentId),
    );
  }

  @override
  State<TransportPlanDetailsScreen> createState() =>
      _TransportPlanDetailsScreenState();
}

class _TransportPlanDetailsScreenState
    extends State<TransportPlanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchPlanDetails();
  }

  void _fetchPlanDetails() {
    int? userId = widget.studentId;

    // If still null, this means we don't have a valid student ID
    if (userId == null) {
      print("Error: No valid student ID found for transport plan details");
      return;
    }

    context.read<TransportPlanDetailsCubit>().fetchPlanDetails(userId: userId);
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
            child: BlocBuilder<TransportPlanDetailsCubit,
                TransportPlanDetailsState>(
              builder: (context, state) {
                if (state is TransportPlanDetailsFetchInProgress) {
                  return _buildLoadingState();
                }

                if (state is TransportPlanDetailsNoData) {
                  return Center(
                    child: NoDataContainer(
                      titleKey: noTransportAssignedKey,
                    ),
                  );
                }

                if (state is TransportPlanDetailsFetchFailure) {
                  return ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: _fetchPlanDetails,
                  );
                }

                if (state is TransportPlanDetailsFetchSuccess) {
                  return _buildPlanDetailsContent(state.planDetails);
                }

                // Default loading state
                return _buildLoadingState();
              },
            ),
          ),
          BlocBuilder<TransportPlanDetailsCubit, TransportPlanDetailsState>(
            builder: (context, state) {
              if (state is TransportPlanDetailsFetchSuccess) {
                return _buildBottomButton();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
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
              height: 200,
              width: double.infinity,
              borderRadius: 12,
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ),
          ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 200,
              width: double.infinity,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsContent(planDetails) {
    return RefreshIndicator(
      onRefresh: () async => _fetchPlanDetails(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding,
          vertical: 16,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 860;
            final double gap = isWide ? 20.0 : 14.0;

            final Widget routePickupSection = _SectionCard(
              title: ' Route & Pickup Details',
              children: [
                LabelValue(
                  label: 'Route Name',
                  value: planDetails.route?.name ?? 'Not specified',
                  addTopSpacing: false,
                ),
                LabelValue(
                  label: 'Pickup Location',
                  value: planDetails.pickupStop?.name ?? 'Not specified',
                ),
                LabelValue(
                  label: 'Shift',
                  value: planDetails.shiftDetails,
                ),
                LabelValue(
                  label: 'Pickup Time',
                  value: planDetails.pickupTimeFormatted,
                  addBottomSpacing: false,
                ),
              ],
            );

            final Widget planSection = _SectionCard(
              title: ' Plan Details',
              children: [
                LabelValue(
                  label: 'Plan',
                  value: planDetails.duration ?? 'Not specified',
                  addTopSpacing: false,
                ),
                LabelValue(
                  label: 'Validity',
                  value: planDetails.validityPeriod,
                ),
                LabelValue(
                  label: 'Total Fee',
                  value: planDetails.totalFee ?? 'Not specified',
                ),
                LabelValue(
                  label: 'Payment Mode',
                  value: planDetails.paymentModeFormatted,
                  addBottomSpacing: false,
                ),
              ],
            );

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  routePickupSection,
                  SizedBox(height: gap),
                  planSection,
                  SizedBox(height: gap),
                  const SizedBox(height: 8),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: routePickupSection),
                    SizedBox(width: gap),
                    Expanded(child: planSection),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return SafeArea(
      top: false,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(appContentHorizontalPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CustomRoundedButton(
          onTap: () {
            Get.toNamed(Routes.busRouteScreen, arguments: {
              'studentId': widget.studentId,
              'planDetails':
                  context.read<TransportPlanDetailsCubit>().getPlanDetails(),
            });
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          buttonTitle: busRouteKey,
          showBorder: false,
          widthPercentage: 1.0,
          height: 50,
          radius: 8,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CustomTextContainer(
            textKey: title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        EnrollCard(
          title: '',
          trailing: const SizedBox(),
          showHeader: false,
          children: children,
        ),
      ],
    );
  }
}
