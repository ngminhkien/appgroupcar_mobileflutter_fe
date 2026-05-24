import 'dart:convert';

class JwtDecoder {
  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return <String, dynamic>{};
    }
    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    final jsonMap = jsonDecode(decoded);
    if (jsonMap is Map<String, dynamic>) {
      return jsonMap;
    }
    return <String, dynamic>{};
  }

  static String? extractRole(String token) {
    final payload = decodePayload(token);
    final dynamic roleValue =
        payload['Roles'] ?? payload['role'] ?? payload['roles'];
    if (roleValue is String) {
      final normalized = roleValue.trim().toUpperCase();
      if (normalized.isEmpty) {
        return null;
      }
      return normalized;
    }
    if (roleValue is List && roleValue.isNotEmpty) {
      final roles = roleValue
          .whereType<String>()
          .map((role) => role.toUpperCase())
          .toList();
      if (roles.contains('STAFF_COMPANY')) {
        return 'STAFF_COMPANY';
      }
      if (roles.contains('DRIVER')) {
        return 'DRIVER';
      }
      if (roles.contains('COMPANY')) {
        return 'COMPANY';
      }
      if (roles.contains('USER')) {
        return 'USER';
      }
      if (roles.isNotEmpty) {
        return roles.first;
      }
    }
    return null;
  }
}
