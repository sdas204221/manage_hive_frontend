import '../repositories/auth_repository.dart';
import '../repositories/token_repository.dart';

class UserService {
  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  UserService({
    required AuthRepository authRepository,
    required TokenRepository tokenRepository,
  })  : _authRepository = authRepository,
        _tokenRepository = tokenRepository;

  Future<void> loginUser(String username, String password) async {
    final result = await _authRepository.login(username, password,isAdmin: false);
    await _tokenRepository.saveToken(result['token'], result['authority']);
  }

  Future<void> logout() async {
    await _tokenRepository.clearStorage();
  }

  Future<String?> getToken() async => await _tokenRepository.getToken();

  Future<String?> getAuthority() async => await _tokenRepository.getAuthority();
}
