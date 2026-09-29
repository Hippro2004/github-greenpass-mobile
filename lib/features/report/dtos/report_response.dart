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
  final String? typeName;
  final String? image;

  ReportResponse({
    required this.reportId,
    required this.name,
    required this.description,
    required this.status,
    required this.reportDate,
    required this.reportTime,
    required this.parkId,
    required this.parkName,
    this.typeName,
    this.image,
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
      'typeName': typeName,
      'image': image,
    };
  }

  factory ReportResponse.fromMap(Map<String, dynamic> map) {
    int parsedParkId = 0;
    if (map['parkId'] != null) {
      parsedParkId = (map['parkId'] as num).toInt();
    } else if (map['park'] != null && map['park'] is Map) {
      parsedParkId = (map['park']['parkId'] as num?)?.toInt() ?? 0;
    }

    String parsedParkName = '';
    if (map['parkName'] != null) {
      parsedParkName = map['parkName'].toString();
    } else if (map['park'] != null && map['park'] is Map) {
      parsedParkName = (map['park']['name'] ?? '').toString();
    }

    String? parsedTypeName;
    if (map['typeName'] != null) {
      parsedTypeName = map['typeName'].toString();
    } else if (map['type'] != null && map['type'] is Map) {
      parsedTypeName = (map['type']['typeName'] ?? map['type']['name'])?.toString();
    } else if (map['reportType'] != null) {
      parsedTypeName = map['reportType'].toString();
    }

    return ReportResponse(
      reportId: (map['reportId'] ?? map['id'])?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? '',
      reportDate: map['reportDate']?.toString() ?? '',
      reportTime: (map['reportTime'] ?? map['reporttime'])?.toString() ?? '',
      parkId: parsedParkId,
      parkName: parsedParkName,
      typeName: parsedTypeName,
      image: map['image'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportResponse.fromJson(String source) =>
      ReportResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ReportResponse(reportId: $reportId, name: $name, description: $description, status: $status, reportDate: $reportDate, reportTime: $reportTime, parkId: $parkId, parkName: $parkName, typeName: $typeName)';
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
        other.parkName == parkName &&
        other.typeName == typeName;
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
        parkName.hashCode ^
        typeName.hashCode;
  }
}
