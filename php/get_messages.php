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

$conversationId = $_POST['conversation_id'];

// 获取会话消息
$sql = "SELECT * FROM messages WHERE conversation_id = '$conversationId' ORDER BY create_time ASC";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $messages = [];
    while ($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }
    echo json_encode(['status' => 'success', 'messages' => $messages]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No messages found']);
}

$conn->close();
?>
