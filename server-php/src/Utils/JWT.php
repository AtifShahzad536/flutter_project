<?php

namespace App\Utils;

class JWT {
    private static function getSecret() {
        return defined('JWT_SECRET') ? JWT_SECRET : 'default_secret_key';
    }
    
    public static function encode($payload) {
        // Header
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        
        // Payload
        $payload['iat'] = time();
        $payload['exp'] = time() + JWT_EXPIRE_TIME;
        $payload_encoded = json_encode($payload);
        
        // Base64 encode
        $header_encoded = self::base64UrlEncode($header);
        $payload_encoded = self::base64UrlEncode($payload_encoded);
        
        // Signature
        $signature = hash_hmac('sha256', $header_encoded . "." . $payload_encoded, self::getSecret(), true);
        $signature_encoded = self::base64UrlEncode($signature);
        
        return $header_encoded . "." . $payload_encoded . "." . $signature_encoded;
    }
    
    public static function decode($jwt) {
        $parts = explode('.', $jwt);
        
        if (count($parts) !== 3) {
            return false;
        }
        
        $header = self::base64UrlDecode($parts[0]);
        $payload = self::base64UrlDecode($parts[1]);
        $signature = $parts[2];
        
        // Verify signature
        $header_encoded = self::base64UrlEncode($header);
        $payload_encoded = self::base64UrlEncode($payload);
        
        $expected_signature = hash_hmac('sha256', $header_encoded . "." . $payload_encoded, self::getSecret(), true);
        $expected_signature_encoded = self::base64UrlEncode($expected_signature);
        
        if (!hash_equals($expected_signature_encoded, $signature)) {
            return false;
        }
        
        $payload = json_decode($payload, true);
        
        // Check expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }
        
        return $payload;
    }
    
    private static function base64UrlEncode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
    
    private static function base64UrlDecode($data) {
        return base64_decode(str_pad(strtr($data, '-_', '+/'), strlen($data) % 4, '=', STR_PAD_RIGHT));
    }
}
