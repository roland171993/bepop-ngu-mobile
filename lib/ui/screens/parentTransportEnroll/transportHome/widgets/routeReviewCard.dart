import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:flutter/material.dart';

class RouteReviewCard extends StatelessWidget {
  final String currentRouteName;
  final String currentPickup;
  final String requestedRouteName;
  final String requestedPickup;
  final String currentFee;
  final String requestedFee;
  final String? noteText;

  const RouteReviewCard({
    super.key,
    required this.currentRouteName,
    required this.currentPickup,
    required this.requestedRouteName,
    required this.requestedPickup,
    required this.currentFee,
    required this.requestedFee,
    this.noteText,
  });

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CustomTextContainer(
        textKey: title,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _routeRow(
      BuildContext context, String label, String value, String fee) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextContainer(
            textKey: '$label : $value',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomTextContainer(
          textKey: '$fee',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Current Route'),
          _routeRow(context, 'Route', currentRouteName, currentFee),
          const SizedBox(height: 6),
          CustomTextContainer(
            textKey: 'Pick/Drop Point : $currentPickup',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(height: 12),
          _sectionHeader(context, 'Requested Route'),
          _routeRow(context, 'Route', requestedRouteName, requestedFee),
          const SizedBox(height: 6),
          CustomTextContainer(
            textKey: 'Pick/Drop Point : $requestedPickup',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if ((noteText ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            CustomTextContainer(
              textKey: noteText!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
