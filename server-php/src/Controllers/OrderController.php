<?php

namespace App\Controllers;

use App\Core\Request;
use App\Models\Order;
use PDO;

class OrderController extends BaseController {
    private $order;
    
    public function __construct() {
        $this->order = new Order();
    }
    
    public function create(Request $request) {
        \App\Middleware\AuthMiddleware::authenticate();
        $currentUser = $GLOBALS['current_user'] ?? null;
        if (!$currentUser) return $this->error('Unauthorized', 401);

        $data = $request->getBody();
        
        if (empty($data['products']) || empty($data['total_amount']) || empty($data['customer']) || empty($data['payment_type'])) {
            return $this->error('Missing required fields');
        }
        
        $this->order->buyer_id = $currentUser['id'];
        $this->order->total_amount = $data['total_amount'];
        $this->order->payment_type = $data['payment_type'];
        $this->order->customer_name = $data['customer']['name'] ?? '';
        $this->order->customer_phone = $data['customer']['phone'] ?? '';
        $this->order->customer_address = $data['customer']['address'] ?? '';
        $this->order->customer_map_link = $data['customer']['mapLink'] ?? '';
        
        $this->order->pickup_address = $data['pickup_location']['address'] ?? '';
        $this->order->pickup_lat = $data['pickup_location']['lat'] ?? '';
        $this->order->pickup_lng = $data['pickup_location']['lng'] ?? '';
        
        $this->order->delivery_address = $data['delivery_location']['address'] ?? '';
        $this->order->delivery_lat = $data['delivery_location']['lat'] ?? '';
        $this->order->delivery_lng = $data['delivery_location']['lng'] ?? '';
        
        if ($this->order->create()) {
            if ($this->order->addOrderItems($this->order->id, $data['products'])) {
                return $this->success([
                    'id' => $this->order->id,
                    'order_id' => $this->order->order_id,
                    'total_amount' => $this->order->total_amount,
                    'status' => 'Pending'
                ], 'Order created successfully');
            }
            return $this->error('Order created but failed to add items', 500);
        }
        return $this->error('Order creation failed', 500);
    }
    
    public function getMyOrders(Request $request) {
        \App\Middleware\AuthMiddleware::authenticate();
        $currentUser = $GLOBALS['current_user'] ?? null;
        if (!$currentUser) return $this->error('Unauthorized', 401);
        
        $stmt = $this->order->getByBuyer($currentUser['id']);
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $this->success($orders);
    }
    
    public function getAvailableOrders(Request $request) {
        \App\Middleware\AuthMiddleware::requireRole('rider');
        $currentUser = $GLOBALS['current_user'] ?? null;
        if (!$currentUser || $currentUser['role'] !== 'rider') {
            return $this->error('Access denied', 403);
        }
        
        $stmt = $this->order->getAvailableOrders();
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $this->success($orders);
    }
    
    public function getOrder(Request $request) {
        $id = $request->getBody()['id'] ?? $request->getParam(0);
        error_log("OrderController::getOrder called with ID: " . ($id ?? 'NULL'));
        if (!$id) return $this->error('Order ID required');

        $orderData = $this->order->getById($id);
        if ($orderData) {
            $items_stmt = $this->order->getOrderItems($id);
            $orderData['items'] = $items_stmt->fetchAll(PDO::FETCH_ASSOC);
            return $this->success($orderData);
        }
        return $this->error("Order with DB ID '$id' not found in database", 404);
    }
    
    public function pickOrder(Request $request) {
        $currentUser = $GLOBALS['current_user'] ?? null;
        if (!$currentUser || $currentUser['role'] !== 'rider') {
            return $this->error('Access denied', 403);
        }
        
        $data = $request->getBody();
        $id = $data['id'] ?? null;
        if (!$id) return $this->error('Order ID required');

        $this->order->id = $id;
        if ($this->order->pickOrder($currentUser['id'])) {
            return $this->success(null, 'Order picked successfully');
        }
        return $this->error('Failed to pick order', 500);
    }
    
    public function updateStatus(Request $request) {
        $currentUser = $GLOBALS['current_user'] ?? null;
        if (!$currentUser || $currentUser['role'] !== 'rider') {
            return $this->error('Access denied', 403);
        }
        
        $data = $request->getBody();
        $id = $data['id'] ?? null;
        $status = $data['status'] ?? null;
        
        if (!$id || !$status) return $this->error('Order ID and status required');

        $allowed_statuses = ['Picked', 'OnTheWay', 'Delivered', 'Cancelled'];
        if (!in_array($status, $allowed_statuses)) return $this->error('Invalid status');
        
        $this->order->id = $id;
        $this->order->payment_type = $data['payment_type'] ?? 'Cash';
        
        if ($this->order->updateStatus($status, $currentUser['id'])) {
            return $this->success(null, 'Order status updated successfully');
        }
        return $this->error('Failed to update order status', 500);
    }
    
    public function getRiderOrders(Request $request) {
        \App\Middleware\AuthMiddleware::requireRole('rider');
        $currentUser = $GLOBALS['current_user'] ?? null;
        if (!$currentUser || $currentUser['role'] !== 'rider') {
            return $this->error('Access denied', 403);
        }
        
        $stmt = $this->order->getByRider($currentUser['id']);
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $this->success($orders);
    }
}
