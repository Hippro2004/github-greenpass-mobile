import 'dart:convert';

class AnnouncementResponse {
  final int announcementId;
  final String announcementTitle;
  final String postDate;
  final String? description;
  final String parkName;
  final String? parkRangerName;

  AnnouncementResponse({
    required this.announcementId,
    required this.announcementTitle,
    required this.postDate,
    this.description,
    required this.parkName,
    this.parkRangerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'announcementTitle': announcementTitle,
      'postDate': postDate,
      'description': description,
      'parkName': parkName,
      'parkRangerName': parkRangerName,
    };
  }

  factory AnnouncementResponse.fromMap(Map<String, dynamic> map) {
    return AnnouncementResponse(
      announcementId: map['announcementId']?.toInt() ?? 0,
      announcementTitle: map['announcementTitle'] ?? '',
      postDate: map['postDate'] ?? '',
      description: map['description'],
      parkName: map['parkName'] ?? '',
      parkRangerName: map['parkRangerName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AnnouncementResponse.fromJson(String source) =>
      AnnouncementResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AnnouncementResponse(announcementId: $announcementId, announcementTitle: $announcementTitle, postDate: $postDate, description: $description, parkName: $parkName, parkRangerName: $parkRangerName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnnouncementResponse &&
        other.announcementId == announcementId &&
        other.announcementTitle == announcementTitle &&
        other.postDate == postDate &&
        other.description == description &&
        other.parkName == parkName &&
        other.parkRangerName == parkRangerName;
  }

  @override
  int get hashCode {
    return announcementId.hashCode ^
        announcementTitle.hashCode ^
        postDate.hashCode ^
        description.hashCode ^
        parkName.hashCode ^
        parkRangerName.hashCode;
  }
}
