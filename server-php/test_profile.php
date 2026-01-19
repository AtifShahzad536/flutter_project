<?php
require 'autoload.php';
require 'config/config.php';
use App\Utils\JWT;

$payload = [
    'id' => 9, // Let's use 'atif' (ride@gmail.com) from the list
    'name' => 'atif',
    'email' => 'ride@gmail.com',
    'role' => 'rider'
];

$token = JWT::encode($payload);

$ch = curl_init('http://localhost:8000/api/v1/auth/profile');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token
]);

$response = curl_exec($ch);
$info = curl_getinfo($ch);

echo "STATUS: " . $info['http_code'] . "\n";
echo "RESPONSE_START\n";
echo $response;
echo "\nRESPONSE_END\n";
curl_close($ch);
