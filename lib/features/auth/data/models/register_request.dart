class RegisterRequest {
  const RegisterRequest({
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

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'avatar': null,
    };
  }
}
