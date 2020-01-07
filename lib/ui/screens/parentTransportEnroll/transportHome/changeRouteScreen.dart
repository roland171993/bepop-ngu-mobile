import 'package:bepop_ngu/data/models/transportPlanDetails.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/routeReviewCard.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/selectTransport/widgets/inlineExpandableSelector.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepop_ngu/cubits/transport/pickupPointsCubit.dart';
import 'package:bepop_ngu/cubits/transport/shiftsCubit.dart';
import 'package:bepop_ngu/cubits/transport/feesCubit.dart';
import 'package:bepop_ngu/cubits/transport/enrollFormCubit.dart';
import 'package:bepop_ngu/cubits/transportationPrePaymentTasksCubit.dart';
import 'package:bepop_ngu/cubits/schoolConfigurationCubit.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/data/repositories/schoolRepository.dart';
import 'package:bepop_ngu/data/models/paymentGateway.dart';
import 'package:bepop_ngu/ui/screens/childFeeDetails/widgets/selectPaymentMethodBottomsheet.dart';
import 'package:bepop_ngu/cubits/authCubit.dart';
import 'package:bepop_ngu/utils/paymentGatewayService.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:bepop_ngu/data/models/busRouteStops.dart';
import 'package:get/get.dart';

class ChangeRouteScreen extends StatefulWidget {
  final BusRouteStops? currentRouteStops;
  final TransportPlanDetails? currentPlan;

  const ChangeRouteScreen(
      {super.key, this.currentRouteStops, this.currentPlan});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final BusRouteStops? routeStops =
        arguments?['routeStops'] as BusRouteStops?;
    final TransportPlanDetails? planDetails =
        arguments?['planDetails'] as TransportPlanDetails?;
    return ChangeRouteScreen(
        currentRouteStops: routeStops, currentPlan: planDetails);
  }

  @override
  State<ChangeRouteScreen> createState() => _ChangeRouteScreenState();
}

class _ChangeRouteScreenState extends State<ChangeRouteScreen> {
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

