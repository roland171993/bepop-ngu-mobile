import 'package:intl/intl.dart';

class Holiday {
  Holiday({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  late final int id;
  late final DateTime date;
  late final String title;
  late final String description;
  late final String createdAt;
  late final String updatedAt;

  Holiday.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    // Prefer 'default_date_format' (dd-MM-yyyy). Fallback to 'date' or ISO.
    final rawDateString =
        (json['default_date_format'] ?? json['date'] ?? "").toString().trim();

    DateTime parsedDate;
    if (rawDateString.isEmpty) {
      parsedDate = DateTime.now();
    } else {
      // Try strict dd-MM-yyyy first.
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parseStrict(rawDateString);
      } catch (_) {
        // Fallback to Dart's DateTime.parse for ISO or other supported formats.
        try {
          parsedDate = DateTime.parse(rawDateString);
        } catch (_) {
          parsedDate = DateTime.now();
        }
      }
    }

    date = parsedDate;
    title = json['title'] ?? "";
    description = json['description'] ?? "";
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
  }
}
