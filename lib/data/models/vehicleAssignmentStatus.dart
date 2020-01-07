class VehicleAssignmentStatus {
  final bool isAssigned;
  final String message;
  final String? data;

  VehicleAssignmentStatus({
    required this.isAssigned,
    required this.message,
    this.data,
  });

  factory VehicleAssignmentStatus.fromJson(Map<String, dynamic> json) {
    return VehicleAssignmentStatus(
      isAssigned: json['data'] == 'assigned',
      message: json['message'] ?? '',
      data: json['data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'isAssigned': isAssigned, 'message': message, 'data': data};
  }

  // Helper method to determine routing logic
  bool get shouldShowTransportHome => isAssigned;
  bool get shouldShowEnrollmentFlow => !isAssigned;

  // Check specific statuses
  bool get isExpired =>
      data?.toLowerCase() == 'expired'; // API returns "expired" not "expire"
  bool get isPending => data?.toLowerCase() == 'pending';
  bool get isStatusAssigned => data?.toLowerCase() == 'assigned';
}
