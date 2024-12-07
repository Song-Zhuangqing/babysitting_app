<?php
// 设置响应头
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=UTF-8");

// 引入 config.php
require_once 'config.php';

// 创建数据库连接
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

// 检查连接
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}

// 检查是否为 POST 请求
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 获取 user_id
    $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : null;

    if (is_null($user_id)) {
        echo json_encode(['status' => 'error', 'message' => 'Missing user ID.']);
        exit();
    }

    // 查询证书信息
    $sql = "SELECT certificate_id, certificate_info, certificate_image_url 
            FROM certificate 
            WHERE nannies_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    // 使用 `BASE_URL` 拼接完整的图片路径
    if ($result->num_rows > 0) {
        $certificates = [];
        while ($row = $result->fetch_assoc()) {
            $row['certificate_image_url'] = BASE_URL . '/' . $row['certificate_image_url'];
            $certificates[] = $row;
        }
        echo json_encode(['status' => 'success', 'certificates' => $certificates]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'No certificates found']);
    }

    $stmt->close();
} else {
    // 非 POST 请求处理
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}

// 关闭数据库连接
$conn->close();
?>
