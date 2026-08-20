import 'dart:convert';

class ReportResponse {
  final String name;
  final String description;
  final String status;
  final String reportDate;
  final int parkId;
  final String parkName;
  ReportResponse({
    required this.name,
    required this.description,
    required this.status,
    required this.reportDate,
    required this.parkId,
    required this.parkName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'reportDate': reportDate,
      'parkId': parkId,
      'parkName': parkName,
    };
  }

  factory ReportResponse.fromMap(Map<String, dynamic> map) {
    return ReportResponse(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? '',
      reportDate: map['reportDate'] ?? '',
      parkId: map['parkId']?.toInt() ?? 0,
      parkName: map['parkName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportResponse.fromJson(String source) =>
      ReportResponse.fromMap(json.decode(source));
}
