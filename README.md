# Expense Manager (Flutter)

Offline-first expense and income tracker with accounts, transfers, udhar (lending), categories, budgets, recurring templates, receipt attachments, CSV export, and encrypted backup.

The Dart package name is **`expense_app`** (see `pubspec.yaml`); this repo folder may be named `expense_manager`.

**Store identifiers:** Android `applicationId` and iOS `PRODUCT_BUNDLE_IDENTIFIER` are **`com.expensemanager.app`**. Replace with **your own** reverse-DNS IDs before publishing if you need a unique namespace (changing IDs later breaks updates for existing installs).

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
- Xcode (macOS) for iOS builds; Android Studio / SDK for Android

## Quick start

```bash
flutter pub get
flutter gen-l10n   # optional; usually runs via pub get / build
dart analyze
flutter test
flutter run
```

After cloning, always run **`flutter pub get`** so `.dart_tool/` and plugin registrants are generated locally. Do **not** commit `.dart_tool/`, `build/`, `.idea/`, or `*.iml` (see `.gitignore`).

## Features (summary)

- SQLite database with migrations (accounts, expenses, income, udhar, budgets, recurring templates, receipts)
- Material 3 UI, drawer navigation, onboarding, app PIN (`flutter_secure_storage`)
- Backup/restore and CSV export (paths documented in-app under Settings)

## Security & privacy

- **PIN**: Used for app lock; secrets stored via platform secure storage where supported.
- **Database & backups**: Stored on device storage; backups are files you control—treat them like sensitive data.
- **Android release signing**
  1. Copy `android/key.properties.example` to `android/key.properties` (gitignored).
  2. Create an upload keystore with `keytool` (see comments in the example file).
  3. Place the `.jks` file under `android/` (or use an absolute path in `storeFile`).
  4. Fill `storePassword`, `keyPassword`, `keyAlias`, `storeFile` in `key.properties`.
  5. Build: `flutter build appbundle` (Play Store) or `flutter build apk --release`.

  Without `key.properties`, **release** builds fall back to **debug signing** (fine for local QA only; **not** for Play upload).

- **iOS**: Configure signing & capabilities in Xcode for your Apple Developer team; `ITSAppUsesNonExemptEncryption` is set to **false** for standard app encryption only—adjust if your legal/compliance review requires otherwise.

## Internationalization

ARB strings live under `lib/l10n/` (`app_en.arb`). Supported locales are defined by codegen (`AppLocalizations.supportedLocales`). The app uses the device locale when it matches a supported language; otherwise it falls back to English.

To add a language: create `app_<locale>.arb`, run `flutter gen-l10n`, and extend `supportedLocales` via Flutter’s l10n configuration.

## Platform notes

- **Receipt images**: The app picks images from the **gallery** only. Android and iOS declare usage strings/permissions where required (see manifests).
- **Local reminders** (Android / iOS): Weekly notifications for recurring templates and for backups can be enabled under **Settings → Reminders**. Grant notification permission when prompted.
- **Store submission**: Provide a privacy policy if you publish (local data, optional backups, receipt photos, reminders).

## Store readiness checklist

- [ ] Own **Android application ID** / **iOS bundle ID** registered in Play Console / App Store Connect (replace defaults if needed **before** first public release).
- [ ] Android **`key.properties`** + upload keystore; **`flutter build appbundle`**.
- [ ] Play Console: privacy policy URL, Data safety, content rating, screenshots.
- [ ] Physical device QA on Android + iOS (especially receipts, backup, PIN).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## CI

GitHub Actions runs `dart analyze` and `flutter test` on push and pull requests (`.github/workflows/ci.yml`).
