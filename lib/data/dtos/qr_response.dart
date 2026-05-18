class QrResponse {
  final String qrBase64;
  final int expireAt;

  QrResponse({required this.qrBase64, required this.expireAt});

  factory QrResponse.fromJson(Map<String, dynamic> json) =>
      QrResponse(qrBase64: json['qrBase64'], expireAt: json['expireAt']);
}
