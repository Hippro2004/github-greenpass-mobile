import 'package:dio/dio.dart';

class DioClient {
  static const String _defaultBaseUrl = "http://172.20.10.3:8081/api/v1";
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
}
