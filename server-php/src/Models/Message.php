<?php

namespace App\Models;

use App\Config\Database;
use PDO;

class Message {
    private $conn;
    private $table_name = "messages";
    
    public $id;
    public $sender_id;
    public $receiver_id;
    public $text;
    public $created_at;
    
    public function __construct() {
        $this->conn = Database::getInstance()->getConnection();
    }
    
    // Get chat conversations for a user
    public function getConversations($user_id) {
        $query = "SELECT 
                    CASE 
                        WHEN sender_id = :user_id THEN receiver_id 
                        ELSE sender_id 
                    END AS contact_id,
                    u.name AS contact_name,
                    m.text AS last_message,
                    m.created_at AS last_message_time
                  FROM " . $this->table_name . " m
                  JOIN users u ON u.id = (CASE WHEN sender_id = :user_id THEN receiver_id ELSE sender_id END)
                  WHERE sender_id = :user_id OR receiver_id = :user_id
                  AND m.id IN (
                      SELECT MAX(id)
                      FROM " . $this->table_name . "
                      WHERE sender_id = :user_id OR receiver_id = :user_id
                      GROUP BY LEAST(sender_id, receiver_id), GREATEST(sender_id, receiver_id)
                  )
                  ORDER BY m.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $user_id);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    // Get message history between two users
    public function getHistory($user_id1, $user_id2) {
        $query = "SELECT id, sender_id, receiver_id, text, created_at 
                 FROM " . $this->table_name . " 
                 WHERE (sender_id = ? AND receiver_id = ?) 
                    OR (sender_id = ? AND receiver_id = ?) 
                 ORDER BY created_at ASC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $user_id1);
        $stmt->bindParam(2, $user_id2);
        $stmt->bindParam(3, $user_id2);
        $stmt->bindParam(4, $user_id1);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    // Send a message
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                  SET sender_id=:sender_id, receiver_id=:receiver_id, text=:text";
        
        $stmt = $this->conn->prepare($query);
        
        $this->sender_id = htmlspecialchars(strip_tags($this->sender_id));
        $this->receiver_id = htmlspecialchars(strip_tags($this->receiver_id));
        $this->text = htmlspecialchars(strip_tags($this->text));
        
        $stmt->bindParam(":sender_id", $this->sender_id);
        $stmt->bindParam(":receiver_id", $this->receiver_id);
        $stmt->bindParam(":text", $this->text);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
}
