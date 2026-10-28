import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class AppConfig {
  static const String port = '8080';

  /// Android **emulator** → backend on your dev machine (not localhost from the emulator).
  static const String baseUrlAndroidEmulator = 'http://10.0.2.2:$port';

  /// iOS **simulator** / desktop → backend on same machine.
  static const String baseUrlLoopback = 'http://127.0.0.1:$port';

  static const String baseUrl_aws = 'https://api.smokeread.com';

  /// `true` = AWS load balancer. `false` = local backend (URL depends on platform).
  static const bool useAwsBackend = true;

  /// For a **physical phone** on Wi‑Fi, set your computer’s LAN URL, e.g. `http://192.168.1.42:8080`.
  /// Leave empty to use emulator/simulator defaults above.
  static const String localLanOverride = 'http://192.168.5.0:$port';

  /// Runtime URL (was previously fixed to `192.168.5.0`, which often never connects — see debug timeouts).
  static String get baseUrl {
    if (useAwsBackend) return baseUrl_aws;
    if (localLanOverride.isNotEmpty) return localLanOverride;
    if (kIsWeb) return baseUrlLoopback;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return baseUrlAndroidEmulator;
      case TargetPlatform.iOS:
        return baseUrlLoopback;
      default:
        return baseUrlLoopback;
    }
  }

  static String get authEndpoint => '${baseUrl}/api/v1/auth';
  static String get loginUrl => '$authEndpoint/login';
  static String get signupUrl => '$authEndpoint/register';
  static String get passwordResetUrl => '$authEndpoint/password-reset';

  static String get forgotPasswordRequestUrl =>
      '$authEndpoint/forgot-password/request';

  static String get forgotPasswordConfirmUrl =>
      '$authEndpoint/forgot-password/confirm';

  static String get verifyEmailUrl => '$authEndpoint/verify-email';
  static String get resendVerificationUrl => '$authEndpoint/resend-verification';
  static String get deleteAccountUrl => '$authEndpoint/delete-account';

  static String get locationUploadUrl => '${baseUrl}/api/v1/locationEntries/';
  static String get locationHistoryUrl => '${baseUrl}/api/v1/locationEntries/last';
  static String get smokeSamplerUrl => '${baseUrl}/api/v1/smokeSampler/';
  static String get dataTransferBaseUrl => '${baseUrl}/api/v1/data-transfer';
  static String get ppeSubmitUrl => '$dataTransferBaseUrl/ppe';
  static String get logEventSubmitUrl => '$dataTransferBaseUrl/logevent';
}
