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
$senderId = $_POST['sender_id'];
$senderType = $_POST['sender_type'];
$messageContent = $_POST['message_content'];

// 插入新的消息记录
$sql = "INSERT INTO messages (conversation_id, sender_id, sender_type, message_content) VALUES ('$conversationId', '$senderId', '$senderType', '$messageContent')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
