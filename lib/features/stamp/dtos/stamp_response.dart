import 'dart:convert';

class StampResponse {
  final int stampId;
  final String stampDate;
  final String time;
  final int parkId;
  final String parkName;
  final String parkRangerName;
  final String signature;

  StampResponse({
    required this.stampId,
    required this.stampDate,
    required this.time,
    required this.parkId,
    required this.parkName,
    required this.parkRangerName,
    required this.signature,
  });

  StampResponse copyWith({
    int? stampId,
    String? stampDate,
    String? time,
    int? parkId,
    String? parkName,
    String? parkRangerName,
    String? signature,
  }) {
    return StampResponse(
      stampId: stampId ?? this.stampId,
      stampDate: stampDate ?? this.stampDate,
      time: time ?? this.time,
      parkId: parkId ?? this.parkId,
      parkName: parkName ?? this.parkName,
      parkRangerName: parkRangerName ?? this.parkRangerName,
      signature: signature ?? this.signature,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stampId': stampId,
      'stampDate': stampDate,
      'time': time,
      'parkId': parkId,
      'parkName': parkName,
      'parkRangerName': parkRangerName,
      'signature': signature,
    };
  }

  factory StampResponse.fromMap(Map<String, dynamic> map) {
    return StampResponse(
      stampId: map['stampId']?.toInt() ?? 0,
      stampDate: map['stampDate'] ?? '',
      time: map['time'] ?? '',
      parkId: map['parkId']?.toInt() ?? 0,
      parkName: map['parkName'] ?? '',
      parkRangerName: map['parkRangerName'] ?? '',
      signature: map['signature'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StampResponse.fromJson(String source) =>
      StampResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StampResponse(stampId: $stampId, stampDate: $stampDate, time: $time, parkId: $parkId, parkName: $parkName, parkRangerName: $parkRangerName, signature: $signature)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StampResponse &&
        other.stampId == stampId &&
        other.stampDate == stampDate &&
        other.time == time &&
        other.parkId == parkId &&
        other.parkName == parkName &&
        other.parkRangerName == parkRangerName &&
        other.signature == signature;
  }

  @override
  int get hashCode {
    return stampId.hashCode ^
        stampDate.hashCode ^
        time.hashCode ^
        parkId.hashCode ^
        parkName.hashCode ^
        parkRangerName.hashCode ^
        signature.hashCode;
  }
}
