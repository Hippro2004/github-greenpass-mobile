import 'dart:convert';

class AddReportRequest {
  String name;
  String description;
  int parkId;
  String? image;

  AddReportRequest({
    required this.name,
    required this.description,
    required this.parkId,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'parkId': parkId,
      'image': image,
    };
  }

  factory AddReportRequest.fromMap(Map<String, dynamic> map) {
    return AddReportRequest(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      parkId: map['parkId']?.toInt() ?? 0,
      image: map['image'],
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory AddReportRequest.fromJson(String source) =>
      AddReportRequest.fromMap(json.decode(source));
}
