import 'package:firefighter_safety_data_hub/screens/login_page.dart';
import 'package:firefighter_safety_data_hub/screens/main_navigation.dart';
import 'package:firefighter_safety_data_hub/screens/user_consent_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'services/auth_service.dart';
import 'services/consent_preferences_service.dart';
import 'services/location_background_service.dart';
import 'services/location_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mobile-only background services.
  // Skip these on web so Chrome can render the UI.
  if (!kIsWeb) {
    FlutterForegroundTask.initCommunicationPort();

    final prefs = LocationPreferencesService();
    final intervalMinutes = await prefs.getTrackingIntervalMinutes();

    // Keep partner's export interval preference initialization.
    await prefs.getExportIntervalMinutes();

    LocationBackgroundService.applyForegroundTaskInit(intervalMinutes);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firefighter Safety Data Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const _SessionStartup(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Restores a stored session so returning users skip login; otherwise shows [LoginPage].
class _SessionStartup extends StatefulWidget {
  const _SessionStartup();

  @override
  State<_SessionStartup> createState() => _SessionStartupState();
}

class _SessionStartupState extends State<_SessionStartup> {
  Widget? _home;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final accepted = await ConsentPreferencesService().getUserConsentAccepted();
    if (!mounted) return;

    if (!accepted) {
      setState(() {
        _home = UserConsentPage(onAccepted: _restore);
      });
      return;
    }

    await _restore();
  }

  Future<void> _restore() async {
    if (!mounted) return;

    setState(() {
      _home = null;
    });

    final ok = await AuthService().tryRehydrateSession();

    if (!mounted) return;

    // Only allow tracking to (re)start when authenticated.
    if (ok && !kIsWeb) {
      await LocationBackgroundService().resyncTrackingFromPreferences();
    }

    setState(() {
      _home = ok ? const MainNavigation() : const LoginPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _home ??
        const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
  }
}