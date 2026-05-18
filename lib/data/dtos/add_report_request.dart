import 'dart:convert';

class AddReportRequest {
  String name;
  String description;
  String? image;
  String? status;

  AddReportRequest({
    required this.name,
    required this.description,
    this.image,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'status': status,
    };
  }

  factory AddReportRequest.fromMap(Map<String, dynamic> map) {
    return AddReportRequest(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'],
      status: map['status'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AddReportRequest.fromJson(String source) =>
      AddReportRequest.fromMap(json.decode(source));
}
