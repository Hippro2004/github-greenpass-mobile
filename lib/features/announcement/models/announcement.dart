import 'dart:convert';

class Announcement {
  final int announcementId;
  final String announcementTitle;
  final String postDate;
  final String description;
  final int parkId;

  Announcement({
    required this.announcementId,
    required this.announcementTitle,
    required this.postDate,
    required this.description,
    required this.parkId,
  });

  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'announcementTitle': announcementTitle,
      'postDate': postDate,
      'description': description,
      'parkId': parkId,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      announcementId: map['announcementId']?.toInt() ?? 0,
      announcementTitle: map['announcementTitle'] ?? '',
      postDate: map['postDate'] ?? '',
      description: map['description'] ?? '',
      parkId: map['parkId']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Announcement.fromJson(String source) =>
      Announcement.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Announcement(announcementId: $announcementId, announcementTitle: $announcementTitle, postDate: $postDate, description: $description, parkId: $parkId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Announcement &&
        other.announcementId == announcementId &&
        other.announcementTitle == announcementTitle &&
        other.postDate == postDate &&
        other.description == description &&
        other.parkId == parkId;
  }

  @override
  int get hashCode {
    return announcementId.hashCode ^
        announcementTitle.hashCode ^
        postDate.hashCode ^
        description.hashCode ^
        parkId.hashCode;
  }
}
