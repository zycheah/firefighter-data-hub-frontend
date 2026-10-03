/// Registered by [MainNavigation] so deep links / dialogs can switch the Apps stack tab.
class AppShellNavigation {
  AppShellNavigation._();

  static void Function()? _goToPpeTab;
  static void Function()? _openGpsPreferences;

  static void registerGoToPpeTab(void Function() fn) {
    _goToPpeTab = fn;
  }

  /// Registered by [SettingsPage] — switches to the GPS Preferences tab and scrolls to
  /// Enable all-the-time location.
  static void registerOpenGpsPreferences(void Function() fn) {
    _openGpsPreferences = fn;
  }

  static void unregister() {
    _goToPpeTab = null;
    _openGpsPreferences = null;
  }

  static void unregisterOpenGpsPreferences() {
    _openGpsPreferences = null;
  }

  static void goToPpeTab() {
    _goToPpeTab?.call();
  }

  static void openGpsPreferences() {
    _openGpsPreferences?.call();
  }
}
