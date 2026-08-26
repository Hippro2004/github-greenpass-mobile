import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/dtos/api_response.dart';
import 'package:greenpass/features/stamp/dtos/qr_response.dart';
import 'package:greenpass/features/stamp/dtos/stamp_response.dart';
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

  Future<ApiResponse<List<StampResponse>>> getMyStamps() async {
    final response = await DioClient.dio.get(
      "/stamp/my-stamps",
      options: Options(headers: {"username": Session.currentUser!.username}),
    );

    List<StampResponse> stamps = (response.data['result'] as List)
        .map((e) => StampResponse.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ApiResponse(
      message: response.data['message'],
      success: response.data['success'],

      result: stamps,
    );
  }

  Future<ApiResponse<List<Stamp>>> getStampDetails(int id) async {
    try {
      final response = await DioClient.dio.get(
        "/stamp/stamp-details",
        queryParameters: {"parkId": id},
        options: Options(headers: {"username": Session.currentUser!.username}),
      );

      List<Stamp> stamp = (response.data["result"] as List)
          .map((e) => Stamp.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      return ApiResponse(
        success: response.data["success"],
        message: response.data["message"],
        result: stamp,
      );
    } catch (e) {
      rethrow;
    }
  }
}
