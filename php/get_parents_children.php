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

$parentsId = $_POST['parents_id'];

// 获取父母发布的所有孩子信息
$sql = "SELECT * FROM parents_child WHERE parents_id = '$parentsId'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $children = [];
    while ($row = $result->fetch_assoc()) {
        $children[] = $row;
    }
    echo json_encode(['status' => 'success', 'details' => $children]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No children found']);
}

$conn->close();
?>
