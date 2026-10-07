import 'package:flutter_test/flutter_test.dart';
import 'package:greenpass/features/park/models/park.dart';

void main() {
  group('Park.fromJson tests', () {
    test('parses standard flat park JSON with string times', () {
      final json = {
        'id': 156,
        'name': 'Doi Inthanon',
        'image': 'https://example.com/park.jpg',
        'address': 'Chiang Mai',
        'description': 'Highest peak',
        'location': '18.58,98.48',
        'openTime': '06:00:00',
        'closeTime': '18:00:00',
        'isSeasonalPark': true,
        'seasonOpenDate': '2026-11-01',
        'seasonCloseDate': '2027-04-30',
        'isTemporaryClosed': false,
        'status': 'OPEN',
      };

      final park = Park.fromJson(json);
      expect(park.id, 156);
      expect(park.parkId, 156);
      expect(park.name, 'Doi Inthanon');
      expect(park.openTime, '06:00:00');
      expect(park.closeTime, '18:00:00');
      expect(park.isSeasonalPark, isTrue);
      expect(park.isTemporaryClosed, isFalse);
    });

    test('parses Spring Boot Jackson serialized fields (seasonalPark, temporaryClosed, list times)', () {
      final json = {
        'id': 156,
        'parkName': 'Doi Inthanon',
        'seasonalPark': false,
        'temporaryClosed': true,
        'openTime': [8, 30],
        'closeTime': [16, 30, 0],
        'seasonOpenDate': [2026, 11, 1],
        'seasonCloseDate': [2027, 4, 30],
      };

      final park = Park.fromJson(json);
      expect(park.id, 156);
      expect(park.name, 'Doi Inthanon');
      expect(park.isSeasonalPark, isFalse);
      expect(park.isTemporaryClosed, isTrue);
      expect(park.openTime, '08:30:00');
      expect(park.closeTime, '16:30:00');
      expect(park.seasonOpenDate, '2026-11-01');
      expect(park.seasonCloseDate, '2027-04-30');
    });

    test('parses nested park wrapper and string booleans/numbers', () {
      final json = {
        'park': {
          'parkId': '99',
          'name': 'Khao Yai',
          'seasonalPark': '1',
          'temporaryClosed': 'false',
        },
      };

      final park = Park.fromJson(json);
      expect(park.id, 99);
      expect(park.name, 'Khao Yai');
      expect(park.isSeasonalPark, isTrue);
      expect(park.isTemporaryClosed, isFalse);
    });
  });
}
