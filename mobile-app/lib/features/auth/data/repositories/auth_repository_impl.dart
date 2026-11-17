import 'package:get_it/get_it.dart';
import '../../../../core/network/api_client.dart';
import '../../../../services/api_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IApiClient _apiClient;

  AuthRepositoryImpl({required IApiClient apiClient}) : _apiClient = apiClient;

  @override
  String? get currentToken => _apiClient.authToken;

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiClient.post('/api/v1/auth/login', body: {
      'username': username,
      'password': password,
    });
    if (response is Map<String, dynamic>) {
      final token = response['token'] as String?;
      if (token != null) {
        _apiClient.setAuthToken(token);
        if (GetIt.instance.isRegistered<ApiService>()) {
          GetIt.instance<ApiService>().setAuthToken(token);
        }
      }
      return response;
    }
    throw Exception('Invalid server response format for login');
  }

  @override
  void logout() {
    _apiClient.setAuthToken(null);
    if (GetIt.instance.isRegistered<ApiService>()) {
      GetIt.instance<ApiService>().setAuthToken(null);
    }
  }
}
