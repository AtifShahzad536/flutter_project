<?php

namespace App\Core;

class Router {
    protected array $routes = [];
    public Request $request;

    public function __construct(Request $request) {
        $this->request = $request;
    }

    public function get($path, $callback) {
        $this->routes['GET'][$path] = $callback;
    }

    public function post($path, $callback) {
        $this->routes['POST'][$path] = $callback;
    }

    public function put($path, $callback) {
        $this->routes['PUT'][$path] = $callback;
    }

    public function delete($path, $callback) {
        $this->routes['DELETE'][$path] = $callback;
    }

    public function resolve() {
        $path = $this->request->getPath();
        $method = $this->request->getMethod();
        
        header("X-Debug-Path: $path");
        header("X-Debug-Method: $method");
        
        $path = rtrim($path, '/') ?: '/';
        $callback = $this->routes[$method][$path] ?? false;

        // Try dynamic matching if literal match fails
        if ($callback === false) {
            foreach ($this->routes[$method] as $route => $cb) {
                $normalizedRoute = rtrim($route, '/') ?: '/';
                // Convert {id} to ([^/]+)
                $pattern = preg_replace('#\{[^/]+\}#', '([^/]+)', $normalizedRoute);
                $pattern = "~^" . $pattern . "$~iD";
                
                error_log("Testing route: $normalizedRoute (Pattern: $pattern) against Path: $path");
                if (preg_match($pattern, $path, $matches)) {
                    error_log("Match found! Matches: " . json_encode($matches));
                    array_shift($matches); // Remove full match
                    $this->request->setParams($matches);
                    $callback = $cb;
                    break;
                }
            }
        }

        if ($callback === false) {
            http_response_code(404);
            echo json_encode([
                'error' => 'Not Found', 
                'path' => $path,
                'method' => $method,
                'source' => 'Router'
            ]);
            exit;
        }

        if (is_string($callback)) {
            [$controller, $action] = explode('@', $callback);
            $controller = "App\\Controllers\\$controller";
            $instance = new $controller();
            return call_user_func([$instance, $action], $this->request);
        }

        return call_user_func($callback, $this->request);
    }
}
