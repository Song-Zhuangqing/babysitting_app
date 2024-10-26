<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp"; // 数据库名称

// 创建连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$userId = $_POST['user_id'];

// 查询父母信息
$sql = "SELECT parents_name, parents_phone, parents_sex, parents_email, parents_address FROM parents WHERE parents_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param('i', $userId); // 将用户ID绑定为int类型
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        'status' => 'success',
        'data' => [
            'parents_name' => $row['parents_name'],
            'parents_phone' => (int)$row['parents_phone'], // 返回int类型的手机号
            'parents_sex' => $row['parents_sex'],
            'parents_email' => $row['parents_email'],
            'parents_address' => $row['parents_address'],
        ]
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No parent found']);
}

$conn->close();
?>
