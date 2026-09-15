import 'dart:convert';
import 'package:greenpass/features/report/dtos/report_response.dart';

class NotificationModel {
  final int notificationId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final int? reportId;
  final ReportResponse? report;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.reportId,
    this.report,
  });

  NotificationModel copyWith({
    int? notificationId,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    int? reportId,
    ReportResponse? report,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      reportId: reportId ?? this.reportId,
      report: report ?? this.report,
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate != null) {
      if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate);
      } else if (rawDate is List && rawDate.isNotEmpty) {
        // Handle Jackson array [year, month, day, hour, minute, second]
        try {
          parsedDate = DateTime(
            rawDate[0],
            rawDate.length > 1 ? rawDate[1] : 1,
            rawDate.length > 2 ? rawDate[2] : 1,
            rawDate.length > 3 ? rawDate[3] : 0,
            rawDate.length > 4 ? rawDate[4] : 0,
            rawDate.length > 5 ? rawDate[5] : 0,
          );
        } catch (_) {}
      }
    }

    ReportResponse? parsedReport;
    int? parsedReportId;

    if (map['report'] != null && map['report'] is Map) {
      parsedReport = ReportResponse.fromMap(
        Map<String, dynamic>.from(map['report'] as Map),
      );
      parsedReportId = parsedReport.reportId;
    } else if (map['reportId'] != null) {
      parsedReportId = (map['reportId'] as num?)?.toInt();
    }

    return NotificationModel(
      notificationId: (map['notificationId'] as num?)?.toInt() ??
          (map['id'] as num?)?.toInt() ??
          0,
      title: (map['title'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      isRead: (map['isRead'] ?? map['read'] ?? false) as bool,
      createdAt: parsedDate,
      reportId: parsedReportId,
      report: parsedReport,
    );
  }

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
      'reportId': reportId,
      'report': report?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}
