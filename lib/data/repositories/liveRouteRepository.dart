import 'package:bepop_ngu/data/models/liveRoute.dart';
import 'package:bepop_ngu/utils/api.dart';

class LiveRouteRepository {
  Future<LiveRouteResponse> getLiveRoute({required int userId}) async {
    try {
      final result = await Api.post(
        url: Api.getLiveRoute,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );
      return LiveRouteResponse.fromJson(result);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
