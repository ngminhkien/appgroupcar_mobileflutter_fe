import '../../domain/entities/user_profile.dart';

class UserProfileResponse {
  const UserProfileResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  final int code;
  final String message;
  final UserProfile data;

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    final dataValue = json['data'];
    final dataMap = dataValue is Map<String, dynamic>
        ? dataValue
        : <String, dynamic>{};
    return UserProfileResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: UserProfile.fromJson(dataMap),
    );
  }
}
