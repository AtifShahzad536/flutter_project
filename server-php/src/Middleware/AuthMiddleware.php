<?php

namespace App\Middleware;

use App\Utils\JWT;

class AuthMiddleware {
    public static function authenticate() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        
        if (!$authHeader) {
            self::sendUnauthorized('No authentication token provided');
            return false;
        }
        
        $token = str_replace('Bearer ', '', $authHeader);
        
        if (!$token) {
            self::sendUnauthorized('Invalid token format');
            return false;
        }
        
        $payload = JWT::decode($token);
        
        if (!$payload) {
            self::sendUnauthorized('Invalid or expired token');
            return false;
        }
        
        // Store user data in global variable for controllers to use
        $GLOBALS['current_user'] = (array)$payload;
        
        return true;
    }
    
    public static function getUser() {
        return $GLOBALS['current_user'] ?? null;
    }
    
    public static function requireRole($requiredRole) {
        if (!self::authenticate()) {
            return false;
        }
        
        $user = $GLOBALS['current_user'];
        
        if (!isset($user['role']) || $user['role'] !== $requiredRole) {
            self::sendForbidden('Access denied. Required role: ' . $requiredRole);
            return false;
        }
        
        return true;
    }
    
    private static function sendUnauthorized($message) {
        http_response_code(401);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => $message
        ]);
        exit();
    }
    
    private static function sendForbidden($message) {
        http_response_code(403);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => $message
        ]);
        exit();
    }
}
