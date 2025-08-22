import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_profile_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileService userProfileService;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  UserProfileProvider({required this.userProfileService});

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await userProfileService.fetchUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(User updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool success = await userProfileService.updateUser(updatedUser);
      if (success) {
        _user = await userProfileService.fetchUser();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool success = await userProfileService.deleteUser();
      if (success) {
        _user = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Indicates if the user details need to be updated on startup (e.g. if businessName is null).
  bool get shouldShowEditOnStartup {
    return _user?.businessName == null || _user!.businessName!.isEmpty;
  }
}
