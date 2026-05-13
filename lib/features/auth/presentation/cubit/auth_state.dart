import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.role});

  final AuthStatus status;
  final String? role;

  AuthState copyWith({AuthStatus? status, String? role}) {
    return AuthState(status: status ?? this.status, role: role ?? this.role);
  }

  @override
  List<Object?> get props => [status, role];
}
