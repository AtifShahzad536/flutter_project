<?php
$password = 'password';
$hash = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi';

echo "Testing password: $password\n";
echo "Hash: $hash\n";

if (password_verify($password, $hash)) {
    echo "✓ Matches!\n";
} else {
    echo "✗ Fails!\n";
}

// Generate a new one just to see
echo "\nNewly generated hash for 'password':\n";
echo password_hash($password, PASSWORD_DEFAULT) . "\n";
?>
