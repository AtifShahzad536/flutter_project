<?php
require 'autoload.php';
require 'config/config.php';
use App\Utils\JWT;

$payload = [
    'id' => 4,
    'name' => 'Mike Rider',
    'email' => 'mike@rider.com',
    'role' => 'rider'
];

$token = JWT::encode($payload);
echo "TOKEN_START\n";
echo $token;
echo "\nTOKEN_END\n";
