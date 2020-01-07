import 'package:bepop_ngu/data/models/studentDiaryDetails.dart';

class StudentDiaryResponse {
  final int currentPage;
  final List<StudentDiaryDetails> students;
  final String firstPageUrl;
  final int? from;
  final int lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  StudentDiaryResponse({
    required this.currentPage,
    required this.students,
    required this.firstPageUrl,
    this.from,
    required this.lastPage,
    required this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  StudentDiaryResponse.fromJson(Map<String, dynamic> json)
      : currentPage = json['current_page'] as int? ?? 0,
        students = ((json['data'] ?? []) as List)
            .map((student) =>
                StudentDiaryDetails.fromJson(Map.from(student ?? {})))
            .toList(),
        firstPageUrl = json['first_page_url'] as String? ?? '',
        from = json['from'] as int?,
        lastPage = json['last_page'] as int? ?? 0,
        lastPageUrl = json['last_page_url'] as String? ?? '',
        nextPageUrl = json['next_page_url'] as String?,
        path = json['path'] as String? ?? '',
        perPage = json['per_page'] as int? ?? 0,
        prevPageUrl = json['prev_page_url'] as String?,
        to = json['to'] as int?,
        total = json['total'] as int? ?? 0;

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': students.map((student) => student.toJson()).toList(),
        'first_page_url': firstPageUrl,
        'from': from,
        'last_page': lastPage,
        'last_page_url': lastPageUrl,
        'next_page_url': nextPageUrl,
        'path': path,
        'per_page': perPage,
        'prev_page_url': prevPageUrl,
        'to': to,
        'total': total,
      };
}
