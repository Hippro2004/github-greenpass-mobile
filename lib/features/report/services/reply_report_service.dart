import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/report/dtos/reply_report_response.dart';

class ReplyReportService {
  Future<List<ReplyReportResponse>> getReplyReport(int reportId) async {
    try {
      final response = await DioClient.dio.get(
        "/reply-report/my-reply-report",
        queryParameters: {"reportId": reportId},
      );

      final rawResult = response.data["result"];
      List<ReplyReportResponse> replyReports = [];

      if (rawResult != null && rawResult is List) {
        replyReports = rawResult
            .map(
              (e) => ReplyReportResponse.fromMap(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }

      return replyReports;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReplyReportResponse>> getMyReplyReports() async {
    try {
      final username = Session.currentUser?.username;
      if (username == null || username.isEmpty) {
        throw StateError('User session not found');
      }

      final response = await DioClient.dio.get(
        "/reply-report/my-reply-reports",
        options: Options(headers: {"username": username}),
      );

      final rawResult = response.data["result"];
      List<ReplyReportResponse> replyReports = [];

      if (rawResult != null && rawResult is List) {
        replyReports = rawResult
            .map(
              (e) => ReplyReportResponse.fromMap(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }

      return replyReports;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
