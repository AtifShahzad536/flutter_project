<?php

namespace App\Controllers;

use App\Models\Notification;
use App\Middleware\AuthMiddleware;

class NotificationController extends BaseController {
    
    public function getAll($request) {
        $user = AuthMiddleware::getUser();
        if (!$user) {
            return $this->error("Unauthorized", 401);
        }
        
        $notificationModel = new Notification();
        $notifications = $notificationModel->getByUserId($user['id']);
        
        return $this->success($notifications);
    }
    
    public function markRead($request) {
        $user = AuthMiddleware::getUser();
        if (!$user) {
            return $this->error("Unauthorized", 401);
        }
        
        $data = $request->getJson();
        if (!isset($data['id'])) {
            return $this->error("Notification ID is required", 400);
        }
        
        $notificationModel = new Notification();
        if ($notificationModel->markAsRead($data['id'], $user['id'])) {
            return $this->success("Notification marked as read");
        }
        
        return $this->error("Failed to update notification");
    }
}
