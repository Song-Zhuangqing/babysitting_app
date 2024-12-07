<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$name = $_POST['name'];
$phone = $_POST['phone'];
$gender = $_POST['gender'];
$email = $_POST['email'];
$address = $_POST['address'];
$password = password_hash($_POST['password'], PASSWORD_BCRYPT);

$sql = "INSERT INTO nannies (nannies_name, nannies_phone, nannies_sex, nannies_email, nannies_address, nannies_password) 
        VALUES ('$name', '$phone', '$gender', '$email', '$address', '$password')";

if ($conn->query($sql) === TRUE) {
    $nanny_id = $conn->insert_id; // 获取新增保姆ID
    echo json_encode(['status' => 'success', 'nanny_id' => $nanny_id]);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
