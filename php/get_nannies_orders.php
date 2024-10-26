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

$nanniesId = $_POST['nannies_id'];

// 防止SQL注入
$nanniesId = $conn->real_escape_string($nanniesId);

// 获取保姆的所有订单
$sql = "SELECT o.orders_date, p.parents_name, o.orders_location, o.orders_child_name, o.nannies_details_price
        FROM orders o
        JOIN parents p ON o.parents_id = p.parents_id
        WHERE o.nannies_id = '$nanniesId'
        ORDER BY o.orders_date DESC";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $orders = [];
    while($row = $result->fetch_assoc()) {
        $orders[] = $row;
    }
    echo json_encode(['status' => 'success', 'orders' => $orders]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No orders found']);
}

$conn->close();
?>
