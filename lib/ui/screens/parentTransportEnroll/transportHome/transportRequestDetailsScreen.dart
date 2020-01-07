import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/statusTag.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:bepop_ngu/ui/widgets/customRoundedButton.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:bepop_ngu/data/models/transportDashboard.dart';
import 'package:flutter/material.dart';

class TransportRequestDetailsScreen extends StatelessWidget {
  final RequestDetailsArgs args;
  const TransportRequestDetailsScreen({super.key, required this.args});

  static Widget getRouteInstance({required RequestDetailsArgs args}) =>
      TransportRequestDetailsScreen(args: args);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(title: 'Request Details', showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: appContentHorizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextContainer(
                    textKey: args.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _labelValue(
                                  context, 'Requested on :', args.requestedOn),
                            ),
                            StatusTag(
                              text: args.statusText,
                              bg: args.statusBg,
                              fg: args.statusFg,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (args.sections.isNotEmpty)
                          ...args.sections.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _section(context, s.label, s.value),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (args.footerNote != null) ...[
              CustomTextContainer(
                textKey: args.footerNote!,
                style: TextStyle(
                  fontSize: 12,
                  color: args.statusText.toLowerCase() == 'rejected'
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                if (args.showNewRequest)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      child: const CustomTextContainer(
                        textKey: 'New Request',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (args.showNewRequest) const SizedBox(width: 12),
                Expanded(
                  child: CustomRoundedButton(
                    textSize: 15,
                    onTap: () {
                      final phoneNumber =
                          args.transportRequest?.contactDetails?.schoolPhone;
                      if (phoneNumber != null && phoneNumber.isNotEmpty) {
                        Utils.launchPhoneDialer(phoneNumber);
                      }
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: 'Contact Support',
                    showBorder: false,
                    widthPercentage: 1.0,
                    height: 50,
                    radius: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelValue(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6D6E6F)),
        ),
        const SizedBox(height: 2),
        CustomTextContainer(
          textKey: value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6D6E6F)),
        ),
        const SizedBox(height: 2),
        CustomTextContainer(
          textKey: value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class RequestDetailsArgs {
  final String title;
  final String requestedOn;
  final String statusText;
  final Color statusBg;
  final Color statusFg;
  final List<_DetailItem> sections;
  final String? footerNote;
  final bool showNewRequest;
  final TransportRequest? transportRequest;

  const RequestDetailsArgs({
    required this.title,
    required this.requestedOn,
    required this.statusText,
    required this.statusBg,
    required this.statusFg,
    required this.sections,
    this.footerNote,
    this.showNewRequest = false,
    this.transportRequest,
  });
}

class _DetailItem {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);
}

List<_DetailItem> buildDynamicSections(TransportRequest request) {
  List<_DetailItem> sections = [];

  // Add requested by information
  if (request.requestedBy?.name != null) {
    sections.add(_DetailItem('Requested By', request.requestedBy!.name!));
  }

  // Add pickup stop information
  if (request.details?.pickupStop?.name != null) {
    sections.add(
        _DetailItem('Pickup Location', request.details!.pickupStop!.name!));
  }

  // Add plan information
  if (request.details?.plan?.duration != null) {
    sections
        .add(_DetailItem('Plan Duration', request.details!.plan!.duration!));
  }

  if (request.details?.plan?.validity != null) {
    sections
        .add(_DetailItem('Plan Validity', request.details!.plan!.validity!));
  }

  // Add payment mode
  if (request.mode != null) {
    sections.add(_DetailItem('Payment Mode', request.mode!.toUpperCase()));
  }

  // Add review information
  if (request.review?.respondedOn != null) {
    sections.add(_DetailItem('Responded On', request.review!.respondedOn!));
  }

  // Add contact details
  if (request.contactDetails?.schoolEmail != null) {
    sections
        .add(_DetailItem('School Email', request.contactDetails!.schoolEmail!));
  }

  if (request.contactDetails?.schoolPhone != null) {
    sections
        .add(_DetailItem('School Phone', request.contactDetails!.schoolPhone!));
  }

  return sections;
}
