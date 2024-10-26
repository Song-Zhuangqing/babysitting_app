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

// 防止SQL注入
$parentsId = $conn->real_escape_string($parentsId);

// 获取父母的所有会话
$sql = "SELECT c.conversation_id, n.nannies_name as nanny_name, m.message_content as last_message
        FROM conversations c
        JOIN nannies n ON c.nannies_id = n.nannies_id
        LEFT JOIN messages m ON c.conversation_id = m.conversation_id
        WHERE c.parents_id = '$parentsId'
        GROUP BY c.conversation_id
        ORDER BY m.create_time DESC";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $conversations = [];
    while($row = $result->fetch_assoc()) {
        $conversations[] = $row;
    }
    echo json_encode(['status' => 'success', 'conversations' => $conversations]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No conversations found']);
}

$conn->close();
?>
