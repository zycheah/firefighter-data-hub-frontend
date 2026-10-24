import '../models/user_model.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../config/app_config.dart' as app_config;
import 'ppe_is_updated_storage.dart';
import 'tracking_diagnostics.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  static const Duration _httpTimeout = Duration(seconds: 30);

  static const String _accessTokenKey = 'access_token';
  static const String _userKeyKey = 'user_key';
  static const String _accessTokenObtainedMsKey = 'access_token_obtained_ms';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _currentUser;
  String? _accessToken;
  String? _lastAuthError;

  final Map<String, User> _users = {};

  Future<String?>? _refreshInFlight;
  DateTime? _lastRenewAttemptAt;

  String? get lastAuthError => _lastAuthError;

  Future<void> _persistAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
    await _secureStorage.write(
      key: _accessTokenObtainedMsKey,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> applyNewAccessToken(String token) async {
    if (token.trim().isEmpty) return;
    _accessToken = token;
    await _persistAccessToken(token);
  }

  Future<String?> _readStoredAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<void> _clearStoredAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _accessTokenObtainedMsKey);
  }

  Future<void> _persistUserKey(String userKey) async {
    await _secureStorage.write(key: _userKeyKey, value: userKey);
  }

  Future<String?> _readStoredUserKey() async {
    return _secureStorage.read(key: _userKeyKey);
  }

  Future<void> _clearStoredUserKey() async {
    await _secureStorage.delete(key: _userKeyKey);
  }

  User? getCurrentUser() => _currentUser;

  String? get accessToken => _accessToken;

  bool isLoggedIn() => _currentUser != null;

  Future<String?> getUserKey() async {
    final u = _currentUser;
    if (u != null && u.email.trim().isNotEmpty) {
      return u.email.trim();
    }

    final stored = await _readStoredUserKey();
    return (stored != null && stored.trim().isNotEmpty)
        ? stored.trim()
        : null;
  }

  Future<String?> _getUsableAccessToken() async {
    final token = _accessToken ?? await _readStoredAccessToken();

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    _accessToken = token;
    return token;
  }

  Future<void> _captureAccessTokenFromResponse(http.Response response) async {
    if (response.body.isEmpty) return;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final newToken = decoded['access_token'];

        if (newToken is String && newToken.trim().isNotEmpty) {
          await applyNewAccessToken(newToken);
        }
      }
    } catch (_) {
      // Response may not be JSON. Ignore safely.
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    UserRole role = UserRole.firefighter,
    String? gender,
    String? race,
    String? ethnicity,
    int? birthYear,
    required String height,
    required String weight,
    required bool dominantHand,
    required String dominantHandLabel,
    required double heightCm,
    required double weightKg,
    required String yearsOfExperience,
    required Status status,
    required List<FirefighterType> firefighterTypes,
    String otherFirefighterTypeDetail = '',
    required String firefighterStationName,
    required String city,
    required FFState state,
  }) async {
    _lastAuthError = null;

    final nowYear = DateTime.now().year;
    final age = birthYear != null ? (nowYear - birthYear).clamp(0, 200) : 0;

    final user = User(
      name: name,
      age: age,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
      gender: gender != null && gender.isNotEmpty ? gender : '—',
      race: race != null && race.isNotEmpty ? race : '—',
      ethnicity: ethnicity != null && ethnicity.isNotEmpty ? ethnicity : '—',
      birthYear: birthYear ?? 0,
      height: height,
      weight: weight,
      dominantHandLabel: dominantHandLabel,
      dominantHand: dominantHand,
      yearsOfExperience: yearsOfExperience,
      status: status,
      firefighterTypes: firefighterTypes,
      city: city,
      state: state,
    );

    final requestBody = <String, dynamic>{
      'full_name': name,
      'email': email,
      if (phoneNumber.trim().isNotEmpty) 'phoneNumber': phoneNumber.trim(),
      'password': password,
      'role': userRoleToApiString(role),
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'dominant_hand': dominantHandLabel,
      'years_of_experience': yearsOfExperience,
      'Years_of_experience': yearsOfExperience,
      'firefighter_status': StatusToDisplayString(status).toLowerCase(),
      'type_of_firefighter': typeOfFirefighterForApi(
        firefighterTypes,
        otherFirefighterTypeDetail,
      ).toLowerCase(),
      'firefighter_station_name': firefighterStationName,
      'city': city,
      'state': stateToDisplayString(state).toLowerCase(),
    };

    if (gender != null && gender.isNotEmpty) {
      requestBody['gender'] = gender;
    }

    if (race != null && race.isNotEmpty) {
      requestBody['race'] = race;
    }

    if (ethnicity != null && ethnicity.isNotEmpty) {
      requestBody['ethnicity'] = ethnicity;
    }

    if (birthYear != null) {
      requestBody['year_of_birth'] = birthYear;
    }

    try {
      final response = await http
          .post(
            Uri.parse(app_config.AppConfig.signupUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(_httpTimeout);

      if (response.statusCode != 200) {
        _lastAuthError = _parseFastApiDetail(response.body) ??
            'Signup failed. Please check your details and try again.';
        return false;
      }

      return true;
    } on TimeoutException {
      _lastAuthError = 'Signup request timed out. Please try again.';
      return false;
    } catch (_) {
      _lastAuthError = 'Signup failed. Please try again.';
      return false;
    }
  }

  Future<bool> login(String email, String password, {User? sessionUser}) async {
    _lastAuthError = null;

    final loginBody = {
      'email': email,
      'password': password,
    };

    try {
      final loginResponse = await http
          .post(
            Uri.parse(app_config.AppConfig.loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(loginBody),
          )
          .timeout(_httpTimeout);

      if (loginResponse.statusCode != 200) {
        _lastAuthError = _parseFastApiDetail(loginResponse.body) ??
            'Invalid email or password';
        return false;
      }

      final decodedLogin =
          jsonDecode(loginResponse.body) as Map<String, dynamic>;
      final token = decodedLogin['access_token'] as String?;

      if (token == null || token.isEmpty) {
        _lastAuthError = 'Invalid server response. Please try again.';
        return false;
      }

      _accessToken = token;
      await _persistAccessToken(token);

      final meUrl = '${app_config.AppConfig.authEndpoint}/me';

      final meResponse = await http
          .get(
            Uri.parse(meUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_httpTimeout);

      if (meResponse.statusCode != 200) {
        _lastAuthError = _parseFastApiDetail(meResponse.body) ??
            'Could not load user profile. Please try again.';
        return false;
      }

      final me = jsonDecode(meResponse.body) as Map<String, dynamic>;

      if (sessionUser != null) {
        _currentUser = sessionUser;
      } else {
        _currentUser = User.fromAuthMeJson(me);
      }

      final userKey = _currentUser?.email.trim();
      if (userKey != null && userKey.isNotEmpty) {
        await _persistUserKey(userKey);
      }

      await clearPendingIsPpeUpdated();
      return true;
    } on TimeoutException {
      _lastAuthError = 'Connection timed out. Please try again.';
      rethrow;
    } on SocketException catch (_) {
      _lastAuthError = 'Network error. Please check your connection.';
      return false;
    } catch (_) {
      _lastAuthError = 'Login failed. Please try again.';
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _accessToken = null;
    _lastAuthError = null;

    unawaited(_clearStoredAccessToken());
    unawaited(_clearStoredUserKey());
    unawaited(clearPendingIsPpeUpdated());
  }

  /// Drops the rejected token but keeps the user key, so capture continues.
  void _expireSession() {
    TrackingDiagnostics.log('session expired');
    _currentUser = null;
    _accessToken = null;

    unawaited(_clearStoredAccessToken());
  }

  /// True when a known user has no valid session.
  Future<bool> needsSignIn() async {
    if (await getUserKey() == null) return false;
    return await _getUsableAccessToken() == null;
  }

  /// Renews the token at half its lifetime; the server rejects expired tokens.
  Future<void> renewSessionIfStale() async {
    final token = await _getUsableAccessToken();
    if (token == null) return;

    final now = DateTime.now();
    final lastAttempt = _lastRenewAttemptAt;
    if (lastAttempt != null &&
        now.difference(lastAttempt) < const Duration(minutes: 10)) {
      return;
    }

    final expiresAt = _tokenExpiry(token);
    final obtainedMs = int.tryParse(
      await _secureStorage.read(key: _accessTokenObtainedMsKey) ?? '',
    );
    if (expiresAt != null && obtainedMs != null) {
      final obtainedAt = DateTime.fromMillisecondsSinceEpoch(obtainedMs);
      final halfLife = expiresAt.difference(obtainedAt) ~/ 2;
      if (now.isBefore(obtainedAt.add(halfLife))) return;
    }

    _lastRenewAttemptAt = now;
    final renewed = await refreshAccessToken();
    TrackingDiagnostics.log('session renewal ok=${renewed != null}');
  }

  /// Reads the `exp` claim of a JWT without verifying it.
  DateTime? _tokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload is Map<String, dynamic> ? payload['exp'] : null;
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch((exp * 1000).round());
    } catch (_) {
      return null;
    }
  }

  Future<String?> refreshAccessToken() async {
    if (_refreshInFlight != null) {
      return await _refreshInFlight;
    }

    _refreshInFlight = _refreshAccessTokenInternal();

    try {
      return await _refreshInFlight;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<String?> _refreshAccessTokenInternal() async {
    final token = await _getUsableAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final refreshUrl = '${app_config.AppConfig.authEndpoint}/refresh';

    bool isDefinitiveAuthFailure(int statusCode) =>
        statusCode == 401 || statusCode == 403;

    bool isTransientStatus(int statusCode) =>
        statusCode == 408 || statusCode == 429 || statusCode >= 500;

    const int maxAttempts = 2;
    const Duration baseDelay = Duration(milliseconds: 350);
    final rng = Random();

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse(refreshUrl),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
            .timeout(_httpTimeout);

        final sc = response.statusCode;

        if (sc == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final newToken = decoded['access_token'] as String?;

          if (newToken == null || newToken.isEmpty) {
            return null;
          }

          await applyNewAccessToken(newToken);
          debugPrint('[AuthService] refresh success');
          return newToken;
        }

        if (isDefinitiveAuthFailure(sc)) {
          debugPrint('[AuthService] refresh auth failure ($sc)');
          _expireSession();
          return null;
        }

        if (!isTransientStatus(sc)) {
          debugPrint('[AuthService] refresh non-auth HTTP $sc');
          return null;
        }
      } on TimeoutException {
        debugPrint('[AuthService] refresh timeout');
      } on SocketException {
        debugPrint('[AuthService] refresh socket error');
      } on http.ClientException {
        debugPrint('[AuthService] refresh client error');
      } catch (_) {
        debugPrint('[AuthService] refresh unexpected error');
        return null;
      }

      if (attempt < maxAttempts) {
        final pow2 = 1 << (attempt - 1);
        final backoff = Duration(milliseconds: baseDelay.inMilliseconds * pow2);
        final jitterMs = rng.nextInt(200);
        await Future<void>.delayed(backoff + Duration(milliseconds: jitterMs));
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> verifyEmailToken(String token) async {
    try {
      final response = await http
          .post(
            Uri.parse(app_config.AppConfig.verifyEmailUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(_httpTimeout);

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Email verified successfully',
        };
      }

      return {
        'success': false,
        'message': decoded['detail'] ?? 'Email verification failed',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Verification request timed out',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Something went wrong during verification',
      };
    }
  }

  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse(app_config.AppConfig.resendVerificationUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_httpTimeout);

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Verification email sent',
        };
      }

      return {
        'success': false,
        'message': decoded['detail'] ?? 'Could not resend verification email',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Something went wrong while resending verification email',
      };
    }
  }

  Future<PasswordResetRequestResult> requestPasswordReset(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse(app_config.AppConfig.forgotPasswordRequestUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        return PasswordResetRequestResult.ok();
      }

      final detail = _parseFastApiDetail(response.body);

      return PasswordResetRequestResult.fail(
        detail ?? 'Could not start password reset. Please try again.',
      );
    } on TimeoutException {
      return PasswordResetRequestResult.fail(
        'Request timed out. Please try again.',
      );
    } catch (_) {
      return PasswordResetRequestResult.fail(
        'Could not start password reset. Please try again.',
      );
    }
  }

  Future<PasswordUpdateResult> resetForgottenPassword(
    String email,
    String newPassword,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(app_config.AppConfig.forgotPasswordConfirmUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'newPassword': newPassword,
            }),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        return PasswordUpdateResult.ok();
      }

      final detail = _parseFastApiDetail(response.body);

      return PasswordUpdateResult.fail(
        detail ?? 'Could not update password. Please try again.',
      );
    } on TimeoutException {
      return PasswordUpdateResult.fail(
        'Request timed out. Please try again.',
      );
    } catch (_) {
      return PasswordUpdateResult.fail(
        'Could not update password. Please try again.',
      );
    }
  }

  Future<http.Response> authorizedGet(
    Uri uri, {
    Map<String, String>? headers,
    bool retryOnceOn401 = true,
  }) async {
    final token = await _getUsableAccessToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    final effectiveHeaders = <String, String>{
      'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
      'Content-Type': 'application/json',
    };

    var response = await http.get(uri, headers: effectiveHeaders);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _captureAccessTokenFromResponse(response);
      return response;
    }

    if (retryOnceOn401 && response.statusCode == 401) {
      final refreshedToken = await refreshAccessToken();

      if (refreshedToken != null) {
        final retryHeaders = <String, String>{
          'Authorization': 'Bearer $refreshedToken',
          if (headers != null) ...headers,
          'Content-Type': 'application/json',
        };

        response = await http.get(uri, headers: retryHeaders);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          await _captureAccessTokenFromResponse(response);
        }
      }
    }

    return response;
  }

  Future<http.Response> authorizedPost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    bool retryOnceOn401 = true,
  }) async {
    final token = await _getUsableAccessToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    final effectiveHeaders = <String, String>{
      'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      uri,
      headers: effectiveHeaders,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _captureAccessTokenFromResponse(response);
      return response;
    }

    if (retryOnceOn401 && response.statusCode == 401) {
      final refreshedToken = await refreshAccessToken();

      if (refreshedToken != null) {
        final retryHeaders = <String, String>{
          'Authorization': 'Bearer $refreshedToken',
          if (headers != null) ...headers,
          'Content-Type': 'application/json',
        };

        response = await http.post(
          uri,
          headers: retryHeaders,
          body: body,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          await _captureAccessTokenFromResponse(response);
        }
      }
    }

    return response;
  }

  Future<http.Response> authorizedDelete(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    bool retryOnceOn401 = true,
  }) async {
    final token = await _getUsableAccessToken();

    if (token == null) {
      return http.Response('Unauthorized', 401);
    }

    final effectiveHeaders = <String, String>{
      'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
      'Content-Type': 'application/json',
    };

    var response = await http.delete(
      uri,
      headers: effectiveHeaders,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _captureAccessTokenFromResponse(response);
      return response;
    }

    if (retryOnceOn401 && response.statusCode == 401) {
      final refreshedToken = await refreshAccessToken();

      if (refreshedToken != null) {
        final retryHeaders = <String, String>{
          'Authorization': 'Bearer $refreshedToken',
          if (headers != null) ...headers,
          'Content-Type': 'application/json',
        };

        response = await http.delete(
          uri,
          headers: retryHeaders,
          body: body,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          await _captureAccessTokenFromResponse(response);
        }
      }
    }

    return response;
  }

  Future<bool> tryRehydrateSession() async {
    final storedToken = await _readStoredAccessToken();

    if (storedToken == null || storedToken.isEmpty) {
      return false;
    }

    _accessToken = storedToken;

    final meUrl = Uri.parse('${app_config.AppConfig.authEndpoint}/me');
    final http.Response meResponse;
    try {
      meResponse = await authorizedGet(meUrl).timeout(_httpTimeout);
    } catch (_) {
      // Offline: keep the session for the next launch.
      return false;
    }

    if (meResponse.statusCode == 401 || meResponse.statusCode == 403) {
      _expireSession();
      return false;
    }

    if (meResponse.statusCode != 200) {
      return false;
    }

    final me = jsonDecode(meResponse.body) as Map<String, dynamic>;

    _currentUser = User.fromAuthMeJson(me);

    final userKey = _currentUser?.email.trim();
    if (userKey != null && userKey.isNotEmpty) {
      await _persistUserKey(userKey);
    }

    return true;
  }

  Future<DeleteAccountResult> deleteAccount(String password) async {
    if (_currentUser == null) {
      return DeleteAccountResult.fail('You must be signed in.');
    }

    final uri = Uri.parse(app_config.AppConfig.deleteAccountUrl);

    final response = await authorizedDelete(
      uri,
      body: jsonEncode({'password': password}),
    );

    if (response.statusCode == 200) {
      _currentUser = null;
      _accessToken = null;
      _lastAuthError = null;

      await _clearStoredAccessToken();
      await _clearStoredUserKey();
      await clearPendingIsPpeUpdated();

      return DeleteAccountResult.ok();
    }

    final detail = _parseFastApiDetail(response.body);

    if (response.statusCode == 400) {
      return DeleteAccountResult.fail(
        detail ?? 'Wrong password. Please try again.',
      );
    }

    if (response.statusCode == 401) {
      return DeleteAccountResult.fail(
        detail ?? 'Your session expired. Please sign in again.',
      );
    }

    return DeleteAccountResult.fail(
      detail ?? 'Could not delete account. Please try again.',
    );
  }

  Future<bool> setPasswordByEmail(String email, String newPassword) async {
    final result = await resetForgottenPassword(email, newPassword);
    return result.success;
  }

  Future<PasswordUpdateResult> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = await _getUsableAccessToken();

    if (_currentUser == null || token == null || token.isEmpty) {
      return PasswordUpdateResult.fail('You must be signed in.');
    }

    final uri = Uri.parse(app_config.AppConfig.passwordResetUrl);

    final response = await authorizedPost(
      uri,
      body: jsonEncode({
        'password': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = decoded['access_token'] as String?;

        if (newToken != null && newToken.isNotEmpty) {
          await applyNewAccessToken(newToken);
        }

        return PasswordUpdateResult.ok();
      } catch (_) {
        return PasswordUpdateResult.ok();
      }
    }

    final detail = _parseFastApiDetail(response.body);

    if (response.statusCode == 401) {
      return PasswordUpdateResult.fail(
        detail ??
            'Current password is incorrect or your session expired. Please sign in again.',
      );
    }

    return PasswordUpdateResult.fail(
      detail ?? 'Could not update password. Please try again.',
    );
  }
}

