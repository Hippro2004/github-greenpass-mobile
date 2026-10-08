import 'dart:convert';

class ReplyReportResponse {
  final int? replyReportId;
  final int? reportId;
  final String updateDate;
  final String updateTime;
  final String progress;
  final String currentStatus;
  final String image;
  final String? parkRangerName;
  final String? parkRangerUsername;
  final String reportType;

  ReplyReportResponse({
    this.replyReportId,
    this.reportId,
    required this.updateDate,
    required this.updateTime,
    required this.progress,
    required this.currentStatus,
    required this.image,
    required this.parkRangerName,
    this.parkRangerUsername,
    required this.reportType,
  });

  String get reporyType => reportType;

  Map<String, dynamic> toMap() {
    return {
      'replyReportId': replyReportId,
      'reportId': reportId,
      'updateDate': updateDate,
      'updateTime': updateTime,
      'progress': progress,
      'currentStatus': currentStatus,
      'image': image,
      'parkRangerName': parkRangerName,
      'parkRangerUsername': parkRangerUsername,
      'reportType': reportType,
    };
  }

  factory ReplyReportResponse.fromMap(Map<String, dynamic> map) {
    return ReplyReportResponse(
      replyReportId: (map['replyReportId'] as num?)?.toInt(),
      reportId: (map['reportId'] as num?)?.toInt(),
      updateDate: (map['updateDate'] ?? '').toString(),
      updateTime: (map['updateTime'] ?? '').toString(),
      progress: (map['progress'] ?? '').toString(),
      currentStatus: (map['currentStatus'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
      parkRangerName: map['parkRangerName']?.toString() ?? '',
      parkRangerUsername: map['parkRangerUsername']?.toString(),
      reportType: (map['reportType'] ?? map['reporyType'] ?? '').toString(),
    );
  }

  ReplyReportResponse copyWith({
    int? replyReportId,
    int? reportId,
    String? updateDate,
    String? updateTime,
    String? progress,
    String? currentStatus,
    String? image,
    String? parkRangerName,
    String? parkRangerUsername,
    String? reportType,
  }) {
    return ReplyReportResponse(
      replyReportId: replyReportId ?? this.replyReportId,
      reportId: reportId ?? this.reportId,
      updateDate: updateDate ?? this.updateDate,
      updateTime: updateTime ?? this.updateTime,
      progress: progress ?? this.progress,
      currentStatus: currentStatus ?? this.currentStatus,
      image: image ?? this.image,
      parkRangerName: parkRangerName ?? this.parkRangerName,
      parkRangerUsername: parkRangerUsername ?? this.parkRangerUsername,
      reportType: reportType ?? this.reportType,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReplyReportResponse.fromJson(String source) =>
      ReplyReportResponse.fromMap(json.decode(source));
}
