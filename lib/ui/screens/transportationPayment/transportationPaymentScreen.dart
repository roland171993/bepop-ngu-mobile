import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/latestPaymentTransactionCubit.dart';
import 'package:bepop_ngu/cubits/schoolConfigurationCubit.dart';
import 'package:bepop_ngu/cubits/transportationPrePaymentTasksCubit.dart';
import 'package:bepop_ngu/data/models/paymentGateway.dart';
import 'package:bepop_ngu/data/models/pickupPoint.dart';
import 'package:bepop_ngu/data/models/transportFee.dart';
import 'package:bepop_ngu/data/repositories/paymentRepository.dart';
import 'package:bepop_ngu/ui/screens/childFeeDetails/widgets/pendingTransactionWarningDialog.dart';
import 'package:bepop_ngu/ui/screens/childFeeDetails/widgets/selectPaymentMethodBottomsheet.dart';
import 'package:bepop_ngu/ui/widgets/customBackButton.dart';
import 'package:bepop_ngu/ui/widgets/customCircularProgressIndicator.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/paymentGatewayService.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class TransportationPaymentScreen extends StatefulWidget {
  final PickupPoint pickupPoint;
  final TransportFeePlan selectedPlan;
  final int transportationFeeId;
  final int userId;
  final int shiftId;

  const TransportationPaymentScreen({
    Key? key,
    required this.pickupPoint,
    required this.selectedPlan,
    required this.transportationFeeId,
    required this.userId,
    required this.shiftId,
  }) : super(key: key);

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TransportationPrePaymentTasksCubit()),
        BlocProvider(
          create: (context) =>
              LatestPaymentTransactionCubit(PaymentRepository()),
        ),
      ],
      child: TransportationPaymentScreen(
        pickupPoint: arguments['pickupPoint'] as PickupPoint,
        selectedPlan: arguments['selectedPlan'] as TransportFeePlan,
        transportationFeeId: arguments['transportationFeeId'] as int,
        userId: arguments['userId'] as int,
        shiftId: arguments['shiftId'] as int,
      ),
    );
  }

  @override
  State<TransportationPaymentScreen> createState() =>
      _TransportationPaymentScreenState();
}

