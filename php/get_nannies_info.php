<?php
// 设置响应头
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// 数据库连接信息
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp";

// 创建数据库连接
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
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

// 检查是否找到保姆用户信息
if ($result->num_rows > 0) {
    $user_info = $result->fetch_assoc();
    $user_info['nannies_certificate'] = (int)$user_info['nannies_certificate'];
    if ($user_info['certificate_image_url']) {
        $user_info['certificate_image_url'] = "http://192.168.43.250/babysitting_app/php/" . $user_info['certificate_image_url'];
    }

    echo json_encode(['status' => 'success', 'data' => $user_info]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'User not found']);
}

// 关闭连接
$stmt->close();
$conn->close();
?>
