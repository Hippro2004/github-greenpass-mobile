import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/report/dtos/report_response.dart';
import 'package:greenpass/features/report/dtos/repory_type_request.dart';

import '../../../core/storage/session_strorage.dart';
import '../dtos/add_report_request.dart';
import '../../../dtos/api_response.dart';

class ReportService {
  Future<ApiResponse<List<ReportResponse>>> getMyReport() async {
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

      return ApiResponse(
        success: response.data["success"],
        message: response.data["message"],
        result: reports,
        // result: (response.data["result"] as List)
        //     .map((e) => ReportResponse.fromJson(e))
        //     .toList(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse(success: true, message: "No reports", result: []);
      }
      rethrow;
    }
  }

  Future<ApiResponse<void>> addReport(
    AddReportRequest addReportRequest,
    int parkId,
  ) async {
    final response = await DioClient.dio.post(
      "/report/add-report",
      data: addReportRequest.toJson(),
      options: Options(headers: {"username": Session.currentUser!.username}),
    );
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
    );
  }

  Future<ApiResponse<List<ReporyTypeRequest>>> getAllReportType() async {
    try {
      final response = await DioClient.dio.get("/report-type/all");

      final rawResult = response.data["result"] as List? ?? [];
      final reportTypes = rawResult
          .map(
            (e) =>
                ReporyTypeRequest.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      return ApiResponse(
        success: response.data["success"],
        message: response.data["message"],
        result: reportTypes,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse(success: true, message: "No reports", result: []);
      }
      rethrow;
    }
  }
}
