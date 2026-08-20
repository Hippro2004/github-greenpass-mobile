import 'dart:convert';

class ReportResponse {
  final String name;
  final String description;
  final String status;
  final String reportDate;
  ReportResponse({
    required this.name,
    required this.description,
    required this.status,
    required this.reportDate,
  });

  ReportResponse copyWith({
    String? name,
    String? description,
    String? status,
    String? reportDate,
  }) {
    return ReportResponse(
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      reportDate: reportDate ?? this.reportDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'reportDate': reportDate,
    };
  }

  factory ReportResponse.fromMap(Map<String, dynamic> map) {
    return ReportResponse(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? '',
      reportDate: map['reportDate'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportResponse.fromJson(String source) =>
      ReportResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ReportResponse(name: $name, description: $description, status: $status, reportDate: $reportDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReportResponse &&
        other.name == name &&
        other.description == description &&
        other.status == status &&
        other.reportDate == reportDate;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        status.hashCode ^
        reportDate.hashCode;
  }
}
