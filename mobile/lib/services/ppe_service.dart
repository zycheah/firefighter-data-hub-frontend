import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/ppe_model.dart';
import 'auth_service.dart';
import 'ppe_is_updated_storage.dart' as ppeStorage;

const _ppePrefsKey = 'ppe_form_snapshot';

class PPEService {
  static final PPEService _instance = PPEService._internal();
  factory PPEService() => _instance;
  PPEService._internal();

  final AuthService _auth = AuthService();

  PPE? _currentPPE;

  PPE? getCurrentPPE() => _currentPPE;

  Future<PPE?> loadPersistedPPE() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ppePrefsKey);

    if (raw == null || raw.isEmpty) {
      _currentPPE = null;
      return null;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ppe = PPE.fromJson(map);
      _currentPPE = ppe;
      return ppe;
    } catch (_) {
      _currentPPE = null;
      return null;
    }
  }

  Future<void> _saveToPreferences(PPE ppe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ppePrefsKey, jsonEncode(ppe.toJson()));
  }

  Future<bool> getIsPpeUpdatedPending() =>
      ppeStorage.getPendingIsPpeUpdated();

  Future<void> setIsPpeUpdatedPending(bool value) =>
      ppeStorage.setPendingIsPpeUpdated(value);

  Future<void> setPendingPpeEventId(String eventId) =>
      ppeStorage.setPendingPpeEventId(eventId);

  Future<String?> getPendingPpeEventId() =>
      ppeStorage.getPendingPpeEventId();

  Future<void> clearPendingPpeEventId() =>
      ppeStorage.clearPendingPpeEventId();

  Future<void> savePPE(PPE ppe) async {
    final withTime = PPE(
      eventId: ppe.eventId,
      helmetId: ppe.helmetId,
      hoodId: ppe.hoodId,
      faceMaskId: ppe.faceMaskId,
      scbaId: ppe.scbaId,
      gloveId: ppe.gloveId,
      bootId: ppe.bootId,
      turnoutCoat: ppe.turnoutCoat,
      turnoutPants: ppe.turnoutPants,
      lastUpdated: DateTime.now(),
    );

    _currentPPE = withTime;
    await _saveToPreferences(withTime);
  }

  Future<bool> submitPPEToBackend(PPE ppe) async {
    final uri = Uri.parse(AppConfig.ppeSubmitUrl);
    final pending = await getIsPpeUpdatedPending();
    final pendingEventId = await getPendingPpeEventId();

    final ppeWithEvent = PPE(
      eventId: pendingEventId,
      helmetId: ppe.helmetId,
      hoodId: ppe.hoodId,
      faceMaskId: ppe.faceMaskId,
      scbaId: ppe.scbaId,
      gloveId: ppe.gloveId,
      bootId: ppe.bootId,
      turnoutCoat: ppe.turnoutCoat,
      turnoutPants: ppe.turnoutPants,
      lastUpdated: ppe.lastUpdated,
    );

    final response = await _auth.authorizedPost(
      uri,
      body: jsonEncode(ppeWithEvent.toApiJson(isPpeUpdated: pending)),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }

    await savePPE(ppeWithEvent);
    await ppeStorage.clearPendingIsPpeUpdated();
    await clearPendingPpeEventId();

    return true;
  }
}