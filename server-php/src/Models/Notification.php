<?php

namespace App\Models;

use App\Config\Database;
use PDO;

class Notification {
    private $conn;
    private $table_name = "notifications";
    
    public $id;
    public $user_id;
    public $title;
    public $body;
    public $type;
    public $is_read;
    public $created_at;
    
    public function __construct() {
        $this->conn = Database::getInstance()->getConnection();
    }
    
    // Get notifications for a user
    public function getByUserId($user_id) {
        $query = "SELECT id, title, body, type, is_read, created_at 
                 FROM " . $this->table_name . " 
                 WHERE user_id = ? 
                 ORDER BY created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $user_id);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    // Create a new notification
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                  SET user_id=:user_id, title=:title, body=:body, type=:type";
        
        $stmt = $this->conn->prepare($query);
        
        $this->user_id = htmlspecialchars(strip_tags($this->user_id));
        $this->title = htmlspecialchars(strip_tags($this->title));
        $this->body = htmlspecialchars(strip_tags($this->body));
        $this->type = htmlspecialchars(strip_tags($this->type ?? 'system'));
        
        $stmt->bindParam(":user_id", $this->user_id);
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":body", $this->body);
        $stmt->bindParam(":type", $this->type);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
    
    // Mark as read
    public function markAsRead($id, $user_id) {
        $query = "UPDATE " . $this->table_name . " SET is_read = 1 WHERE id = ? AND user_id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $id);
        $stmt->bindParam(2, $user_id);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
}
