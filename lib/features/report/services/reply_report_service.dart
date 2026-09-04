import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/dtos/api_response.dart';
import 'package:greenpass/features/report/dtos/reply_report_response.dart';

class ReplyReportService {
  Future<ApiResponse<List<ReplyReportResponse>>> getReplyReport(
    int reportId,
  ) async {
    try {
      final response = await DioClient.dio.get(
        "/reply-report/my-reply-report",
        queryParameters: {"reportId": reportId},
      );

      final rawResult = response.data["result"];
      List<ReplyReportResponse> replyReports = [];

      if (rawResult != null) {
        replyReports = (rawResult as List)
            .map(
              (e) => ReplyReportResponse.fromMap(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }

      return ApiResponse(
        success: response.data["success"],
        message: response.data["message"],
        result: replyReports,
      );
    } catch (e) {
      rethrow;
    }
  }
}
