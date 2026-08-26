import 'dart:convert';

class StampResponse {
  final int stampId;
  final String stampDate;
  final int parkId;
  final String parkName;

  StampResponse({
    required this.stampId,
    required this.stampDate,
    required this.parkId,
    required this.parkName,
  });

  Map<String, dynamic> toMap() {
    return {
      'stampId': stampId,
      'stampDate': stampDate,
      'parkId': parkId,
      'parkName': parkName,
    };
  }

  factory StampResponse.fromMap(Map<String, dynamic> map) {
    return StampResponse(
      stampId: map['stampId']?.toInt() ?? 0,
      stampDate: map['stampDate'] ?? '',
      parkId: map['parkId']?.toInt() ?? 0,
      parkName: map['parkName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StampResponse.fromJson(String source) =>
      StampResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StampResponse(stampId: $stampId, stampDate: $stampDate, parkId: $parkId, parkName: $parkName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StampResponse &&
        other.stampId == stampId &&
        other.stampDate == stampDate &&
        other.parkId == parkId &&
        other.parkName == parkName;
  }

  @override
  int get hashCode {
    return stampId.hashCode ^
        stampDate.hashCode ^
        parkId.hashCode ^
        parkName.hashCode;
  }
}
