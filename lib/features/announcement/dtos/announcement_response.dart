import 'dart:convert';

class AnnouncementResponse {
  final int announcementId;
  final String announcementTitle;
  final String postDate;
  final String description;
  final String parkName;
  final String image;

  AnnouncementResponse({
    required this.announcementId,
    required this.announcementTitle,
    required this.postDate,
    required this.description,
    required this.parkName,
    required this.image,
  });

  AnnouncementResponse copyWith({
    int? announcementId,
    String? announcementTitle,
    String? postDate,
    String? description,
    String? parkName,
    String? image,
  }) {
    return AnnouncementResponse(
      announcementId: announcementId ?? this.announcementId,
      announcementTitle: announcementTitle ?? this.announcementTitle,
      postDate: postDate ?? this.postDate,
      description: description ?? this.description,
      parkName: parkName ?? this.parkName,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'announcementTitle': announcementTitle,
      'postDate': postDate,
      'description': description,
      'parkName': parkName,
      'image': image,
    };
  }

  factory AnnouncementResponse.fromMap(Map<String, dynamic> map) {
    return AnnouncementResponse(
      announcementId: map['announcementId']?.toInt() ?? 0,
      announcementTitle: map['announcementTitle'] ?? '',
      postDate: map['postDate'] ?? '',
      description: map['description'] ?? '',
      parkName: map['parkName'] ?? '',
      image: map['image'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AnnouncementResponse.fromJson(String source) =>
      AnnouncementResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AnnouncementResponse(announcementId: $announcementId, announcementTitle: $announcementTitle, postDate: $postDate, description: $description, parkName: $parkName, image: $image)';
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
        other.image == image;
  }

  @override
  int get hashCode {
    return announcementId.hashCode ^
        announcementTitle.hashCode ^
        postDate.hashCode ^
        description.hashCode ^
        parkName.hashCode ^
        image.hashCode;
  }
}
