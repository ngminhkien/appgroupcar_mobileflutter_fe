class RefreshTokenResponse {
  const RefreshTokenResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  final int code;
  final String message;
  final RefreshTokenData? data;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    final dataValue = json['data'];
    final dataMap = dataValue is Map<String, dynamic>
        ? dataValue
        : <String, dynamic>{};
    return RefreshTokenResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: dataValue == null ? null : RefreshTokenData.fromJson(dataMap),
    );
  }
}

class RefreshTokenData {
  const RefreshTokenData({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenData(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}
