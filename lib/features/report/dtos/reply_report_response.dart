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
  });

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
    );
  }

  String toJson() => json.encode(toMap());

  factory ReplyReportResponse.fromJson(String source) =>
      ReplyReportResponse.fromMap(json.decode(source));
}
