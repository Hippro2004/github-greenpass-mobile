import 'dart:convert';

import 'package:flutter/widgets.dart';

class AddReportRequest {
  String name;
  String description;
  int parkId;
  String typeName;
  String? reportType;
  String? image;

  AddReportRequest({
    required this.name,
    required this.description,
    required this.parkId,
    required this.typeName,
    this.reportType,
    this.image,
  });

  AddReportRequest copyWith({
    String? name,
    String? description,
    int? parkId,
    String? typeName,
    ValueGetter<String?>? reportType,
    ValueGetter<String?>? image,
  }) {
    return AddReportRequest(
      name: name ?? this.name,
      description: description ?? this.description,
      parkId: parkId ?? this.parkId,
      typeName: typeName ?? this.typeName,
      reportType: reportType != null ? reportType() : this.reportType,
      image: image != null ? image() : this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'parkId': parkId,
      'typeName': typeName,
      'reportType': reportType,
      'image': image,
    };
  }

  factory AddReportRequest.fromMap(Map<String, dynamic> map) {
    return AddReportRequest(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      parkId: map['parkId']?.toInt() ?? 0,
      typeName: map['typeName'] ?? '',
      reportType: map['reportType'],
      image: map['image'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AddReportRequest.fromJson(String source) =>
      AddReportRequest.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AddReportRequest(name: $name, description: $description, parkId: $parkId, typeName: $typeName, reportType: $reportType, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddReportRequest &&
        other.name == name &&
        other.description == description &&
        other.parkId == parkId &&
        other.typeName == typeName &&
        other.reportType == reportType &&
        other.image == image;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        parkId.hashCode ^
        typeName.hashCode ^
        reportType.hashCode ^
        image.hashCode;
  }
}
