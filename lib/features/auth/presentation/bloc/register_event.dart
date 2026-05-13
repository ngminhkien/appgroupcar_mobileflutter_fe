part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterAvatarChanged extends RegisterEvent {
  const RegisterAvatarChanged({this.avatarPath});

  final String? avatarPath;

  @override
  List<Object?> get props => [avatarPath];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
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
