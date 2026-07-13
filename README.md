# ResultHub Mobile Application

This repository contains the official mobile application for ResultHub, deployed to Android and iOS platforms.

## 🎯 Purpose
The mobile app is the flagship product of the ResultHub ecosystem. It provides end-users with a native, highly responsive, and immersive social experience directly on their smartphones. Features include endless scrolling feeds, complex UI animations, map integrations, and secure device-level authentication.

## 📦 What It Has
- **Feature-First Architecture:** The codebase is split into discrete features (e.g., `lib/features/auth`, `lib/features/home`) for rapid scalability.
- **Robust State Management:** Powered exclusively by `Riverpod` for reactive data fetching and global state mutation without prop drilling.
- **Type-Safe Routing:** Navigation is handled by `GoRouter`, allowing for deep-linking and modular page transitions.
- **Media Support:** Integrates camera (`image_picker`), video playback (`video_player`), and mapping capabilities (`flutter_map`).
- **Custom Theming:** A highly customized, premium dark-mode focused design system leveraging `AppColorsExtension`.

## 🛠️ How It Is Built
### Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.12.0)
- **Language:** Dart
- **State Management:** Riverpod (`flutter_riverpod`)
- **Networking:** Dio
- **Local Storage:** `shared_preferences`, `flutter_secure_storage`

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and added to your system PATH.
- Android Studio or Xcode (for emulation/building).
- A running instance of the `backend-mern` API.

### Getting Started

1. **Install Dependencies**
   Navigate to the root of the project and pull the dart packages:
   ```bash
   flutter pub get
   ```

2. **Environment Configuration**
   Create a `.env` file in the root directory to point to your backend API.
   *Note: If testing on an Android emulator locally, you must use `10.0.2.2` instead of `localhost`.*
   ```env
   API_BASE_URL=http://10.0.2.2:3001/api
   ```

3. **Run the Application**
   Connect a physical device or start an emulator, then run:
   ```bash
   flutter run
   ```

### Building for Release (Android)
To build a lightweight, optimized APK for modern Android devices (avoiding the massive "fat" APK), run the split command:
```bash
flutter build apk --split-per-abi
```
*Your optimized build will be located at: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`*