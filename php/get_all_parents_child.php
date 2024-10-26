<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp"; // 数据库名称

// 创建连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// 获取所有 parents 发布的孩子信息
$sql = "SELECT parents_child_name, parents_child_sex, parents_child_details, parents_id FROM parents_child";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $details = [];
    while($row = $result->fetch_assoc()) {
        $details[] = $row;
    }
    echo json_encode(['status' => 'success', 'details' => $details]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No details found']);
}

$conn->close();
?>
