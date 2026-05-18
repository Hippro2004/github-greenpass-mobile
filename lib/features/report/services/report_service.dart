import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';

import '../../../core/storage/session_strorage.dart';
import '../../auth/dtos/add_report_request.dart';
import '../../auth/dtos/api_response.dart';
import '../models/report.dart';

class ReportService {
  Future<ApiResponse<List<Report>>> getMyReport() async {
    final response = await DioClient.dio.get(
      "/report/my-reports",
      options: Options(headers: {"username": Session.currentUser!.username}),
    );
    return ApiResponse(
      success: response.data["success"],
      message: response.data["message"],
      result: (response.data["result"] as List)
          .map((e) => Report.fromJson(e))
          .toList(),
    );
  }

  Future<ApiResponse<void>> addReport(AddReportRequest addReportRequest) async {
    final response = await DioClient.dio.get(
      "/report/add-report",
      data: addReportRequest.toJson(),
    );
    return ApiResponse(
      success: response.data['success'],
      message: response.data['message'],
    );
  }
}
