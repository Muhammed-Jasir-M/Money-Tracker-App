# Finora

Offline-first personal finance app built with Flutter. Track income and expenses, set budgets, view charts, and keep everything on your device — no account, no cloud.

| | |
|---|---|
| **App name** | Finora |
| **Package ID** | `com.finora.app` |
| **Version** | 1.0.0 |
| **Platforms** | Android · iOS · Web (partial) |

## About

Finora helps you manage day-to-day money: log transactions with categories and notes, attach receipt photos, set monthly budgets, and review spending trends. All data is stored locally using Hive. Optional PIN and biometric lock protect the app on your device.

## Features

- **Dashboard** — Balance, income vs expense, recent transactions
- **Transactions** — Add, edit, delete, filter, search, swipe-to-delete
- **Stats** — Category donut chart and daily/monthly trend line chart
- **Budgets** — Total or per-category monthly limits with progress
- **Categories** — Custom income/expense categories (icons & colors)
- **Settings** — Theme, currency, profile name, app lock, biometrics
- **Backup & export** — JSON backup/restore, CSV export for spreadsheets
- **Offline & private** — No login, no analytics, no cloud sync

## Tech stack

| Layer | Tools |
|-------|--------|
| **Framework** | Flutter, Dart 3.6+ |
| **State management** | `flutter_bloc`, `equatable` |
| **Local database** | Hive, `hive_flutter` |
| **Charts** | `fl_chart` |
| **Security** | `local_auth`, `flutter_secure_storage`, `crypto` |
| **Media & files** | `image_picker`, `file_picker`, `path_provider` |
| **Export / share** | `share_plus`, `csv` |
| **UI** | Material 3, `google_fonts`, `font_awesome_flutter` |

## Architecture

```
lib/
├── core/           # Theme, backup, CSV export, app lock, Hive helpers
├── data/           # Models, datasources, repositories
├── features/       # Feature modules (dashboard, transactions, stats, …)
└── shared/         # Reusable widgets (app bar, tiles, dialogs, …)
```

Each feature follows **BLoC → Repository → Datasource** with Hive as the single source of truth on device.

## Getting started

### Prerequisites

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.6 or newer)
2. Install [Git](https://git-scm.com/)
3. Use **VS Code** or **Android Studio** with Flutter/Dart plugins
4. Connect a device or start an emulator, then verify:

```bash
flutter doctor
```

### Clone & run

```bash
git clone https://github.com/Muhammed-Jasir-M/Money-Tracker-App.git
cd Money-Tracker-App
flutter pub get
flutter run
```

When prompted, pick your device (Android phone, emulator, Chrome, etc.).

### Release build (optional)

```bash
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

> **Note:** Package ID is `com.finora.app`. Uninstall older builds (`com.example.*` or `com.moneytracker.app`) before installing a new package ID.

## Developer notes

**Regenerate app icon** — replace `assets/icon/app_icon.png` (1024×1024), then:

```bash
dart run flutter_launcher_icons
```

**Regenerate Hive adapters** — after changing `@HiveType` models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**After adding native plugins** (e.g. biometrics) — use a full rebuild, not hot restart:

```bash
flutter run
```

Branding constants: `lib/core/constants/app_branding.dart`

## License

Personal and portfolio use. Add a `LICENSE` file (e.g. MIT) if you publish the repo publicly.

## Author

**Muhammed Jasir** — [GitHub](https://github.com/Muhammed-Jasir-M)
