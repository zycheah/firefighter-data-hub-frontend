import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../config/app_config.dart';
import 'location_storage_service.dart';
import 'auth_service.dart';

class LocationSyncService {
  static final LocationSyncService _instance =
      LocationSyncService._internal();

  factory LocationSyncService() => _instance;

  LocationSyncService._internal();

  Future<void> exportAllAndClearOnSuccess() async {
    final userKey = await AuthService().getUserKey();
    if (userKey == null) return;

    final storage = LocationStorageService();
    final entries = await storage.getAllEntries(userKey: userKey);

    if (entries.isEmpty) {
      debugPrint('No location entries to export.');
      return;
    }

    final payload = jsonEncode(
      entries.map((e) => e.toApiMap()).toList(),
    );

    try {
      final uri = Uri.parse(AppConfig.locationUploadUrl);
      final response = await AuthService().authorizedPost(
        uri,
        body: payload,
      );

      if (response.statusCode == 201) {
        await storage.clearAll(userKey: userKey);
      }
    } catch (_) {
      // Ignore errors – will retry on the next scheduled run.
    }
  }
}

