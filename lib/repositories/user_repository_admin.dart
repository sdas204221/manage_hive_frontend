import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/user.dart';

class UserRepositoryAdmin {
  final Dio _dio = Dio();

  Future<List<User>> fetchUsers(String token) async {
    final response = await _dio.get(
      '${AppConfig.baseUrl}/api/admin/users',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      List<User> users = data.map((json) => User.fromJson(json)).toList();
      // Return only users with role 'USER'
      return users.where((user) => user.role == 'USER').toList();
    } else {
      throw Exception("Failed to fetch users. Status code: ${response.statusCode}");
    }
  }

  Future<void> addUser(String token, String username, String password) async {
    final response = await _dio.post(
      '${AppConfig.baseUrl}/api/admin/user',
      data: {
        'username': username,
        'password': password,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add user. Status code: ${response.statusCode}");
    }
  }
  Future<void> changePassword(String token, String username, String password) async {
    final response = await _dio.patch(
      '${AppConfig.baseUrl}/api/admin/user/password',
      data: {
        'username': username,
        'password': password,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add user. Status code: ${response.statusCode}");
    }
  }

  Future<void> deleteUser(String token, String username) async {
    final response = await _dio.delete(
      '${AppConfig.baseUrl}/api/admin/user',
      data: {'username': username},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to delete user. Status code: ${response.statusCode}");
    }
  }

  Future<void> toggleLock(String token, String username, bool lock) async {
    final endpoint = lock ? 'lock' : 'unlock';
      final response = await _dio.patch(
      '${AppConfig.baseUrl}/api/admin/user/$endpoint',
      data: {'username': username},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to toggle lock. Status code: ${response.statusCode}");
    } 
  }
}
