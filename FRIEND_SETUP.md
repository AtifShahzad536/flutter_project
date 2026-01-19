# Setup Guide for Friend

Here are the exact commands you need to run to get the project working on your PC.

### 1. Download the Project
Open your terminal (Git Bash or Command Prompt) and run these **one by one** (do not copy both lines at once):

1. `git clone https://github.com/AtifShahzad536/flutter_project.git`
2. `cd flutter_project`

### 2. Setup the Website/Backend (PHP)
1.  Make sure you have XAMPP (or PHP and MySQL) installed.
2.  Open your database tool (like phpMyAdmin) and create a new **empty database** called: `flutter_chat`
3.  Run these commands in your terminal:

```bash
cd server-php

# Run the database setup script (creates tables for you)
php setup_chat_db.php

# Start the server (KEEP THIS TERMINAL OPEN!)
php -S localhost:8000 -t public
```

*(If you see an error about database connection, check `server-php/config/config.php` and make sure the password matches your local MySQL).*

### 3. Run the Mobile App (Flutter)
Open a **NEW** terminal window (do not close the PHP one), then run:

```bash
cd mobile
flutter pub get
flutter run
```

The app should now launch and connect to your local backend!

---

## 📂 Where is the Code? (Project Map)

If you are looking for specific screens or features in the Flutter app, look in **`mobile/lib/features/`**:

| Feature | Folder Path | Key Screen |
| :--- | :--- | :--- |
| **Login / Register** | `lib/features/auth/view/` | `login_screen.dart` |
| **Dashboard** | `lib/features/rider/view/` | `rider_dashboard_screen.dart` |
| **Orders** | `lib/features/rider/view/` | `rider_orders_screen.dart` |
| **Messaging/Chat** | `lib/features/rider/view/` | `rider_chat_screen.dart` |
| **Store/Products**| `lib/features/products/view/` | `product_list_screen.dart` |

### Important Folders:
- **`lib/main.dart`**: The starting point of the app.
- **`lib/core/`**: Shared styles, API constants, and helper functions.
- **`lib/data/`**: Where the app talks to the PHP server (API services).

---

## 📱 Web & Mobile Responsiveness

The project is designed to look great on both mobile phones and web browsers (Desktop).

### How it works:
We use a special widget called **`ResponsiveLayout`** (found in `lib/core/widgets/responsive_layout.dart`). It automatically detects the screen size and switches the UI.

### Examples in the code:
- **`lib/features/auth/view/login_screen.dart`**: Uses a split-screen for Web and a centered card for Mobile.
- **`lib/features/rider/view/rider_dashboard_screen.dart`**: Uses a Sidebar for Web and a Bottom Navigation Bar for Mobile.

### How to make a new screen responsive:
When creating a new screen, wrap it in a `ResponsiveLayout`:

```dart
return ResponsiveLayout(
  mobile: MyMobileUI(),
  desktop: MyDesktopUI(),
);
```
