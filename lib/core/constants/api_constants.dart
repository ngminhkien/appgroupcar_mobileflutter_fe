import 'package:flutter/foundation.dart';

class ApiConstants {
  static const int _devPort = 5039;
  static const String _scheme = 'http';

  static String get baseUrl {
    if (kIsWeb) {
      return '$_scheme://localhost:$_devPort/';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '$_scheme://10.0.2.2:$_devPort/';
      case TargetPlatform.iOS:
        return '$_scheme://localhost:$_devPort/';
      default:
        return '$_scheme://localhost:$_devPort/';
    }
  }
}
