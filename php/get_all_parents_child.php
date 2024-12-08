<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp";

// 创建连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// 获取所有孩子的信息，包括父母的 ID
$sql = "SELECT 
            parents_child.parents_id, 
            parents_child.parents_child_details, 
            parents_child.parents_child_address, 
            parents_child.parents_child_age, 
            parents_child.parents_child_language, 
            parents_child.parents_child_require, 
            parents_child.parents_child_time, 
            parents_child.parents_child_money 
        FROM parents_child";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $details = [];
    while ($row = $result->fetch_assoc()) {
        // 添加调试日志
        error_log("Fetched child details: " . json_encode($row));
        $details[] = $row;
    }
    echo json_encode(['status' => 'success', 'details' => $details]);
} else {
    error_log("No child details found");
    echo json_encode(['status' => 'error', 'message' => 'No details found']);
}

$conn->close();
?>
