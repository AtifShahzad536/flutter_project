<?php

// Database Configuration
define('DB_HOST', 'localhost');
define('DB_NAME', 'export_trix');
define('DB_USER', 'root');
define('DB_PASS', '');

// JWT Configuration
define('JWT_SECRET', 'your_jwt_secret_key_change_this_in_production');
define('JWT_EXPIRE_TIME', 86400); // 24 hours

// API Configuration
define('API_BASE_URL', 'http://localhost/server-php/api');
define('CORS_ALLOWED_ORIGINS', '*');

// Application Configuration
define('APP_NAME', 'Export Trix API');
define('APP_VERSION', '1.0.0');

// Error Reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Handle preflight requests
// (Removed - now handled in index.php to ensure CORS headers are set)
?>
