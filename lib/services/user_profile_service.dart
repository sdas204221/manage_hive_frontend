import 'package:manage_hive/repositories/token_repository.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserProfileService {
  final UserRepository userRepository;
  final TokenRepository tokenRepository;
  User? _cachedUser;

  UserProfileService({ required this.userRepository,required this.tokenRepository });

  /// Fetches the current user profile and caches it in RAM.
  Future<User?> fetchUser() async {
    String token=(await tokenRepository.getToken())!;
    _cachedUser = await userRepository.getUser(token);
    return _cachedUser;
  }

  /// Returns the cached user profile.
  User? get cachedUser => _cachedUser;

  /// Updates the user profile on the server.
  /// If successful, updates the cached user profile.
  Future<bool> updateUser(User user) async {
    String token=(await tokenRepository.getToken())!;
    final success = await userRepository.updateUser(user, token);
    if (success) {
      _cachedUser = user;
    }
    return success;
  }

  /// Deletes the user account from the server.
  /// Clears the cached user profile on success.
  Future<bool> deleteUser() async {
    String token=(await tokenRepository.getToken())!;
    final success = await userRepository.deleteUser(token);
    if (success) {
      _cachedUser = null;
    }
    return success;
  }
}
