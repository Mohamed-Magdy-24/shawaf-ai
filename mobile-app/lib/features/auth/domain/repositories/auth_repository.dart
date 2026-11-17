abstract class IAuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  void logout();
  String? get currentToken;
}
