<?php
// 数据库配置
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp"; // 数据库名称

// 创建数据库连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed: ' . $conn->connect_error]));
}

// 获取 POST 请求中的数据
$userId = $_POST['user_id'];
$name = $_POST['nannies_name'];
$phone = $_POST['nannies_phone'];
$sex = $_POST['nannies_sex'];
$email = $_POST['nannies_email'];
$address = $_POST['nannies_address'];

// 更新保姆信息
$sql = "UPDATE nannies SET nannies_name = ?, nannies_phone = ?, nannies_sex = ?, nannies_email = ?, nannies_address = ? WHERE nannies_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssssss", $name, $phone, $sex, $email, $address, $userId);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update information']);
}

// 关闭连接
$stmt->close();
$conn->close();
?>
