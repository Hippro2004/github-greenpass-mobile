class Park {
  final int id;
  final String name;
  final String? image;
  final String? address;
  final String? description;
  final String? location;
  final String? openTime;
  final String? closeTime;
  final String? eventNote;
  final bool? isSeasonalPark;
  final String? seasonOpenDate;
  final String? seasonCloseDate;
  final bool? isTemporaryClosed;
  final String? status;
  Park({
    required this.id,
    required this.name,
    this.image,
    this.address,
    this.description,
    this.location,
    this.openTime,
    this.closeTime,
    this.eventNote,
    this.isSeasonalPark,
    this.seasonOpenDate,
    this.seasonCloseDate,
    this.isTemporaryClosed,
    this.status,
  });

  factory Park.fromJson(Map<String, dynamic> json) => Park(
    id: json['id'],
    name: json['name'],
    image: json['image'],
    address: json['address'],
    description: json['description'],
    location: json['location'],
    openTime: json['openTime'],
    closeTime: json['closeTime'],
    eventNote: json['eventNote'],
    isSeasonalPark: json['isSeasonalPark'],
    seasonOpenDate: json['seasonOpenDate'],
    seasonCloseDate: json['seasonCloseDate'],
    isTemporaryClosed: json['isTemporaryClosed'],
    status: json['status'],
  );
}