class _TransportationPaymentScreenState
    extends State<TransportationPaymentScreen> {
  final Razorpay _razorpay = Razorpay();
  PaymentGatewayService? _paymentService;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _paymentService?.dispose();
    super.dispose();
  }

  /// Initialize payment service when context is available
  void _initializePaymentService() {
    _paymentService ??= PaymentGatewayService(
      context: context,
      razorpay: _razorpay,
      onPaymentComplete: () {
        // Payment completed callback - can be used for cleanup or tracking
      },
      transportationCubit: context.read<TransportationPrePaymentTasksCubit>(),
      schoolConfigCubit: context.read<SchoolConfigurationCubit>(),
      authCubit: context.read<AuthCubit>(),
    );
  }

  String getCurrencySymbol() {
    return context
            .read<SchoolConfigurationCubit>()
            .getSchoolConfiguration()
            .schoolSettings
            .currencySymbol ??
        '';
  }

  TextStyle getPaymentInfoTitleStyle() {
    return TextStyle(
      fontSize: 16.0,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  TextStyle getPaymentInfoAmountValueStyle() {
    return TextStyle(
      fontSize: 16.0,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  void startPrePaymentProcess() {
    final enabledPaymentGateways = context
        .read<SchoolConfigurationCubit>()
        .getSchoolConfiguration()
        .enabledPaymentGateways;

    if (enabledPaymentGateways.length == 1) {
      context.read<TransportationPrePaymentTasksCubit>().performPrePaymentTasks(
            paymentMethod: enabledPaymentGateways.first,
            userId: widget.userId,
            pickupPointId: widget.pickupPoint.id ?? 0,
            transportationFeeId: widget.transportationFeeId,
            shiftId: widget.shiftId,
          );
    } else {
      Utils.showBottomSheet(
        child: SelectPaymentMethodBottomsheet(
          paymentGeteways: enabledPaymentGateways,
        ),
        context: context,
      ).then((selectedPaymentMethod) {
        if (selectedPaymentMethod != null) {
          context
              .read<TransportationPrePaymentTasksCubit>()
              .performPrePaymentTasks(
                paymentMethod: selectedPaymentMethod as PaymentGeteway,
                userId: widget.userId,
                pickupPointId: widget.pickupPoint.id ?? 0,
                transportationFeeId: widget.transportationFeeId,
                shiftId: widget.shiftId,
              );
        }
      });
    }
  }

  void latestPaymentTransactionListener({
    required LatestPaymentTransactionState state,
  }) {
    if (state is LatestPaymentTransactionFetchSuccess) {
      if (context
          .read<LatestPaymentTransactionCubit>()
          .doesUserHaveLatestPendingTransactions()) {
        Get.dialog<bool>(PendingTransactionWarningDialog()).then((value) {
          if (value != null && value) {
            startPrePaymentProcess();
          }
        });
      } else {
        startPrePaymentProcess();
      }
    } else if (state is LatestPaymentTransactionFetchFailure) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getErrorMessageFromErrorCode(
          context,
          state.errorMessage,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomBackButton(
                onTap: () {
                  if (context.read<TransportationPrePaymentTasksCubit>().state
                      is TransportationPrePaymentTasksInProgress) {
                    return;
                  }
                  if (context.read<LatestPaymentTransactionCubit>().state
                      is LatestPaymentTransactionFetchInProgress) {
                    return;
                  }
                  Get.back();
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: boxConstraints.maxWidth * (0.8),
                  child: Text(
                    Utils.getTranslatedLabel(transportationPaymentKey),
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentInfoBackgroundContainer({required Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 7.5,
            color: Colors.black26,
            spreadRadius: 2.5,
            offset: Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Utils.bottomSheetTopRadius),
          topRight: Radius.circular(Utils.bottomSheetTopRadius),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      child: child,
    );
  }

  Widget _buildTransportationInfoContainer() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTranslatedLabel(transportationDetailsKey),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 15),
          _buildInfoRow(Utils.getTranslatedLabel(pickupPointKey),
              widget.pickupPoint.name ?? ""),
          _buildInfoRow(Utils.getTranslatedLabel(planDurationKey),
              widget.selectedPlan.displayLabel),
          _buildInfoRow(
            Utils.getTranslatedLabel(feeAmountLabelKey),
            "${getCurrencySymbol()}${widget.selectedPlan.feeAmount}",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: getPaymentInfoTitleStyle()),
          SizedBox(width: 10),
          Expanded(child: Text(value, style: getPaymentInfoAmountValueStyle())),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoContainer() {
    return _buildPaymentInfoBackgroundContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                Utils.getTranslatedLabel(totalAmountKey),
                style: getPaymentInfoTitleStyle(),
              ),
              const Spacer(),
              Text(
                "${getCurrencySymbol()}${widget.selectedPlan.feeAmount}",
                style: getPaymentInfoAmountValueStyle(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildPayNowButton(),
        ],
      ),
    );
  }

  Widget _buildPayNowButton() {
    return BlocConsumer<LatestPaymentTransactionCubit,
        LatestPaymentTransactionState>(
      listener: (context, state) {
        latestPaymentTransactionListener(state: state);
      },
      builder: (context, state) {
        return BlocConsumer<TransportationPrePaymentTasksCubit,
            TransportationPrePaymentTasksState>(
          listener: (context, state) {
            // Initialize payment service if not already done
            _initializePaymentService();

            // Handle the payment gateway opening using the service
            _paymentService?.handlePrePaymentTasksListener(state);
          },
          builder: (context, paymentTaskState) {
            return PopScope(
              canPop: (state is! LatestPaymentTransactionFetchInProgress) &&
                  (paymentTaskState
                      is! TransportationPrePaymentTasksInProgress),
              child: CustomRoundedButton(
                height: 35,
                radius: 5.0,
                widthPercentage: 0.9,
                backgroundColor: Theme.of(context).colorScheme.primary,
                buttonTitle: Utils.getTranslatedLabel(payNowKey),
                showBorder: false,
                child: (paymentTaskState
                            is TransportationPrePaymentTasksInProgress) ||
                        (state is LatestPaymentTransactionFetchInProgress)
                    ? CustomCircularProgressIndicator(
                        widthAndHeight: 20,
                        strokeWidth: 2,
                      )
                    : null,
                onTap: () {
                  if (state is LatestPaymentTransactionFetchInProgress) {
                    return;
                  }
                  if (paymentTaskState
                      is TransportationPrePaymentTasksInProgress) {
                    return;
                  }

                  context
                      .read<LatestPaymentTransactionCubit>()
                      .fetchLatestPaymentTransactions();
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * (0.3),
                left: Utils.screenContentHorizontalPadding,
                right: Utils.screenContentHorizontalPadding,
                top: Utils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
                ),
              ),
              child: Column(children: [_buildTransportationInfoContainer()]),
            ),
          ),
          Align(alignment: Alignment.topCenter, child: _buildAppBar()),
          Align(
            alignment: Alignment.bottomCenter,
            child: context
                    .read<SchoolConfigurationCubit>()
                    .getSchoolConfiguration()
                    .isOnlineFeePaymentEnable()
                ? _buildPaymentInfoContainer()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
