<?php
// 数据库连接信息
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp";

// 创建连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$nanniesId = $_POST['nannies_id'] ?? null; // 接收POST参数

if (!$nanniesId) {
    echo json_encode(['status' => 'error', 'message' => 'Nanny ID is required']);
    exit();
}

// 查询保姆信息
$sql = "SELECT * FROM nannies WHERE nannies_id = '$nanniesId'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $nannyInfo = $result->fetch_assoc();
    echo json_encode(['status' => 'success', 'data' => $nannyInfo]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Nanny not found']);
}

$conn->close();
?>
