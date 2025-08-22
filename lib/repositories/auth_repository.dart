import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthRepository {
  final String adminLoginEndpoint = "${AppConfig.baseUrl}/api/admin/login";
  final String userLoginEndpoint = "${AppConfig.baseUrl}/api/user/login";

  Future<Map<String, dynamic>> login(String username, String password, {required bool isAdmin}) async {
    final endpoint = isAdmin ? adminLoginEndpoint : userLoginEndpoint;

    final response = await http.post(
      Uri.parse(endpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'token': response.body,
        'authority': isAdmin ? 'ADMIN' : 'USER',
      };
    } else {
      throw Exception("Failed to login. Status code: \${response.statusCode}");
    }
  }
}