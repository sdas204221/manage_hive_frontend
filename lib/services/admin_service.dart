import 'package:manage_hive/models/user.dart';
import 'package:manage_hive/repositories/user_repository_admin.dart';

import '../repositories/auth_repository.dart';
import '../repositories/token_repository.dart';

class AdminService {
  final AuthRepository authRepository;
  final TokenRepository tokenRepository;
  final UserRepositoryAdmin userRepository;
  String? _token;
  AdminService({
    required this.authRepository,
    required this.tokenRepository,
    required this.userRepository,
  });

  /// Calls the AuthRepository to login and then stores the token and authority.
  Future<void> adminLogin(String username, String password) async {
    final result = await authRepository.login(username,password,isAdmin: true);
    _token = result['token'];
    final authority = result['authority'];
    await tokenRepository.saveToken(_token!, authority);
  }

  /// Clears all stored data on logout.
  Future<void> logout() async {
    _token=null;
    await tokenRepository.clearStorage();
  }
  Future<List<User>> fetchUsers() async {
    _token=await tokenRepository.getToken();
    if (_token == null) throw Exception("No token available");
    return await userRepository.fetchUsers(_token!);
  }

  Future<void> addUser(String username, String password) async {
    _token=await tokenRepository.getToken();
    if (_token == null) throw Exception("No token available");
    await userRepository.addUser(_token!, username, password);
  }
  Future<void> changePassword(String username, String password) async {
    _token=await tokenRepository.getToken();
    if (_token == null) throw Exception("No token available");
    await userRepository.changePassword(_token!, username, password);
  }
  Future<void> deleteUser(String username) async {
    _token=await tokenRepository.getToken();
    if (_token == null) throw Exception("No token available");
    await userRepository.deleteUser(_token!, username);
  }

  Future<void> toggleLock(String username, bool lock) async {
    _token=await tokenRepository.getToken();
    if (_token == null) throw Exception("No token available");
    await userRepository.toggleLock(_token!, username, lock);
  }
}
