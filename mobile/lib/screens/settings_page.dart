import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/location_background_service.dart';
import '../services/location_preferences_service.dart';
import '../services/location_service.dart';
import 'account_deleted_page.dart';
import 'change_password_page.dart';
import 'login_page.dart';
import 'location_consent_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey _gpsEnableAnchorKey = GlobalKey();

  bool _isLoadingPreferences = true;
  bool _allTheTimeLocationEnabled = false;
  bool _anyForegroundLocationGranted = false;
  bool _requestingAllTheTimeLocation = false;
  bool _highlightEnableAllTheTimeButton = false;
  Timer? _enableButtonHighlightTimer;
  int _trackingIntervalMinutes =
      LocationPreferencesService.defaultTrackingIntervalMinutes;

  final List<int> _intervalOptions = [15, 20, 30, 60, 120];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPreferences();
  }

  @override
  void dispose() {
    _enableButtonHighlightTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  static const _enableButtonHighlightDuration = Duration(seconds: 4);

  void _scheduleClearEnableButtonHighlight() {
    _enableButtonHighlightTimer?.cancel();
    _enableButtonHighlightTimer = Timer(_enableButtonHighlightDuration, () {
      if (!mounted) return;
      setState(() => _highlightEnableAllTheTimeButton = false);
    });
  }

  /// Opens the GPS Preferences tab and scrolls so [Enable all-the-time location] is visible.
  void jumpToGpsPreferencesAndFocusEnable() {
    unawaited(_jumpToGpsPreferencesAndFocusEnableAsync());
  }

  Future<void> _jumpToGpsPreferencesAndFocusEnableAsync() async {
    if (!mounted) return;
    if (_tabController.index != 1) {
      _tabController.animateTo(1);
      // [animateTo] does not return a Future; wait for the tab animation to settle.
      await Future<void>.delayed(const Duration(milliseconds: 320));
    }
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _gpsEnableAnchorKey.currentContext;
      if (target == null) return;
      unawaited(() async {
        await Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut,
          alignment: 0.28,
        );
        if (!mounted) return;
        setState(() => _highlightEnableAllTheTimeButton = true);
        _scheduleClearEnableButtonHighlight();
      }());
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = LocationPreferencesService();
    final interval = await prefs.getTrackingIntervalMinutes();
    final always = await LocationService().hasAllTheTimeLocationAccess();
    final anyFg = await LocationService().hasAnyLocationPermission();

    setState(() {
      _trackingIntervalMinutes = interval;
      _allTheTimeLocationEnabled = always;
      _anyForegroundLocationGranted = anyFg;
      _isLoadingPreferences = false;
    });
  }

  Future<void> _requestAllTheTimeLocation() async {
    _enableButtonHighlightTimer?.cancel();
    setState(() {
      _requestingAllTheTimeLocation = true;
      _highlightEnableAllTheTimeButton = false;
    });
    final ok = await showLocationConsentIfNeeded(
      context,
      hasOsLocationPermission: () => LocationService().hasAnyLocationPermission(),
    );
    if (ok && mounted) {
      await LocationService().requestAllTheTimeLocationAccess();
    }
    final always = await LocationService().hasAllTheTimeLocationAccess();
    final anyFg = await LocationService().hasAnyLocationPermission();
    if (!mounted) return;
    setState(() {
      _requestingAllTheTimeLocation = false;
      _allTheTimeLocationEnabled = always;
      _anyForegroundLocationGranted = anyFg;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          always
              ? 'All-the-time location is on. Periodic tracking can run in the background.'
              : 'All-the-time location is still off. On iOS choose Always; on Android allow '
                  'location all the time, or change it in system Settings.',
        ),
      ),
    );
    if (always) {
      await LocationBackgroundService()
          .syncSchedulingFromPreferencesIfAllTheTimeAccess();
    }
  }

  Future<void> _onTrackingIntervalChanged(int? value) async {
    if (value == null) return;

    final prefs = LocationPreferencesService();
    await prefs.setTrackingIntervalMinutes(value);

    setState(() {
      _trackingIntervalMinutes = value;
    });

    await LocationBackgroundService().updateScheduling(
      isEnabled: true,
      intervalMinutes: _trackingIntervalMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Account Details'),
            Tab(text: 'GPS Preferences'),
          ],
        ),
      ),
      body: user == null
          ? const Center(
              child: Text('No user information available'),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAccountDetailsTab(context, user),
                _buildGpsPreferencesTab(),
              ],
            ),
    );
  }

  Widget _buildAccountDetailsTab(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.person,
                    'Name',
                    user.name,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Age',
                    user.age > 0 ? user.age.toString() : '—',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.email,
                    'Email',
                    user.email,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.phone,
                    'Phone Number',
                    user.phoneNumber,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.male,
                    'Gender',
                    user.gender,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.people,
                    'Race',
                    user.race,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.public,
                    'Ethnicity',
                    user.ethnicity,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.cake,
                    'Year of birth',
                    user.birthYear > 0 ? user.birthYear.toString() : '—',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.height,
                    'Height',
                    user.height,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.monitor_weight,
                    'Weight',
                    user.weight,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.pan_tool,
                    'Dominant hand',
                    user.dominantHandLabel,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.local_fire_department,
                    'Years and months of firefighting',
                    user.yearsOfExperience,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.badge,
                    'Firefighting status',
                    StatusToDisplayString(user.status),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.list,
                    'Type of firefighting',
                    user.firefighterTypes
                        .map(firefighterTypeToDisplayString)
                        .join(', '),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.location_city,
                    'Firefighting city/town',
                    user.city,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.map,
                    'US state',
                    stateToDisplayString(user.state),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
            icon: const Icon(Icons.lock),
            label: const Text('Change password'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await LocationBackgroundService().stopTracking();
              await LocationPreferencesService().setIsTrackingEnabled(false);
              AuthService().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showDeleteAccountDialog(context),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Account'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => _DeleteAccountDialog(
        onCancel: () => Navigator.pop(dialogContext),
        onDeleted: () {
          Navigator.pop(dialogContext);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const AccountDeletedPage(),
            ),
            (route) => false,
          );
        },
        onFailed: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGpsPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GPS Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoadingPreferences)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tracking interval (minutes)',
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<int>(
                      value: _intervalOptions.contains(_trackingIntervalMinutes)
                          ? _trackingIntervalMinutes
                          : _intervalOptions.first,
                      items: _intervalOptions
                          .map(
                            (m) => DropdownMenuItem<int>(
                              value: m,
                              child: Text(m.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: _onTrackingIntervalChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _allTheTimeLocationEnabled
                      ? 'All-the-time location: enabled'
                      : 'All-the-time location: off — background GPS needs this',
                  style: TextStyle(
                    fontSize: 14,
                    color: _allTheTimeLocationEnabled
                        ? Colors.green
                        : Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Why periodic location',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                _bulletLine(
                  'Periodic check-ins for safety and incident-related location history.',
                ),
                _bulletLine(
                  '“While using the app” is not permission to keep locating you when the app '
                  'is not active—Always / Allow all the time is.',
                ),
                _bulletLine(
                  'Tap Enable all-the-time location below and confirm Always (iOS) or Allow '
                  'all the time (Android) when the system prompts.',
                ),
                if (!_allTheTimeLocationEnabled &&
                    _anyForegroundLocationGranted) ...[
                  const SizedBox(height: 12),
                  Text(
                    'You may already see location allowed—that often means only while the '
                    'app is open. All-the-time is a separate switch required for '
                    'background tracking.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                KeyedSubtree(
                  key: _gpsEnableAnchorKey,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: _highlightEnableAllTheTimeButton
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: _highlightEnableAllTheTimeButton ? 2.5 : 0,
                      ),
                      boxShadow: _highlightEnableAllTheTimeButton
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.35),
                                blurRadius: 14,
                                spreadRadius: 0,
                              ),
                            ]
                          : const [],
                    ),
                    child: FilledButton.icon(
                      onPressed: _requestingAllTheTimeLocation
                          ? null
                          : _requestAllTheTimeLocation,
                      icon: _requestingAllTheTimeLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _requestingAllTheTimeLocation
                            ? 'Requesting…'
                            : 'Enable all-the-time location',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _bulletLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.circle,
              size: 6,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({
    required this.onCancel,
    required this.onDeleted,
    required this.onFailed,
  });

  final VoidCallback onCancel;
  final VoidCallback onDeleted;
  final void Function(String message) onFailed;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final TextEditingController _passwordController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action cannot be undone. Enter your password to confirm account deletion.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submitting
              ? null
              : () async {
                  final password = _passwordController.text.trim();
                  if (password.isEmpty) {
                    widget.onFailed('Enter your password to confirm.');
                    return;
                  }
                  setState(() => _submitting = true);
                  final result =
                      await AuthService().deleteAccount(password);
                  if (!mounted) return;
                  if (result.success) {
                    widget.onDeleted();
                  } else {
                    setState(() => _submitting = false);
                    widget.onFailed(
                      result.message ?? 'Could not delete account.',
                    );
                  }
                },
          child: Text(_submitting ? 'Deleting…' : 'Delete'),
        ),
      ],
    );
  }
}

