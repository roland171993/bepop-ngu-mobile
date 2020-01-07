class TransportShift {
  final int? id;
  final String? name;
  final String? startTime;
  final String? endTime;

  const TransportShift({this.id, this.name, this.startTime, this.endTime});

  factory TransportShift.fromJson(Map<String, dynamic> json) {
    return TransportShift(
      id: json['id'] as int?,
      name: json['name'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
      };

  String get displayName {
    if ((startTime ?? '').isEmpty && (endTime ?? '').isEmpty) {
      return name ?? '';
    }
    return '${name ?? ''} : ${startTime ?? ''} to ${endTime ?? ''}';
  }

  @override
  String toString() => displayName;
}
