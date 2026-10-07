import '../../../core/network/dio_client.dart';
import '../models/park.dart';

class ParkService {
  Future<List<Park>> searchParks(String keyword) async {
    try {
      final response = await DioClient.dio.get(
        "/park/search",
        queryParameters: {"keyword": keyword},
      );
      final rawResult = response.data['result'];
      if (rawResult is List) {
        return rawResult
            .whereType<Map>()
            .map((e) => Park.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