  Widget _headerCard() {
    // Get route display info from the passed routeStops data
    final String routeInfo = widget.currentRouteStops?.routeDisplayInfo ??
        widget.currentPlan?.route?.name ??
        'Route information not available';
    final String pickupInfo = widget.currentRouteStops?.userPickupInfo ??
        widget.currentPlan?.pickupStop?.name ??
        'Your pickup information not available';

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF57CC99)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaRow(left: routeInfo, right: ''),
          const SizedBox(height: 4),
          _MetaRow(left: pickupInfo, right: ''),
        ],
      ),
    );
  }

  Widget _content() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth >= 600;
      final double gap = isWide ? 20.0 : 16.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCard(),
          SizedBox(height: gap),
          // Pickup Points Dropdown
          BlocBuilder<PickupPointsCubit, PickupPointsState>(
            builder: (context, pickupState) {
              final formState = context.watch<TransportEnrollFormCubit>().state;
              final bool isLoading = pickupState is PickupPointsFetchInProgress;
              final List<String> values =
                  pickupState is PickupPointsFetchSuccess
                      ? pickupState.pickupPoints
                          .map((e) => e.name ?? '')
                          .where((e) => e.isNotEmpty)
                          .toList()
                      : <String>[];
              String? selected = formState.selectedPickup?.name;
              bool disabled = isLoading || values.isEmpty;
              if (values.isEmpty) {
                selected = Utils.getTranslatedLabel(noDataFoundKey);
              }
              return InlineExpandableSelector(
                label: selectPickDropPointKey,
                hint: values.isEmpty
                    ? Utils.getTranslatedLabel(noDataFoundKey)
                    : selectPickDropPointKey,
                selected: selected,
                values: values,
                isOpen: formState.isPickupOpen,
                isDisabled: disabled,
                onHeaderTap: () {
                  context.read<TransportEnrollFormCubit>().togglePickupOpen();
                },
                onSelected: (v) {
                  if (pickupState is! PickupPointsFetchSuccess) return;
                  final picked = pickupState.pickupPoints.firstWhere(
                      (element) => (element.name ?? '') == v,
                      orElse: () => pickupState.pickupPoints.first);
                  context.read<TransportEnrollFormCubit>().selectPickup(picked);
                  // Fetch dependent data
                  if (picked.id != null) {
                    context
                        .read<ShiftsCubit>()
                        .fetch(pickupPointId: picked.id!);
                    context.read<FeesCubit>().fetch(pickupPointId: picked.id!);
                  }
                },
              );
            },
          ),
          SizedBox(height: gap),
          // Shifts Dropdown
          BlocBuilder<ShiftsCubit, ShiftsState>(
            builder: (context, shiftsState) {
              final formState = context.watch<TransportEnrollFormCubit>().state;
              final bool isLoading = shiftsState is ShiftsFetchInProgress;
              final List<String> values = shiftsState is ShiftsFetchSuccess
                  ? shiftsState.shifts
                      .map((e) => e.displayName)
                      .where((e) => e.isNotEmpty)
                      .toList()
                  : <String>[];
              String? selected = formState.selectedShift?.displayName;
              final bool disabled = formState.selectedPickup == null ||
                  isLoading ||
                  values.isEmpty;
              if (values.isEmpty && formState.selectedPickup != null) {
                selected = Utils.getTranslatedLabel(noDataFoundKey);
              }
              return InlineExpandableSelector(
                label: selectShiftKey,
                hint: values.isEmpty
                    ? Utils.getTranslatedLabel(noDataFoundKey)
                    : selectShiftKey,
                selected: selected,
                values: values,
                isOpen: formState.isShiftOpen,
                isDisabled: disabled,
                onHeaderTap: () {
                  if (!disabled) {
                    context.read<TransportEnrollFormCubit>().toggleShiftOpen();
                  }
                },
                onSelected: (v) {
                  if (shiftsState is! ShiftsFetchSuccess) return;
                  final picked = shiftsState.shifts.firstWhere(
                      (element) => element.displayName == v,
                      orElse: () => shiftsState.shifts.first);
                  context.read<TransportEnrollFormCubit>().selectShift(picked);
                },
              );
            },
          ),
          SizedBox(height: gap),
          // Fees Dropdown
          BlocBuilder<FeesCubit, FeesState>(
            builder: (context, feesState) {
              final formState = context.watch<TransportEnrollFormCubit>().state;
              final bool isLoading = feesState is FeesFetchInProgress;
              final List<String> values = feesState is FeesFetchSuccess
                  ? feesState.feesResponse.fees
                      .map((e) => e.toString())
                      .where((e) => e.isNotEmpty)
                      .toList()
                  : <String>[];
              String? selected = formState.selectedFee?.toString();
              final bool disabled = formState.selectedPickup == null ||
                  isLoading ||
                  values.isEmpty;
              if (values.isEmpty && formState.selectedPickup != null) {
                selected = Utils.getTranslatedLabel(noDataFoundKey);
              }
              return InlineExpandableSelector(
                label: selectDurationKey,
                hint: values.isEmpty
                    ? Utils.getTranslatedLabel(noDataFoundKey)
                    : selectDurationKey,
                selected: selected,
                values: values,
                isOpen: formState.isDurationOpen,
                isDisabled: disabled,
                onHeaderTap: () {
                  if (!disabled) {
                    context
                        .read<TransportEnrollFormCubit>()
                        .toggleDurationOpen();
                  }
                },
                onSelected: (v) {
                  if (feesState is! FeesFetchSuccess) return;
                  final picked = feesState.feesResponse.fees.firstWhere(
                      (element) => element.toString() == v,
                      orElse: () => feesState.feesResponse.fees.first);
                  context.read<TransportEnrollFormCubit>().selectFee(picked);
                },
              );
            },
          ),
          SizedBox(height: gap * 2),
        ],
      );
    });
  }

  void _onContinueTap(BuildContext context) {
    final formState = context.read<TransportEnrollFormCubit>().state;

    // Validate form data
    if (formState.selectedPickup == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(pleaseSelectPickDropPointKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (formState.selectedShift == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(pleaseSelectShiftKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final feesState = context.read<FeesCubit>().state;
    final bool mustSelectFee =
        feesState is FeesFetchSuccess && feesState.feesResponse.fees.isNotEmpty;

    if (mustSelectFee && formState.selectedFee == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(pleaseSelectDurationKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    _showReviewBottomSheet(context, formState);
  }

  void _handleConfirmPayment(
      BuildContext context, TransportEnrollFormState formState) async {
    try {
      // Get user details from AuthRepository
      final userDetails = AuthRepository.getParentDetails();
      final userId = userDetails.id;

      if (userId == null) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: "User not authenticated. Please login again.",
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      // Validate required data
      if (formState.selectedPickup?.id == null) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: Utils.getTranslatedLabel(invalidPickupPointKey),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      if (formState.selectedFee?.id == null) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: Utils.getTranslatedLabel(invalidFeePlanKey),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      if (formState.selectedShift?.id == null) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: Utils.getTranslatedLabel(invalidShiftKey),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      // Get enabled payment gateways from school configuration
      final enabledPaymentGateways = context
          .read<SchoolConfigurationCubit>()
          .getSchoolConfiguration()
          .enabledPaymentGateways;

      if (enabledPaymentGateways.isEmpty) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: "${Utils.getTranslatedLabel(noPaymentMethodsAvailableKey)} ${Utils.getTranslatedLabel(contactSupportKey)}.",
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      if (enabledPaymentGateways.length == 1) {
        // Use the only available payment method
        await context
            .read<TransportationPrePaymentTasksCubit>()
            .performPrePaymentTasks(
              paymentMethod: enabledPaymentGateways.first,
              userId: userId,
              pickupPointId: formState.selectedPickup!.id!,
              transportationFeeId: formState.selectedFee!.id!,
              shiftId: formState.selectedShift!.id!,
              isChangeRoute: true, // This is the key parameter for change route
            );
      } else {
        // Show payment method selection bottom sheet
        final selectedPaymentMethod = await Utils.showBottomSheet(
          child: SelectPaymentMethodBottomsheet(
            paymentGeteways: enabledPaymentGateways,
          ),
          context: context,
        );

        if (selectedPaymentMethod != null) {
          await context
              .read<TransportationPrePaymentTasksCubit>()
              .performPrePaymentTasks(
                paymentMethod: selectedPaymentMethod as PaymentGeteway,
                userId: userId,
                pickupPointId: formState.selectedPickup!.id!,
                transportationFeeId: formState.selectedFee!.id!,
                shiftId: formState.selectedShift!.id!,
                isChangeRoute:
                    true, // This is the key parameter for change route
              );
        }
      }
    } catch (e) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: "An error occurred: ${e.toString()}",
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  void _showReviewBottomSheet(
      BuildContext context, TransportEnrollFormState formState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocProvider(
            create: (context) => TransportationPrePaymentTasksCubit(),
            child: BlocListener<TransportationPrePaymentTasksCubit,
                TransportationPrePaymentTasksState>(
              listener: (bottomSheetContext, state) {
                // Initialize payment service with the correct cubits
                _paymentService = PaymentGatewayService(
                  context: bottomSheetContext,
                  razorpay: _razorpay,
                  onPaymentComplete: () {
                    // Payment completed callback - can be used for cleanup or tracking
                  },
                  transportationCubit: bottomSheetContext
                      .read<TransportationPrePaymentTasksCubit>(),
                  schoolConfigCubit:
                      this.context.read<SchoolConfigurationCubit>(),
                  authCubit: this.context.read<AuthCubit>(),
                );

                // Close the bottom sheet first when payment tasks complete
                if (state is TransportationPrePaymentTasksSuccess ||
                    state is TransportationPrePaymentTasksFailure) {
                  Navigator.of(ctx).pop();
                }

                // Handle the payment gateway opening using the service
                _paymentService?.handlePrePaymentTasksListener(state);
              },
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: appContentHorizontalPadding,
                    right: appContentHorizontalPadding,
                    top: 15,
                    bottom: MediaQuery.of(ctx).padding.bottom + 15,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextContainer(
                              textKey: 'Route Details',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),
                      RouteReviewCard(
                          currentRouteName: widget.currentPlan?.route?.name ??
                              '-', // You can get this from current transport plan
                          currentPickup: widget.currentPlan?.pickupStop?.name ??
                              '-', // You can get this from current transport plan
                          requestedRouteName:
                              formState.selectedPickup?.name ?? '-',
                          requestedPickup:
                              formState.selectedPickup?.name ?? '-',
                          currentFee: widget.currentPlan?.totalFee ??
                              '0', // You can get this from current transport plan
                          requestedFee:
                              formState.selectedFee?.formattedFeeAmount ?? '0',
                          noteText:
                              'Note: You need to pay \$${(double.tryParse(formState.selectedFee?.feeAmount ?? '0'))}. '
                              'The remaining balance from your current package cannot be applied to the new package. '
                              'To change the stop, you must pay the full price of the new stop.'),
                      const SizedBox(height: 15),
                      BlocBuilder<TransportationPrePaymentTasksCubit,
                          TransportationPrePaymentTasksState>(
                        builder: (context, paymentState) {
                          final bool isLoading = paymentState
                              is TransportationPrePaymentTasksInProgress;

                          return CustomRoundedButton(
                            onTap: isLoading
                                ? null
                                : () =>
                                    _handleConfirmPayment(context, formState),
                            backgroundColor: Theme.of(ctx).colorScheme.primary,
                            buttonTitle:
                                isLoading ? 'Processing...' : confirmKey,
                            showBorder: false,
                            widthPercentage: 1.0,
                            height: 50,
                            radius: 8,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PickupPointsCubit()..fetch()),
        BlocProvider(create: (_) => ShiftsCubit()),
        BlocProvider(create: (_) => FeesCubit()),
        BlocProvider(create: (_) => TransportEnrollFormCubit()),
        BlocProvider(create: (_) => TransportationPrePaymentTasksCubit()),
        BlocProvider(
            create: (_) => SchoolConfigurationCubit(SchoolRepository())
              ..fetchSchoolConfiguration(useParentApi: true)),
        BlocProvider(create: (_) => AuthCubit(AuthRepository())),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Column(
              children: [
                CustomAppBar(
                    title: Utils.getTranslatedLabel(changeRouteKey),
                    showBackButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding,
                      vertical: 16,
                    ),
                    child: _content(),
                  ),
                ),
                SafeArea(
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
                      onTap: () => _onContinueTap(context),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: continueKey,
                      showBorder: false,
                      widthPercentage: 1.0,
                      height: 50,
                      radius: 8,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String left;
  final String right;
  const _MetaRow({required this.left, required this.right});
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
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        CustomTextContainer(
          textKey: right,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}
