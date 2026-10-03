import 'dart:async';

import 'package:flutter/material.dart';

import '../services/app_shell_navigation.dart';
import '../services/location_background_service.dart';
import '../services/location_service.dart';
import 'glove_support_tab.dart';
import 'home_tab.dart';
import 'location_history_page.dart';
import 'location_onboarding_page.dart';
import 'log_event_tab.dart';
import 'ppe_page.dart';
import 'settings_page.dart';
import 'smoke_sampler_page.dart';
import 'location_consent_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _stackIndex = 0;
  bool _locationPromptRouteOpen = false;

  final GlobalKey<PPEPageState> _ppePageKey = GlobalKey<PPEPageState>();
  final GlobalKey<SettingsPageState> _settingsPageKey =
      GlobalKey<SettingsPageState>();

  void _schedulePpePendingSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ppePageKey.currentState?.syncPendingBannerFromStorage();
    });
  }

  @override
  void initState() {
    super.initState();
    AppShellNavigation.registerGoToPpeTab(() {
      if (!mounted) return;
      setState(() {
        _currentIndex = 1;
        _stackIndex = 3;
      });
      _schedulePpePendingSync();
    });
    AppShellNavigation.registerOpenGpsPreferences(_openSettingsGpsPreferences);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_promptAlwaysLocationIfNeeded());
    });
  }

  @override
  void dispose() {
    AppShellNavigation.unregister();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _openSettingsGpsPreferences() {
    if (!mounted) return;
    setState(() {
      _currentIndex = 2;
      _stackIndex = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settingsPageKey.currentState?.jumpToGpsPreferencesAndFocusEnable();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(() async {
        await _promptAlwaysLocationIfNeeded();
        await LocationBackgroundService().resyncTrackingFromPreferences();
      }());
      return;
    }

    // If we are not in the foreground, stop any foreground-only capture loop.
    unawaited(LocationBackgroundService().stopForegroundOnlyTracking());
  }

  /// Shown after login and whenever the app resumes until "Always" location is granted.
  Future<void> _promptAlwaysLocationIfNeeded() async {
    if (_locationPromptRouteOpen) return;
    if (!mounted) return;
    if (await LocationService().hasAllTheTimeLocationAccess()) return;
    if (!mounted) return;

    _locationPromptRouteOpen = true;
    try {
      final ok = await showLocationConsentIfNeeded(
        context,
        hasOsLocationPermission: () => LocationService().hasAnyLocationPermission(),
      );
      if (!ok || !mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (context) => const LocationOnboardingPage(),
        ),
      );
      await LocationBackgroundService().resyncTrackingFromPreferences();
    } finally {
      _locationPromptRouteOpen = false;
    }
  }

  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _tabs = [
    const HomeTab(),
    SettingsPage(key: _settingsPageKey),
    const LogEventTab(),
    PPEPage(key: _ppePageKey),
    const GloveSupportTab(),
    const LocationHistoryPage(),
    const SmokeSamplerPage(),
  ];

void _onBottomNavTapped(int index) {
    if (index == 1) {
      // If the "App" button (middle) is tapped, trigger the popup menu
      _showAppMenu();
    } else {
      // If "Home" (0) or "Settings" (2) is tapped, update the UI
      setState(() {
        _currentIndex = index;
        // Map BottomNav index 0 to Stack index 0 (Home)
        // Map BottomNav index 2 to Stack index 1 (Settings)
        _stackIndex = index == 0 ? 0 : 1; 
      });
    }
  }

  // void _showAppMenu() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (BuildContext context) {
  //       return SafeArea(
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 16.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min, // Wrap content height
  //             children: [
  //               const Padding(
  //                 padding: EdgeInsets.only(bottom: 8.0),
  //                 child: Text(
  //                   'Apps',
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                 ),
  //               ),
  //               ListTile(
  //                 leading: const Icon(Icons.event_note),
  //                 title: const Text('Log Event'),
  //                 onTap: () => _navigateToAppPage(2),
  //               ),
  //               ListTile(
  //                 leading: const Icon(Icons.shield),
  //                 title: const Text('PPE'),
  //                 onTap: () => _navigateToAppPage(3),
  //               ),
  //               ListTile(
  //                 leading: const Icon(Icons.support),
  //                 title: const Text('Glove Support'),
  //                 onTap: () => _navigateToAppPage(4),
  //               ),
  //               ListTile(
  //                 leading: const Icon(Icons.location_on),
  //                 title: const Text('Location History'),
  //                 onTap: () => _navigateToAppPage(5),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

void _showAppMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'More Apps',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // NEW: Wrap allows items to flow horizontally and wrap to the next line if needed
                Wrap(
                  spacing: 16.0, // Horizontal gap between boxes
                  runSpacing: 16.0, // Vertical gap between rows
                  alignment: WrapAlignment.center,
                  children: [
                    _buildAppBox(Icons.event_note, 'Log Event', 2),
                    _buildAppBox(Icons.shield, 'PPE', 3),
                    _buildAppBox(Icons.support, 'Glove Support', 4),
                    _buildAppBox(Icons.location_on, 'Location\nHistory', 5),
                    _buildAppBox(Icons.science, 'Smoke\npassive\nSampling', 6),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// NEW: Helper method to create clickable horizontal boxes
  Widget _buildAppBox(IconData icon, String label, int targetStackIndex) {
    return InkWell(
      onTap: () => _navigateToAppPage(targetStackIndex),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 85, // Adjust width of the box
        height: 90, // Adjust height of the box
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100, // Light background for the box
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, height: 1.1),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
void _navigateToAppPage(int targetStackIndex) {
    Navigator.pop(context); // Close the popup menu first
    setState(() {
      _currentIndex = 1; // Keep the "App" button highlighted
      _stackIndex = targetStackIndex; // Display the chosen page in the IndexedStack
    });
    if (targetStackIndex == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ppePageKey.currentState?.startFreshEntry();
        _ppePageKey.currentState?.syncPendingBannerFromStorage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Apps'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
