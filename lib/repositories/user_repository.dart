import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/user.dart';

class UserRepository {
  final _storage = const FlutterSecureStorage();
  final String _url = "${AppConfig.baseUrl}/api/user";

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$_url/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final token = response.body;
      await _storage.write(key: "token", value: token);
      return token;
    } else {
      return null;
    }
  }

  Future<User?> getUser(String token) async {
    final response = await http.get(
      Uri.parse(_url),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> updateUser(User user, String token) async {
    final response = await http.patch(
      Uri.parse(_url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteUser(String token) async {
    final response = await http.delete(
      Uri.parse(_url),
      headers: {"Authorization": "Bearer $token"},
    );
    return response.statusCode == 204;
  }
}
