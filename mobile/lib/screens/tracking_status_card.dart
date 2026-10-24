import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/location_preferences_service.dart';
import '../services/location_service.dart';

/// Shows whether background location recording is running and when the last
/// location was recorded.
class TrackingStatusCard extends StatefulWidget {
  const TrackingStatusCard({super.key});

  @override
  State<TrackingStatusCard> createState() => _TrackingStatusCardState();
}

class _TrackingStatusCardState extends State<TrackingStatusCard>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  bool _loaded = false;
  bool _enabled = false;
  bool _alwaysAccess = false;
  DateTime? _lastRecordedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final prefs = LocationPreferencesService();
    final enabled = await prefs.getIsTrackingEnabled();
    final always = await LocationService().hasAllTheTimeLocationAccess();
    final lastMs = await prefs.getLastLocationCaptureMs();
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _enabled = enabled;
      _alwaysAccess = always;
      _lastRecordedAt =
          lastMs == null ? null : DateTime.fromMillisecondsSinceEpoch(lastMs);
    });
  }

  String _lastRecordedText() {
    final last = _lastRecordedAt;
    if (last == null) return 'No location recorded yet.';
    final minutes = DateTime.now().difference(last).inMinutes;
    if (minutes < 1) return 'Last location recorded just now.';
    if (minutes < 60) return 'Last location recorded $minutes min ago.';
    final hours = minutes ~/ 60;
    return 'Last location recorded $hours h ago.';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final String title;
    final String detail;
    final Color color;
    final bool showSettingsLink;
    if (!_enabled) {
      title = 'Location recording: Off';
      detail = 'Recording is switched off in Settings → GPS Preferences.';
      color = Colors.grey;
      showSettingsLink = false;
    } else if (!_alwaysAccess) {
      title = 'Location recording: Paused';
      detail = 'Recording in the background needs location access set to '
          'Always. ${_lastRecordedText()}';
      color = Colors.orange;
      showSettingsLink = true;
    } else {
      title = 'Location recording: On';
      detail = _lastRecordedText();
      color = Colors.green;
      showSettingsLink = false;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (showSettingsLink)
                    TextButton(
                      onPressed: openAppSettings,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Open Settings'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
