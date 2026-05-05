# Expense Manager (Flutter)

Offline-first expense and income tracker with accounts, transfers, udhar (lending), categories, budgets, recurring templates, receipt attachments, CSV export, and encrypted backup.

The Dart package name is **`expense_app`** (see `pubspec.yaml`); this repo folder may be named `expense_manager`.

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
- **Release signing (Android)**: Use a local keystore and `key.properties`; **never** commit keystores or passwords. Add `key.properties` and `*.jks` to `.gitignore` if you introduce them.

## Internationalization

ARB strings live under `lib/l10n/` (`app_en.arb`). Supported locales are defined by codegen (`AppLocalizations.supportedLocales`). The app uses the device locale when it matches a supported language; otherwise it falls back to English.

To add a language: create `app_<locale>.arb`, run `flutter gen-l10n`, and extend `supportedLocales` via Flutter’s l10n configuration.

## Platform notes

- **Receipt images**: The app picks images from the **gallery** only. Android and iOS declare usage strings/permissions where required (see manifests).
- **Store submission**: Provide a privacy policy if you publish (local data, optional backups, receipt photos).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## CI

GitHub Actions runs `dart analyze` and `flutter test` on push and pull requests (`.github/workflows/ci.yml`).