String? _parseFastApiDetail(String body) {
  try {
    final decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final detail = decoded['detail'];

    if (detail is String) {
      return detail;
    }

    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;

      if (first is Map && first['msg'] != null) {
        return first['msg'].toString();
      }
    }
  } catch (_) {}

  return null;
}

class PasswordResetRequestResult {
  final bool success;
  final String? message;

  const PasswordResetRequestResult._({
    required this.success,
    this.message,
  });

  factory PasswordResetRequestResult.ok() {
    return const PasswordResetRequestResult._(success: true);
  }

  factory PasswordResetRequestResult.fail([String? message]) {
    return PasswordResetRequestResult._(
      success: false,
      message: message,
    );
  }
}

class PasswordUpdateResult {
  final bool success;
  final String? message;

  const PasswordUpdateResult._({
    required this.success,
    this.message,
  });

  factory PasswordUpdateResult.ok() {
    return const PasswordUpdateResult._(success: true);
  }

  factory PasswordUpdateResult.fail([String? message]) {
    return PasswordUpdateResult._(
      success: false,
      message: message,
    );
  }
}

class DeleteAccountResult {
  final bool success;
  final String? message;

  const DeleteAccountResult._({
    required this.success,
    this.message,
  });

  factory DeleteAccountResult.ok() {
    return const DeleteAccountResult._(success: true);
  }

  factory DeleteAccountResult.fail([String? message]) {
    return DeleteAccountResult._(
      success: false,
      message: message,
    );
  }
}