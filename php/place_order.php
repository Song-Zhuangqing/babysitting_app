<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp"; // 数据库名称

// 创建连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$parentsId = $_POST['parents_id'];
$parentsName = $_POST['parents_name'];
$nanniesId = $_POST['nannies_id'];
$nanniesName = $_POST['nannies_name'];
$ordersLocation = $_POST['orders_location'];
$ordersChildName = $_POST['orders_child_name'];
$nanniesDetailsPrice = $_POST['nannies_details_price'];

// 插入新的订单记录
$sql = "INSERT INTO orders (parents_id, parents_name, nannies_id, nannies_name, orders_location, orders_child_name, nannies_details_price) VALUES ('$parentsId', '$parentsName', '$nanniesId', '$nanniesName', '$ordersLocation', '$ordersChildName', '$nanniesDetailsPrice')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
