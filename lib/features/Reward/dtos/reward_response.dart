import 'dart:convert';

class RewardResponse {
  final int rewardId;
  final String rewardTitle;
  final String rewardDetails;
  final String rewardAnnouncementDate;
  final String image;

  const RewardResponse({
    required this.rewardId,
    required this.rewardTitle,
    required this.rewardDetails,
    required this.rewardAnnouncementDate,
    required this.image,
  });

  RewardResponse copyWith({
    int? rewardId,
    String? rewardTitle,
    String? rewardDetails,
    String? rewardAnnouncementDate,
    String? image,
  }) {
    return RewardResponse(
      rewardId: rewardId ?? this.rewardId,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      rewardDetails: rewardDetails ?? this.rewardDetails,
      rewardAnnouncementDate:
          rewardAnnouncementDate ?? this.rewardAnnouncementDate,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'rewardDetails': rewardDetails,
      'rewardAnnouncementDate': rewardAnnouncementDate,
      'image': image,
    };
  }

  factory RewardResponse.fromMap(Map<String, dynamic> map) {
    return RewardResponse(
      rewardId: (map['rewardId'] ?? map['id'] ?? 0) is num
          ? (map['rewardId'] ?? map['id'] ?? 0).toInt()
          : int.tryParse((map['rewardId'] ?? map['id'] ?? 0).toString()) ?? 0,
      rewardTitle: (map['rewardTitle'] ?? map['title'] ?? '').toString(),
      rewardDetails:
          (map['rewardDetails'] ?? map['details'] ?? map['description'] ?? '')
              .toString(),
      rewardAnnouncementDate:
          (map['rewardAnnouncementDate'] ??
                  map['announcementDate'] ??
                  map['date'] ??
                  '')
              .toString(),
      image: (map['image'] ?? map['imageUrl'] ?? '').toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory RewardResponse.fromJson(String source) =>
      RewardResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RewardResponse(rewardId: $rewardId, rewardTitle: $rewardTitle, rewardDetails: $rewardDetails, rewardAnnouncementDate: $rewardAnnouncementDate, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RewardResponse &&
        other.rewardId == rewardId &&
        other.rewardTitle == rewardTitle &&
        other.rewardDetails == rewardDetails &&
        other.rewardAnnouncementDate == rewardAnnouncementDate &&
        other.image == image;
  }

  @override
  int get hashCode {
    return rewardId.hashCode ^
        rewardTitle.hashCode ^
        rewardDetails.hashCode ^
        rewardAnnouncementDate.hashCode ^
        image.hashCode;
  }
}
