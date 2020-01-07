class TransportFeePlan {
  final int? id; // Fee plan ID for API calls
  final String? duration; // days: e.g., "30", "90", "365"
  final String? feeAmount; // e.g., "12000.00"
  final String? formattedFeeAmount;

  const TransportFeePlan(
      {this.id, this.duration, this.feeAmount, this.formattedFeeAmount});

  factory TransportFeePlan.fromJson(Map<String, dynamic> json) {
    return TransportFeePlan(
      id: json['id'] as int?,
      duration: json['duration']?.toString(),
      feeAmount: json['fee_amount']?.toString(),
      formattedFeeAmount: json['formatted_fee_amount']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'duration': duration,
        'fee_amount': feeAmount,
        'formatted_fee_amount': formattedFeeAmount,
      };

  String get displayLabel {
    final intDuration = int.tryParse(duration ?? '');
    String period;
    if (intDuration == 30) {
      period = 'Monthly';
    } else if (intDuration == 90) {
      period = 'Quarterly';
    } else if (intDuration == 365) {
      period = 'Yearly';
    } else if (intDuration != null) {
      period = '$intDuration days';
    } else {
      period = (duration ?? '').isEmpty ? 'Duration' : duration!;
    }
    final amountText =
        (formattedFeeAmount ?? '').isEmpty ? '' : formattedFeeAmount!;
    return amountText.isEmpty ? period : '$period : $amountText';
  }

  @override
  String toString() => displayLabel;
}

class TransportFeesResponse {
  final List<TransportFeePlan> fees;
  final bool takePayments;

  const TransportFeesResponse({required this.fees, required this.takePayments});

  factory TransportFeesResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    final feesList = (data['fees'] as List?)
            ?.map((e) =>
                TransportFeePlan.fromJson(Map<String, dynamic>.from(e ?? {})))
            .toList() ??
        <TransportFeePlan>[];
    final takePayments = (data['take_payments'] is Map &&
        (data['take_payments']['status'] == true));
    return TransportFeesResponse(fees: feesList, takePayments: takePayments);
  }
}
