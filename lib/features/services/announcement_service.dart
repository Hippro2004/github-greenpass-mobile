import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/dtos/announcement_response.dart';
import 'package:greenpass/dtos/api_response.dart';

class AnnoucementService {
  Future<ApiResponse<List<AnnouncementResponse>>> getAllAnnouncements() async {
    final res = await DioClient.dio.get("/announcement/all-announcement");

    List<AnnouncementResponse> announcements = (res.data["result"] as List)
        .map(
          (e) =>
              AnnouncementResponse.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    return ApiResponse(
      success: res.data["success"],
      message: res.data["message"],
      result: announcements,
    );
  }
}
