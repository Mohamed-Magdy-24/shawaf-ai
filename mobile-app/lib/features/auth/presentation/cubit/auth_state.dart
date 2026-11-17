import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

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
