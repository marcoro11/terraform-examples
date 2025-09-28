#!/bin/bash

yum update -y
yum install -y httpd php php-mysqlnd php-gd php-xml php-mbstring mysql

systemctl start httpd
systemctl enable httpd

cat > /var/www/html/index.php << 'EOF'
<?php
// Database configuration
$db_host = '${database_endpoint}';
$db_user = '${db_username}';
$db_pass = '${db_password}';
$db_name = '${db_name}';

// Redis configuration
$redis_host = '${redis_endpoint}';
$redis_port = 6379;

// Connect to database
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Connect to Redis
$redis = new Redis();
$redis->connect($redis_host, $redis_port);

// Increment visitor counter
$visitors = $redis->incr('visitors');

// Get server info
$result = $conn->query("SELECT VERSION() as version");
$row = $result->fetch_assoc();

echo "<h1>Welcome to Your Web Application</h1>";
echo "<p>Database Version: " . $row['version'] . "</p>";
echo "<p>Visitors: " . $visitors . "</p>";
echo "<p>Server: " . gethostname() . "</p>";
echo "<p>Time: " . date('Y-m-d H:i:s') . "</p>";

$conn->close();
$redis->close();
?>
EOF

chown apache:apache /var/www/html/index.php
chmod 644 /var/www/html/index.php

systemctl restart httpd