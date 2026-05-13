import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.roles,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final List<String> roles;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rolesValue = json['roles'];
    final rolesList = rolesValue is List
        ? rolesValue.whereType<String>().toList()
        : <String>[];
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      roles: rolesList,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, phoneNumber, roles];
}
