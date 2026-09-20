import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/report/dtos/report_response.dart';

import '../../../core/storage/session_strorage.dart';
import '../dtos/add_report_request.dart';

class ReportService {
  Future<List<ReportResponse>> getMyReport() async {
    try {
      final response = await DioClient.dio.get(
        "/report/my-reports",
        options: Options(headers: {"username": Session.currentUser!.username}),
      );

      final rawResult = response.data["result"];
      List<ReportResponse> reports = [];

      if (rawResult != null) {
        reports = (rawResult as List)
            .map((e) => ReportResponse.fromMap(e as Map<String, dynamic>))
            .toList();
      }

      return reports;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> addReport(AddReportRequest addReportRequest, int parkId) async {
    await DioClient.dio.post(
      "/report/add-report",
      data: addReportRequest.toJson(),
      options: Options(headers: {"username": Session.currentUser!.username}),
    );
  }
}
