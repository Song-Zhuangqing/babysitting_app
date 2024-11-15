<?php
// 设置响应头
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=UTF-8");

// 包含数据库配置
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp"; // 使用您提供的数据库名称

// 创建数据库连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    error_log("Database connection failed: " . $conn->connect_error);
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}

// 响应数组
$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 获取 user_id
    $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : null;

    if (is_null($user_id)) {
        $response['status'] = 'error';
        $response['message'] = 'Missing user ID.';
        echo json_encode($response);
        exit();
    }

    // 获取证书状态
    $has_certificate = isset($_POST['has_certificate']) ? intval($_POST['has_certificate']) : 0;

    // 检查是否上传了图片
    if (isset($_FILES['certificate_image_url']['name'])) {
        $target_dir = "uploads/certificates/";
        $file_name = basename($_FILES["certificate_image_url"]["name"]);
        $target_file = $target_dir . time() . "_" . $file_name; // 生成唯一文件名

        // 检查目录权限
        if (!is_dir($target_dir) && !mkdir($target_dir, 0777, true)) {
            $response['status'] = 'error';
            $response['message'] = 'Failed to create directory.';
            echo json_encode($response);
            exit();
        }

        // 上传文件
        if (move_uploaded_file($_FILES["certificate_image_url"]["tmp_name"], $target_file)) {
            // 成功上传图片后，设置图片路径
            $certificate_image_url = $target_file;

            // 打印调试信息
            error_log("File uploaded successfully: " . $certificate_image_url);

            // 更新带图片的SQL语句
            $sql = "UPDATE nannies SET nannies_certificate = ?, certificate_image_url = ? WHERE nannies_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('isi', $has_certificate, $certificate_image_url, $user_id);
        } else {
            $error = error_get_last();
            error_log("File upload error: " . $error['message']);
            $response['status'] = 'error';
            $response['message'] = 'File upload failed. Please check permissions and path. Reason: ' . $error['message'];
            echo json_encode($response);
            exit();
        }
    } else {
        // 没有上传图片时的SQL语句
        $sql = "UPDATE nannies SET nannies_certificate = ? WHERE nannies_id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('ii', $has_certificate, $user_id);
    }

    // 执行更新操作
    if ($stmt->execute()) {
        $response['status'] = 'success';
        $response['message'] = 'Certificate information updated successfully.';
    } else {
        error_log("Failed to execute statement: " . $stmt->error);
        $response['status'] = 'error';
        $response['message'] = 'Failed to update certificate information.';
    }

    echo json_encode($response);
    $stmt->close();
    $conn->close();
} else {
    // 处理无效的请求方法
    $response['status'] = 'error';
    $response['message'] = 'Invalid request method.';
    echo json_encode($response);
}
?>
