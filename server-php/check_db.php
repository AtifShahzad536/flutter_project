<?php
require_once __DIR__ . '/autoload.php';
require_once __DIR__ . '/config/config.php';

use App\Config\Database;

try {
    $conn = Database::getInstance()->getConnection();
    echo "Database connected successfully.\n";
    
    $stmt = $conn->query("SELECT id, order_id, status FROM orders LIMIT 10");
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Sample Orders:\n";
    foreach ($orders as $order) {
        echo "ID: {$order['id']}, OrderID: {$order['order_id']}, Status: {$order['status']}\n";
    }
    
    $count = $conn->query("SELECT COUNT(*) FROM orders")->fetchColumn();
    echo "Total Orders: $count\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
