import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../config/app_config.dart';
import 'location_storage_service.dart';
import 'auth_service.dart';
import 'tracking_diagnostics.dart';

class LocationSyncService {
  static final LocationSyncService _instance =
      LocationSyncService._internal();

  factory LocationSyncService() => _instance;

  LocationSyncService._internal();

  /// Uploads all stored entries and removes them on success. Returns true if accepted.
  Future<bool> exportAllAndClearOnSuccess() async {
    final userKey = await AuthService().getUserKey();
    if (userKey == null) return false;

    final storage = LocationStorageService();
    final entries = await storage.getAllEntries(userKey: userKey);

    if (entries.isEmpty) {
      debugPrint('No location entries to export.');
      return false;
    }

    final payload = jsonEncode(
      entries.map((e) => e.toApiMap()).toList(),
    );

    try {
      final uri = Uri.parse(AppConfig.locationUploadUrl);
      // Time-limited so a stalled upload cannot block later uploads.
      final response = await AuthService()
          .authorizedPost(uri, body: payload)
          .timeout(const Duration(seconds: 60));

      TrackingDiagnostics.log(
        'export count=${entries.length} status=${response.statusCode}',
      );
      if (response.statusCode != 201) return false;

      final maxId = entries
          .map((e) => e.id)
          .whereType<int>()
          .fold<int>(0, (a, b) => a > b ? a : b);
      await storage.deleteThrough(maxId, userKey: userKey);
      return true;
    } catch (e) {
      // Will retry on a later run.
      TrackingDiagnostics.log('export failed: ${e.runtimeType}');
      return false;
    }
  }
}
