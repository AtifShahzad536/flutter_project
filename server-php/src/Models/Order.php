<?php

namespace App\Models;

use App\Config\Database;
use PDO;

class Order {
    private $conn;
    private $table_name = "orders";
    private $order_items_table = "order_items";
    
    public $id;
    public $order_id;
    public $buyer_id;
    public $rider_id;
    public $total_amount;
    public $payment_type;
    public $payment_status;
    public $status;
    public $customer_name;
    public $customer_phone;
    public $customer_address;
    public $customer_map_link;
    public $pickup_address;
    public $pickup_lat;
    public $pickup_lng;
    public $delivery_address;
    public $delivery_lat;
    public $delivery_lng;
    public $created_at;
    public $updated_at;
    
    public function __construct() {
        $this->conn = Database::getInstance()->getConnection();
    }
    
    // Create new order
    public function create() {
        // Generate unique order ID
        $this->order_id = 'ORD' . date('Ymd') . str_pad(mt_rand(1, 999), 3, '0', STR_PAD_LEFT);
        
        $query = "INSERT INTO " . $this->table_name . " 
                  SET order_id=:order_id, buyer_id=:buyer_id, total_amount=:total_amount,
                      payment_type=:payment_type, customer_name=:customer_name,
                      customer_phone=:customer_phone, customer_address=:customer_address,
                      customer_map_link=:customer_map_link, pickup_address=:pickup_address,
                      pickup_lat=:pickup_lat, pickup_lng=:pickup_lng, delivery_address=:delivery_address,
                      delivery_lat=:delivery_lat, delivery_lng=:delivery_lng";
        
        $stmt = $this->conn->prepare($query);
        
        // Sanitize
        $this->buyer_id = htmlspecialchars(strip_tags($this->buyer_id));
        $this->total_amount = htmlspecialchars(strip_tags($this->total_amount));
        $this->payment_type = htmlspecialchars(strip_tags($this->payment_type));
        $this->customer_name = htmlspecialchars(strip_tags($this->customer_name));
        $this->customer_phone = htmlspecialchars(strip_tags($this->customer_phone));
        $this->customer_address = htmlspecialchars(strip_tags($this->customer_address));
        $this->customer_map_link = htmlspecialchars(strip_tags($this->customer_map_link));
        $this->pickup_address = htmlspecialchars(strip_tags($this->pickup_address ?? ''));
        $this->pickup_lat = htmlspecialchars(strip_tags($this->pickup_lat ?? ''));
        $this->pickup_lng = htmlspecialchars(strip_tags($this->pickup_lng ?? ''));
        $this->delivery_address = htmlspecialchars(strip_tags($this->delivery_address ?? ''));
        $this->delivery_lat = htmlspecialchars(strip_tags($this->delivery_lat ?? ''));
        $this->delivery_lng = htmlspecialchars(strip_tags($this->delivery_lng ?? ''));
        
        // Bind values
        $stmt->bindParam(":order_id", $this->order_id);
        $stmt->bindParam(":buyer_id", $this->buyer_id);
        $stmt->bindParam(":total_amount", $this->total_amount);
        $stmt->bindParam(":payment_type", $this->payment_type);
        $stmt->bindParam(":customer_name", $this->customer_name);
        $stmt->bindParam(":customer_phone", $this->customer_phone);
        $stmt->bindParam(":customer_address", $this->customer_address);
        $stmt->bindParam(":customer_map_link", $this->customer_map_link);
        $stmt->bindParam(":pickup_address", $this->pickup_address);
        $stmt->bindParam(":pickup_lat", $this->pickup_lat);
        $stmt->bindParam(":pickup_lng", $this->pickup_lng);
        $stmt->bindParam(":delivery_address", $this->delivery_address);
        $stmt->bindParam(":delivery_lat", $this->delivery_lat);
        $stmt->bindParam(":delivery_lng", $this->delivery_lng);
        
        if($stmt->execute()) {
            $this->id = $this->conn->lastInsertId();
            return true;
        }
        
        return false;
    }
    
    // Add order items
    public function addOrderItems($order_id, $items) {
        $query = "INSERT INTO " . $this->order_items_table . " 
                  (order_id, product_id, quantity, price) VALUES 
                  (:order_id, :product_id, :quantity, :price)";
        
        $stmt = $this->conn->prepare($query);
        
        foreach($items as $item) {
            $stmt->bindParam(":order_id", $order_id);
            $stmt->bindParam(":product_id", $item['product_id']);
            $stmt->bindParam(":quantity", $item['quantity']);
            $stmt->bindParam(":price", $item['price']);
            
            if(!$stmt->execute()) {
                return false;
            }
        }
        
        return true;
    }
    
