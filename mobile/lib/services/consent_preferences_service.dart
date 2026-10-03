import 'package:shared_preferences/shared_preferences.dart';

class ConsentPreferencesService {
  static final ConsentPreferencesService _instance =
      ConsentPreferencesService._internal();

  factory ConsentPreferencesService() => _instance;

  ConsentPreferencesService._internal();

  static const String _userConsentAcceptedKey = 'user_consent_accepted';
  static const String _locationConsentAcceptedKey = 'location_consent_accepted';

  Future<bool> getUserConsentAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userConsentAcceptedKey) ?? false;
  }

  Future<void> setUserConsentAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userConsentAcceptedKey, accepted);
  }

  Future<bool> getLocationConsentAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationConsentAcceptedKey) ?? false;
  }

  Future<void> setLocationConsentAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationConsentAcceptedKey, accepted);
  }
}

