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

// 获取表单数据
$parentsId = $_POST['parents_id'];
$childDetails = $_POST['parents_child_details'];
$childAddress = $_POST['parents_child_address'];
$childAge = $_POST['parents_child_age'];
$childLanguage = $_POST['parents_child_language'];
$childRequire = $_POST['parents_child_require'];
$childTime = $_POST['parents_child_time'];
$childMoney = $_POST['parents_child_money'];

// 插入数据
$sql = "INSERT INTO parents_child (
            parents_id, 
            parents_child_details, 
            parents_child_address, 
            parents_child_age, 
            parents_child_language, 
            parents_child_require, 
            parents_child_time, 
            parents_child_money
        ) VALUES (
            '$parentsId', 
            '$childDetails', 
            '$childAddress', 
            '$childAge', 
            '$childLanguage', 
            '$childRequire', 
            '$childTime', 
            '$childMoney'
        )";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
