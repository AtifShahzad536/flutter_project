<?php

// Include configuration
require_once __DIR__ . '/config/config.php';

echo "Testing PHP Backend Connection...\n\n";

// Test 1: Check PHP version
echo "PHP Version: " . phpversion() . "\n";

// Test 2: Check required extensions
echo "\nChecking required extensions:\n";
echo "PDO: " . (extension_loaded('pdo') ? '✓ Installed' : '✗ Missing') . "\n";
echo "PDO MySQL: " . (extension_loaded('pdo_mysql') ? '✓ Installed' : '✗ Missing') . "\n";
echo "JSON: " . (extension_loaded('json') ? '✓ Installed' : '✗ Missing') . "\n";

// Test 3: Database connection
echo "\nTesting database connection...\n";
try {
    $conn = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME, DB_USER, DB_PASS);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Database connection successful\n";
    echo "✓ Connected to database: " . DB_NAME . "\n";
    echo "✓ Host: " . DB_HOST . "\n";
    
    // Test 4: Check if tables exist
    echo "\nChecking database tables...\n";
    $tables = ['users', 'products', 'orders', 'order_items'];
    
    foreach($tables as $table) {
        $stmt = $conn->query("SHOW TABLES LIKE '$table'");
        if($stmt->rowCount() > 0) {
            echo "✓ Table '$table' exists\n";
        } else {
            echo "✗ Table '$table' missing\n";
        }
    }
    
    // Test 5: Test a simple query
    echo "\nTesting database query...\n";
    $stmt = $conn->query("SELECT COUNT(*) as user_count FROM users");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "✓ Query executed successfully\n";
    echo "✓ Found " . $result['user_count'] . " users in database\n";
    
    $conn = null;
    
} catch(PDOException $e) {
    echo "✗ Database connection failed: " . $e->getMessage() . "\n";
    echo "✗ Please check:\n";
    echo "  - MySQL server is running\n";
    echo "  - Database '" . DB_NAME . "' exists\n";
    echo "  - Username '" . DB_USER . "' and password are correct\n";
}

// Test 6: Check if API files exist
echo "\nChecking API files...\n";
$api_files = [
    'index.php',
    'config/config.php',
    'config/database.php',
    'models/User.php',
    'models/Product.php',
    'models/Order.php',
    'controllers/AuthController.php',
    'controllers/ProductController.php',
    'controllers/OrderController.php',
    'controllers/DashboardController.php',
    'routes/auth.php',
    'routes/products.php',
    'routes/orders.php',
    'routes/dashboard.php'
];

foreach($api_files as $file) {
    if(file_exists(__DIR__ . '/' . $file)) {
        echo "✓ $file\n";
    } else {
        echo "✗ $file\n";
    }
}

echo "\nConnection test completed!\n";
echo "If all tests pass, your PHP backend is ready.\n";
echo "You can access the API at: http://localhost/server-php/\n";
?>