    // Get order by ID with details
    public function getById($id) {
        $query = "SELECT o.*, 
                        buyer.name as buyer_name, buyer.email as buyer_email,
                        rider.name as rider_name, rider.phone as rider_phone
                 FROM " . $this->table_name . " o
                 LEFT JOIN users buyer ON o.buyer_id = buyer.id
                 LEFT JOIN users rider ON o.rider_id = rider.id
                 WHERE o.id = ? LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $id);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if($row) {
            $this->id = $row['id'];
            $this->order_id = $row['order_id'];
            $this->buyer_id = $row['buyer_id'];
            $this->rider_id = $row['rider_id'];
            $this->total_amount = $row['total_amount'];
            $this->payment_type = $row['payment_type'];
            $this->payment_status = $row['payment_status'];
            $this->status = $row['status'];
            $this->customer_name = $row['customer_name'];
            $this->customer_phone = $row['customer_phone'];
            $this->customer_address = $row['customer_address'];
            $this->customer_map_link = $row['customer_map_link'];
            $this->pickup_address = $row['pickup_address'];
            $this->pickup_lat = $row['pickup_lat'];
            $this->pickup_lng = $row['pickup_lng'];
            $this->delivery_address = $row['delivery_address'];
            $this->delivery_lat = $row['delivery_lat'];
            $this->delivery_lng = $row['delivery_lng'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            
            return $row;
        }
        
        return false;
    }
    
    // Get order items
    public function getOrderItems($order_id) {
        $query = "SELECT oi.*, p.name as product_name, p.image_url as product_image
                 FROM " . $this->order_items_table . " oi
                 LEFT JOIN products p ON oi.product_id = p.id
                 WHERE oi.order_id = ?";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $order_id);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Get orders by buyer
    public function getByBuyer($buyer_id) {
        $query = "SELECT o.*, 
                        buyer.name as buyer_name, buyer.email as buyer_email,
                        rider.name as rider_name, rider.phone as rider_phone
                 FROM " . $this->table_name . " o
                 LEFT JOIN users buyer ON o.buyer_id = buyer.id
                 LEFT JOIN users rider ON o.rider_id = rider.id
                 WHERE o.buyer_id = ?
                 ORDER BY o.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $buyer_id);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Get available orders for riders
    public function getAvailableOrders() {
        $query = "SELECT o.*, 
                        buyer.name as buyer_name, buyer.email as buyer_email
                 FROM " . $this->table_name . " o
                 LEFT JOIN users buyer ON o.buyer_id = buyer.id
                 WHERE o.status IN ('Pending', 'Confirmed') AND o.rider_id IS NULL
                 ORDER BY o.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Get orders by rider
    public function getByRider($rider_id) {
        $query = "SELECT o.*, 
                        buyer.name as buyer_name, buyer.email as buyer_email
                 FROM " . $this->table_name . " o
                 LEFT JOIN users buyer ON o.buyer_id = buyer.id
                 WHERE o.rider_id = ?
                 ORDER BY o.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $rider_id);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Update order status
    public function updateStatus($status, $rider_id = null) {
        $query = "UPDATE " . $this->table_name . "
                 SET status = :status";
        
        if($rider_id) {
            $query .= ", rider_id = :rider_id";
        }
        
        if($status === 'Delivered' && $this->payment_type === 'Cash') {
            $query .= ", payment_status = 'Paid'";
        }
        
        $query .= " WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        
        $this->status = htmlspecialchars(strip_tags($status));
        $this->id = htmlspecialchars(strip_tags($this->id));
        
        $stmt->bindParam(":status", $this->status);
        $stmt->bindParam(":id", $this->id);
        
        if($rider_id) {
            $stmt->bindParam(":rider_id", $rider_id);
        }
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
    
    // Pick order (assign rider)
    public function pickOrder($rider_id) {
        $query = "UPDATE " . $this->table_name . "
                 SET rider_id = :rider_id, status = 'Picked'
                 WHERE id = :id AND rider_id IS NULL";
        
        $stmt = $this->conn->prepare($query);
        
        $this->id = htmlspecialchars(strip_tags($this->id));
        $rider_id = htmlspecialchars(strip_tags($rider_id));
        
        $stmt->bindParam(":rider_id", $rider_id);
        $stmt->bindParam(":id", $this->id);
        
        if($stmt->execute()) {
            return true;
        }
        
        return false;
    }
    
    // Get recent orders
    public function getRecentOrders($limit = 5) {
        $query = "SELECT o.id, o.order_id, o.status, o.total_amount, o.customer_address, o.created_at
                 FROM " . $this->table_name . " o
                 ORDER BY o.created_at DESC
                 LIMIT ?";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt;
    }
    
    // Get order statistics
    public function getStats() {
        $stats = array();
        
        // Total completed orders
        $query = "SELECT COUNT(*) as completed_trips FROM " . $this->table_name . " WHERE status = 'Delivered'";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        $stats['completed_trips'] = $result['completed_trips'];
        
        // Active orders
        $query = "SELECT * FROM " . $this->table_name . " WHERE status IN ('Pending', 'Picked') ORDER BY created_at DESC LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        $stats['active_order'] = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $stats;
    }
}
