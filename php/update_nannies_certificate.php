<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=UTF-8");

// 数据库配置信息
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp";

// 创建数据库连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    error_log("数据库连接失败: " . $conn->connect_error);
    die(json_encode(['status' => 'error', 'message' => '数据库连接失败']));
}

$response = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 获取必要字段
    $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : null;
    $certificate_info = isset($_POST['certificate_info']) ? $_POST['certificate_info'] : '';

    if (is_null($user_id)) {
        $response['status'] = 'error';
        $response['message'] = '缺少用户 ID';
        echo json_encode($response);
        exit();
    }

    if (empty($certificate_info)) {
        $response['status'] = 'error';
        $response['message'] = '证书信息不能为空';
        echo json_encode($response);
        exit();
    }

    // 上传文件
    if (isset($_FILES['certificate_image']['name'])) {
        $target_dir = "uploads/certificates/";
        $file_name = basename($_FILES["certificate_image"]["name"]);
        $target_file = $target_dir . time() . "_" . $file_name;

        // 检查目录是否存在
        if (!is_dir($target_dir) && !mkdir($target_dir, 0777, true)) {
            error_log("目录创建失败: $target_dir");
            die(json_encode(['status' => 'error', 'message' => '目录创建失败']));
        }

        // 上传文件
        if (move_uploaded_file($_FILES["certificate_image"]["tmp_name"], $target_file)) {
            $certificate_image_url = $target_file;

            // 插入数据到 certificate 表
            $sql = "INSERT INTO certificate (nannies_id, certificate_info, certificate_image_url) 
                    VALUES (?, ?, ?)";
            $stmt = $conn->prepare($sql);

            if (!$stmt) {
                error_log("SQL 预处理失败: " . $conn->error);
                die(json_encode(['status' => 'error', 'message' => 'SQL 预处理失败: ' . $conn->error]));
            }

            $stmt->bind_param('iss', $user_id, $certificate_info, $certificate_image_url);

            if ($stmt->execute()) {
                $response['status'] = 'success';
                $response['message'] = '证书上传成功';
            } else {
                error_log("SQL 执行失败: " . $stmt->error);
                $response['status'] = 'error';
                $response['message'] = '证书上传失败';
            }

            $stmt->close();
        } else {
            $response['status'] = 'error';
            $response['message'] = '证书图片上传失败';
        }
    } else {
        $response['status'] = 'error';
        $response['message'] = '缺少证书图片';
    }

    echo json_encode($response);
    $conn->close();
} else {
    echo json_encode(['status' => 'error', 'message' => '无效的请求方法']);
}
?>
