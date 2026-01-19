<?php

use App\Core\Router;
use App\Core\Request;

require_once __DIR__ . '/../autoload.php';

// CORS Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

$request = new Request();
error_log("Incoming Request: " . $request->getMethod() . " " . $request->getPath());
$router = new Router($request);

// Define Routes
// Auth
$router->post('/api/v1/auth/register', 'AuthController@register');
$router->post('/api/v1/auth/login', 'AuthController@login');
$router->get('/api/v1/auth/profile', 'AuthController@getProfile');

// Products
$router->get('/api/v1/products', 'ProductController@getAll');
$router->post('/api/v1/products', 'ProductController@create');

// Orders
$router->get('/api/v1/orders/available', 'OrderController@getAvailableOrders'); // Matches frontend
$router->get('/api/v1/orders/rider', 'OrderController@getRiderOrders');         // Matches frontend
$router->get('/api/v1/orders/my-orders', 'OrderController@getMyOrders');
$router->post('/api/v1/orders', 'OrderController@create');

// Dashboard
$router->get('/api/v1/dashboard', 'DashboardController@getDashboardStats');     // Matches frontend

// Others
$router->get('/api/v1/notifications', 'NotificationController@getAll');
$router->get('/api/v1/users', 'ChatController@getUsers');
$router->get('/api/v1/chats', 'ChatController@getConversations');

$router->get('/api/v1/ping', function() {
    echo json_encode(['status' => 'success', 'message' => 'pong', 'time' => date('Y-m-d H:i:s')]);
});

// Resolve the request
try {
    $router->resolve();
} catch (\Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Internal Server Error', 'message' => $e->getMessage()]);
}
