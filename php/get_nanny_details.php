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

$nanniesId = $_POST['nannies_id'];

// 防止SQL注入
$nanniesId = $conn->real_escape_string($nanniesId);

// 获取保姆的发布信息，使用 `nannies_details_date` 进行排序
$sql = "SELECT * FROM nannies_details WHERE nannies_id = '$nanniesId' ORDER BY nannies_details_date DESC";
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
