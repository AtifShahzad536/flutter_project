<?php
require_once __DIR__ . '/autoload.php';
require_once __DIR__ . '/config/config.php';
use App\Config\Database;

try {
    $db = Database::getInstance()->getConnection();
    $stmt = $db->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Tables in " . DB_NAME . ":\n";
    foreach ($tables as $table) {
        echo "- $table\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
