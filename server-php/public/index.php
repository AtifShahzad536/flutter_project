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
$router = new Router($request);

// Define Routes
$router->post('/api/v1/auth/register', 'AuthController@register');
$router->post('/api/v1/auth/login', 'AuthController@login');
$router->get('/api/v1/rider/stats', 'DashboardController@getRiderStats');
$router->get('/api/v1/rider/active-orders', 'DashboardController@getActiveOrders');
$router->get('/api/v1/ping', function() {
    echo json_encode(['message' => 'pong', 'time' => date('Y-m-d H:i:s')]);
});

// Resolve the request
try {
    $router->resolve();
} catch (\Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Internal Server Error', 'message' => $e->getMessage()]);
}
