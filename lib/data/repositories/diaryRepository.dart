import 'package:bepop_ngu/data/models/studentDiaryResponse.dart';
import 'package:bepop_ngu/utils/api.dart';

class DiaryRepository {
  Future<StudentDiaryResponse> getDiaries({
    int? studentId,
    int? page,
    int? classSectionId,
    int? sessionYearId,
    int? diaryCategoryId,
    int? subjectId,
    String? search,
    String? sort,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getDiaries,
        useAuthToken: true,
        queryParameters: {
          if (studentId != null) 'student_id': studentId,
          if (page != null) 'page': page,
          if (classSectionId != null) 'class_section_id': classSectionId,
          if (sessionYearId != null) 'session_year_id': sessionYearId,
          if (diaryCategoryId != null) 'diary_category_id': diaryCategoryId,
          if (subjectId != null) 'subject_id': subjectId,
          if (search != null && search.isNotEmpty) 'search': search,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
        },
      );

      return StudentDiaryResponse.fromJson(Map.from(result['data'] ?? {}));
    } catch (e, st) {
      print("This is the error: $e");
      print("This is the stack trace: $st");
      throw ApiException(e.toString());
    }
  }
}
