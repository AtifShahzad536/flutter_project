<?php

namespace App\Controllers;

use App\Core\Request;
use App\Config\Database;
use PDO;

class AuthController extends BaseController {
    public function register(Request $request) {
        $data = $request->getBody();
        
        $name = $data['name'] ?? null;
        $email = $data['email'] ?? null;
        $password = $data['password'] ?? null;
        $role = $data['role'] ?? 'user';

        if (!$name || !$email || !$password) {
            return $this->error('Name, email, and password are required');
        }

        $db = Database::getInstance()->getConnection();

        // Check if email exists
        $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            return $this->error('Email already registered');
        }

        // Hash password
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

        // Insert user
        $stmt = $db->prepare("INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)");
        if ($stmt->execute([$name, $email, $hashedPassword, $role])) {
            return $this->success(null, 'User registered successfully');
        }

        return $this->error('Failed to register user');
    }

    public function login(Request $request) {
        $data = $request->getBody();
        
        $email = $data['email'] ?? null;
        $password = $data['password'] ?? null;

        if (!$email || !$password) {
            return $this->error('Email and password are required');
        }

        $db = Database::getInstance()->getConnection();
        $stmt = $db->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($password, $user['password'])) {
            return $this->error('Invalid credentials', 401);
        }

        // Generate Token (Mock JWT for now, can integrate JWT library later)
        // Note: Using the same logic as the root AuthMiddleware/JWT for compatibility
        $token_payload = [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'role' => $user['role']
        ];
        
        $token = \App\Utils\JWT::encode($token_payload);

        return $this->success([
            'token' => $token,
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'role' => $user['role']
            ]
        ], 'Login successful');
    }

    public function getProfile(Request $request) {
        $currentUser = \App\Middleware\AuthMiddleware::getUser();
        if (!$currentUser) {
            return $this->error('Unauthorized', 401);
        }

        $userModel = new \App\Models\User();
        if ($userModel->getById($currentUser['id'])) {
            return $this->success([
                'id' => $userModel->id,
                'name' => $userModel->name,
                'email' => $userModel->email,
                'role' => $userModel->role,
                'phone' => $userModel->phone,
                'created_at' => $userModel->created_at
            ]);
        }

        return $this->error('User not found', 404);
    }
}
