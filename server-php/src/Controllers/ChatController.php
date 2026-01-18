<?php

namespace App\Controllers;

use App\Models\Message;
use App\Models\User;
use App\Middleware\AuthMiddleware;

class ChatController extends BaseController {
    
    public function getConversations($request) {
        $user = AuthMiddleware::getUser();
        if (!$user) {
            return $this->error("Unauthorized", 401);
        }
        
        $messageModel = new Message();
        $conversations = $messageModel->getConversations($user['id']);
        
        return $this->success($conversations);
    }
    
    public function getHistory($request) {
        $user = AuthMiddleware::getUser();
        if (!$user) {
            return $this->error("Unauthorized", 401);
        }
        
        $params = $request->getParams();
        $contact_id = $params['id'] ?? null;
        
        if (!$contact_id) {
            return $this->error("Contact ID is required", 400);
        }
        
        $messageModel = new Message();
        $history = $messageModel->getHistory($user['id'], $contact_id);
        
        return $this->success($history);
    }
    
    public function sendMessage($request) {
        $user = AuthMiddleware::getUser();
        if (!$user) {
            return $this->error("Unauthorized", 401);
        }
        
        $data = $request->getJson();
        if (!isset($data['receiver_id']) || !isset($data['text'])) {
            return $this->error("Receiver ID and text are required", 400);
        }
        
        $messageModel = new Message();
        $messageModel->sender_id = $user['id'];
        $messageModel->receiver_id = $data['receiver_id'];
        $messageModel->text = $data['text'];
        
        if ($messageModel->create()) {
            return $this->success("Message sent successfully");
        }
        
        return $this->error("Failed to send message");
    }
    
    public function getUsers($request) {
        $user = AuthMiddleware::getUser();
        if (!$user) {
            return $this->error("Unauthorized", 401);
        }
        
        $userModel = new User();
        $stmt = $userModel->getAll();
        $users = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        
        // Filter out current user
        $users = array_filter($users, function($u) use ($user) {
            return $u['id'] != $user['id'];
        });
        
        return $this->success(array_values($users));
    }
}
