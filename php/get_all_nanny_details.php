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

// 获取所有保姆发布的信息并联接 nannies 表
$sql = "SELECT n.nannies_name, n.nannies_email, d.nannies_details_date, d.nannies_details_price, d.nannies_details_content, d.nannies_details_location, d.nannies_id AS user_id
        FROM nannies_details d
        JOIN nannies n ON d.nannies_id = n.nannies_id";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $details = [];
    while ($row = $result->fetch_assoc()) {
        $details[] = $row;
    }
    echo json_encode(['status' => 'success', 'details' => $details]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No details found']);
}

$conn->close();
?>
