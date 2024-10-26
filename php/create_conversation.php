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
$nanniesId = $_POST['nannies_id'];

// 防止SQL注入
$parentsId = $conn->real_escape_string($parentsId);
$nanniesId = $conn->real_escape_string($nanniesId);

// 插入新的会话记录
$sql = "INSERT INTO conversations (parents_id, nannies_id) VALUES ('$parentsId', '$nanniesId')";

if ($conn->query($sql) === TRUE) {
    $conversationId = $conn->insert_id;
    echo json_encode(['status' => 'success', 'conversation_id' => $conversationId]);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
