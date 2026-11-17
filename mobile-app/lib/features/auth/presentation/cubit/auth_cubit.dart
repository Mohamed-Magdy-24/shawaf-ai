import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _repository;

  AuthCubit({required IAuthRepository repository})
      : _repository = repository,
        super(const AuthInitial());

  Future<bool> login(String username, String password) async {
    final cleanUser = username.trim();
    final cleanPass = password.trim();

    if (cleanUser.isEmpty || cleanPass.isEmpty) {
      emit(const AuthUnauthenticated('Username and password are required.'));
      return false;
    }

    emit(const AuthLoading());
    try {
      final data = await _repository.login(cleanUser, cleanPass);
      final token = data['token'] as String? ?? '';
      final role = data['role'] as String? ?? 'operator';
      final siteId = data['site_id'] as String?;

      emit(AuthAuthenticated(
        token: token,
        username: cleanUser,
        role: role,
        siteId: siteId,
      ));
      return true;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthUnauthenticated(msg));
      return false;
    }
  }

  void logout() {
    _repository.logout();
    emit(const AuthUnauthenticated());
  }
}
