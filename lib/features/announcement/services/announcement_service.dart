import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/announcement/dtos/announcement_response.dart';

class AnnoucementService {
  Future<List<AnnouncementResponse>> getAllAnnouncements() async {
    final res = await DioClient.dio.get("/announcement/all-announcement");

    if (res.statusCode == 204 || res.data == null) {
      return [];
    }

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

    return announcements;
  }

  Future<AnnouncementResponse> getAnnouncementDetails(int id) async {
    final res = await DioClient.dio.get(
      "/announcement/announcement-details",
      queryParameters: {"announcementId": id},
    );

    final rawResult = res.data["result"];
    if (rawResult is! Map) {
      throw const FormatException("ไม่พบข้อมูลประกาศ");
    }
    return AnnouncementResponse.fromMap(Map<String, dynamic>.from(rawResult));
  }
}
