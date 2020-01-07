import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/selectTransport/widgets/inlineExpandableSelector.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepop_ngu/cubits/transport/feesCubit.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/cubits/latestPaymentTransactionCubit.dart';
import 'package:bepop_ngu/cubits/schoolConfigurationCubit.dart';
import 'package:bepop_ngu/cubits/transportationPrePaymentTasksCubit.dart';
import 'package:bepop_ngu/cubits/transportPlanDetailsCubit.dart';
import 'package:bepop_ngu/data/models/paymentGateway.dart';
import 'package:bepop_ngu/data/repositories/paymentRepository.dart';
import 'package:bepop_ngu/ui/screens/childFeeDetails/widgets/pendingTransactionWarningDialog.dart';
import 'package:bepop_ngu/ui/screens/childFeeDetails/widgets/selectPaymentMethodBottomsheet.dart';
import 'package:bepop_ngu/ui/widgets/customCircularProgressIndicator.dart';
import 'package:bepop_ngu/utils/paymentGatewayService.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/ui/widgets/errorContainer.dart';

class PlanRenewalScreen extends StatefulWidget {
  final int? userId;

  const PlanRenewalScreen({super.key, this.userId});

  static Widget getRouteInstance() {
    final arguments = Get.arguments;
    int? userId;

    // Extract userId from arguments if provided
    if (arguments is Map<String, dynamic>) {
      userId = arguments['userId'] as int?;
    } else if (arguments is int) {
      userId = arguments;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FeesCubit()),
        BlocProvider(create: (context) => TransportationPrePaymentTasksCubit()),
        BlocProvider(
          create: (context) =>
              LatestPaymentTransactionCubit(PaymentRepository()),
        ),
        BlocProvider(create: (context) => TransportPlanDetailsCubit()),
      ],
      child: PlanRenewalScreen(userId: userId),
    );
  }

  @override
  State<PlanRenewalScreen> createState() => _PlanRenewalScreenState();
}

class _PlanRenewalScreenState extends State<PlanRenewalScreen> {
  bool _isDurationOpen = false;
  String? _selectedDuration;
  final Razorpay _razorpay = Razorpay();
  PaymentGatewayService? _paymentService;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();

    // Get userId from widget or AuthRepository
    _currentUserId = widget.userId;
    if (_currentUserId == null) {
      final student = AuthRepository.getStudentDetails();
      _currentUserId = student.id;
    }

    // Fetch plan details from API
    if (_currentUserId != null) {
      Future.delayed(Duration.zero, () {
        context.read<TransportPlanDetailsCubit>().fetchPlanDetails(
              userId: _currentUserId!,
            );
      });
    }
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
        // Payment completed callback - navigate back or show success
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

