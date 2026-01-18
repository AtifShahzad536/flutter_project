# Setup Guide for Friend

Here are the exact commands you need to run to get the project working on your PC.

### 1. Download the Project
Open your terminal (Git Bash or Command Prompt) and run:

```bash
git clone https://github.com/AtifShahzad536/flutter_project.git
cd flutter_project
```

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
