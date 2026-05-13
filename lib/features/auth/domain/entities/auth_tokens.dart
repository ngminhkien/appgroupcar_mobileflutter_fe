import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.role,
  });

  final String accessToken;
  final String refreshToken;
  final String? role;

  @override
  List<Object?> get props => [accessToken, refreshToken, role];
}
