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

// 获取 POST 请求参数
$parentsId = $_POST['parents_id'];
$ordersId = $_POST['orders_id'];
$nanniesId = $_POST['nannies_id'];
$reviewsContent = $_POST['reviews_content'];
$reviewsStar = $_POST['reviews_star']; // 获取评分

// 插入评论并包含评分
$sql = "INSERT INTO reviews (parents_id, orders_id, nannies_id, reviews_content, reviews_star) 
        VALUES ('$parentsId', '$ordersId', '$nanniesId', '$reviewsContent', '$reviewsStar')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
