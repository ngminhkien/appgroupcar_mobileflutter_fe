import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

enum UserProfileStatus { initial, loading, success, failure }

class UserProfileState extends Equatable {
  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.isLoggingOut = false,
  });

  final UserProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;
  final bool isLoggingOut;

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
    bool? isLoggingOut,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage, isLoggingOut];
}
