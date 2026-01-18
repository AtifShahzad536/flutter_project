<?php

namespace App\Core;

class Request {
    public function getMethod() {
        return $_SERVER['REQUEST_METHOD'];
    }

    public function getPath() {
        $path = $_SERVER['REQUEST_URI'] ?? '/';
        
        // Remove base path /server-php if present
        if (strpos($path, '/server-php') === 0) {
            $path = substr($path, 11);
        }
        
        $position = strpos($path, '?');
        if ($position === false) {
            return empty($path) ? '/' : $path;
        }
        $path = substr($path, 0, $position);
        $path = rtrim($path, '/');
        return empty($path) ? '/' : $path;
    }

    private array $params = [];

    public function setParams($params) {
        $this->params = $params;
    }

    public function getParam($index) {
        return $this->params[$index] ?? null;
    }

    public function getBody() {
        $data = [];
        $method = $this->getMethod();

        if ($method === 'GET') {
            foreach ($_GET as $key => $value) {
                $data[$key] = filter_input(INPUT_GET, $key, FILTER_SANITIZE_SPECIAL_CHARS);
            }
        }
        
        if (in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'])) {
            $json = file_get_contents('php://input');
            $data = json_decode($json, true) ?? [];
            if (empty($data) && $method === 'POST') {
                foreach ($_POST as $key => $value) {
                    $data[$key] = filter_input(INPUT_POST, $key, FILTER_SANITIZE_SPECIAL_CHARS);
                }
            }
        }
        return $data;
    }
}
