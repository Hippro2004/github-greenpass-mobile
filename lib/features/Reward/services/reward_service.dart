import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/reward/dtos/reward_response.dart';

class RewardService {
  Future<List<RewardResponse>> getAllRewards() async {
    try {
      final response = await DioClient.dio.get("/reward/reward-all");

      if (response.statusCode == 204 || response.data == null) {
        return [];
      }

      final data = response.data;
      if (data is! Map) {
        throw const FormatException("รูปแบบข้อมูลของรางวัลไม่ถูกต้อง");
      }

      final rawResult = data["result"];
      List<RewardResponse> rewards = [];

      if (rawResult is List) {
        rewards = rawResult
            .whereType<Map>()
            .map((e) => RewardResponse.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }

      return rewards;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<RewardResponse> getRewardDetails(int rewardId) async {
    try {
      final response = await DioClient.dio.get("/reward/$rewardId");

      final data = response.data;
      if (data is! Map) {
        throw const FormatException("รูปแบบข้อมูลของรางวัลไม่ถูกต้อง");
      }

      final rawResult = data["result"];
      if (rawResult is! Map) {
        throw const FormatException("ไม่พบข้อมูลของรางวัล");
      }
      return RewardResponse.fromMap(Map<String, dynamic>.from(rawResult));
    } catch (e) {
      rethrow;
    }
  }
}
