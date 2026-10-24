import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/app_shell_navigation.dart';
import '../services/location_service.dart';

/// Full-screen prompt until all-the-time location is granted; drives users to GPS Preferences.
class LocationOnboardingPage extends StatefulWidget {
  const LocationOnboardingPage({super.key});

  @override
  State<LocationOnboardingPage> createState() => _LocationOnboardingPageState();
}

class _LocationOnboardingPageState extends State<LocationOnboardingPage> {
  bool _checkingServices = true;
  bool _servicesEnabled = true;
  bool _loadingPermissionHint = true;
  bool _showPermissionGrantedClarifier = false;

  @override
  void initState() {
    super.initState();
    _refreshLocationServices();
    unawaited(_loadPermissionHint());
  }

  Future<void> _loadPermissionHint() async {
    final any = await LocationService().hasAnyLocationPermission();
    if (!mounted) return;
    setState(() {
      _showPermissionGrantedClarifier = any;
      _loadingPermissionHint = false;
    });
  }

  Future<void> _refreshLocationServices() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    setState(() {
      _servicesEnabled = enabled;
      _checkingServices = false;
    });
  }

  Future<void> _completeAndPop({SnackBar? snackBar}) async {
    final messenger =
        snackBar != null ? ScaffoldMessenger.of(context) : null;
    if (!mounted) return;
    Navigator.of(context).pop();
    if (snackBar != null && messenger != null) {
      messenger.showSnackBar(snackBar);
    }
  }

  Future<void> _onOpenLocationSettings() async {
    await Geolocator.openLocationSettings();
    await _refreshLocationServices();
  }

  void _onOpenGpsPreferences() {
    if (!mounted) return;
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppShellNavigation.openGpsPreferences();
    });
  }

  void _onNotNow() {
    unawaited(
      _completeAndPop(
        snackBar: const SnackBar(
          content: Text(
            'Background location is still off. When you\'re ready, go to GPS '
            'Preferences and tap Enable all-the-time location.',
          ),
        ),
      ),
    );
  }

  Widget _bulletLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finish enabling background GPS'),
        ),
        body: SafeArea(
          child: _checkingServices
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We need all-the-time location so this app can record your '
                        'position on a schedule even when it’s closed or not on '
                        'screen—for safety history during incidents. “While using '
                        'the app” alone is not enough for that; the system keeps '
                        'those as two separate permissions.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The research study records your location regularly, including '
                        'when the app is in the background. iOS and Android only allow '
                        'this when location access is set to Always (iOS) or Allow all '
                        'the time (Android). With "While Using the App", recording '
                        'stops when the app is not on screen. You can change this at any '
                        'time in your device settings.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.42,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Why we need this',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 10),
                      _bulletLine(
                        'Why: Location is recorded regularly so researchers can study '
                        'firefighter exposure during shifts.',
                      ),
                      _bulletLine(
                        'Why not “only while using”: The OS does not treat that as '
                        'permission to keep locating you when the app isn’t active.',
                      ),
                      _bulletLine(
                        'How to change it: Open GPS Preferences and tap Enable '
                        'all-the-time location. The choice is yours.',
                      ),
                      if (!_loadingPermissionHint &&
                          _showPermissionGrantedClarifier) ...[
                        const SizedBox(height: 12),
                        Text(
                          'You may already see location allowed—that often means '
                          'only while the app is open. All-the-time is a separate '
                          'switch required for background tracking.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    height: 1.45,
                                    color: Colors.blueGrey.shade800,
                                  ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Text(
                        'Background recording is available when location access is '
                        'set to Always (iOS) or Allow all the time (Android). You can '
                        'change this in Settings → GPS Preferences.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.42,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 28),
                      if (!_servicesEnabled) ...[
                        Text(
                          'Device location is turned off. Turn it on to continue.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _onOpenLocationSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('Open location settings'),
                        ),
                        const SizedBox(height: 20),
                      ],
                      FilledButton.icon(
                        onPressed: !_servicesEnabled ? null : _onOpenGpsPreferences,
                        icon: const Icon(Icons.settings_suggest_outlined),
                        label: const Text('Open GPS Preferences'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _onNotNow,
                        child: const Text('Not now'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
