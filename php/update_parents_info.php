<?php
// 数据库配置
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "babysitting_db"; // 数据库名称

// 创建数据库连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed: ' . $conn->connect_error]));
}

// 获取 POST 请求中的数据
$userId = $_POST['user_id'];
$name = $_POST['parents_name'];
$phone = $_POST['parents_phone'];
$sex = $_POST['parents_sex'];
$address = $_POST['parents_address'];

// 更新父母信息
$sql = "UPDATE parents SET parents_name = ?, parents_phone = ?, parents_sex = ?, parents_address = ? WHERE parents_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $name, $phone, $sex, $address, $userId);
if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update information']);
}

// 关闭连接
$stmt->close();
$conn->close();
?>
