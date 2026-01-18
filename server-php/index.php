<?php

require_once __DIR__ . '/autoload.php';
require_once __DIR__ . '/config/config.php';

use App\Core\Request;
use App\Core\Router;
use App\Middleware\AuthMiddleware;

// CORS Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

$request = new Request();
$router = new Router($request);

// --- Auth Routes ---
$router->post('/api/v1/auth/register', 'AuthController@register');
$router->post('/api/v1/auth/login', 'AuthController@login');
$router->get('/api/v1/auth/profile', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\AuthController();
        return $controller->getProfile($request);
    }
});

// --- Product Routes ---
$router->get('/api/v1/products', 'ProductController@getAll');
$router->post('/api/v1/products', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\ProductController();
        return $controller->create($request);
    }
});
$router->get('/api/v1/products/seller', 'ProductController@getBySeller');
$router->get('/api/v1/products/{id}', function($request) {
    // The path parameter {id} is automatically passed as the first parameter to getParam()
    // The ProductController@getProduct method will handle retrieving the ID from the request.
    $controller = new \App\Controllers\ProductController();
    return $controller->getProduct($request);
});

// --- Order Routes ---
$router->post('/api/v1/orders', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\OrderController();
        return $controller->create($request);
    }
});
$router->get('/api/v1/orders/detail', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\OrderController();
        return $controller->getOrder($request);
    }
});
$router->get('/api/v1/orders/{id}', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\OrderController();
        return $controller->getOrder($request);
    }
});
$router->get('/api/v1/orders/my', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\OrderController();
        return $controller->getMyOrders($request);
    }
});
$router->get('/api/v1/orders/available', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\OrderController();
        return $controller->getAvailableOrders($request);
    }
});
$router->get('/api/v1/orders/rider', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\OrderController();
        return $controller->getRiderOrders($request);
    }
});
$router->put('/api/v1/orders/status', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\OrderController();
        return $controller->updateStatus($request);
    }
});
$router->post('/api/v1/orders/pick', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\OrderController();
        return $controller->pickOrder($request);
    }
});

// --- Dashboard Routes ---
$router->get('/api/v1/dashboard', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\DashboardController();
        return $controller->getDashboardStats($request);
    }
});
$router->get('/api/v1/rider/stats', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\DashboardController();
        return $controller->getRiderStats($request);
    }
});

// --- Notification Routes ---
$router->get('/api/v1/notifications', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\NotificationController();
        return $controller->getAll($request);
    }
});
$router->post('/api/v1/notifications/read', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\NotificationController();
        return $controller->markRead($request);
    }
});

// --- Chat Routes ---
$router->get('/api/v1/chats', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\ChatController();
        return $controller->getConversations($request);
    }
});
$router->get('/api/v1/chats/history/{id}', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\ChatController();
        return $controller->getHistory($request);
    }
});
$router->post('/api/v1/chats/send', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\ChatController();
        return $controller->sendMessage($request);
    }
});
$router->get('/api/v1/users', function($request) {
    if (AuthMiddleware::authenticate()) {
        $controller = new \App\Controllers\ChatController();
        return $controller->getUsers($request);
    }
});

// Root information
$router->get('/', function() {
    echo json_encode([
        'success' => true,
        'message' => 'Export Trix PHP API is running (Centralized Router)',
        'version' => '2.0.0'
    ]);
});

// Handle subdirectory if needed in Request or here
// For now, let's prefix routes with /server-php if the server is hosted there
// Or assume .htaccess handles it.

$router->resolve();
