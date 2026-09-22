import 'package:greenpass/core/network/dio_client.dart';

String resolveImageUrl(String? imagePath, {String defaultCategory = 'users'}) {
  if (imagePath == null) return '';
  final trimmed = imagePath.trim();
  if (trimmed.isEmpty) return '';

  final apiBaseUrl = DioClient.dio.options.baseUrl.replaceAll(
    RegExp(r'/+$'),
    '',
  );

  // กรณีเป็น Full URL อยู่แล้ว
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    final baseUri = Uri.tryParse(apiBaseUrl);
    // กรณีที่ Backend ส่ง URL ที่เป็น localhost/127.0.0.1 กลับมา ให้แปลงเป็น IP เดียวกับที่ Mobile ใช้ต่อ API
    if (baseUri != null &&
        (trimmed.contains('localhost:8081') ||
            trimmed.contains('127.0.0.1:8081'))) {
      return trimmed.replaceFirst(
        'http://localhost:8081',
        '${baseUri.scheme}://${baseUri.authority}',
      );
      // .replaceFirst(
      //   'http://127.0.0.1:8081',
      //   '${baseUri.scheme}://${baseUri.authority}',
      // );
    }
    return trimmed;
  }

  // กรณีเป็น Relative Path
  String cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';

  // ป้องกันกรณี path มี /api/v1 นำหน้าอยู่แล้วซ้ำกับ apiBaseUrl
  if (apiBaseUrl.endsWith('/api/v1') && cleanPath.startsWith('/api/v1/')) {
    cleanPath = cleanPath.substring('/api/v1'.length);
  }

  // ถ้าส่งมาเป็นชื่อไฟล์เดี่ยวๆ หรือมีโฟลเดอร์หมวดหมู่นำหน้ามาแล้วแต่ยังไม่มี /uploads/
  if (!cleanPath.startsWith('/uploads/')) {
    if (cleanPath.startsWith('/signatures/') ||
        cleanPath.startsWith('/users/') ||
        cleanPath.startsWith('/reports/') ||
        cleanPath.startsWith('/rewards/') ||
        cleanPath.startsWith('/announcements/') ||
        cleanPath.startsWith('/$defaultCategory/')) {
      cleanPath = '/uploads$cleanPath';
    } else {
      cleanPath = '/uploads/$defaultCategory$cleanPath';
    }
  }

  return '$apiBaseUrl$cleanPath';
}
