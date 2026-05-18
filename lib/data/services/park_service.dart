import '../../core/network/dio_client.dart';
import '../models/park.dart';

class ParkService {
  Future<List<Park>> searchParks(String keyword) async {
    try {
      final response = await DioClient.dio.get(
        "/park/search",
        queryParameters: {"keyword": keyword},
      );
      return (response.data['result'] as List)
          .map((e) => Park.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
