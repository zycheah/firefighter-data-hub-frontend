# Mobile App

Firefighter-facing Flutter application for the Firefighter Safety Data Hub. Firefighters create an account, give consent, and submit exposure data: location, fire events, personal protective equipment (PPE) and smoke sampler results.

| Item | Value |
|---|---|
| Package name | `firefighter_safety_data_hub` |
| Android application ID | `com.sloumua.firefighterguard` |
| Version | 1.0.1+4 (see `pubspec.yaml`) |
| Dart SDK | ^3.11.0 |
| Target platforms | Android and iOS (web and desktop folders exist for testing only) |

---

## 1. Features

| Area | What it does |
|---|---|
| Onboarding | User consent, location consent and permission onboarding, stored on the device |
| Accounts | Sign-up with firefighter profile, email verification by token, login, forgot password, change password, account deletion |
| Session | The access token is kept in secure storage, so returning users skip the login screen |
| Location | Periodic GPS tracking in a foreground service with a configurable interval, local SQLite buffering, batch upload, location history |
| Event log | Record a fire event (date, address, whether the usual PPE was worn) |
| PPE | Record the IDs of helmet, hood, face mask, SCBA, gloves, boots, bunker coat and pants |
| Smoke sampler | Submit one or more chemicals with their percentage |
| Glove support | Glove fit support tab |

The main screen has three tabs: **Home**, **Apps** (data-entry tools) and **Settings**.

---

## 2. Getting started

### Step 1: Install the prerequisites

- Flutter SDK with Dart 3.11 or newer
- Android Studio with the Android SDK and an emulator
- Xcode and CocoaPods (macOS only, for iOS)

Check your setup:

```bash
flutter --version
flutter doctor -v
flutter doctor --android-licenses   # accept Android licenses if prompted
```

### Step 2: Install dependencies

```bash
cd mobile
flutter pub get
```

### Step 3: Point the app at an API

The API address is set in `lib/config/app_config.dart`. As committed, the app uses the deployed API (`useAwsBackend = true`), so no change is needed to run against it.

To use a local API instead, set these values:

```dart
static const String port = '8000';          // port of your local API
static const bool useAwsBackend = false;    // true = deployed API, false = local API
static const String localLanOverride = '';  // e.g. 'http://192.168.1.42:8000' for a physical phone
```

`localLanOverride` is not empty in the committed file. Clear it, or the emulator and simulator addresses below are never used.

When `useAwsBackend` is `false`, the address is chosen as follows:

| Device | Address used |
|---|---|
| Any device, when `localLanOverride` is set | `localLanOverride` |
| Android emulator | `http://10.0.2.2:<port>` (the host machine) |
| iOS simulator, desktop, web | `http://127.0.0.1:<port>` |

A physical phone must be on the same network as the computer running the API, and the API must listen on `0.0.0.0`.

### Step 4: Add the Android signing file (Android only)

Every Android build, including debug builds, reads `android/key.properties`. Without it the build fails with `null cannot be cast to non-null type kotlin.String`. There are two ways to provide it:

