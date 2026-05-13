part of 'register_bloc.dart';

enum RegisterStatus { initial, loading, success, failure }

const Object _unset = Object();

class RegisterState extends Equatable {
  const RegisterState({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
    this.avatarPath,
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String? avatarPath;
  final RegisterStatus status;
  final String? errorMessage;
  final String? successMessage;

  RegisterState copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    Object? avatarPath = _unset,
    RegisterStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return RegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      avatarPath: avatarPath == _unset
          ? this.avatarPath
          : avatarPath as String?,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    email,
    phoneNumber,
    password,
    avatarPath,
    status,
    errorMessage,
    successMessage,
  ];
}
