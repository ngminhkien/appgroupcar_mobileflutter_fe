import 'package:equatable/equatable.dart';

import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(RegisterParams params) {
    return _repository.register(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
      avatarPath: params.avatarPath,
    );
  }
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.avatarPath,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String? avatarPath;

  @override
  List<Object?> get props => [
    fullName,
    email,
    phoneNumber,
    password,
    avatarPath,
  ];
}
