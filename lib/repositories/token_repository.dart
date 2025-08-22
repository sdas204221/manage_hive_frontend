import 'package:shared_preferences/shared_preferences.dart';

class TokenRepository {
  static const String _tokenKey = 'jwt_token';
  static const String _authorityKey = 'user_authority';

  Future<void> saveToken(String token, String authority) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_authorityKey, authority);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getAuthority() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authorityKey);
  }

  // Clear entire storage instead of just one key
  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
