import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/childFeeDetailsCubit.dart';
import 'package:bepop_ngu/data/models/childFeeDetails.dart';
import 'package:bepop_ngu/data/models/student.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/customCircularProgressIndicator.dart';
import 'package:bepop_ngu/ui/widgets/customRefreshIndicator.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';
import 'package:bepop_ngu/ui/widgets/noDataContainer.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChildFeesScreen extends StatefulWidget {
  final Student child;
  ChildFeesScreen({Key? key, required this.child}) : super(key: key);

  static Widget routeInstance() {
    return ChildFeesScreen(
      child: Get.arguments as Student,
    );
  }

  @override
  State<ChildFeesScreen> createState() => _ChildFeesScreenState();
}

class _ChildFeesScreenState extends State<ChildFeesScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Add the observer to listen for screen size/metrics changes
    WidgetsBinding.instance.addObserver(this);

    // Initial data fetch
    Future.delayed(Duration.zero, () {
      fetchChildFeeDetails();
    });
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Implement didChangeMetrics method
  @override
  void didChangeMetrics() {
    // Handle the metrics change, if needed
    super.didChangeMetrics();
  }

  void fetchChildFeeDetails() {
    if (mounted) {
      context
          .read<ChildFeeDetailsCubit>()
          .fetchChildFeeDetails(childId: widget.child.id ?? 0);
    }
  }

  Widget _buildFeesContainer({required List<ChildFeeDetails> fees}) {
    return CustomRefreshIndicator(
      displacment: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarSmallerHeightPercentage),
      onRefreshCallback: () async {
        fetchChildFeeDetails();
      },
      child: ListView.builder(
          padding: EdgeInsets.only(
            bottom: 25,
            left: Utils.screenContentHorizontalPadding,
            right: Utils.screenContentHorizontalPadding,
            top: Utils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
            ),
          ),
          itemCount: fees.length,
          itemBuilder: (context, index) {
            final feeDetails = fees[index];
            final valueTextStyle = TextStyle(
                fontSize: 13.0,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.9));
            final feePaymentStatusKey = feeDetails.getFeePaymentStatus();
            final feePaymentStatusColor = feePaymentStatusKey == pendingKey
                ? Theme.of(context).colorScheme.error
                : (feePaymentStatusKey == paidKey)
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary;
            return Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: GestureDetector(
                onTap: () {
                  // Use GetX navigation with refresh callback
                  Get.toNamed(Routes.childFeeDetails, arguments: {
                    "childFeeDetails": feeDetails,
                    "child": widget.child
                  })?.then((_) {
                    // Refresh data when returning from details/payment screen
                    fetchChildFeeDetails();
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feeDetails.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            "${Utils.getTranslatedLabel(classKey)} : ${feeDetails.classDetails?.name ?? '-'}",
                            style: valueTextStyle,
                          ),
                          const Spacer(),
                          Text(
                            feeDetails.sessionYear?.name ?? "",
                            style: valueTextStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.5),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Text(
                                  "${Utils.getTranslatedLabel(statusKey)} : ",
                                  style: valueTextStyle,
                                ),
                                Flexible(
                                  child: Text(
                                    Utils.getTranslatedLabel(
                                        feePaymentStatusKey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: valueTextStyle.copyWith(
                                        color: feePaymentStatusColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (feePaymentStatusKey != paidKey &&
                              !feeDetails
                                  .didUserPaidPreviousCompulsoryFeeInInstallment())
                            Expanded(
                              flex: 3,
                              child: Text(
                                "${Utils.getTranslatedLabel(dueDateKey)} : ${feeDetails.dueDate ?? ''}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: valueTextStyle,
                                textAlign: TextAlign.end,
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ChildFeeDetailsCubit, ChildFeeDetailsState>(
              builder: (context, state) {
            if (state is ChildFeeDetailsFetchSuccess) {
              if (state.fees.isEmpty) {
                return Center(
                  child: NoDataContainer(titleKey: noFeesFoundKey),
                );
              }
              return _buildFeesContainer(fees: state.fees);
            }
            if (state is ChildFeeDetailsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessageCode: state.errorMessage,
                  onTapRetry: () {
                    fetchChildFeeDetails();
                  },
                ),
              );
            }
            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }),
          Align(
            alignment: Alignment.topCenter,
            child: CustomAppBar(
              title: Utils.getTranslatedLabel(feesKey),
              onPressBackButton: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
