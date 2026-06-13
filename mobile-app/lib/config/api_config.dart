import 'package:flutter/foundation.dart';

class ApiConfig {
  static const productionUrl = 'https://api.marqueeflow.com';
  static const stagingUrl = 'https://api-staging.marqueeflow.com';
  static const localUrl = 'http://127.0.0.1:4010';

  /// Set at build time via:
  /// `--dart-define=API_BASE_URL=https://api.marqueeflow.com`
  /// Debug builds default to local backend when not overridden.
  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    if (kDebugMode) return localUrl;
    return productionUrl;
  }

  static bool get isStaging => baseUrl.contains('staging');
  static bool get isLocal => baseUrl.contains('127.0.0.1') || baseUrl.contains('localhost');
}
