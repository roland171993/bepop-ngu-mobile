import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/selectTransport/widgets/inlineExpandableSelector.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/cubits/transport/pickupPointsCubit.dart';
import 'package:bepop_ngu/cubits/transport/shiftsCubit.dart';
import 'package:bepop_ngu/cubits/transport/feesCubit.dart';
import 'package:bepop_ngu/cubits/transport/enrollFormCubit.dart';

class StaffTransportEnrollScreen extends StatelessWidget {
  final int? studentUserId;

  const StaffTransportEnrollScreen({super.key, this.studentUserId});

  static Widget getRouteInstance() {
    // Extract the student's userId from navigation arguments
    final int? studentUserId = Get.arguments as int?;
    return StaffTransportEnrollScreen(studentUserId: studentUserId);
  }

  Widget _buildFormContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
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
          _onContinueTap(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        buttonTitle: continueKey,
        showBorder: false,
        widthPercentage: 1.0,
        height: 50,
        radius: 8,
      ),
    );
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

    int? userId = studentUserId;

    if (userId == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(unableToIdentifyStudentKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    // Get transportation fee ID from selected fee plan
    int transportationFeeId = formState.selectedFee?.id ?? 1;

    if (formState.selectedFee?.id == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(invalidFeePlanKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    // Get shift ID - this is required
    int? shiftId = formState.selectedShift?.id;

    if (shiftId == null) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(invalidShiftKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    // Navigate to transportation payment screen with selected data
    Get.toNamed(Routes.transportationPayment, arguments: {
      'pickupPoint': formState.selectedPickup!,
      'selectedPlan': formState.selectedFee!,
      'transportationFeeId': transportationFeeId,
      'userId': userId,
      'shiftId': shiftId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PickupPointsCubit()..fetch()),
        BlocProvider(create: (_) => ShiftsCubit()),
        BlocProvider(create: (_) => FeesCubit()),
        BlocProvider(create: (_) => TransportEnrollFormCubit()),
        // AuthCubit should already be available from higher level, but we can access it
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Column(
              children: [
                const CustomAppBar(
                  title: transportationKey,
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildFormContent(context),
                  ),
                ),
                SafeArea(top: false, child: _buildBottomAction(context)),
              ],
            ),
          );
        },
      ),
    );
  }
}
