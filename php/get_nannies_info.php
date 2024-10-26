<?php
// 数据库连接信息
$servername = "localhost";
$username = "root"; // 数据库用户名
$password = ""; // 数据库密码
$dbname = "cbcp"; // 数据库名称

// 创建连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

// 获取POST请求中的user_id
$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'User ID is required']);
    exit();
}

// 查询保姆信息
$sql = "SELECT nannies_name, nannies_phone, nannies_sex, nannies_email, nannies_address, nannies_certificate, certificate_image_url 
        FROM nannies 
        WHERE nannies_id = ?";

// 预处理查询
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id); // 将user_id绑定到SQL查询中
$stmt->execute();
$result = $stmt->get_result();

// 检查是否找到保姆用户信息
if ($result->num_rows > 0) {
    $user_info = $result->fetch_assoc();
    echo json_encode(['status' => 'success', 'data' => $user_info]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'User not found']);
}

// 关闭连接
$stmt->close();
$conn->close();
?>
