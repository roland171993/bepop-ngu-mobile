import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/data/models/transportDashboard.dart' as models;
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/ui/screens/parentTransportEnroll/transportHome/transportRequestDetailsScreen.dart';

class TransportRequest extends StatelessWidget {
  final models.TransportRequest? requestData;

  const TransportRequest({super.key, this.requestData});

  /// Get status display properties based on request status
  Map<String, dynamic> _getStatusProperties(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return {
          'text': acceptedKey,
          'backgroundColor': const Color(0xFFE7F6ED),
          'textColor': const Color(0xFF2E7D32),
        };
      case 'rejected':
        return {
          'text': rejectedKey,
          'backgroundColor': const Color(0xFFF9D2D2),
          'textColor': const Color(0xFFB71C1C),
        };
      case 'pending':
      default:
        return {
          'text': pendingKey,
          'backgroundColor': const Color(0xFFFEEED7),
          'textColor': const Color(0xFF9E6C2C),
        };
    }
  }

  /// Get appropriate title based on request type
  String _getRequestTitle(models.TransportRequest? request) {
    if (request?.details?.pickupStop != null) {
      return changeRouteKey;
    }
    return newTransportationPlanKey;
  }

  /// Get footer note based on status
  String _getFooterNote(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return 'Your request has been approved. The changes will be reflected in your transport plan shortly.';
      case 'rejected':
        return 'Your request was rejected. Please contact the transport department for alternate arrangements or refund.';
      case 'pending':
      default:
        return 'Approval usually takes 1–2 working days. If urgent, please contact your school transport in-charge.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no request data, show a message
    if (requestData == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey: transportationRequestKey,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: CustomTextContainer(
              textKey: noDataFoundKey,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      );
    }

    // Get status properties for the request
    final statusProps = _getStatusProperties(requestData!.status);
    final title = _getRequestTitle(requestData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: 'Transportation Request',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Get.toNamed(
              Routes.transportRequestDetailsScreen,
              arguments: RequestDetailsArgs(
                title: title,
                requestedOn: requestData!.requestedOn ?? 'Unknown Date',
                statusText: statusProps['text'],
                statusBg: statusProps['backgroundColor'],
                statusFg: statusProps['textColor'],
                sections: buildDynamicSections(requestData!),
                footerNote: _getFooterNote(requestData!.status),
                showNewRequest:
                    requestData!.status?.toLowerCase() == 'rejected',
                transportRequest: requestData,
              ),
            );
          },
          child: RequestCard(
            title: title,
            statusBg: statusProps['backgroundColor'],
            statusText: statusProps['text'],
            requestedOn: requestData!.requestedOn,
            pickupStopName: requestData!.details?.pickupStop?.name,
            planDuration: requestData!.details?.plan?.duration,
            planType: requestData!.requestType,
            planValidity: requestData!.details?.plan?.validity,
          ),
        ),
      ],
    );
  }
}
