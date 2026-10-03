import 'package:shared_preferences/shared_preferences.dart';

const _isPpeUpdatedPendingKey = 'is_ppe_updated_pending';
const _pendingPpeEventIdKey = 'pending_ppe_event_id';

Future<bool> getPendingIsPpeUpdated() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_isPpeUpdatedPendingKey) ?? false;
}

Future<void> setPendingIsPpeUpdated(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_isPpeUpdatedPendingKey, value);
}

Future<void> clearPendingIsPpeUpdated() async {
  await setPendingIsPpeUpdated(false);
}

Future<void> setPendingPpeEventId(String eventId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_pendingPpeEventIdKey, eventId);
}

Future<String?> getPendingPpeEventId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_pendingPpeEventIdKey);
}

Future<void> clearPendingPpeEventId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_pendingPpeEventIdKey);
}