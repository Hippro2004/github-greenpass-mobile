import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/dtos/announcement_response.dart';
import 'package:greenpass/dtos/api_response.dart';
import 'package:greenpass/features/models/announcement.dart';

class AnnoucementService {
  Future<ApiResponse<List<AnnouncementResponse>>> getAllAnnouncements() async {
    final res = await DioClient.dio.get("/announcement/all-announcement");

    if (res.data is! Map) {
      throw const FormatException("รูปแบบข้อมูลประกาศไม่ถูกต้อง");
    }

    final data = Map<String, dynamic>.from(res.data as Map);
    final rawResult = data["result"];
    final announcements = rawResult is List
        ? rawResult
              .whereType<Map>()
              .map(
                (e) =>
                    AnnouncementResponse.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList()
        : <AnnouncementResponse>[];

    return ApiResponse(
      success: data["success"] == true || data["sussess"] == true,
      message: data["message"]?.toString() ?? "",
      result: announcements,
    );
  }

  Future<ApiResponse<AnnouncementResponse>> getAnnouncementDetails(
    int id,
  ) async {
    final res = await DioClient.dio.get(
      "/announcement/announcement-details",
      queryParameters: {"announcementId": id},
    );

    final rawResult = res.data["result"];
    final result = rawResult is Map
        ? AnnouncementResponse.fromMap(Map<String, dynamic>.from(rawResult))
        : null;

    return ApiResponse(
      success: res.data["success"] == true || res.data["sussess"] == true,
      message: res.data["message"]?.toString() ?? "",
      result: result,
    );
  }
}
