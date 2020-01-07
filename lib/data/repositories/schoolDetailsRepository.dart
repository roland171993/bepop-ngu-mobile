import 'package:bepop_ngu/data/models/schoolDetails.dart';
import 'package:bepop_ngu/utils/api.dart';

class Schooldetailsfetch {
  static Future<SchoolDetails> fetchSchoolDetails() async {
    try {
      final result = await Api.get(
        url: Api.schoolDetails,
        useAuthToken: true,
      );

      print("This is school details : ${result['data']}");

      final SchoolDetails schoolDetails =
          SchoolDetails.fromJson(result['data']);

      return schoolDetails;
    } catch (e, st) {
      print("this is School details error : ${st}");
      throw ApiException(e.toString());
    }
  }
}
