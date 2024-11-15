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

$nanniesId = $_POST['nannies_id'] ?? null; // 接收传递的 nannies_id

if (!$nanniesId) {
    echo json_encode(['status' => 'error', 'message' => 'Nanny ID is required']);
    exit();
}

// 查询保姆的评价信息，包括星级
$sql = "SELECT reviews_content, reviews_star FROM reviews WHERE nannies_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $nanniesId);
$stmt->execute();
$result = $stmt->get_result();

// 检查是否有评价
if ($result->num_rows > 0) {
    $reviews = [];
    while ($row = $result->fetch_assoc()) {
        $reviews[] = $row;
    }
    echo json_encode(['status' => 'success', 'data' => $reviews]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No reviews found']);
}

// 关闭连接
$stmt->close();
$conn->close();
?>
