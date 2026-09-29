import 'dart:convert';
import 'package:greenpass/features/report/dtos/reply_report_response.dart';
import 'package:greenpass/features/report/dtos/report_response.dart';

class NotificationModel {
  final int notificationId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final int? reportId;
  final ReportResponse? report;
  final String? currentStatus;
  final String? progress;
  final String? image;
  final String? parkRangerName;
  final String? parkRangerUsername;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.reportId,
    this.report,
    this.currentStatus,
    this.progress,
    this.image,
    this.parkRangerName,
    this.parkRangerUsername,
  });

  NotificationModel copyWith({
    int? notificationId,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    int? reportId,
    ReportResponse? report,
    String? currentStatus,
    String? progress,
    String? image,
    String? parkRangerName,
    String? parkRangerUsername,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      reportId: reportId ?? this.reportId,
      report: report ?? this.report,
      currentStatus: currentStatus ?? this.currentStatus,
      progress: progress ?? this.progress,
      image: image ?? this.image,
      parkRangerName: parkRangerName ?? this.parkRangerName,
      parkRangerUsername: parkRangerUsername ?? this.parkRangerUsername,
    );
  }

  factory NotificationModel.fromReplyReport(
    ReplyReportResponse reply, {
    ReportResponse? report,
    bool isRead = false,
  }) {
    DateTime? parsedDate;
    if (reply.updateDate.isNotEmpty) {
      final timeStr =
          reply.updateTime.isNotEmpty ? reply.updateTime : '00:00:00';
      parsedDate = DateTime.tryParse('${reply.updateDate}T$timeStr') ??
          DateTime.tryParse('${reply.updateDate} $timeStr');
    }
    parsedDate ??= DateTime.now();

    String title = '';
    final status = reply.currentStatus.trim();
    switch (status) {
      case 'Pending':
        title = 'แจ้งรายงานปัญหา';
        break;
      case 'InProgress':
        title = 'กำลังดำเนินการแก้ไข';
        break;
      case 'Completed':
        title = 'ดำเนินการแก้ไขสำเร็จ';
        break;
      default:
        title = status.isNotEmpty ? status : 'อัปเดตรายงาน';
    }

    String message = reply.progress.trim();
    if (message.isEmpty) {
      if (status.isNotEmpty) {
        message = 'รายงานได้รับการเปลี่ยนสถานะเป็น $title';
      } else {
        message = 'มีความคืบหน้าใหม่ในรายงานของคุณ';
      }
    }

    final id = reply.replyReportId ??
        (reply.reportId != null ? (reply.reportId! * 1000) : 0);

    return NotificationModel(
      notificationId: id,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: parsedDate,
      reportId: reply.reportId,
      report: report,
      currentStatus: reply.currentStatus,
      progress: reply.progress,
      image: reply.image,
      parkRangerName: reply.parkRangerName,
      parkRangerUsername: reply.parkRangerUsername,
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
    } else if (map['updateDate'] != null) {
      final uDate = map['updateDate'].toString().trim();
      final uTime = (map['updateTime'] ?? '').toString().trim();
      if (uDate.isNotEmpty) {
        try {
          final timeStr = uTime.isNotEmpty ? uTime : '00:00:00';
          parsedDate = DateTime.tryParse('${uDate}T$timeStr') ??
              DateTime.tryParse('$uDate $timeStr');
        } catch (_) {}
      }
    }
    parsedDate ??= DateTime.now();

    final currentStatus = map['currentStatus']?.toString();
    final progress = map['progress']?.toString();
    final parkRangerName = map['parkRangerName']?.toString();
    final parkRangerUsername = map['parkRangerUsername']?.toString();
    final image = map['image']?.toString();

    // Determine Title
    String title = (map['title'] ?? '').toString().trim();
    if (title.isEmpty) {
      if (currentStatus != null && currentStatus.isNotEmpty) {
        switch (currentStatus.trim()) {
          case 'Pending':
            title = 'แจ้งรายงานปัญหา';
            break;
          case 'InProgress':
            title = 'กำลังดำเนินการแก้ไข';
            break;
          case 'Completed':
            title = 'ดำเนินการแก้ไขสำเร็จ';
            break;
          default:
            title = currentStatus;
        }
      } else {
        title = 'อัปเดตรายงาน';
      }
    }

    // Determine Message
    String message = (map['message'] ?? '').toString().trim();
    if (message.isEmpty) {
      if (progress != null && progress.trim().isNotEmpty) {
        message = progress.trim();
      } else if (currentStatus != null && currentStatus.isNotEmpty) {
        message = 'รายงานได้รับการเปลี่ยนสถานะเป็น $title';
      } else {
        message = 'มีความคืบหน้าใหม่ในรายงานของคุณ';
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

    final id = (map['notificationId'] as num?)?.toInt() ??
        (map['replyReportId'] as num?)?.toInt() ??
        (map['id'] as num?)?.toInt() ??
        (parsedReportId != null
            ? (parsedReportId * 1000)
            : (parsedDate.millisecondsSinceEpoch % 1000000000));

    return NotificationModel(
      notificationId: id,
      title: title,
      message: message,
      isRead: (map['isRead'] ?? map['read'] ?? false) as bool,
      createdAt: parsedDate,
      reportId: parsedReportId,
      report: parsedReport,
      currentStatus: currentStatus,
      progress: progress,
      image: image,
      parkRangerName: parkRangerName,
      parkRangerUsername: parkRangerUsername,
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
      'currentStatus': currentStatus,
      'progress': progress,
      'image': image,
      'parkRangerName': parkRangerName,
      'parkRangerUsername': parkRangerUsername,
    };
  }

  String toJson() => json.encode(toMap());
}
