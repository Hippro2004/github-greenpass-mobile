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

  int get parkId => id;

  factory Park.fromJson(Map json) {
    final Map data = (json['park'] != null && json['park'] is Map)
        ? json['park'] as Map
        : json;

    return Park(
      id: _parseInt(data['id'] ?? data['parkId'] ?? data['park_id']),
      name: data['name']?.toString() ??
          data['parkName']?.toString() ??
          data['park_name']?.toString() ??
          '',
      image: data['image']?.toString() ??
          data['imageUrl']?.toString() ??
          data['parkImage']?.toString(),
      address: data['address']?.toString(),
      description: data['description']?.toString(),
      location: data['location']?.toString(),
      openTime: _parseTime(data['openTime'] ?? data['open_time']),
      closeTime: _parseTime(data['closeTime'] ?? data['close_time']),
      eventNote: (data['eventNote'] ?? data['event_note'])?.toString(),
      isSeasonalPark: _parseBool(
        data['isSeasonalPark'] ??
            data['seasonalPark'] ??
            data['is_seasonal_park'],
      ),
      seasonOpenDate: _parseDate(
        data['seasonOpenDate'] ?? data['season_open_date'],
      ),
      seasonCloseDate: _parseDate(
        data['seasonCloseDate'] ?? data['season_close_date'],
      ),
      isTemporaryClosed: _parseBool(
        data['isTemporaryClosed'] ??
            data['temporaryClosed'] ??
            data['is_temporary_closed'],
      ),
      status: data['status']?.toString(),
    );
  }

  static int _parseInt(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final s = value.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return null;
  }

  static String? _parseTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim();
    if (value is List && value.isNotEmpty) {
      final h = value[0].toString().padLeft(2, '0');
      final m = (value.length > 1 ? value[1] : 0).toString().padLeft(2, '0');
      final s = (value.length > 2 ? value[2] : 0).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    if (value is Map) {
      final h = (value['hour'] ?? 0).toString().padLeft(2, '0');
      final m = (value['minute'] ?? 0).toString().padLeft(2, '0');
      final s = (value['second'] ?? 0).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    return value.toString();
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim();
    if (value is List && value.length >= 3) {
      final y = value[0].toString().padLeft(4, '0');
      final m = value[1].toString().padLeft(2, '0');
      final d = value[2].toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    if (value is Map) {
      final y = (value['year'] ?? 0).toString().padLeft(4, '0');
      final m = (value['month'] ?? 0).toString().padLeft(2, '0');
      final d = (value['day'] ?? 0).toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'parkId': id,
    'name': name,
    'image': image,
    'address': address,
    'description': description,
    'location': location,
    'openTime': openTime,
    'closeTime': closeTime,
    'eventNote': eventNote,
    'isSeasonalPark': isSeasonalPark,
    'seasonOpenDate': seasonOpenDate,
    'seasonCloseDate': seasonCloseDate,
    'isTemporaryClosed': isTemporaryClosed,
    'status': status,
  };
}