  void startPrePaymentProcess() {
    // Validate selected duration
    if (_selectedDuration == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: "Please select a duration",
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    // Get plan details from cubit
    final planDetailsCubit = context.read<TransportPlanDetailsCubit>();
    final planDetails = planDetailsCubit.getPlanDetails();

    // Validate all required fields
    if (planDetails == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: "Plan details not available. Please try again.",
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_currentUserId == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(unableToIdentifyStudentKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (planDetails.pickupStop?.id == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(invalidPickupPointKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (planDetails.shiftId == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage:
            "Shift information not available. Please contact support.",
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    // Get the selected fee plan from FeesCubit
    final feesState = context.read<FeesCubit>().state;
    if (feesState is! FeesFetchSuccess) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: "Fee information not available. Please try again.",
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final selectedFeePlan = feesState.feesResponse.fees.firstWhere(
      (fee) => fee.displayLabel == _selectedDuration,
      orElse: () => feesState.feesResponse.fees.first,
    );

    if (selectedFeePlan.id == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(invalidFeePlanKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final enabledPaymentGateways = context
        .read<SchoolConfigurationCubit>()
        .getSchoolConfiguration()
        .enabledPaymentGateways;

    if (enabledPaymentGateways.length == 1) {
      context.read<TransportationPrePaymentTasksCubit>().performPrePaymentTasks(
            paymentMethod: enabledPaymentGateways.first,
            userId: _currentUserId!,
            pickupPointId: planDetails.pickupStop!.id!,
            transportationFeeId: selectedFeePlan.id!,
            shiftId: planDetails.shiftId!,
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
                userId: _currentUserId!,
                pickupPointId: planDetails.pickupStop!.id!,
                transportationFeeId: selectedFeePlan.id!,
                shiftId: planDetails.shiftId!,
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

  Widget _buildCurrentPlanCard(TransportPlanDetailsState state) {
    if (state is TransportPlanDetailsFetchInProgress) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CustomCircularProgressIndicator(
            widthAndHeight: 30,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (state is TransportPlanDetailsFetchFailure) {
      return ErrorContainer(
        errorMessageCode: state.errorMessage,
        onTapRetry: () {
          if (_currentUserId != null) {
            context
                .read<TransportPlanDetailsCubit>()
                .fetchPlanDetails(userId: _currentUserId!);
          }
        },
      );
    }

    if (state is TransportPlanDetailsNoData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 60,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  if (_currentUserId != null) {
                    context
                        .read<TransportPlanDetailsCubit>()
                        .fetchPlanDetails(userId: _currentUserId!);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TransportPlanDetailsFetchSuccess) {
      final planDetails = state.planDetails;

      // Fetch fees when we have pickup point ID
      if (planDetails.pickupStop?.id != null) {
        final feesState = context.watch<FeesCubit>().state;
        if (feesState is FeesInitial) {
          Future.delayed(Duration.zero, () {
            context.read<FeesCubit>().fetch(
                  pickupPointId: planDetails.pickupStop!.id!,
                );
          });
        }
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 720;
          final double gap = isWide ? 16 : 12;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTextContainer(
                textKey: 'Current Plan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.tertiary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelValue(
                        label: 'Route Name',
                        value: planDetails.route?.name ?? 'N/A',
                        addTopSpacing: false),
                    LabelValue(
                        label: 'Pickup Location',
                        value: planDetails.pickupStop?.name ?? 'N/A'),
                    LabelValue(
                        label: 'Plan', value: planDetails.duration ?? 'N/A'),
                    LabelValue(
                        label: 'Validity',
                        value: planDetails.validFrom != null &&
                                planDetails.validTo != null
                            ? '${planDetails.validFrom} - ${planDetails.validTo}'
                            : 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              CustomTextContainer(
                textKey:
                    'No changes will be made to your route or pickup point',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: gap + 6),
              // Fee/Duration selector
              BlocBuilder<FeesCubit, FeesState>(
                builder: (context, feesState) {
                  final bool isLoading = feesState is FeesFetchInProgress;
                  final List<String> durations = feesState is FeesFetchSuccess
                      ? feesState.feesResponse.fees
                          .map((fee) => fee.displayLabel)
                          .toList()
                      : [];

                  final bool hasError = feesState is FeesFetchFailure;
                  final bool disabled = isLoading || durations.isEmpty;

                  String hint = 'Select Duration';
                  if (isLoading) {
                    hint = 'Loading fees...';
                  } else if (hasError) {
                    hint = 'Failed to load fees';
                  } else if (durations.isEmpty) {
                    hint = Utils.getTranslatedLabel(noDataFoundKey);
                  }

                  return InlineExpandableSelector(
                    label: 'Select Duration',
                    hint: hint,
                    selected: _selectedDuration,
                    values: durations,
                    isOpen: _isDurationOpen,
                    isDisabled: disabled,
                    onHeaderTap: () {
                      if (!disabled) {
                        setState(() => _isDurationOpen = !_isDurationOpen);
                      }
                    },
                    onSelected: (v) => setState(() {
                      _selectedDuration = v;
                      _isDurationOpen = false;
                    }),
                  );
                },
              ),
              SizedBox(height: gap),
            ],
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const CustomAppBar(title: 'Plan Renewal', showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: appContentHorizontalPadding,
                vertical: 16,
              ),
              child: BlocBuilder<TransportPlanDetailsCubit,
                  TransportPlanDetailsState>(
                builder: (context, state) {
                  return _buildCurrentPlanCard(state);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(appContentHorizontalPadding),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: BlocConsumer<LatestPaymentTransactionCubit,
                    LatestPaymentTransactionState>(
                  listener: (context, state) {
                    latestPaymentTransactionListener(state: state);
                  },
                  builder: (context, state) {
                    return BlocConsumer<TransportationPrePaymentTasksCubit,
                        TransportationPrePaymentTasksState>(
                      listener: (context, paymentTaskState) {
                        // Initialize payment service if not already done
                        _initializePaymentService();

                        // Handle the payment gateway opening using the service
                        _paymentService
                            ?.handlePrePaymentTasksListener(paymentTaskState);
                      },
                      builder: (context, paymentTaskState) {
                        final planDetailsState =
                            context.watch<TransportPlanDetailsCubit>().state;
                        final feesState = context.watch<FeesCubit>().state;

                        final isLoading = (state
                                is LatestPaymentTransactionFetchInProgress) ||
                            (paymentTaskState
                                is TransportationPrePaymentTasksInProgress) ||
                            (planDetailsState
                                is TransportPlanDetailsFetchInProgress) ||
                            (feesState is FeesFetchInProgress);

                        final isDisabled = isLoading ||
                            planDetailsState
                                is! TransportPlanDetailsFetchSuccess ||
                            feesState is! FeesFetchSuccess;

                        return PopScope(
                          canPop: !isLoading,
                          child: CustomRoundedButton(
                            onTap: () {
                              if (isDisabled) {
                                return;
                              }

                              // Trigger payment flow
                              context
                                  .read<LatestPaymentTransactionCubit>()
                                  .fetchLatestPaymentTransactions();
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            buttonTitle: (planDetailsState
                                        is TransportPlanDetailsFetchInProgress) ||
                                    (feesState is FeesFetchInProgress)
                                ? 'Loading...'
                                : 'Continue',
                            showBorder: false,
                            widthPercentage: 1.0,
                            height: 50,
                            radius: 12,
                            child: isLoading
                                ? CustomCircularProgressIndicator(
                                    widthAndHeight: 20,
                                    strokeWidth: 2,
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
