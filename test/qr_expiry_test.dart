import 'package:flutter_test/flutter_test.dart';
import 'package:greenpass/features/stamp/dtos/qr_response.dart';

void main() {
  test(
    'QR should be considered expired when the current time is after expireAt',
    () {
      final now = DateTime.now();
      final qr = QrResponse(
        qrBase64: 'abc',
        expireAt: now
            .subtract(const Duration(seconds: 1))
            .millisecondsSinceEpoch,
      );

      expect(qr.isExpiredAt(now), isTrue);
      expect(qr.remainingSecondsAt(now), equals(0));
    },
  );

  test('QR should keep remaining seconds before expiry', () {
    final now = DateTime.now();
    final qr = QrResponse(
      qrBase64: 'abc',
      expireAt: now.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
    );

    expect(qr.isExpiredAt(now), isFalse);
    expect(qr.remainingSecondsAt(now), inInclusiveRange(299, 300));
  });
}
