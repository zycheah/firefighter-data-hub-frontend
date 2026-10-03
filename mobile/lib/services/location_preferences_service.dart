import 'package:shared_preferences/shared_preferences.dart';

class LocationPreferencesService {
  static final LocationPreferencesService _instance =
      LocationPreferencesService._internal();

  factory LocationPreferencesService() => _instance;

  LocationPreferencesService._internal();

  static const _trackingEnabledKey = 'location_tracking_enabled';
  static const _trackingIntervalMinutesKey =
      'location_tracking_interval_minutes';
  static const _exportIntervalMinutesKey = 'location_export_interval_minutes';
  static const _lastLocationExportMsKey = 'last_location_export_ms';

  /// Default settings: tracking enabled, every 20 minutes.
  static const int defaultTrackingIntervalMinutes = 20;
  static const bool defaultTrackingEnabled = true;

  /// Default batched export to backend while the foreground service runs.
  /// *********************************************************************************
  static const int defaultExportIntervalMinutes = 120+5;

  Future<bool> getIsTrackingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trackingEnabledKey) ?? defaultTrackingEnabled;
  }

  Future<void> setIsTrackingEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trackingEnabledKey, value);
  }

  Future<int> getTrackingIntervalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_trackingIntervalMinutesKey) ??
        defaultTrackingIntervalMinutes;
  }

  Future<void> setTrackingIntervalMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _trackingIntervalMinutesKey,
      minutes.clamp(1, 24 * 60),
    );
  }

  Future<int> getExportIntervalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_exportIntervalMinutesKey) ??
        defaultExportIntervalMinutes;
    return v.clamp(1, 24 * 60);
  }

  Future<void> setExportIntervalMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _exportIntervalMinutesKey,
      minutes.clamp(1, 24 * 60),
    );
  }

  Future<int?> getLastLocationExportMs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastLocationExportMsKey);
  }

  Future<void> setLastLocationExportMs(int ms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLocationExportMsKey, ms);
  }
}
