<?php
$data = ['email' => 'mike@rider.com', 'password' => 'password'];
$json = json_encode($data);

$ch = curl_init('http://localhost:8000/api/v1/auth/login');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $json);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($json)
]);

$response = curl_exec($ch);
$info = curl_getinfo($ch);

if (curl_errno($ch)) {
    echo 'Login Curl error: ' . curl_error($ch);
} else {
    echo "Login Status: " . $info['http_code'] . "\n";
    $data = json_decode($response, true);
    $token = $data['data']['token'] ?? null;
    
    if ($token) {
        echo "Token obtained. Testing dashboard...\n";
        $ch2 = curl_init('http://localhost:8000/api/v1/dashboard');
        curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch2, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Accept: application/json'
        ]);
        
        $response2 = curl_exec($ch2);
        $info2 = curl_getinfo($ch2);
        
        echo "Dashboard Status: " . $info2['http_code'] . "\n";
        echo "Dashboard Response: " . $response2 . "\n";
        curl_close($ch2);
    } else {
        echo "Login failed or no token in response\n";
    }
}

curl_close($ch);
?>
