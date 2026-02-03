<?php

namespace App\Config;

use PDO;
use PDOException;

class Database {
    private static $instance = null;
    private $conn;

    private function __construct() {
        // Load config
        require_once __DIR__ . '/../../config/config.php';
        
        $host = DB_HOST;
        $db_name = DB_NAME;
        $username = DB_USER;
        $password = DB_PASS;
        $port = '3306'; // Changed from 3307 to 3306 to match netstat results

        try {
            $this->conn = new PDO("mysql:host=$host;port=$port;dbname=$db_name", $username, $password);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            die(json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]));
        }
    }

    public static function getInstance() {
        if (!self::$instance) {
            self::$instance = new Database();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->conn;
    }
}
