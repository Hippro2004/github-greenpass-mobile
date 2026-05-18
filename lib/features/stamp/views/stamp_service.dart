import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/auth/dtos/api_response.dart';
import 'package:greenpass/features/auth/dtos/qr_response.dart';
import 'package:greenpass/features/stamp/models/stamp.dart';

class StampService {
  Future<ApiResponse<QrResponse>> getQr() async {
    try {
      final response = await DioClient.dio.get(
        "/stamp/qr",
        options: Options(
          headers: {"username": "${Session.currentUser!.username}"},
        ),
      );
      return ApiResponse(
        message: response.data['message'],
        success: response.data['success'],
        result: QrResponse.fromJson(response.data['result']),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<Stamp>>> getMyStamps() async {
    final response = await DioClient.dio.get(
      "/stamp/my-stamps",
      options: Options(headers: {"username": Session.currentUser!.username}),
    );
    return ApiResponse(
      message: response.data['message'],
      success: response.data['success'],
      result: (response.data['result'] as List)
          .map((e) => Stamp.fromJson(e))
          .toList(),
    );
  }
}
