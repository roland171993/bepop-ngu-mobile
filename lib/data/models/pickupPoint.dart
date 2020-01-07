class PickupPoint {
  final int? id;
  final String? name;
  final String? latitude;
  final String? longitude;

  const PickupPoint({this.id, this.name, this.latitude, this.longitude});

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'] as int?,
      name: json['name'] as String?,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() => name ?? '';
}
