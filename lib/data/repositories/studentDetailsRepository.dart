import 'package:bepop_ngu/data/models/studentDetailsResponse.dart';
import 'package:bepop_ngu/utils/api.dart';

class StudentDetailsRepository {
  Future<StudentDetailsResponse> getStudentDetails(
      {required int studentId}) async {
    try {
      final result = await Api.get(
        url: Api.getStudentDetails,
        useAuthToken: true,
        queryParameters: {
          'student_id': studentId,
        },
      );

      return StudentDetailsResponse.fromJson(Map.from(result['data'] ?? {}));
    } catch (e, st) {
      print("this is the error $e");
      print("this is the stack trace $st");
      throw ApiException(e.toString());
    }
  }
}
