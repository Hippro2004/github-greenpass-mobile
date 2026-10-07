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
    id: json['id'] is int
        ? json['id'] as int
        : (json['parkId'] is int
            ? json['parkId'] as int
            : int.tryParse('${json['id'] ?? json['parkId']}') ?? 0),
    name: json['name']?.toString() ?? '',
    image: json['image']?.toString(),
    address: json['address']?.toString(),
    description: json['description']?.toString(),
    location: json['location']?.toString(),
    openTime: json['openTime']?.toString(),
    closeTime: json['closeTime']?.toString(),
    eventNote: json['eventNote']?.toString(),
    isSeasonalPark: json['isSeasonalPark'] as bool?,
    seasonOpenDate: json['seasonOpenDate']?.toString(),
    seasonCloseDate: json['seasonCloseDate']?.toString(),
    isTemporaryClosed: json['isTemporaryClosed'] as bool?,
    status: json['status']?.toString(),
  );
}
