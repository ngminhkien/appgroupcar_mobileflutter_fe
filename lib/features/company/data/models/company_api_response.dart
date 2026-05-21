class CompanyApiResponse {
  const CompanyApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.errors,
  });

  final int code;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  factory CompanyApiResponse.fromJson(
    Map<String, dynamic> json, {
    required int fallbackCode,
  }) {
    final rawErrors = json['errors'];
    final errors = rawErrors is Map
        ? rawErrors.map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : null;
    return CompanyApiResponse(
      code: json['code'] as int? ?? fallbackCode,
      message: json['message'] as String? ?? '',
      data: json['data'],
      errors: errors,
    );
  }
}
