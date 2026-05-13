part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.role,
  });

  final LoginStatus status;
  final String? errorMessage;
  final String? role;

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    String? role,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, role];
}
