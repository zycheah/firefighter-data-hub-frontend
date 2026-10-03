import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_config.dart' as app_config;
import '../models/location_entry_model.dart';
import '../screens/location_consent_page.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/location_storage_service.dart';
import '../services/location_sync_service.dart';

class LocationHistoryPage extends StatefulWidget {
  const LocationHistoryPage({super.key});

  @override
  State<LocationHistoryPage> createState() => _LocationHistoryPageState();
}

class _LocationHistoryPageState extends State<LocationHistoryPage> {
  late Future<List<LocationEntry>> _entriesFuture;
  bool _capturingLocation = false;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
  }

  Future<List<LocationEntry>> _loadEntries() async {
    final backendEntries = await _loadBackendEntries();

    if (backendEntries.isNotEmpty) {
      return backendEntries;
    }

    final userKey = await AuthService().getUserKey();

    if (userKey == null) {
      return [];
    }

    return LocationStorageService().getLastEntries(10, userKey: userKey);
  }

  Future<List<LocationEntry>> _loadBackendEntries() async {
    try {
      final response = await AuthService().authorizedGet(
        Uri.parse(app_config.AppConfig.locationHistoryUrl),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      final List<dynamic> rows;

      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['results'] is List) {
        rows = decoded['results'] as List<dynamic>;
      } else {
        return [];
      }

      return rows
          .whereType<Map<String, dynamic>>()
          .map(_locationEntryFromApi)
          .toList();
    } catch (_) {
      return [];
    }
  }

  LocationEntry _locationEntryFromApi(Map<String, dynamic> json) {
    final timestampValue =
        json['locationTimestamp'] ?? json['timestamp'] ?? json['recorded_at'];

    return LocationEntry(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: timestampValue != null
          ? DateTime.parse(timestampValue.toString())
          : DateTime.now().toUtc(),
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : json['accuracy_m'] != null
              ? (json['accuracy_m'] as num).toDouble()
              : null,
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _entriesFuture = _loadEntries();
    });
  }

  Future<void> _captureCurrentLocation() async {
    if (_capturingLocation) return;

    setState(() {
      _capturingLocation = true;
    });

    try {
      final userKey = await AuthService().getUserKey();

      if (userKey == null) return;
      if (!mounted) return;

      final hasOsPermission = await LocationService().hasAnyLocationPermission();

      bool allowRequestPermission = false;

      if (!hasOsPermission) {
        if (!mounted) return;

        final accepted = await showLocationConsentIfNeeded(
          context,
          hasOsLocationPermission: () =>
              LocationService().hasAnyLocationPermission(),
        );

        if (!accepted) return;

        allowRequestPermission = true;
      }

      final ok = await LocationService().captureAndStoreCurrentLocation(
        allowRequestPermission: allowRequestPermission,
      );

      if (!mounted) return;

      if (ok) {
        await LocationSyncService().exportAllAndClearOnSuccess();
        await _refresh();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current location saved')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not get location. Check permissions and that location services are on.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _capturingLocation = false;
        });
      }
    }
  }

  Future<void> _showClearConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all location history?'),
        content: const Text(
          'This clears only location history stored locally on this device. '
          'Server-side RDS records are not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Clear local'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final userKey = await AuthService().getUserKey();

      if (userKey == null) return;

      await LocationStorageService().clearAll(userKey: userKey);

      if (!context.mounted) return;

      await _refresh();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local location history cleared')),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not clear local location history'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear local location history',
            onPressed: () => _showClearConfirmation(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _capturingLocation ? null : _captureCurrentLocation,
        tooltip: 'Save current location',
        child: _capturingLocation
            ? SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.my_location),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<LocationEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Failed to load location history'),
              );
            }

            final entries = snapshot.data ?? [];

            if (entries.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                children: const [
                  SizedBox(height: 48),
                  Text(
                    'No location entries yet. Tap the location button to save your current position.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            Widget entryCard(LocationEntry entry) {
              final timestampLocal = entry.timestamp.toLocal();

              final subtitle = StringBuffer()
                ..write(
                  'Lat: ${entry.latitude.toStringAsFixed(5)}, '
                  'Lng: ${entry.longitude.toStringAsFixed(5)}',
                );

              if (entry.accuracy != null) {
                subtitle.write(
                  '\nAccuracy: ${entry.accuracy!.toStringAsFixed(1)} m',
                );
              }

              if (entry.altitude != null) {
                subtitle.write(
                  '\nAltitude: ${entry.altitude!.toStringAsFixed(1)} m',
                );
              }

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(dateFormat.format(timestampLocal)),
                  subtitle: Text(subtitle.toString()),
                ),
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Showing latest ${entries.length} location record${entries.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  entryCard(entries[i]),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}