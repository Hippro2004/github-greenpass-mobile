import 'dart:convert';

class ReplyReportResponse {
  final String updateDate;
  final String updateTime;
  final String progress;
  final String currentStatus;
  final String image;
  final String? parkRangerName;

  ReplyReportResponse({
    required this.updateDate,
    required this.updateTime,
    required this.progress,
    required this.currentStatus,
    required this.image,
    required this.parkRangerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'updateDate': updateDate,
      'updateTime': updateTime,
      'progress': progress,
      'currentStatus': currentStatus,
      'image': image,
      'parkRangerName': parkRangerName,
    };
  }

  factory ReplyReportResponse.fromMap(Map<String, dynamic> map) {
    return ReplyReportResponse(
      updateDate: map['updateDate'] ?? '',
      updateTime: map['updateTime'] ?? '',
      progress: map['progress'] ?? '',
      currentStatus: map['currentStatus'] ?? '',
      image: map['image'] ?? '',
      parkRangerName: map['parkRangerName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ReplyReportResponse.fromJson(String source) =>
      ReplyReportResponse.fromMap(json.decode(source));
}
