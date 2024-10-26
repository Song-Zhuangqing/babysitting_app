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

$parentsId = $_POST['parents_id'];

// 获取订单信息
$sql = "SELECT orders.orders_id, orders.orders_date, orders.orders_location, orders.orders_child_name, 
        nannies.nannies_name, nannies.nannies_id, orders.parents_id, orders.nannies_details_price 
        FROM orders 
        JOIN nannies ON orders.nannies_id = nannies.nannies_id
        WHERE orders.parents_id = '$parentsId'";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $orders = [];
    while ($row = $result->fetch_assoc()) {
        $orders[] = [
            'orders_id' => $row['orders_id'],
            'orders_date' => $row['orders_date'],
            'nannies_name' => $row['nannies_name'],
            'nannies_id' => $row['nannies_id'],
            'parents_id' => $row['parents_id'],
            'orders_location' => $row['orders_location'],
            'orders_child_name' => $row['orders_child_name'],
            'nannies_details_price' => $row['nannies_details_price']
        ];
    }
    echo json_encode(['status' => 'success', 'orders' => $orders]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No orders found']);
}

$conn->close();
?>
