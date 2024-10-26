<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=UTF-8");

include_once 'config.php'; // 包含数据库配置

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 获取user_id
    if (isset($_POST['user_id'])) {
        $user_id = intval($_POST['user_id']);
    } else {
        $response['status'] = 'error';
        $response['message'] = 'Missing user ID.';
        echo json_encode($response);
        exit();
    }

    // 处理证书状态（是否有证书）
    $has_certificate = isset($_POST['has_certificate']) ? intval($_POST['has_certificate']) : 0;

    // 检查是否上传了图片
    if (isset($_FILES['certificate_image_url']['name'])) {
        $target_dir = "uploads/certificates/";
        $file_name = basename($_FILES["certificate_image_url"]["name"]);
        $target_file = $target_dir . time() . "_" . $file_name; // 生成唯一文件名

        // 上传文件
        if (move_uploaded_file($_FILES["certificate_image_url"]["tmp_name"], $target_file)) {
            // 成功上传图片后，将路径保存到数据库
            $certificate_image_url = $target_file;

            // 更新数据库中的证书信息
            $sql = "UPDATE nannies SET nannies_certificate = ?, certificate_image_url = ? WHERE nannies_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('isi', $has_certificate, $certificate_image_url, $user_id);
        } else {
            $response['status'] = 'error';
            $response['message'] = 'File upload failed.';
            echo json_encode($response);
            exit();
        }
    } else {
        // 没有上传图片，仅更新证书状态
        $sql = "UPDATE nannies SET nannies_certificate = ? WHERE nannies_id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('ii', $has_certificate, $user_id);
    }

    if ($stmt->execute()) {
        $response['status'] = 'success';
        $response['message'] = 'Certificate information updated successfully.';
    } else {
        $response['status'] = 'error';
        $response['message'] = 'Failed to update certificate information.';
    }

    echo json_encode($response);
    $stmt->close();
    $conn->close();
} else {
    // 错误的请求方法
    $response['status'] = 'error';
    $response['message'] = 'Invalid request method.';
    echo json_encode($response);
}
?>
