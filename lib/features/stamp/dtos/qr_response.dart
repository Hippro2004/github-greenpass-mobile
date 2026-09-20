class QrResponse {
  final String qrBase64;
  final int expireAt;
  final int expiresInSeconds;

  QrResponse({
    required this.qrBase64,
    required this.expireAt,
    this.expiresInSeconds = 300,
  });

  factory QrResponse.fromJson(Map<String, dynamic> json) {
    final expireAt = (json['expireAt'] as num?)?.toInt() ?? 0;
    final expiresInSeconds = (json['expiresInSeconds'] as num?)?.toInt() ?? 300;

    return QrResponse(
      qrBase64: json['qrBase64'] ?? '',
      expireAt: expireAt,
      expiresInSeconds: expiresInSeconds > 0 ? expiresInSeconds : 300,
    );
  }

  bool isExpiredAt(DateTime now) => expireAt <= now.millisecondsSinceEpoch;

  int remainingSecondsAt(DateTime now) {
    if (expiresInSeconds > 0) return expiresInSeconds;
    final remainingMs = expireAt - now.millisecondsSinceEpoch;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 1000).ceil();
  }
}
