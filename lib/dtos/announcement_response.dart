import 'dart:convert';

class AnnouncementResponse {
  final int annoucementId;
  final String annoucementName;
  final String postDate;
  final String description;
  final String parkName;
  AnnouncementResponse({
    required this.annoucementId,
    required this.annoucementName,
    required this.postDate,
    required this.description,
    required this.parkName,
  });

  Map<String, dynamic> toMap() {
    return {
      'annoucementId': annoucementId,
      'annoucementName': annoucementName,
      'postDate': postDate,
      'description': description,
      'parkName': parkName,
    };
  }

  factory AnnouncementResponse.fromMap(Map<String, dynamic> map) {
    return AnnouncementResponse(
      annoucementId: map['annoucementId']?.toInt() ?? 0,
      annoucementName: map['annoucementName'] ?? '',
      postDate: map['postDate'] ?? '',
      description: map['description'] ?? '',
      parkName: map['parkName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AnnouncementResponse.fromJson(String source) =>
      AnnouncementResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AnnoucementResponse(annoucementId: $annoucementId, annoucementName: $annoucementName, postDate: $postDate, description: $description, parkName: $parkName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnnouncementResponse &&
        other.annoucementId == annoucementId &&
        other.annoucementName == annoucementName &&
        other.postDate == postDate &&
        other.description == description &&
        other.parkName == parkName;
  }

  @override
  int get hashCode {
    return annoucementId.hashCode ^
        annoucementName.hashCode ^
        postDate.hashCode ^
        description.hashCode ^
        parkName.hashCode;
  }
}
