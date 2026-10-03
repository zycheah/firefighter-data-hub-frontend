import 'dart:async';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import 'auth_service.dart';
import 'location_preferences_service.dart';
import 'location_service.dart';
import 'location_storage_service.dart';
import 'location_sync_service.dart';

/// Top-level callback for [FlutterForegroundTask.startService]. Must stay top-level.
@pragma('vm:entry-point')
void locationTrackingTaskCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTrackingTaskHandler());
}

/// Runs in the foreground service isolate: periodic GPS capture and batched
/// backend export (export cadence is separate from capture, via preferences).
class LocationTrackingTaskHandler extends TaskHandler {
  late DateTime _lastExportAt;

  Future<void> _runCaptureAndMaybeExport() async {
    await LocationService()
        .captureAndStoreCurrentLocation(allowRequestPermission: false);

    final prefs = LocationPreferencesService();
    final exportIntervalMinutes = await prefs.getExportIntervalMinutes();
    final now = DateTime.now();
    if (now.difference(_lastExportAt) <
        Duration(minutes: exportIntervalMinutes)) {
      return;
    }

    final userKey = await AuthService().getUserKey();
    if (userKey == null) return;

    final storage = LocationStorageService();
    final before = await storage.getAllEntries(userKey: userKey);
    if (before.isEmpty) return;

    await LocationSyncService().exportAllAndClearOnSuccess();

    final after = await storage.getAllEntries(userKey: userKey);
    if (after.isEmpty) {
      final successAt = DateTime.now();
      _lastExportAt = successAt;
      await prefs.setLastLocationExportMs(successAt.millisecondsSinceEpoch);
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    DartPluginRegistrant.ensureInitialized();
    final prefs = LocationPreferencesService();
    final persisted = await prefs.getLastLocationExportMs();
    if (persisted != null) {
      _lastExportAt = DateTime.fromMillisecondsSinceEpoch(persisted);
    } else {
      _lastExportAt = DateTime.now();
    }
    await _runCaptureAndMaybeExport();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    unawaited(_runCaptureAndMaybeExport());
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

class LocationBackgroundService {
  LocationBackgroundService._internal();

  static final LocationBackgroundService _instance =
      LocationBackgroundService._internal();

  factory LocationBackgroundService() => _instance;

  static const String _notificationTitle = 'Firefighter Safety Tracker';
  static const String _notificationText =
      'Recording your location for safety monitoring';

  Timer? _foregroundOnlyTimer;
  bool _foregroundOnlyRunInProgress = false;
  DateTime? _foregroundOnlyLastExportAt;

  /// Initializes [FlutterForegroundTask] static options (safe to call repeatedly).
  static void applyForegroundTaskInit(int intervalMinutes) {
    final intervalMs = intervalMinutes.clamp(1, 24 * 60) * 60 * 1000;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_tracking_channel',
        channelName: 'Location Tracking',
        channelDescription:
            'Shows while your location is recorded periodically for safety.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(intervalMs),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
      ),
    );
  }

  /// Applies tracking and export interval preferences to foreground scheduling.
  Future<void> scheduleFromPreferences() async {
    final prefs = LocationPreferencesService();
    final isEnabled = await prefs.getIsTrackingEnabled();
    final intervalMinutes = await prefs.getTrackingIntervalMinutes();
    await prefs.getExportIntervalMinutes();

    if (!isEnabled) {
      await stopForegroundOnlyTracking();
      await _stopForegroundServiceIfRunning();
      return;
    }

    await updateScheduling(
      isEnabled: true,
      intervalMinutes: intervalMinutes,
    );
  }

  /// Resyncs tracking based on current preferences and OS permission state.
  ///
  /// - If permission is **Always**, uses the foreground-task scheduler (works while app is closed).
  /// - If permission is **While In Use**, runs a foreground-only periodic capture loop (app open).
  /// - If permission is denied/restricted, stops any running tracking.
  Future<void> resyncTrackingFromPreferences() async {
    final prefs = LocationPreferencesService();
    final isEnabled = await prefs.getIsTrackingEnabled();
    final intervalMinutes = await prefs.getTrackingIntervalMinutes();
    await prefs.getExportIntervalMinutes();

    if (!isEnabled) {
      debugPrint('[LocationBackgroundService] tracking disabled by preference.');
      await stopForegroundOnlyTracking();
      await _stopForegroundServiceIfRunning();
      return;
    }

    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    final permission = await Geolocator.checkPermission();
    debugPrint('[LocationBackgroundService] permission: $permission');

    if (permission == LocationPermission.always) {
      await stopForegroundOnlyTracking();
      await updateScheduling(isEnabled: true, intervalMinutes: intervalMinutes);
      return;
    }

    if (permission == LocationPermission.whileInUse) {
      // Ensure we aren't running the background scheduler without Always.
      await _stopForegroundServiceIfRunning();
      await startForegroundOnlyTracking(intervalMinutes: intervalMinutes);
      return;
    }

    // denied / deniedForever / unableToDetermine etc.
    await stopForegroundOnlyTracking();
    await _stopForegroundServiceIfRunning();
  }

  Future<void> updateScheduling({
    required bool isEnabled,
    required int intervalMinutes,
  }) async {
    if (!isEnabled) {
      await stopForegroundOnlyTracking();
      await _stopForegroundServiceIfRunning();
      return;
    }

    final prefs = LocationPreferencesService();
    await prefs.getExportIntervalMinutes();

    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    applyForegroundTaskInit(intervalMinutes);

    if (!await LocationService().hasAllTheTimeLocationAccess()) {
      debugPrint(
        'LocationBackgroundService: skipping foreground tracking — '
        'all-the-time location not granted.',
      );
      return;
    }

    await _ensureAndroidNotificationPermission();

    final running = await FlutterForegroundTask.isRunningService;
    if (running) {
      await FlutterForegroundTask.updateService(
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(
            intervalMinutes.clamp(1, 24 * 60) * 60 * 1000,
          ),
          autoRunOnBoot: true,
          autoRunOnMyPackageReplaced: true,
          allowWakeLock: true,
        ),
        notificationTitle: _notificationTitle,
        notificationText: _notificationText,
      );
      return;
    }

    final result = await FlutterForegroundTask.startService(
      serviceTypes: const [ForegroundServiceTypes.location],
      notificationTitle: _notificationTitle,
      notificationText: _notificationText,
      callback: locationTrackingTaskCallback,
    );
    if (result is ServiceRequestFailure) {
      debugPrint(
        'LocationBackgroundService: startService failed: ${result.error}',
      );
    }
  }

