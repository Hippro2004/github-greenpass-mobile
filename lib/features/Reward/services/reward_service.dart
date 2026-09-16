import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/dtos/api_response.dart';
import 'package:greenpass/features/Reward/dtos/reward_response.dart';

class RewardService {
  Future<ApiResponse<List<RewardResponse>>> getAllRewards() async {
    try {
      final response = await DioClient.dio.get("/reward/reward-all");

      if (response.statusCode == 204 || response.data == null) {
        return const ApiResponse(
          success: true,
          message: "No rewards available",
          result: [],
        );
      }

      final data = response.data;
      if (data is! Map) {
        return const ApiResponse(
          success: false,
          message: "รูปแบบข้อมูลของรางวัลไม่ถูกต้อง",
          result: [],
        );
      }

      final rawResult = data["result"];
      List<RewardResponse> rewards = [];

      if (rawResult is List) {
        rewards = rawResult
            .whereType<Map>()
            .map((e) => RewardResponse.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }

      return ApiResponse(
        success: data["success"] == true,
        message: data["message"]?.toString() ?? "Success",
        result: rewards,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const ApiResponse(
          success: true,
          message: "ไม่พบข้อมูลของรางวัล",
          result: [],
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<RewardResponse>> getRewardDetails(int rewardId) async {
    try {
      final response = await DioClient.dio.get("/reward/$rewardId");

      final data = response.data;
      if (data is! Map) {
        throw const FormatException("รูปแบบข้อมูลของรางวัลไม่ถูกต้อง");
      }

      final rawResult = data["result"];
      final reward = rawResult is Map
          ? RewardResponse.fromMap(Map<String, dynamic>.from(rawResult))
          : null;

      return ApiResponse(
        success: data["success"] == true,
        message: data["message"]?.toString() ?? "",
        result: reward,
      );
    } catch (e) {
      rethrow;
    }
  }
}
