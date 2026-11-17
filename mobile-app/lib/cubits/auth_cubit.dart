import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/surveillance_repository.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final String username;
  final String role;
  final String? siteId;

  const AuthAuthenticated({
    required this.token,
    required this.username,
    required this.role,
    this.siteId,
  });

  @override
  List<Object?> get props => [token, username, role, siteId];
}

class AuthUnauthenticated extends AuthState {
  final String? errorMessage;
  const AuthUnauthenticated([this.errorMessage]);

  @override
  List<Object?> get props => [errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  final SurveillanceRepository _repository;

  AuthCubit({required SurveillanceRepository repository})
      : _repository = repository,
        super(AuthInitial());

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      emit(const AuthUnauthenticated('Username and password are required.'));
      return false;
    }
    emit(AuthLoading());
    try {
      final data = await _repository.login(username, password);
      final token = data['token'] as String? ?? '';
      final role = data['role'] as String? ?? 'operator';
      final siteId = data['site_id'] as String?;
      emit(AuthAuthenticated(
        token: token,
        username: username.trim(),
        role: role,
        siteId: siteId,
      ));
      return true;
    } catch (e) {
      emit(AuthUnauthenticated(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }

  void logout() {
    _repository.logout();
    emit(const AuthUnauthenticated());
  }
}
