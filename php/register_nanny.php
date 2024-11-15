<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cbcp";

// Create database connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get POST request fields
$name = $_POST['name'];
$phone = $_POST['phone'];
$gender = $_POST['gender'];
$email = $_POST['email'];
$address = $_POST['address'];
$password = $_POST['password'];
$nannies_certificate = $_POST['nannies_certificate'];

// Encrypt the password
$hashed_password = password_hash($password, PASSWORD_BCRYPT); // 使用 BCRYPT 加密算法

// Check for certificate image upload
$certificate_image_url = '';
if (isset($_FILES['certificate_image_url'])) {
    $file_tmp = $_FILES['certificate_image_url']['tmp_name'];
    $file_name = basename($_FILES['certificate_image_url']['name']);
    $upload_dir = 'uploads/';
    $file_path = $upload_dir . $file_name;

    if (move_uploaded_file($file_tmp, $file_path)) {
        $certificate_image_url = $file_path;
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to upload certificate']);
        exit();
    }
}

// Insert data into the database with the hashed password
$sql = "INSERT INTO nannies (nannies_name, nannies_phone, nannies_sex, nannies_email, nannies_address, nannies_password, nannies_certificate, certificate_image_url) 
        VALUES ('$name', '$phone', '$gender', '$email', '$address', '$hashed_password', '$nannies_certificate', '$certificate_image_url')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

// Close connection
$conn->close();
?>
    