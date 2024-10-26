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
$childName = $_POST['parents_child_name'];
$childSex = $_POST['parents_child_sex'];
$childDetails = $_POST['parents_child_details'];
$addressLine1 = $_POST['parents_child_address_line1'];
$addressLine2 = $_POST['parents_child_address_line2'];
$city = $_POST['parents_child_city'];
$state = $_POST['parents_child_state'];
$postalCode = $_POST['parents_child_postal_code'];
$country = $_POST['parents_child_country'];

// 插入新的孩子信息，包括地址字段
$sql = "INSERT INTO parents_child (
            parents_id, 
            parents_child_name, 
            parents_child_sex, 
            parents_child_details, 
            parents_child_address_line1, 
            parents_child_address_line2, 
            parents_child_city, 
            parents_child_state, 
            parents_child_postal_code, 
            parents_child_country
        ) VALUES (
            '$parentsId', 
            '$childName', 
            '$childSex', 
            '$childDetails', 
            '$addressLine1', 
            '$addressLine2', 
            '$city', 
            '$state', 
            '$postalCode', 
            '$country'
        )";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
