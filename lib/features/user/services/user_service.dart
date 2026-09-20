import 'package:dio/dio.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/user/dtos/login_request.dart';
import 'package:greenpass/features/user/dtos/register_request.dart';
import 'package:greenpass/features/user/dtos/update_request.dart';
import 'package:greenpass/features/user/models/user.dart';

class UserSevice {
  Future<User> login(LoginRequest loginRequest) async {
    try {
      final response = await DioClient.dio.post(
        "/user/login",
        data: loginRequest.toJson(),
      );
      return User.fromJson(response.data['result']);
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateRequest> getProfile() async {
    try {
      final response = await DioClient.dio.get(
        "/user/profile",
        options: Options(headers: {"username": Session.currentUser!.username}),
      );
      return UpdateRequest.fromJson(response.data["result"]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(RegisterRequest registerRequest) async {
    try {
      await DioClient.dio.post(
        "/user/register",
        data: registerRequest.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(String username, UpdateRequest updateRequest) async {
    try {
      await DioClient.dio.put(
        "/user/${Session.currentUser!.username}",
        data: updateRequest.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final username = Session.currentUser?.username;
      if (username == null) {
        throw StateError('No current user in session');
      }
      await DioClient.dio.put(
        "/user/$username/fcm-token",
        data: {"fcmToken": fcmToken},
      );
    } catch (e) {
      rethrow;
    }
  }
}
