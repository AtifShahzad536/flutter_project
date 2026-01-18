<?php

namespace App\Controllers;

abstract class BaseController {
    protected function json($data, $statusCode = 200) {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }

    protected function success($data = [], $message = 'Success') {
        return $this->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ]);
    }

    protected function error($message = 'An error occurred', $statusCode = 400) {
        return $this->json([
            'success' => false,
            'message' => $message
        ], $statusCode);
    }
}
