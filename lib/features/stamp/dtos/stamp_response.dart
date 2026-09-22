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
    int parsedParkId = 0;
    if (map['parkId'] != null) {
      parsedParkId = (map['parkId'] as num).toInt();
    } else if (map['park'] != null && map['park'] is Map) {
      parsedParkId = (map['park']['parkId'] as num?)?.toInt() ?? 0;
    }

    String parsedParkName = '';
    if (map['parkName'] != null && map['parkName'].toString().trim().isNotEmpty) {
      parsedParkName = map['parkName'].toString().trim();
    } else if (map['park'] != null && map['park'] is Map) {
      parsedParkName = (map['park']['name'] ?? '').toString().trim();
    }

    String parsedRangerName = '';
    if (map['parkRangerName'] != null &&
        map['parkRangerName'].toString().trim().isNotEmpty) {
      parsedRangerName = map['parkRangerName'].toString().trim();
    } else if (map['parkRanger'] != null && map['parkRanger'] is Map) {
      final ranger = map['parkRanger'] as Map;
      final fn = (ranger['firstname'] ?? '').toString().trim();
      final sn = (ranger['surname'] ?? '').toString().trim();
      parsedRangerName = '$fn $sn'.trim();
    }

    String parsedSignature = '';
    if (map['signature'] != null &&
        map['signature'].toString().trim().isNotEmpty) {
      parsedSignature = map['signature'].toString().trim();
    } else if (map['parkRanger'] != null && map['parkRanger'] is Map) {
      parsedSignature =
          (map['parkRanger']['signature'] ?? '').toString().trim();
    }

    return StampResponse(
      stampId: (map['stampId'] as num?)?.toInt() ?? 0,
      stampDate: map['stampDate']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
      parkId: parsedParkId,
      parkName: parsedParkName,
      parkRangerName: parsedRangerName,
      signature: parsedSignature,
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
