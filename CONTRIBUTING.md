# Contributing

## Local setup

1. Install Flutter (stable).
2. `flutter pub get`
3. `dart analyze` and `flutter test` should pass before you open a PR.

## Do not commit

Generated and IDE-local paths are ignored via `.gitignore`, including:

- `.dart_tool/`, `build/`
- `.flutter-plugins-dependencies`
- `.idea/`, `*.iml`

If Git still tracks a path after we ignored it, run `git rm -r --cached <path>` once and commit.

## Code style

- Follow existing patterns in `lib/` (providers, repositories, screens).
- Run `dart format .` on changed Dart files.
- Prefer fixing analyzer issues over disabling lints unless there is a strong reason.

## Pull requests

- Describe behavior changes and any schema / backup format bumps.
- For UI changes, note platforms tested (Android / iOS / desktop).

## Release builds

- **Android**: See root `README.md` → Security → Android release signing (`android/key.properties.example`).
- **iOS**: Open `ios/Runner.xcworkspace`, set your Team and bundle identifier if you replace the default `com.expensemanager.app`.
