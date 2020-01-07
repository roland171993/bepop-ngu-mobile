import 'package:bepop_ngu/cubits/schoolConfigurationCubit.dart';
import 'package:bepop_ngu/data/models/advanceFee.dart';
import 'package:bepop_ngu/ui/widgets/bottomsheetTopTitleAndCloseButton.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class AdvanceInstallmentPaidAmountBottomsheet extends StatelessWidget {
  final List<AdvanceFee> advanceFees;
  const AdvanceInstallmentPaidAmountBottomsheet(
      {super.key, required this.advanceFees});

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context
            .read<SchoolConfigurationCubit>()
            .getSchoolConfiguration()
            .schoolSettings
            .currencySymbol ??
        '';
    double totalAdvancePaidAmount = 0.0;
    for (var advanceFee in advanceFees) {
      totalAdvancePaidAmount += (advanceFee.amount ?? 0.0);
    }

    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (0.075),
          vertical: MediaQuery.of(context).size.height * (0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomsheetTopTitleAndCloseButton(
              onTapCloseButton: () {
                Get.back();
              },
              titleKey: Utils.getTranslatedLabel(advancePaidAmountDetailsKey),
            ),
            Row(
              children: [
                Text(
                  Utils.getTranslatedLabel(totalAmountKey),
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "${currencySymbol}${totalAdvancePaidAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const Divider(),
            Text(
              Utils.getTranslatedLabel(advanceAmountBreakdownKey),
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            ...advanceFees
                .map((advanceFee) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${Utils.getTranslatedLabel(paidOnKey)} ${Utils.formatDate(DateTime.parse(advanceFee.createdAt!))}",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                            Text(
                              "${currencySymbol}${advanceFee.amount?.toStringAsFixed(2) ?? '0.00'}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "${Utils.getTranslatedLabel(paymentIdKey)} : ${advanceFee.id}",
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(),
                      ],
                    ))
                .toList(),
            if (advanceFees.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    Utils.getTranslatedLabel(noAdvancePaymentRecordsFoundKey),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10),
            Text(
              Utils.getTranslatedLabel(noteAdvanceAmountsKey),
              style: TextStyle(
                fontSize: 12.0,
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
