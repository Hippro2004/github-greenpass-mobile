import 'dart:convert';

class Stamp {
  final int id;
  final String? stampImage;
  final String stampDate;
  final String lastStampDate;
  final int parkId;
  final String parkName;
  final int parkRangerId;

  Stamp(
    this.id,
    this.stampImage,
    this.stampDate,
    this.lastStampDate,
    this.parkId,
    this.parkName,
    this.parkRangerId,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stampImage': stampImage,
      'stampDate': stampDate,
      'lastStampDate': lastStampDate,
      'parkId': parkId,
      'parkName': parkName,
      'parkRangerId': parkRangerId,
    };
  }

  factory Stamp.fromMap(Map<String, dynamic> map) {
    return Stamp(
      map['id']?.toInt() ?? 0,
      map['stampImage'],
      map['stampDate'] ?? '',
      map['lastStampDate'] ?? '',
      map['parkId']?.toInt() ?? 0,
      map['parkName'] ?? '',
      map['parkRangerId']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Stamp.fromJson(String source) => Stamp.fromMap(json.decode(source));
}
