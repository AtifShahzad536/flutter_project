# Migration Guide: Auth & Rider Features

This guide explains how to move the **Auth** (Login/Register) and **Rider** (Dashboard/Orders) features into your own existing Flutter project.

## 1. Copy the Core Logic
First, copy the folder `mobile/lib/core` into your `lib/` directory. This contains:
- **`responsive_layout.dart`**: Essential for making the UI look good on Web and Mobile.
- **`api_client.dart` & `token_storage.dart`**: Handles talking to the PHP server and saving login tokens.
- **`api_endpoints.dart`**: Lists all the URL paths for the backend.

## 2. Copy the Features
Copy these specific folders from `mobile/lib/features/` to your `lib/features/`:

| Feature | What to copy | What it does |
| :--- | :--- | :--- |
| **Auth** | `lib/features/auth/` | Login, Register, Forget Password, Auth check. |
| **Rider** | `lib/features/rider/` | Dashboard, Orders, Profile, History, and Chat. |

## 3. Copy the API Services
Copy the folder `mobile/lib/data/` to your `lib/data/`.
This folder contains `api_service.dart`, which the Rider features use to fetch data from the server.

## 4. Add Required Dependencies
Open your `pubspec.yaml` and make sure you have these packages installed:

```yaml
dependencies:
  dio: ^5.7.0
  provider: ^6.0.0
  shared_preferences: ^2.2.0
  fl_chart: ^0.68.0
  intl: ^0.18.1
```
Run `flutter pub get` after adding these.

## 5. Setup Routes
In your `main.dart` or your router file, add these routes so the navigation works:

```dart
// Example routing setup
routes: {
  '/': (context) => const AuthCheckScreen(),
  '/login': (context) => const LoginScreen(),
  '/dashboard': (context) => const RiderDashboardScreen(),
},
```

## 6. How to use Responsiveness
When you use the screens you moved (like `LoginScreen`), they already use the `ResponsiveLayout` widget.

If you want to make **your own** new screens responsive like this project, do this:
```dart
return ResponsiveLayout(
  mobile: MyMobileWidget(), // For phones
  desktop: MyDesktopWidget(), // For Website/PC
);
```
