# Project Setup Instructions

This repository contains two parts:
1. **Mobile App** (Flutter)
2. **Backend Server** (PHP)

Follow these steps to set up the project on your machine.

## 0. Download the Project
Open your terminal (Command Prompt or Git Bash) and run:
```bash
git clone https://github.com/AtifShahzad536/flutter_project.git
cd flutter_project
```

## 1. Setup Backend (PHP)

Navigate to the `server-php` directory:

```bash
cd server-php
```

### Install Dependencies
If you have `composer.json` (if not, skip this):
```bash
composer install
```

### Database Setup
1. Create a MySQL database (e.g., `flutter_chat`).
2. Import any `.sql` files provided, or run the setup scripts if available:
   ```bash
   php setup_chat_db.php
   ```
   *(Note: Check `src/Config/Database.php` or `.env` to configure your database credentials).*

### Start the Server
You can start the built-in PHP server:
```bash
php -S localhost:8000 -t public
```
Or use the provided script:
```bash
start_server.php
```

---

## 2. Setup Mobile App (Flutter)

Navigate to the `mobile` directory:

```bash
cd mobile
```

### Install Dependencies
```bash
flutter pub get
```

### Run the App
Ensure your emulator or device is connected.
```bash
flutter run
```

---

## Important Notes for Collaborators
- **Do not** upload `build/`, `.dart_tool/`, or `vendor/` folders. These are large and auto-generated.
- If you change database credentials, update them in your local config, but **do not commit** your local secrets if `.env` is ignored.
