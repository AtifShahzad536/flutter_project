<?php
require_once __DIR__ . '/autoload.php';
require_once __DIR__ . '/config/config.php';
use App\Config\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    // Notifications table
    $db->exec("CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        title VARCHAR(255) NOT NULL,
        body TEXT NOT NULL,
        type VARCHAR(50) DEFAULT 'system',
        is_read TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )");
    
    // Messages table
    $db->exec("CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id INT NOT NULL,
        receiver_id INT NOT NULL,
        text TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
    )");
    
    echo "Tables 'notifications' and 'messages' created successfully.\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
