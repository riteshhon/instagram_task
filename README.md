# Task App

A Flutter app with an Instagram-style feed: posts, stories, shimmer loading, pinch-to-zoom on images, and infinite scroll.

## Demo

📱 **[Watch the app demo on YouTube](https://youtube.com/shorts/5he0jiqgpjw?si=8PQgEIY9uSkI9OaO)**

---

## State management: Provider

This project uses **[Provider](https://pub.dev/packages/provider)** for state management.

- **Why Provider**  
  Provider is official, lightweight, and fits well with Flutter’s widget tree. It keeps UI and business logic separate and makes state predictable and testable.

- **How it’s used**
  - **FeedProvider** holds feed state: posts, stories, loading flags, errors, and UI state (shimmer, post carousel page, caption expanded). It’s provided at the app root via `MultiProvider` in `main.dart`.
  - Screens and widgets use `context.read<FeedProvider>()` for one-off actions and `context.watch<FeedProvider>()` or `Selector<FeedProvider, T>` so only affected widgets rebuild when state changes.
  - Local, short-lived UI state (e.g. pinch overlay, comment sheet) uses `ValueNotifier` + `ValueListenableBuilder` instead of `setState`, so the app stays free of widget-level `setState` for feed and overlay logic.

- **Architecture**  
  Presentation (screens/widgets) only reads and updates state via Provider or listenables; business logic and data live in providers and services.

---

## How to run and build

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (compatible with SDK ^3.10.4)
- A device or emulator

### Run the app

```bash
# Get dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Build

```bash
# Debug build (APK on Android)
flutter build apk --debug

# Release APK (Android)
flutter build apk --release

# Release App Bundle (Android, for Play Store)
flutter build appbundle --release

# Release iOS
flutter build ios --release
```

### Run tests

```bash
flutter test
```

---

## Project structure

```
lib/
├── main.dart                 # App entry, Provider setup
├── constants/                # App constants (e.g. logged-in user)
├── core/theme/               # Theme and styling
├── models/                   # Data models
├── providers/                # State (e.g. FeedProvider)
├── screens/home/             # Home feed screen and widgets
├── services/                 # Data/API layer
└── utils/                    # Helpers (e.g. format utils)
```
