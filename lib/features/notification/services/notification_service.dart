import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';

class NotificationService {
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final username = Session.currentUser?.username;
      if (username == null || username.isEmpty) {
        throw StateError('User session not found');
      }

      final response = await DioClient.dio.get(
        "/notification/my-notifications",
        options: Options(headers: {"username": username}),
      );

      final rawResult = response.data['result'];
      List<NotificationModel> notifications = [];

      if (rawResult != null && rawResult is List) {
        notifications = rawResult
            .map(
              (item) => NotificationModel.fromMap(item as Map<String, dynamic>),
            )
            .toList();
      }

      return notifications;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await DioClient.dio.put("/notification/$notificationId/read");
    } catch (e) {
      rethrow;
    }
  }
}
