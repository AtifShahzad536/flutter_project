<?php

namespace App\Models;

use App\Config\Database;
use PDO;

class User {
    private $conn;
    private $table_name = "users";
    
    public $id;
    public $name;
    public $email;
    public $password;
    public $role;
    public $phone;
    public $created_at;
    
    public function __construct() {
        $this->conn = Database::getInstance()->getConnection();
    }
    
    // Create new user
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                  SET name=:name, email=:email, password=:password, role=:role, phone=:phone";
        
        $stmt = $this->conn->prepare($query);
        
        // Sanitize
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->password = password_hash($this->password, PASSWORD_DEFAULT);
        $this->role = htmlspecialchars(strip_tags($this->role));
        $this->phone = htmlspecialchars(strip_tags($this->phone ?? ''));
        
        // Bind values
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":password", $this->password);
        $stmt->bindParam(":role", $this->role);
        $stmt->bindParam(":phone", $this->phone);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
    
    // Check if user exists by email
    public function emailExists() {
        $query = "SELECT id, name, email, password, role, phone 
                 FROM " . $this->table_name . " 
                 WHERE email = ? LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $this->email = htmlspecialchars(strip_tags($this->email));
        $stmt->bindParam(1, $this->email);
        $stmt->execute();
        
        $num = $stmt->rowCount();
        
        if($num > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $this->id = $row['id'];
            $this->name = $row['name'];
            $this->password = $row['password'];
            $this->role = $row['role'];
            $this->phone = $row['phone'];
            
            return true;
        }
        
        return false;
    }
    
    // Get user by ID
    public function getById($id) {
        $query = "SELECT id, name, email, role, phone, created_at 
                 FROM " . $this->table_name . " 
                 WHERE id = ? LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $id);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if($row) {
            $this->id = $row['id'];
            $this->name = $row['name'];
            $this->email = $row['email'];
            $this->role = $row['role'];
            $this->phone = $row['phone'];
            $this->created_at = $row['created_at'];
            
            return true;
        }
        
        return false;
    }
    
    // Get all users
    public function getAll() {
        $query = "SELECT id, name, email, role, phone, created_at 
                 FROM " . $this->table_name . " 
                 ORDER BY created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Update user
    public function update() {
        $query = "UPDATE " . $this->table_name . "
                 SET name=:name, email=:email, role=:role, phone=:phone
                 WHERE id=:id";
        
        $stmt = $this->conn->prepare($query);
        
        // Sanitize
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->role = htmlspecialchars(strip_tags($this->role));
        $this->phone = htmlspecialchars(strip_tags($this->phone ?? ''));
        $this->id = htmlspecialchars(strip_tags($this->id));
        
        // Bind values
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":role", $this->role);
        $stmt->bindParam(":phone", $this->phone);
        $stmt->bindParam(":id", $this->id);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
    
    // Delete user
    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
}
