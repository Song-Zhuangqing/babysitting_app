<?php
// 连接到数据库
include_once 'db_config.php'; // 包含数据库配置文件

// 获取传递的POST参数
$user_id = isset($_POST['user_id']) ? $_POST['user_id'] : '';
$nannies_name = isset($_POST['nannies_name']) ? $_POST['nannies_name'] : '';
$nannies_phone = isset($_POST['nannies_phone']) ? $_POST['nannies_phone'] : '';
$nannies_sex = isset($_POST['nannies_sex']) ? $_POST['nannies_sex'] : '';
$nannies_email = isset($_POST['nannies_email']) ? $_POST['nannies_email'] : '';
$nannies_address = isset($_POST['nannies_address']) ? $_POST['nannies_address'] : '';

// 检查必要参数是否完整
if (empty($user_id) || empty($nannies_name) || empty($nannies_phone) || empty($nannies_sex) || empty($nannies_email) || empty($nannies_address)) {
    $response = [
        'status' => 'error',
        'message' => 'Required fields are missing'
    ];
    echo json_encode($response);
    exit();
}

// 创建SQL语句更新保姆信息
$sql = "UPDATE nannies SET 
            nannies_name = ?, 
            nannies_phone = ?, 
            nannies_sex = ?, 
            nannies_email = ?, 
            nannies_address = ? 
        WHERE nannies_id = ?";

// 准备SQL语句
$stmt = $conn->prepare($sql);

// 绑定参数
$stmt->bind_param('sisssi', $nannies_name, $nannies_phone, $nannies_sex, $nannies_email, $nannies_address, $user_id);

// 执行查询
if ($stmt->execute()) {
    $response = [
        'status' => 'success',
        'message' => 'Nannies information updated successfully'
    ];
} else {
    $response = [
        'status' => 'error',
        'message' => 'Failed to update nannies information'
    ];
}

// 返回JSON格式的响应
echo json_encode($response);

// 关闭连接
$stmt->close();
$conn->close();
?>
