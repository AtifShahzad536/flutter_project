<?php

namespace App\Middleware;

use App\Utils\JWT;

class AuthMiddleware {
    public static function authenticate() {
        error_log("AuthMiddleware::authenticate called");
        
        $authHeader = null;
        $headers = array_change_key_case(getallheaders(), CASE_LOWER);
        
        if (isset($headers['authorization'])) {
            $authHeader = $headers['authorization'];
        } elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        } elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
        }
        
        error_log("Auth Header found: " . ($authHeader ? 'YES' : 'NO'));

        if (!$authHeader) {
            self::sendUnauthorized('No authentication header found');
            return false;
        }
        
        // Robust token extraction (case-insensitive Bearer)
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $token = $matches[1];
        } else {
            // Fallback for cases without Bearer prefix
            $token = $authHeader;
        }
        
        if (!$token || $token === 'null') {
            self::sendUnauthorized('Invalid or missing token');
            return false;
        }
        
        $payload = JWT::decode($token);
        
        if (!$payload) {
            error_log("JWT Decode failed for token: " . substr($token, 0, 10) . "...");
            self::sendUnauthorized('Invalid or expired token');
            return false;
        }
        
        // Store user data in global variable for controllers to use
        $GLOBALS['current_user'] = (array)$payload;
        error_log("Auth success: User ID " . ($payload['id'] ?? 'unknown'));
        
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
        $userRole = isset($user['role']) ? strtolower($user['role']) : null;
        $requiredRoleLower = strtolower($requiredRole);

        error_log("Required role: $requiredRoleLower, User role: $userRole");
        
        if (!$userRole || $userRole !== $requiredRoleLower) {
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
