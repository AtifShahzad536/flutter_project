<?php

namespace App\Models;

use App\Config\Database;
use PDO;

class Product {
    private $conn;
    private $table_name = "products";
    
    public $id;
    public $name;
    public $description;
    public $price;
    public $image_url;
    public $category;
    public $seller_id;
    public $created_at;
    
    public function __construct() {
        $this->conn = Database::getInstance()->getConnection();
    }
    
    // Create new product
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                  SET name=:name, description=:description, price=:price, 
                      image_url=:image_url, category=:category, seller_id=:seller_id";
        
        $stmt = $this->conn->prepare($query);
        
        // Sanitize
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->description = htmlspecialchars(strip_tags($this->description));
        $this->price = htmlspecialchars(strip_tags($this->price));
        $this->image_url = htmlspecialchars(strip_tags($this->image_url));
        $this->category = htmlspecialchars(strip_tags($this->category));
        $this->seller_id = htmlspecialchars(strip_tags($this->seller_id));
        
        // Bind values
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(":image_url", $this->image_url);
        $stmt->bindParam(":category", $this->category);
        $stmt->bindParam(":seller_id", $this->seller_id);
        
        if($stmt->execute()) {
            $this->id = $this->conn->lastInsertId();
            return true;
        }
        
        return false;
    }
    
    // Get product by ID
    public function getById($id) {
        $query = "SELECT p.*, u.name as seller_name, u.email as seller_email 
                 FROM " . $this->table_name . " p
                 LEFT JOIN users u ON p.seller_id = u.id
                 WHERE p.id = ? LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $id);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if($row) {
            $this->id = $row['id'];
            $this->name = $row['name'];
            $this->description = $row['description'];
            $this->price = $row['price'];
            $this->image_url = $row['image_url'];
            $this->category = $row['category'];
            $this->seller_id = $row['seller_id'];
            $this->created_at = $row['created_at'];
            
            return $row;
        }
        
        return false;
    }
    
    // Get all products
    public function getAll() {
        $query = "SELECT p.*, u.name as seller_name, u.email as seller_email 
                 FROM " . $this->table_name . " p
                 LEFT JOIN users u ON p.seller_id = u.id
                 ORDER BY p.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Get products by seller
    public function getBySeller($seller_id) {
        $query = "SELECT p.*, u.name as seller_name, u.email as seller_email 
                 FROM " . $this->table_name . " p
                 LEFT JOIN users u ON p.seller_id = u.id
                 WHERE p.seller_id = ?
                 ORDER BY p.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $seller_id);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Get products by category
    public function getByCategory($category) {
        $query = "SELECT p.*, u.name as seller_name, u.email as seller_email 
                 FROM " . $this->table_name . " p
                 LEFT JOIN users u ON p.seller_id = u.id
                 WHERE p.category = ?
                 ORDER BY p.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $category);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Update product
    public function update() {
        $query = "UPDATE " . $this->table_name . "
                 SET name=:name, description=:description, price=:price, 
                     image_url=:image_url, category=:category
                 WHERE id=:id AND seller_id=:seller_id";
        
        $stmt = $this->conn->prepare($query);
        
        // Sanitize
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->description = htmlspecialchars(strip_tags($this->description));
        $this->price = htmlspecialchars(strip_tags($this->price));
        $this->image_url = htmlspecialchars(strip_tags($this->image_url));
        $this->category = htmlspecialchars(strip_tags($this->category));
        $this->id = htmlspecialchars(strip_tags($this->id));
        $this->seller_id = htmlspecialchars(strip_tags($this->seller_id));
        
        // Bind values
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(":image_url", $this->image_url);
        $stmt->bindParam(":category", $this->category);
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":seller_id", $this->seller_id);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
    
    // Delete product
    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = ? AND seller_id = ?";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->bindParam(2, $this->seller_id);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
    
    // Search products
    public function search($search_term) {
        $query = "SELECT p.*, u.name as seller_name, u.email as seller_email 
                 FROM " . $this->table_name . " p
                 LEFT JOIN users u ON p.seller_id = u.id
                 WHERE p.name LIKE ? OR p.description LIKE ? OR p.category LIKE ?
                 ORDER BY p.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $search_param = "%" . $search_term . "%";
        $stmt->bindParam(1, $search_param);
        $stmt->bindParam(2, $search_param);
        $stmt->bindParam(3, $search_param);
        $stmt->execute();
        
        return $stmt;
    }
}
