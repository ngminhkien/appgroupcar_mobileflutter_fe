class RegisterResponse {
  const RegisterResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final Object? data;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'],
    );
  }
}
