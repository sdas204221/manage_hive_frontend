import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class BackupRepository {
  final String _base = "${AppConfig.baseUrl}/api";

  Future<String?> getUserBackup(String token) async {
    final response = await http.get(
      Uri.parse("$_base/user/backup"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    return response.statusCode == 200 ? response.body : null;
  }

  Future<String?> getAdminBackup(String token) async {
    final response = await http.get(
      Uri.parse("$_base/admin/backup"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    return response.statusCode == 200 ? response.body : null;
  }
}
