class Stamp {
  final int id;
  final String? stampImage;
  final String stampDate;
  final String lastStampDate;
  final int parkId;
  final String parkName;

  Stamp({
    required this.id,
    this.stampImage,
    required this.stampDate,
    required this.lastStampDate,
    required this.parkId,
    required this.parkName,
  });

  factory Stamp.fromJson(Map<String, dynamic> json) => Stamp(
    id: json['id'],
    stampImage: json['stampImage'],
    stampDate: json['stampDate'],
    lastStampDate: json['lastStampDate'],
    parkId: json['park']['id'],
    parkName: json['park']['name'],
  );
}