  /// Call after the user may have granted all-the-time location so periodic
  /// tracking matches current preferences.
  Future<void> syncSchedulingFromPreferencesIfAllTheTimeAccess() async {
    if (!await LocationService().hasAllTheTimeLocationAccess()) return;
    final prefs = LocationPreferencesService();
    final isEnabled = await prefs.getIsTrackingEnabled();
    final interval = await prefs.getTrackingIntervalMinutes();
    await prefs.getExportIntervalMinutes();
    await updateScheduling(
      isEnabled: isEnabled,
      intervalMinutes: interval,
    );
  }

  /// Starts foreground location tracking if the tracking preference is enabled.
  Future<void> startTracking() async {
    final prefs = LocationPreferencesService();
    if (!await prefs.getIsTrackingEnabled()) return;
    final intervalMinutes = await prefs.getTrackingIntervalMinutes();
    await prefs.getExportIntervalMinutes();
    await updateScheduling(
      isEnabled: true,
      intervalMinutes: intervalMinutes,
    );
  }

  /// Stops the foreground location service (capture and export stop with it).
  Future<void> stopTracking() async {
    await stopForegroundOnlyTracking();
    await _stopForegroundServiceIfRunning();
  }

  Future<void> startForegroundOnlyTracking({
    required int intervalMinutes,
  }) async {
    final interval = Duration(minutes: intervalMinutes.clamp(1, 24 * 60));
    debugPrint(
      '[LocationBackgroundService] starting foreground-only tracking '
      '(every ${interval.inMinutes}m)',
    );

    _foregroundOnlyTimer?.cancel();

    final prefs = LocationPreferencesService();
    final persisted = await prefs.getLastLocationExportMs();
    _foregroundOnlyLastExportAt = persisted != null
        ? DateTime.fromMillisecondsSinceEpoch(persisted)
        : DateTime.now();

    Future<void> tick() async {
      if (_foregroundOnlyRunInProgress) return;
      _foregroundOnlyRunInProgress = true;
      try {
        await _runCaptureAndMaybeExportForegroundOnly();
      } finally {
        _foregroundOnlyRunInProgress = false;
      }
    }

    // Run immediately once, then periodically.
    unawaited(tick());
    _foregroundOnlyTimer = Timer.periodic(interval, (_) => unawaited(tick()));
  }

  Future<void> stopForegroundOnlyTracking() async {
    if (_foregroundOnlyTimer == null) return;
    debugPrint('[LocationBackgroundService] stopping foreground-only tracking');
    _foregroundOnlyTimer?.cancel();
    _foregroundOnlyTimer = null;
    _foregroundOnlyRunInProgress = false;
  }

  Future<void> _runCaptureAndMaybeExportForegroundOnly() async {
    await LocationService()
        .captureAndStoreCurrentLocation(allowRequestPermission: false);

    final prefs = LocationPreferencesService();
    final exportIntervalMinutes = await prefs.getExportIntervalMinutes();
    final now = DateTime.now();
    final last = _foregroundOnlyLastExportAt ?? now;
    if (now.difference(last) < Duration(minutes: exportIntervalMinutes)) {
      return;
    }

    final userKey = await AuthService().getUserKey();
    if (userKey == null) return;

    final storage = LocationStorageService();
    final before = await storage.getAllEntries(userKey: userKey);
    if (before.isEmpty) return;

    await LocationSyncService().exportAllAndClearOnSuccess();

    final after = await storage.getAllEntries(userKey: userKey);
    if (after.isEmpty) {
      final successAt = DateTime.now();
      _foregroundOnlyLastExportAt = successAt;
      await prefs.setLastLocationExportMs(successAt.millisecondsSinceEpoch);
    }
  }

  static Future<void> _stopForegroundServiceIfRunning() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    if (!await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.stopService();
  }

  static Future<void> _ensureAndroidNotificationPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final permission = await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }
}