- **Use the project's existing signing key.** It is in the handover package, inside `handover/code/g_sb_2.zip`, under `Frontend/mobile_app/firefighter_safety_data_hub/android/`. Copy `key.properties` to `android/key.properties` and `app/upload-keystore.jks` to `android/app/upload-keystore.jks`.
- **Create your own**, as described in [Release builds](#6-release-builds).

Both files are ignored by Git and must not be committed.

iOS builds do not need this file.

### Step 5: Run the app

```bash
flutter devices                # list emulators and connected devices
flutter run -d <device_id>
```

Start an Android emulator from Android Studio, or an iOS simulator with `open -a Simulator`.

> **macOS.** Keep the project outside iCloud-synced folders such as Desktop and Documents. iCloud adds file metadata that makes iOS code signing fail with `resource fork, Finder information, or similar detritus not allowed`.

---

## 3. Commands

| Command | Description |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter run -d <device>` | Run in debug mode |
| `flutter analyze` | Static analysis (rules in `analysis_options.yaml`) |
| `flutter test` | Run tests in `test/` |
| `flutter clean` | Remove build output (use when builds behave unexpectedly) |
| `flutter build appbundle` | Android release bundle for Google Play |
| `flutter build ipa` | iOS release archive |
| `dart run flutter_launcher_icons` | Regenerate app icons from `assets/icon.png` |

---

## 4. Project structure

```
mobile/
├── lib/
│   ├── main.dart                  # Start-up: consent check, session restore, background service init
│   ├── config/app_config.dart     # API base URL and all endpoint URLs
│   ├── models/                    # User, event, PPE and location models
│   ├── screens/                   # UI screens (see table below)
│   ├── services/                  # API calls, storage and location services
│   ├── doc/                       # Consent texts, event-log question set, AI interview script
│   └── debug/                     # Debug helpers
├── assets/                        # App icon and bundled documents
├── android/                       # Android project (manifest, Gradle, permissions)
├── ios/                           # iOS project
├── test/                          # Widget tests
└── pubspec.yaml                   # Dependencies and app version
```

### Screens (`lib/screens/`)

| Screen | Purpose |
|---|---|
| `user_consent_page`, `location_consent_page`, `location_onboarding_page` | Consent and location permission flow |
| `UserPrivacyNotice/` | Privacy notice |
| `login_page`, `signup_page` | Sign in and registration |
| `verify_email_page`, `manual_verify_email_page` | Email verification by token |
| `forgot_password_page`, `set_new_password_page`, `change_password_page` | Password management |
| `main_navigation` | Bottom navigation shell (Home, Apps, Settings) |
| `home_tab` | Home screen and location status |
| `location_history_page` | Recent location points (from the API, falling back to local storage) |
| `log_event_tab` | Fire event log |
| `ppe_page` | PPE entry |
| `smoke_sampler_page` | Smoke sampler entry |
| `glove_support_tab` | Glove support |
| `settings_page`, `account_deleted_page` | Settings, sign out, account deletion |

### Services (`lib/services/`)

| Service | Responsibility |
|---|---|
| `auth_service` | Login, registration, verification, password flows, account deletion, token storage |
| `log_event_service`, `event_service` | Event submission |
| `ppe_service`, `ppe_is_updated_storage` | PPE submission and local state |
| `location_service` | Location permission and position capture |
| `location_storage_service` | Local SQLite storage of location points |
| `location_sync_service` | Uploads stored points to the API |
| `location_background_service` | Foreground service scheduling for periodic tracking |
| `location_preferences_service`, `consent_preferences_service` | Settings and consent stored with `shared_preferences` |
| `app_shell_navigation` | Navigation helpers |

### API endpoints used

All URLs are built in `lib/config/app_config.dart` from the base URL.

| Feature | Endpoint |
|---|---|
| Auth | `/api/v1/auth/register`, `/login`, `/verify-email`, `/resend-verification`, `/forgot-password/request`, `/forgot-password/confirm`, `/password-reset`, `/delete-account` |
| Location | `/api/v1/locationEntries/`, `/api/v1/locationEntries/last` |
| Event log and PPE | `/api/v1/data-transfer/logevent`, `/api/v1/data-transfer/ppe` |
| Smoke sampler | `/api/v1/smokeSampler/` |

---

## 5. Permissions

Declared in `android/app/src/main/AndroidManifest.xml`:

| Permission | Reason |
|---|---|
| `INTERNET` | API communication |
| `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | GPS tracking |
| `ACCESS_BACKGROUND_LOCATION` | Tracking while the app is in the background |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION` | Periodic tracking service |
| `POST_NOTIFICATIONS` | Foreground service notification |
| `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED` | Keep tracking running and restart it after reboot |

Google Play requires a written justification for background location. iOS location usage descriptions are in `ios/Runner/Info.plist`.

---

## 6. Release builds

### Android

1. Create an upload keystore (once) and keep it outside the repository:

   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties` (ignored by Git):

   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=/absolute/path/to/upload-keystore.jks
   ```

3. Set `useAwsBackend = true` and the production `baseUrl_aws` in `app_config.dart`.
4. Increase `version` in `pubspec.yaml`.
5. Build:

   ```bash
   flutter build appbundle
   ```

   The bundle is written to `build/app/outputs/bundle/release/app-release.aab`.

### iOS

1. Open `ios/Runner.xcworkspace` in Xcode and select the signing team.
2. Run `flutter build ipa` and upload the archive with Xcode or Transporter.

Never commit keystores, `key.properties`, `local.properties` or provisioning profiles.
