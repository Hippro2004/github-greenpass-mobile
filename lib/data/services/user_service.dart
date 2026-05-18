import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/core/session.dart';
import 'package:greenpass/data/dtos/api_response.dart';
import 'package:greenpass/data/dtos/login_request.dart';
import 'package:greenpass/data/dtos/register_request.dart';
import 'package:greenpass/data/dtos/update_request.dart';
import 'package:greenpass/data/models/user.dart';

class UserSevice {
  Future<ApiResponse<User>> login(LoginRequest loginRequest) async {
    try {
      final response = await DioClient.dio.post(
        "/user/login",
        data: loginRequest.toJson(),
      );
      // return User.fromJson(response.data['result']);
      return ApiResponse(
        success: response.data['success'],
        message: response.data['message'],
        result: User.fromJson(response.data['result']),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> register(RegisterRequest registerRequest) async {
    try {
      final response = await DioClient.dio.post(
        "/user/register",
        data: registerRequest.toJson(),
      );
      return ApiResponse(
        success: response.data['success'],
        message: response.data['message'],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> update(
    String username,
    UpdateRequest updateRequest,
  ) async {
    try {
      final response = await DioClient.dio.put(
        "/user/${Session.currentUser!.username}",
        data: updateRequest.toJson(),
      );
      return ApiResponse(
        success: response.data['success'],
        message: response.data['message'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
