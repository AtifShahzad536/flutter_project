<?php
require 'autoload.php';
require 'config/config.php';
use App\Config\Database;

try {
    $db = Database::getInstance()->getConnection();
    $stmt = $db->query("SELECT id, name, email, role FROM users");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "USERS_START\n";
    echo json_encode($users);
    echo "\nUSERS_END\n";
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage();
}
