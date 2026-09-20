import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/report/dtos/report_type_request.dart';

class ReportTypeService {
  Future<List<ReporyTypeRequest>> getAllReportType() async {
    try {
      final response = await DioClient.dio.get("/report-type/all");

      final rawResult = response.data["result"] as List? ?? [];
      final reportTypes = rawResult
          .map(
            (e) =>
                ReporyTypeRequest.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      return reportTypes;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }
}
