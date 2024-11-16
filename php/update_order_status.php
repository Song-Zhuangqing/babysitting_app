<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$orders_id = $_POST['orders_id'];
$orders_status = $_POST['orders_status'];

$sql = "UPDATE orders SET orders_status = ? WHERE orders_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $orders_status, $orders_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$stmt->close();
$conn->close();
?>
