# ResultHub Mobile Application

## 🌍 Complete Project Overview
**ResultHub** is a comprehensive, multi-platform social and organizational ecosystem designed to bridge the gap between institutions, data, and the community. It allows organizations (like sports leagues, educational institutions, or event organizers) to securely upload and manage complex datasets. Simultaneously, it provides end-users with an engaging, modern social network to view these results, interact with posts, customize their profiles, and stay connected with real-time feeds.

The platform is decoupled into four codebases:
1. **Backend API**
2. **Public Web** (User-facing social network)
3. **Business Web** (Enterprise dashboard)
4. **Mobile App (This repository)**

---

## 🎯 Purpose of This Repository
The mobile app is the flagship product of the ResultHub ecosystem. Built to natively run on Android and iOS devices, it provides users with an immersive, hardware-accelerated social experience. Features include endless scrolling feeds, complex UI animations, push notifications, map integrations, and secure device-level authentication.

## 🔌 How It Integrates with the Backend
As a frontend client, the Flutter app has no internal centralized database. It uses the `Dio` HTTP networking package to continuously communicate with the `backend-mern` Node.js API over the internet.

1. **Persistent Authentication:** When a user logs in, the API returns a JWT token. Instead of storing it in local storage like a browser, Flutter uses the `flutter_secure_storage` package to encrypt the token and save it directly into the iOS Keychain or Android Keystore.
2. **Global Network Interceptors:** The `Dio` client is configured with interceptors. Every single time the app tries to fetch the feed or search for a user, the interceptor automatically pulls the encrypted token from the Keystore and slaps it onto the `Authorization` header so the backend knows who is making the request.
3. **Hardware-to-Backend Parsing:** When a user takes a photo with the `image_picker` to update their profile picture, Flutter converts the native file binary into a Multipart upload and posts it to the backend's Multer endpoint.

## 📦 What It Has
- **Feature-First Architecture:** The codebase is split into discrete features (e.g., `lib/features/auth`, `lib/features/home`) for rapid scalability.
- **Robust State Management:** Powered exclusively by `Riverpod` for reactive data fetching and global state mutation without prop drilling.
- **Type-Safe Routing:** Navigation is handled by `GoRouter`, allowing for deep-linking and modular page transitions.
- **Hardware Integrations:** Video playback (`video_player`), camera (`image_picker`), and maps (`flutter_map`).

## 🛠️ How It Is Built
### Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.12.0)
- **Language:** Dart
- **State Management:** Riverpod (`flutter_riverpod`)
- **Networking:** Dio

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- A running instance of the `backend-mern` API.

### Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Environment Configuration**
   Create a `.env` file in the root. If testing on an Android emulator locally, you must use `10.0.2.2` instead of `localhost`.
   ```env
   API_BASE_URL=http://10.0.2.2:3001/api
   ```

3. **Run the Application**
   ```bash
   flutter run
   ```

### Building for Release (Android)
To build an optimized split APK for modern Android devices:
```bash
flutter build apk --split-per-abi
```