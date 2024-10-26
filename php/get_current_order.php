<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp";

// 创建连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$user_email = $_POST['user_email'];

// 使用邮箱查找订单信息
$sql = "SELECT orders_id, parents_id, nannies_id FROM orders WHERE parents_email = '$user_email' LIMIT 1";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        'status' => 'success',
        'order_id' => $row['orders_id'], 
        'parents_id' => $row['parents_id'], 
        'nannies_id' => $row['nannies_id']
    ]);
} else {
    echo json_encode([
        'status' => 'error', 
        'message' => 'No order found for this user'
    ]);
}

$conn->close();
?>
