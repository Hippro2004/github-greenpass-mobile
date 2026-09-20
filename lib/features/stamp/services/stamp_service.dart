import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/stamp/dtos/qr_response.dart';
import 'package:greenpass/features/stamp/dtos/stamp_response.dart';

class StampService {
  Future<QrResponse> getQr() async {
    try {
      final response = await DioClient.dio.get(
        "/stamp/qr",
        options: Options(
          headers: {"username": "${Session.currentUser!.username}"},
        ),
      );
      return QrResponse.fromJson(response.data['result']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StampResponse>> getMyStamps() async {
    try {
      final response = await DioClient.dio.get(
        "/stamp/my-stamps",
        options: Options(headers: {"username": Session.currentUser!.username}),
      );

      List<StampResponse> stamps = (response.data['result'] as List)
          .map((stamp) => StampResponse.fromMap(stamp as Map<String, dynamic>))
          .toList();

      return stamps;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StampResponse>> getStampDetails(int id) async {
    try {
      final response = await DioClient.dio.get(
        "/stamp/stamp-details",
        queryParameters: {"parkId": id},
        options: Options(headers: {"username": Session.currentUser!.username}),
      );

      final stamps = (response.data["result"] as List)
          .map(
            (e) => StampResponse.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      return stamps;
    } catch (e) {
      rethrow;
    }
  }
}
