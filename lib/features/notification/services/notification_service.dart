import 'package:dio/dio.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';
import 'package:greenpass/features/notification/services/notification_read_store.dart';
import 'package:greenpass/features/report/dtos/reply_report_response.dart';
import 'package:greenpass/features/report/dtos/report_response.dart';
import 'package:greenpass/features/report/services/reply_report_service.dart';
import 'package:greenpass/features/report/services/report_service.dart';

class NotificationService {
  final ReplyReportService _replyReportService = ReplyReportService();
  final ReportService _reportService = ReportService();

  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final username = Session.currentUser?.username;
      if (username == null || username.isEmpty) {
        throw StateError('User session not found');
      }

      // ดึงประวัติ reply report ของ user นั้นๆ มาแสดงเป็นการแจ้งเตือน
      final List<ReplyReportResponse> replies =
          await _replyReportService.getMyReplyReports();

      // ดึง reports ของ user เพื่อนำมาจับคู่ข้อมูลอุทยานและรายละเอียด report ให้สมบูรณ์
      final Map<int, ReportResponse> reportMap = {};
      try {
        final reports = await _reportService.getMyReport();
        for (final r in reports) {
          reportMap[r.reportId] = r;
        }
      } catch (_) {}

      // ดึงรายการที่อ่านแล้วจาก local storage
      final readIds = await NotificationReadStore.getReadIds(username);

      final List<NotificationModel> notifications = replies.map((reply) {
        final isRead = reply.replyReportId != null &&
            readIds.contains(reply.replyReportId.toString());
        final matchedReport =
            reply.reportId != null ? reportMap[reply.reportId] : null;

        return NotificationModel.fromReplyReport(
          reply,
          report: matchedReport,
          isRead: isRead,
        );
      }).toList();

      return notifications;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final username = Session.currentUser?.username;
    if (username != null && username.isNotEmpty) {
      await NotificationReadStore.markAsRead(username, notificationId);
    }
  }

  Future<void> markAllAsRead(Iterable<int> notificationIds) async {
    final username = Session.currentUser?.username;
    if (username != null && username.isNotEmpty) {
      await NotificationReadStore.markAllAsRead(username, notificationIds);
    }
  }
}
