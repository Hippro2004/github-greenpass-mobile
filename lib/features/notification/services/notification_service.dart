import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/dtos/api_response.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';

class NotificationService {
  Future<ApiResponse<List<NotificationModel>>> getMyNotifications() async {
    try {
      final username = Session.currentUser?.username;
      if (username == null || username.isEmpty) {
        return ApiResponse(
          success: false,
          message: 'User session not found',
          result: [],
        );
      }

      final response = await DioClient.dio.get(
        "/notification/my-notifications",
        options: Options(headers: {"username": username}),
      );

      final rawResult = response.data['result'];
      List<NotificationModel> notifications = [];

      if (rawResult != null && rawResult is List) {
        notifications = rawResult
            .map((item) => NotificationModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse(
        success: response.data['success'] ?? true,
        message: response.data['message'] ?? 'Notifications found',
        result: notifications,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse(
          success: true,
          message: 'No notifications found',
          result: [],
        );
      }
      return ApiResponse(
        success: false,
        message: e.message ?? 'Failed to load notifications',
        result: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        result: [],
      );
    }
  }

  Future<ApiResponse<void>> markAsRead(int notificationId) async {
    try {
      final response = await DioClient.dio.put(
        "/notification/$notificationId/read",
      );

      return ApiResponse(
        success: response.data['success'] ?? true,
        message: response.data['message'] ?? 'Notification marked as read',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}
