import 'dart:convert';

class Report {
  final String id;
  final String name;
  final String reportDate;
  final String description;
  final String image;
  final String status;

  Report(
    this.id,
    this.name,
    this.reportDate,
    this.description,
    this.image,
    this.status,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reportDate': reportDate,
      'description': description,
      'image': image,
      'status': status,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      map['id'] ?? '',
      map['name'] ?? '',
      map['reportDate'] ?? '',
      map['description'] ?? '',
      map['image'] ?? '',
      map['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Report.fromJson(String source) => Report.fromMap(json.decode(source));
}
