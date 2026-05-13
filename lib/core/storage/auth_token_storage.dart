import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStorage {
  AuthTokenStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _roleKey = 'auth_role';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? role,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
    if (role != null && role.isNotEmpty) {
      await _prefs.setString(_roleKey, role);
    }
  }

  String? getAccessToken() => _prefs.getString(_accessTokenKey);

  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);

  String? getRole() => _prefs.getString(_roleKey);

  Future<void> clear() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_roleKey);
  }
}
