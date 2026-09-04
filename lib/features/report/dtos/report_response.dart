import 'dart:convert';

class ReportResponse {
  final int reportId;
  final String name;
  final String description;
  final String status;
  final String reportDate;
  final String reportTime;
  final int parkId;
  final String parkName;

  ReportResponse({
    required this.reportId,
    required this.name,
    required this.description,
    required this.status,
    required this.reportDate,
    required this.reportTime,
    required this.parkId,
    required this.parkName,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'name': name,
      'description': description,
      'status': status,
      'reportDate': reportDate,
      'reportTime': reportTime,
      'parkId': parkId,
      'parkName': parkName,
    };
  }

  factory ReportResponse.fromMap(Map<String, dynamic> map) {
    return ReportResponse(
      reportId: (map['reportId'] ?? map['id'])?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? '',
      reportDate: map['reportDate'] ?? '',
      reportTime: map['reportTime'] ?? map['reporttime'] ?? '',
      parkId: map['parkId']?.toInt() ?? 0,
      parkName: map['parkName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportResponse.fromJson(String source) =>
      ReportResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ReportResponse(reportId: $reportId, name: $name, description: $description, status: $status, reportDate: $reportDate, reportTime: $reportTime, parkId: $parkId, parkName: $parkName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReportResponse &&
        other.reportId == reportId &&
        other.name == name &&
        other.description == description &&
        other.status == status &&
        other.reportDate == reportDate &&
        other.reportTime == reportTime &&
        other.parkId == parkId &&
        other.parkName == parkName;
  }

  @override
  int get hashCode {
    return reportId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        status.hashCode ^
        reportDate.hashCode ^
        reportTime.hashCode ^
        parkId.hashCode ^
        parkName.hashCode;
  }
}
