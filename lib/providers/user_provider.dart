import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../repositories/token_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserService userService;
  final TokenRepository tokenRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProvider({required this.userService, required this.tokenRepository});

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await userService.loginUser(username, password);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await tokenRepository.clearStorage();
    _isLoading = false;
    notifyListeners();
  }

}
