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

// 从POST请求中获取数据
$email = $_POST['email'];
$password = $_POST['password'];

// 验证父母用户
$sql_parents = "SELECT parents_id AS user_id, parents_password AS password FROM parents WHERE parents_email='$email'";
$result_parents = $conn->query($sql_parents);

if ($result_parents->num_rows > 0) {
    $row = $result_parents->fetch_assoc();
    if (password_verify($password, $row['password'])) {
        echo json_encode(['status' => 'success', 'user_id' => $row['user_id'], 'user_type' => 'parent']);
        $conn->close();
        exit();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid password']);
        $conn->close();
        exit();
    }
}

// 验证保姆用户
$sql_nannies = "SELECT nannies_id AS user_id, nannies_password AS password FROM nannies WHERE nannies_email='$email'";
$result_nannies = $conn->query($sql_nannies);

if ($result_nannies->num_rows > 0) {
    $row = $result_nannies->fetch_assoc();
    if (password_verify($password, $row['password'])) {
        echo json_encode(['status' => 'success', 'user_id' => $row['user_id'], 'user_type' => 'nanny']);
        $conn->close();
        exit();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid password']);
        $conn->close();
        exit();
    }
}

// 如果用户未找到
echo json_encode(['status' => 'error', 'message' => 'User not found']);
$conn->close();
?>
