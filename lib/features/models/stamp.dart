import 'dart:convert';

class Stamp {
  final int id;
  final String? stampImage;
  final String stampDate;
  final int parkId;
  final String parkName;
  final int parkRangerId;

  Stamp(
    this.id,
    this.stampImage,
    this.stampDate,
    this.parkId,
    this.parkName,
    this.parkRangerId,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stampImage': stampImage,
      'stampDate': stampDate,
      'parkId': parkId,
      'parkName': parkName,
      'parkRangerId': parkRangerId,
    };
  }

  factory Stamp.fromMap(Map<String, dynamic> map) {
    final parkValue = map['parkId'] ?? map['park_id'] ?? map['park'];

    return Stamp(
      _toInt(map['stampId'] ?? map['stamp_id'] ?? map['id']),
      map['stampImage'],
      map['stampDate'] ?? '',
      _toInt(parkValue),
      map['parkName'] ?? map['name'] ?? '',
      map['parkRangerId']?.toInt() ?? 0,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String toJson() => json.encode(toMap());

  factory Stamp.fromJson(String source) => Stamp.fromMap(json.decode(source));
}
