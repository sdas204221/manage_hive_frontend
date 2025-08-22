import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService adminService;

  bool _isLoading = false;
  String? _errorMessage;
  List<User> _users = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<User> get users => _users;

  AdminProvider({required this.adminService});

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await adminService.adminLogin(username, password);
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
    await adminService.logout();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await adminService.fetchUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await adminService.addUser(username, password);
      await fetchUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await adminService.changePassword(username, password);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await adminService.deleteUser(username);
      await fetchUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLock(String username, bool lock) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await adminService.toggleLock(username, lock);
      await fetchUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
