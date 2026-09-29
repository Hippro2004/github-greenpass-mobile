import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/announcement/dtos/announcement_response.dart';

class AnnoucementService {
  Future<List<AnnouncementResponse>> getAllAnnouncements({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final res = await DioClient.dio.get(
      "/announcement/all-announcement",
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (res.statusCode == 204 || res.data == null) {
      return [];
    }

    if (res.data is! Map) {
      throw const FormatException("รูปแบบข้อมูลประกาศไม่ถูกต้อง");
    }

    final data = Map<String, dynamic>.from(res.data as Map);
    final rawResult = data["result"];
    List rawList = [];
    if (rawResult is List) {
      rawList = rawResult;
    } else if (rawResult is Map && rawResult["content"] is List) {
      rawList = rawResult["content"] as List;
    } else if (data["content"] is List) {
      rawList = data["content"] as List;
    }

    final announcements = rawList
        .whereType<Map>()
        .map(
          (e) => AnnouncementResponse.fromMap(Map<String, dynamic>.from(e)),
        )
        .toList();

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
