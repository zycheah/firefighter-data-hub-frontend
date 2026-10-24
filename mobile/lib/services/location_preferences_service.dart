import 'package:shared_preferences/shared_preferences.dart';

class LocationPreferencesService {
  static final LocationPreferencesService _instance =
      LocationPreferencesService._internal();

  factory LocationPreferencesService() => _instance;

  LocationPreferencesService._internal();

  static const _trackingEnabledKey = 'location_tracking_enabled';
  static const _exportIntervalMinutesKey = 'location_export_interval_minutes';
  static const _lastLocationExportMsKey = 'last_location_export_ms';
  static const _lastLocationCaptureMsKey = 'last_location_capture_ms';

  /// Location is recorded every minute; the interval is not user-configurable.
  static const int defaultTrackingIntervalMinutes = 1;
  static const bool defaultTrackingEnabled = true;

  /// Default batched export to backend while the foreground service runs.
  /// *********************************************************************************
  static const int defaultExportIntervalMinutes = 15;

  Future<bool> getIsTrackingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trackingEnabledKey) ?? defaultTrackingEnabled;
  }

  Future<void> setIsTrackingEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trackingEnabledKey, value);
  }

  /// Fixed interval; any value saved by earlier app versions is ignored.
  Future<int> getTrackingIntervalMinutes() async =>
      defaultTrackingIntervalMinutes;

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

  Future<int?> getLastLocationCaptureMs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getInt(_lastLocationCaptureMsKey);
  }

  Future<void> setLastLocationCaptureMs(int ms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLocationCaptureMsKey, ms);
  }

  Future<void> setLastLocationExportMs(int ms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLocationExportMsKey, ms);
  }
}
