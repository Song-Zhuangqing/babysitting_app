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

// 从POST请求中获取数据
$nanniesId = $_POST['user_id'];
$price = $_POST['nannies_details_price'];
$content = $_POST['nannies_details_content'];
$location = $_POST['nannies_details_location'];

// 插入新的发布内容
$sql = "INSERT INTO nannies_details (nannies_id, nannies_details_price, nannies_details_content, nannies_details_location) VALUES ('$nanniesId', '$price', '$content', '$location')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
