<?php

// Simple server startup script
echo "Starting Export Trix PHP Backend Server...\n\n";

// Check if database connection works
require_once __DIR__ . '/config/config.php';

try {
    $conn = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME, DB_USER, DB_PASS);
    echo "✓ Database connection successful\n";
    echo "✓ Connected to: " . DB_NAME . "\n";
    $conn = null;
} catch(PDOException $e) {
    echo "✗ Database connection failed: " . $e->getMessage() . "\n";
    echo "Please check your database settings in config/config.php\n";
    exit(1);
}

echo "\nTo start the PHP server, run one of these commands:\n";
echo "1. Using PHP built-in server:\n";
echo "   php -S localhost:8000 index.php\n\n";
echo "2. Using XAMPP/WAMP:\n";
echo "   - Start Apache from XAMPP/WAMP control panel\n";
echo "   - Access at: http://localhost/server-php/\n\n";
echo "3. Using command line (if PHP is in PATH):\n";

// Try to find PHP executable
$php_paths = [
    'C:\xampp\php\php.exe',
    'C:\wamp64\bin\php\php.exe',
    'C:\php\php.exe',
    'php'  // If in PATH
];

$php_found = false;
foreach($php_paths as $php_path) {
    if(file_exists($php_path) || $php_path === 'php') {
        echo "   Found PHP at: " . $php_path . "\n";
        echo "   Run: " . $php_path . " -S localhost:8000 " . __DIR__ . "\index.php\n";
        $php_found = true;
        break;
    }
}

if(!$php_found) {
    echo "   PHP not found in common locations\n";
    echo "   Please install PHP or add it to your PATH\n";
}

echo "\nAPI Endpoints:\n";
echo "- Root: http://localhost:8000/\n";
echo "- Auth: http://localhost:8000/api/auth\n";
echo "- Products: http://localhost:8000/api/products\n";
echo "- Orders: http://localhost:8000/api/orders\n";
echo "- Dashboard: http://localhost:8000/api/dashboard\n";

echo "\nTest the API:\n";
echo "curl http://localhost:8000/\n";
?>
