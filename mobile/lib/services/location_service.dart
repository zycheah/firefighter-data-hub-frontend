import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/location_entry_model.dart';
import 'auth_service.dart';
import 'location_storage_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  Future<bool> _hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// True when the OS already granted any location permission (While In Use or Always).
  /// This does not request permission and does not show dialogs.
  Future<bool> hasAnyLocationPermission() async {
    return _hasLocationPermission();
  }

  /// Request permission from the user in the foreground.
  /// Returns true if permission is granted.
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // We do not attempt to open settings automatically; user can do it manually.
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Used from background tasks – does not pop permission dialogs.
  Future<bool> hasLocationPermissionForBackground() async {
    return _hasLocationPermission();
  }

  /// Whether the OS granted **all-the-time** location (iOS "Always", Android background).
  /// This is what you need for periodic GPS while the app is not open.
  Future<bool> hasAllTheTimeLocationAccess() async {
    if (kIsWeb) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always;
  }

  /// Requests **When In Use** first, then **Always / all the time** (background).
  ///
  /// Geolocator alone only requests When In Use on iOS when both location plist strings exist,
  /// so background tracking never gets "Always" without this second step.
  ///
  /// Call only while the app is in the foreground (shows system dialogs).
  Future<bool> requestAllTheTimeLocationAccess() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    if (!await Geolocator.isLocationServiceEnabled()) return false;

    debugPrint(
      '[LocationService] locationWhenInUse BEFORE: '
      '${await Permission.locationWhenInUse.status}',
    );
    var whenInUse = await Permission.locationWhenInUse.status;
    if (!whenInUse.isGranted) {
      whenInUse = await Permission.locationWhenInUse.request();
    }
    debugPrint('[LocationService] locationWhenInUse AFTER: $whenInUse');
    if (!whenInUse.isGranted) return false;

    debugPrint(
      '[LocationService] locationAlways BEFORE: '
      '${await Permission.locationAlways.status}',
    );
    var always = await Permission.locationAlways.status;
    if (always.isGranted) return true;

    always = await Permission.locationAlways.request();
    debugPrint('[LocationService] locationAlways AFTER: $always');
    if (always.isGranted) return true;

    final geo = await Geolocator.checkPermission();
    return geo == LocationPermission.always;
  }

  /// Capture the current position and store it in SQLite.
  /// If [allowRequestPermission] is false, this will not show permission dialogs.
  /// Returns true if a row was written, false if permission was denied or lookup failed.
  Future<bool> captureAndStoreCurrentLocation({
    bool allowRequestPermission = false,
  }) async {
    final userKey = await AuthService().getUserKey();
    if (userKey == null) {
      // Logged out (or session not available): do not store anything.
      return false;
    }

    bool hasPermission = await _hasLocationPermission();

    if (!hasPermission && allowRequestPermission) {
      hasPermission = await requestLocationPermission();
    }

    if (!hasPermission) {
      return false;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint(
        'The Location details: ${position.latitude} ${position.longitude}',
      );

      final entry = LocationEntry(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now().toUtc(),
        accuracy: position.accuracy,
        altitude: position.altitude,
      );

      await LocationStorageService().insert(entry, userKey: userKey);
      return true;
    } catch (e) {
      // Background jobs should not crash the app; callers may inspect the bool.
      return false;
    }
  }
}

