<?php
require_once __DIR__ . '/autoload.php';
require_once __DIR__ . '/config/config.php';
use App\Config\Database;
use App\Models\Notification;
use App\Models\Message;

try {
    $db = Database::getInstance()->getConnection();
    
    // Get a user ID (e.g., rider)
    $stmt = $db->query("SELECT id FROM users LIMIT 1");
    $user = $stmt->fetch();
    
    if (!$user) {
        die("No users found to seed data for.\n");
    }
    
    $user_id = $user['id'];
    
    // Seed Notifications
    $notif = new Notification();
    
    $notif->user_id = $user_id;
    $notif->title = "Welcome to Export Trix";
    $notif->body = "Your account has been fully verified. You can now start picking up orders.";
    $notif->type = "system";
    $notif->create();
    
    $notif->user_id = $user_id;
    $notif->title = "New Order Available";
    $notif->body = "Order #ORD005 is available for pickup at 123 Main St.";
    $notif->type = "order";
    $notif->create();
    
    // Seed Messages
    // For simplicity, we need another user to chat with
    $stmt = $db->query("SELECT id FROM users WHERE id != $user_id LIMIT 1");
    $contact = $stmt->fetch();
    
    if ($contact) {
        $contact_id = $contact['id'];
        
        $msg = new Message();
        $msg->sender_id = $contact_id;
        $msg->receiver_id = $user_id;
        $msg->text = "Hello! Are you available for a delivery today?";
        $msg->create();
        
        $msg->sender_id = $user_id;
        $msg->receiver_id = $contact_id;
        $msg->text = "Yes, I am starting my shift now.";
        $msg->create();
    }
    
    echo "Seed data created successfully for user ID: $user_id\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
